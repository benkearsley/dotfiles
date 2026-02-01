use std::{
    collections::{HashMap, HashSet}, env, error, process::Command, str::from_utf8
};
use tui_textarea::TextArea;
use ratatui::style::{Color, Style};
use indexmap::IndexMap;

/// Application result type.
pub type AppResult<T> = std::result::Result<T, Box<dyn error::Error>>;

#[derive(Debug, PartialEq, Eq, Hash, Clone)]
pub enum AppState {
    Sessions,
    SessionsSearch,
    Deleting,
    Renaming,
    WarnNested,
    NewSession,
}

#[derive(Debug)]
pub enum ExitAction {
    AttachSession(String, bool),
    NewSession,
    None
}


/// Application.
#[derive(Debug)]
pub struct App<'a> {
    /// Is the application running?
    pub running: bool,
    /// counter
    pub counter: u8,
    /// session name to attach
    pub on_exit: ExitAction,
    /// Current (attached) session - shown separately at top
    pub current_session: Option<(String, String)>,
    /// Other Tmux sessions (name, desc) - excludes current session
    pub sessions: Vec<(String, String)>,
    /// Selected session index (in the sessions list, not including current)
    pub selected_session: usize,
    /// Whether we're renaming the current session (true) or a selected session (false)
    pub renaming_current: bool,
    /// The application state
    pub state: AppState,
    /// Rename prompt
    pub rename_session_ta: Option<TextArea<'a>>,
    /// New session name prompt
    pub new_session_ta: Option<TextArea<'a>>,
    /// Search prompt
    pub search_session_ta: Option<TextArea<'a>>,
    /// The row selected by a search operation
    pub search_session_selected: Option<usize>,
    /// All row indexes that match current search terms
    pub matching_rows: Vec<usize>,
    /// hotkey bar
    pub hotkeys: HashMap<AppState, IndexMap<&'a str, &'a str>>,
}

impl<'a> Default for App<'a> {
    fn default() -> Self {
        let mut def = Self {
            running: true,
            counter: 0,
            current_session: None,
            sessions: vec![],
            selected_session: 0,
            renaming_current: false,
            on_exit: ExitAction::None,
            state: AppState::Sessions,
            new_session_ta: None,
            rename_session_ta: None,
            search_session_ta: None,
            search_session_selected: None,
            matching_rows: vec![],
            hotkeys: [
                (AppState::Sessions, [
                    ("q", "Quit"),
                    ("a", "Attach"),
                    ("r", "Rename"),
                    ("R", "Rename Current"),
                    ("n", "New"),
                    ("x", "Delete"),
                    ("/", "Search"),
                ].iter().cloned().collect()),
                (AppState::Deleting, [
                    ("q", "Quit"),
                    ("Esc", "Back"),
                    ("y", "Delete"),
                    ("n", "Cancel"),
                ].iter().cloned().collect()),
                (AppState::Renaming, [
                    ("Esc", "Back"),
                    ("Enter", "Rename"),
                ].iter().cloned().collect()),
                (AppState::WarnNested, [
                    ("q", "Quit"),
                    ("Any", "Dismiss"),
                ].iter().cloned().collect()),
                (AppState::SessionsSearch, [
                    ("Esc", "Cancel"),
                    ("Enter", "Confirm"),
                    ("C-n", "Select next match"),
                    ("C-p", "Select previous match"),
                ].iter().cloned().collect()),
            ].iter().cloned().collect(),
        };
        def.refresh();
        // Cursor starts at 0, which is now the previous session
        // (since current session is stored separately)
        def
    }
}

impl<'a> App<'a> {
    /// Constructs a new instance of [`App`].
    pub fn new() -> Self {
        Self::default()
    }

    /// Set running to false to quit the application.
    pub fn quit(&mut self) {
        self.running = false;
    }

    pub fn attach(&mut self, name: String, detach_others: bool) {
        self.running = false;
        self.on_exit = ExitAction::AttachSession(name.clone(), detach_others);
    }

    pub fn increment_counter(&mut self) {
        if let Some(res) = self.counter.checked_add(1) {
            self.counter = res;
        }
    }

    pub fn decrement_counter(&mut self) {
        if let Some(res) = self.counter.checked_sub(1) {
            self.counter = res;
        }
    }

    /// Refresh list of tmux sessions, sorted by most recently accessed
    pub fn refresh(&mut self) {
        // Use custom format to get all session info in a single call:
        // activity_timestamp, name, attached status, and description
        let output = Command::new("tmux")
            .args([
                "list-sessions",
                "-F",
                "#{session_activity}\t#{session_name}\t#{session_attached}\t#{session_windows} windows (created #{t:session_created})"
            ])
            .output()
            .expect("failed to refresh tmux");
        let Ok(stdout) = from_utf8(&output.stdout) else { return };

        // Since the list can change between refreshes, need to get the name of the currently
        // highlighted session and then re-select that row after the list is updated.
        let selected_name = self.sessions.get(self.selected_session).map_or(None, |x| Some(x.0.to_owned()));

        // Parse sessions with activity timestamps for sorting
        // Format: (activity, name, is_attached, description)
        let mut sessions_with_activity: Vec<(u64, String, bool, String)> = stdout.lines().filter_map(|line| {
            let parts: Vec<&str> = line.splitn(4, '\t').collect();
            if parts.len() >= 4 {
                let activity: u64 = parts[0].parse().unwrap_or(0);
                let name = parts[1].to_owned();
                let is_attached = parts[2] == "1";
                let desc = format!(":{}", parts[3]);
                Some((activity, name, is_attached, desc))
            } else {
                None
            }
        }).collect();

        // Sort by activity timestamp descending (most recent first)
        sessions_with_activity.sort_by(|a, b| b.0.cmp(&a.0));

        // Separate the current (attached) session from the rest
        self.current_session = None;
        self.sessions = Vec::new();

        for (_, name, is_attached, desc) in sessions_with_activity {
            if is_attached && self.current_session.is_none() {
                self.current_session = Some((name, desc));
            } else {
                self.sessions.push((name, desc));
            }
        }

        // Find the selected_name in the new session list and select it. If it's not there, do not
        // change the selected row (e.g., on a rename, the new session will not be present, but
        // want to maintain the selection)
        if let Some(selected_name) = selected_name {
            if let Some(idx) = self.sessions.iter().position(|(name, _)| name == &selected_name) {
                self.selected_session = idx
            }
        }
        // Ensure the selected session is legal
        if !self.sessions.is_empty() {
            self.selected_session = self.selected_session.min(self.sessions.len() - 1);
        } else {
            self.selected_session = 0;
        }
    }

    /// Get the maximum width of all session names (including current session)
    pub fn max_session_name_width(&self) -> usize {
        let current_width = self.current_session.as_ref().map_or(0, |(name, _)| name.len());
        self.sessions.iter().map(|(name, _)| {
            name.len()
        }).fold(current_width, |acc, x| acc.max(x))
    }

    /// Start a confirmed delete
    pub fn confirm_delete(&mut self) {
        self.state = AppState::Deleting;
    }

    /// Start a confirmed rename for the selected session
    pub fn confirm_rename(&mut self) {
        self.renaming_current = false;
        let mut textarea = TextArea::default();
        textarea.set_cursor_line_style(Style::default());
        self.rename_session_ta = Some(textarea);
        self.state = AppState::Renaming;
    }

    /// Start a confirmed rename for the current (attached) session
    pub fn confirm_rename_current(&mut self) {
        if self.current_session.is_some() {
            self.renaming_current = true;
            let mut textarea = TextArea::default();
            textarea.set_cursor_line_style(Style::default());
            self.rename_session_ta = Some(textarea);
            self.state = AppState::Renaming;
        }
    }

    /// Start searching
    pub fn search(&mut self) {
        // Create the textarea and switch to renaming state
        let mut textarea = TextArea::default();
        textarea.set_cursor_line_style(Style::default());
        textarea.set_style(Style::default().fg(Color::DarkGray));
        self.search_session_ta = Some(textarea);
        self.state = AppState::SessionsSearch;
    }

    /// Return to the sessions view
    pub fn dismiss_all(&mut self) {
        self.rename_session_ta = None;
        self.search_session_ta = None;
        self.state = AppState::Sessions;
    }

    pub fn is_nested() -> bool {
        let envs: HashMap<String, String> = env::vars().collect();
        envs.get("TMUX").is_some()
    }

    /// Rename a session (current or selected based on renaming_current flag)
    pub fn rename(&mut self, new_name: &str) {
        let name = if self.renaming_current {
            // Renaming the current session
            match &self.current_session {
                Some((n, _)) => n.clone(),
                None => return,
            }
        } else {
            // Renaming a selected session
            match self.sessions.get(self.selected_session) {
                Some((n, _)) => n.clone(),
                None => return,
            }
        };

        let proc = Command::new("tmux")
            .args(["rename-session", "-t", &name, new_name])
            .output()
            .expect(format!("failed to rename tmux session: {}", name).as_str());
        if !proc.status.success() {
            panic!("This is the failure message: {}", std::str::from_utf8(&proc.stderr).unwrap());
            // TODO: display popup with error
        }
        self.refresh();
        self.dismiss_all();
    }

    /// Delete a session
    pub fn delete(&mut self) {
        let Some((name, _)) = self.sessions.get(self.selected_session) else {
            panic!("Could not identify session to delete");
        };
        // Kill the session
        Command::new("tmux")
            .args(["kill-session", "-t", name])
            .output()
            .expect(format!("failed to kill tmux session {}", name).as_str());
        // TODO: check output.status and present dialog or message to user
        // instead of just expect panic?
        // Restore state with a refresh
        self.refresh();
        self.dismiss_all();
    }

    pub fn confirm_new_session(&mut self) {
        // Create the textarea and switch to renaming state
        let mut textarea = TextArea::default();
        textarea.set_cursor_line_style(Style::default());
        self.new_session_ta = Some(textarea);
        self.state = AppState::NewSession;
    }

    /// Create a new session
    pub fn new_session(&mut self, name: Option<&str>) {
        if let Some(name) = name {
            // Create the named session, and highlight it in the list
            let proc = Command::new("tmux")
                .args(["new-session", "-d", "-s", name])
                .output()
                .expect(format!("failed to create new tmux session: {}", name).as_str());
            if !proc.status.success() {
                panic!("This is the failure message: {}", std::str::from_utf8(&proc.stderr).unwrap());
                // TODO: display popup with error
            }
            // TODO: one common failure mode might be that the name already exists, e.g,
            // "duplicate session: <name>"

            // Highlight the newly created session. Tmux may modify characters that are provided
            // based on illegal tmux session names (e.g., 8.1 -> 8_1). It does not report this
            // modification, so we should discover the new session name using the set difference of
            // the new list of sessions and the old list of sessions.
            //
            // TODO: if the user creates new sessions once the new-session procedure has started in
            // tmm, multiple new sessions will appear in this set difference. Use fuzzy-matching to
            // find the best match for the session name among the new sessions to give the best
            // changes of highlighting the correct new session.
            //
            // Before refreshing, build a set of the current names
            let old_session_names: HashSet<String> = self.sessions.iter().map(|(name, _)| name.to_owned()).collect();
            self.refresh();
            let new_session_names: HashSet<String> = self.sessions.iter().map(|(name, _)| name.to_owned()).collect();
            if let Some(new_session_name) = new_session_names.difference(&old_session_names).next() {
                // We were able to find the new session name
                if let Some(idx) = self.sessions.iter().position(|(name, _)| name == new_session_name) {
                    self.selected_session = idx;
                }
            } else {
                // New session name not found for some reason. Do not change the selection.
            }
            self.dismiss_all();
        } else {
            // Exit and attach new session
            self.running = false;
            self.on_exit = ExitAction::NewSession;
        }
    }
}

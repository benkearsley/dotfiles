return {
    {
        "nvimtools/none-ls.nvim",
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    -- ✅ FORMATTERS
                    null_ls.builtins.formatting.stylua,         -- Lua formatter
                    null_ls.builtins.formatting.prettierd,       -- JS/TS/JSON/YAML formatter
                    null_ls.builtins.formatting.blackd,          -- Python formatter (or use ruff_format)

                    -- ✅ DIAGNOSTICS
                    require("none-ls.diagnostics.eslint"),      -- ESLint diagnostics (from none-ls-extras.nvim)

                    -- ✅ OPTIONAL COMPLETION/LINTER
                    null_ls.builtins.completion.spell,          -- Optional: spell checking completions
                },
            })
            vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
        end,
    },
    {
        "nvimtools/none-ls-extras.nvim",
        dependencies = { "nvimtools/none-ls.nvim" },
    },
}

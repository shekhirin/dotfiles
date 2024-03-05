return {
  {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    ft = { "rust" },
    -- dependencies = {
    --   "nvim-lua/plenary.nvim",
    --   {
    --     "lvimuser/lsp-inlayhints.nvim",
    --     opts = {}
    --   },
    -- },
    config = function()
      vim.g.rustaceanvim = {
        -- inlay_hints = {
        --   highlight = "NonText",
        -- },
        -- tools = {
        --   hover_actions = {
        --     auto_focus = true,
        --   },
        -- },
        server = {
          --   cmd = function()
          --     return { "rustup", "run", "nightly", "rust-analyzer", "--log-file", "/tmp/rust-analyzer.log" }
          --   end,
          on_attach = require("config.lsp.on_attach").on_attach,
          -- standalone = false,
          settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
              },
              -- rustfmt = {
              --   extraArgs = { "+nightly " },
              -- },
            },
          },
        },
      }
    end,
  },
  -- crates
  {
    "saecki/crates.nvim",
    version = "v0.3.0",
    lazy = true,
    ft = { "rust", "toml" },
    event = { "BufRead", "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        -- null_ls = {
        --   enabled = true,
        --   name = "crates.nvim",
        -- },
        popup = {
          border = "rounded",
        },
      })
    end,
  },
}

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", version = "^1.0.0", config = true },
    { "williamboman/mason-lspconfig.nvim", version = "^1.0.0" },
    "folke/neodev.nvim",
    { "b0o/schemastore.nvim" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "nvim-lua/lsp-status.nvim" },
  },
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(require("config.lsp.servers")),
    })
    require("lspconfig.ui.windows").default_options.border = "single"

    require("neodev").setup()

    -- Initialize lsp-status
    local lsp_status = require("lsp-status")
    lsp_status.register_progress()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
    capabilities.workspace = { didChangeWatchedFiles = { dynamicRegistration = true } }

    -- Add lsp-status capabilities
    capabilities = vim.tbl_extend("keep", capabilities, lsp_status.capabilities)

    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup_handlers({
      function(server_name)
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            lsp_status.on_attach(client)
            require("config.lsp.on_attach")(client, bufnr)
          end,
          cmd = (require("config.lsp.servers")[server_name] or {}).cmd,
          filetypes = (require("config.lsp.servers")[server_name] or {}).filetypes,
          root_dir = (require("config.lsp.servers")[server_name] or {}).root_dir,
        })
      end,
    })

    vim.diagnostic.config({
      title = false,
      underline = true,
      virtual_text = true,
      signs = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        source = "always",
        style = "minimal",
        border = "rounded",
        header = "",
        prefix = "",
      },
    })

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
  end,
}

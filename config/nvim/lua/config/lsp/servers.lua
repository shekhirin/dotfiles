return {
  jsonls = {},
  terraformls = {
    cmd = { "terraform-ls", "server" },
    filetypes = { "terraform", "tf", "terraform-vars" },
  },
  lua_ls = {
    Lua = {
      telemetry = { enable = false },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- make language server aware of runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
  bashls = {
    filetypes = { "sh", "zsh" },
  },
  vimls = {
    filetypes = { "vim" },
  },
  -- tsserver = {},
  gopls = {},
  solidity_ls_nomicfoundation = {},
  yamlls = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
  },
  zls = {
    mason = false,
    cmd = { vim.fn.expand("$HOME/.zvm/bin/zls") },
    filetypes = { "zig" },
  },
  clangd = {
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  },
  verible = {
    root_dir = function()
      return vim.loop.cwd()
    end,
  },
}

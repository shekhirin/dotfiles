return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<C-\>]],
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      persist_size = false,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "#151819",
          background = "#151819",
        },
        zindex = 500,
      },
      highlights = {
        FloatBorder = {
          guifg = "#4B4F51",
        },
      },
      on_open = function(term)
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = term.bufnr })
      end,
    })
  end,
}

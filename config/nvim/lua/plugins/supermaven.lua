return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "¬",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      log_level = "off",
    })
  end,
}

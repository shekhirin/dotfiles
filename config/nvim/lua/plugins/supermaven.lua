return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<M-;>", -- Alt-;
      },
      log_level = "off",
    })
  end,
}

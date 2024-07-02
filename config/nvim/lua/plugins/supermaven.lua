return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "…", -- Alt-;
      },
      log_level = "off",
    })
  end,
}

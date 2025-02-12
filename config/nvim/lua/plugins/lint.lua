return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("RunLinter", { clear = true }),
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        -- Only run if file is in current working directory
        if bufname:find(vim.loop.cwd() or "", 1, true) == 1 then
          lint.try_lint("codespell")
        end
      end,
    })
  end,
}

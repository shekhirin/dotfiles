return {
  "LunarVim/bigfile.nvim",
  config = function()
    require("bigfile").setup({
      filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
      pattern = function(bufnr)
        -- you can't use `nvim_buf_line_count` because this runs on BufReadPre
        local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
        local file_length = #file_contents
        return file_length > 10000
      end,
      features = { -- features to disable
        -- "indent_blankline",
        -- "illuminate",
        -- "lsp",
        "treesitter",
        -- "syntax",
        -- "matchparen",
        -- "vimopts",
        -- "filetype",
      },
    })
  end,
}

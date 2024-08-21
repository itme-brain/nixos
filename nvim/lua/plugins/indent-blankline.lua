return {
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup({
        --indent = { char = "│" },
        --indent = { char = "⎸" },
        indent = { char = "┆" },
        scope = {
          show_start = false,
          show_end = false
        },
      })
    end,
  }
}

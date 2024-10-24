return {
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup({
        --indent = { char = "│" },
        --indent = { char = "⎸" },
        indent = { char = "┆" },
        scope = {
          enabled = false
        },
      })
    end,
  }
}

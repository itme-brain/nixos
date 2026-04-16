return {
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      local hooks = require("ibl.hooks")

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { link = "Comment" })
      end)

      require("ibl").setup({
        indent = {
          char = "|",
          highlight = "IblIndent",
        },
        scope = {
          enabled = false
        },
      })
    end,
  }
}

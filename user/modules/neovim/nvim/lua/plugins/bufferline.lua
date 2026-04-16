return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup{
        options = {
          separator_style = "thin",
          show_buffer_close_buttons = false,
          show_close_icon = false,
        },
        highlights = {
          -- Force all icon backgrounds to transparent
          buffer_selected = { bg = "NONE" },
          buffer_visible = { bg = "NONE" },
          background = { bg = "NONE" },
          fill = { bg = "NONE" },
          separator = { bg = "NONE" },
          separator_selected = { bg = "NONE" },
          separator_visible = { bg = "NONE" },
          close_button = { bg = "NONE" },
          close_button_selected = { bg = "NONE" },
          close_button_visible = { bg = "NONE" },
          modified = { bg = "NONE" },
          modified_selected = { bg = "NONE" },
          modified_visible = { bg = "NONE" },
          duplicate = { bg = "NONE" },
          duplicate_selected = { bg = "NONE" },
          duplicate_visible = { bg = "NONE" },
          indicator_selected = { bg = "NONE" },
          indicator_visible = { bg = "NONE" },
          pick = { bg = "NONE" },
          pick_selected = { bg = "NONE" },
          pick_visible = { bg = "NONE" },
        },
      }
    end
  }
}

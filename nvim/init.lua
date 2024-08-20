local function load_config_directory(directory)
  local config_path = vim.fn.stdpath("config") .. "/lua/" .. directory
  local files = vim.fn.glob(config_path .. "/*.lua", false, true)

  for _, file in ipairs(files) do
    local file_name = vim.fn.fnamemodify(file, ":t:r")  -- Extract filename without extension
    require(directory .. "." .. file_name)
  end
end

load_config_directory("config")

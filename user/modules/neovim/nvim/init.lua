local function load_config_directory(directory)
  local config_path = vim.fn.stdpath("config") .. "/lua/" .. directory
  local files = vim.fn.readdir(config_path, function(name)
    return name:sub(-4) == ".lua"
  end)

  for _, file in ipairs(files) do
    local file_name = file:sub(1, -5)
    require(directory .. "." .. file_name)
  end
end

load_config_directory("config")

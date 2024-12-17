local function enable_features(features)
  local features = features.fargs

  -- make sure the value is a string
  if type(features) == "table" then
    features = table.concat(features, ",")
  end

  if type(features) ~= "string" then
    print("features must be a string or a table of strings")
    return
  else
    -- make this a table with one element
    features = { features }
  end

  -- set new features
  cargo_features = features

  -- restart rust-analyzer, do the equivalent of :RustAnalyzer restart
  vim.api.nvim_command("RustAnalyzer restart")
end

local function clear_features()
  cargo_features = nil
end
vim.api.nvim_create_user_command("RustClearFeatures", clear_features, {})
vim.api.nvim_create_user_command("RustEnableFeatures", enable_features, { nargs = 1 })

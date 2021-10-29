local Config = {}

function Config:new(options)
  options = options or {}

  -- defaults
  local config = {
    spoon_dir = "Packer",
    github_url_format = 'https://github.com/%s.git',
  }

  setmetatable(config, self)
  self.__index = self

  config:setOptions(options)

  return config
end

function Config:setOptions(options)
  for key, value in pairs(options) do
    self[key] = value
  end
end

return Config

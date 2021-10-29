local Packer = {
  author = "Ryan Schlesinger <ryan@ryanschlesinger.com>",
  homepage = "https://github.com/ryansch/Packer.spoon",
  name = "Packer",
  version = "0.1.0",
  license = "MIT",
  spoonPath = hs.spoons.scriptPath()
}

local util = dofile(hs.spoons.resourcePath("util.lua"))
local Spoon = dofile(hs.spoons.resourcePath("spoon.lua"))
local Config = dofile(hs.spoons.resourcePath("config.lua"))

function Packer:new()
  local packer = {}

  setmetatable(packer, self)
  self.__index = self

  packer.config = Config:new()

  packer.spoons = {}
  packer.spoon_specifications = {}

  packer.log = hs.logger.new("[packer]")

  return packer
end

function Packer:bindHotKeys(mapping)
  local spec = {
    update = hs.fnutils.partial(self.update, self),
  }

  hs.spoons.bindHotkeysToSpec(spec, mapping)
  return self
end

function Packer:setLogLevel(level)
  self.log.setLogLevel(level)
  return self
end

function Packer:setSpoonDir(dir)
  self.config:setOptions({ spoon_dir = dir })
  return self
end

--- Add a plugin to the managed set
function Packer:use(plugin_spec, func)
  self.spoon_specifications[#self.spoon_specifications + 1] = {
    spec = plugin_spec,
    line = debug.getinfo(2, 'l').currentline,
    func = func
  }
  return self
end

function Packer:activate()
  self.log.d("Activating spoons")
  self.log.d("Spoon specs:")
  self.log.d(hs.inspect(self.spoon_specifications))

  package.path = package.path .. ";" .. util.join_paths(hs.configdir, "Packer/?.spoon/init.lua")

  for _, spec in ipairs(self.spoon_specifications) do
    self:activateSpoon(spec)
  end

  return self
end

function Packer:activateSpoon(spoon_data)
  self.log.d("activating:")
  self.log.d(hs.inspect(spoon_data))

  local spoon_spec = spoon_data.spec
  local spec_line = spoon_data.line
  local spec_type = type(spoon_spec)

  if spec_type == "string" then
    spoon_spec = { spoon_spec }
  else
    log.error(
      "Unsupported spoon spec "
      .. spoon_spec
      .. " on line "
      .. spec_line
    )
    return
  end

  if spoon_spec[1] == nil then
    self.log.warn('No plugin name provided at line ' .. spec_line .. '!')
    return
  end

  spoon_spec.spoon_dir = self.config.spoon_dir
  spoon_spec.github_url_format = self.config.github_url_format
  spoon_spec.setup_func = spoon_data.func
  spoon_spec.log = self.log
  local spoon = Spoon:new(spoon_spec)

  if self.spoons[spoon.short_name] then
    log.warn('Spoon "' .. spoon.short_name .. '" is used twice! (line ' .. spoon.spec_line .. ')')
    return
  end

  spoon:activate()

  self.spoons[spoon.short_name] = spoon

  return self
end

function Packer:update()
  self.log.i("Updating spoons")
  return self
end

return Packer

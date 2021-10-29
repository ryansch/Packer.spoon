local Spoon = {}

local util = dofile(hs.spoons.resourcePath("util.lua"))
local local_spoon_type = 'local'
local github_spoon_type = 'github'
local spoon_install_type = 'spoon_install'

function Spoon:new(spoon)
  local spoon = spoon or {}

  setmetatable(spoon, self)
  self.__index = self

  spoon.path = spoon[1]

  local name_segments = hs.fnutils.split(spoon.path, util.get_separator())
  local segment_idx = #name_segments
  local name = name_segments[segment_idx]
  while name == '' and segment_idx > 0 do
    name = name_segments[segment_idx]
    segment_idx = segment_idx - 1
  end

  spoon.short_name = name
  spoon.spoon_name = string.match(name, "^(.+)%.spoon$")
  spoon.name = spoon.path

  if spoon.name == '' then
    self.log.warn('"' .. spoon.path .. '" is an invalid plugin name!')
    error('"' .. spoon.path .. '" is an invalid plugin name!')
  end

  spoon.install_path = util.join_paths(spoon.spoon_dir, spoon.short_name)

  if not spoon.type then
    spoon:guessType()
  end

  spoon.log.d(hs.inspect(spoon))

  return spoon
end

function Spoon:guessType()
  if util.is_dir(self.path) then
    self.url = self.path
    self.type = local_spoon_type
  else
    self.url = self.path
    self.type = github_spoon_type
  end

  return self
end

function Spoon:activate()
  if self.type == local_spoon_type then
    return self:activateLocal()
  elseif self.type == github_spoon_type then
    return self:activateGithub()
  elseif self.type == spoon_install_type then
    return self:activateSpoonInstall()
  else
    error("Unknown spoon type!")
  end

  return self
end

function Spoon:activateLocal()
  error("Not implemented!")
  return self
end

function Spoon:activateGithub()
  if not util.is_dir(self.spoon_dir) then
    hs.fs.mkdir(self.spoon_dir)
  end

  if util.is_dir(util.join_paths(self.spoon_dir, self.short_name, ".git")) then
    self:loadSpoon()
    return
  end

  -- Run gh inside of the user's SHELL to get ssh-agent set up
  local gh = hs.task.new(
    os.getenv("SHELL"),
    function(exitCode, stdOut, stdErr)
      self:_completeActivateGithub(exitCode, stdOut, stdErr)
    end,
    { "-l", "-i", "-c", "/usr/local/bin/gh repo clone " .. self.path }
  )

  gh
    :setWorkingDirectory(self.spoon_dir)
    :start()

  return self
end

function Spoon:_completeActivateGithub(exitCode, stdOut, stdErr)
  self.log.d("completeActivateGithub")
  self.log.d(exitCode)
  self.log.d(stdOut)
  self.log.d(stdErr)

  if exitCode ~= 0 then
    self.log.f("gh command failed with exit code: " .. exitCode)
    self.log.f(stdOut)
    self.log.f(stdErr)
    error("Failed to activate github spoon!")
  end

  self:loadSpoon()
end

function Spoon:activateSpoonInstall()
  error("Not implemented!")
  return self
end

function Spoon:loadSpoon()
  loaded_spoon = hs.loadSpoon(self.spoon_name)

  if self.setup_func ~= nil then
    self.log.d("Calling setup func")
    self.setup_func(loaded_spoon)
  end

  return self
end

return Spoon

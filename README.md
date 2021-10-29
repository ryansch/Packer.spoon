# Packer.spoon

This is a package manager for Hammerspoon that borrows _heavily_ from https://github.com/wbthomason/packer.nvim

Example usage:
```lua
local Packer = hs.loadSpoon("Packer")
local packer = Packer:new()

packer
  :setLogLevel('info')  -- default is hs.logger.defaultLogLevel
  :setSpoonDir("Packer")  -- This is the default path; relative to hammerspoon config dir.
  :bindHotKeys({ update = { {'cmd', 'shift'}, 'u' }})  -- WIP; will be used to trigger Spoon updates
  :use('dbalatero/VimMode.spoon', function(VimMode)  -- See below.
    local vim = VimMode:new()
    vim
      :disableForApp("iTerm")
      :disableForApp("Terminal")
      :disableForApp("Code")
      :enterWithSequence("jk", 100)

    vim:useFallbackMode("Brave")
    vim:useFallbackMode("Chrome")
  end)
  :activate()
```

In the above example, we `use` the VimMode spoon and pass in a function to set it up. If the spoon is not installed, it will be installed in the background with `gh` and then the setup function run after the spoon is loaded.

### Setup
https://github.com/cli/cli#installation

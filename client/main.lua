local duff = duff
local require = duff.package.require
local blips = require 'client.blips'
local config = require 'shared.config'

local function init_blip(settings)
  local blip = blips.create(settings.type, settings.data)
  local name = settings.name
  local options = settings.options
  blips.setconfig(blip, options)
  blips.setname(blip, name)
end

local function init_script(resource)
  if resource and type(resource) == 'string' and resource ~= GetCurrentResourceName() then return end
  for category, blip_configs in pairs(config) do
    category = category:lower()
    for i = 1, #blip_configs do
      blip_configs[i].category = category
      init_blip(blip_configs[i])
    end
  end
end

local function deinit_script(resource)
  if resource and type(resource) == 'string' and resource ~= GetCurrentResourceName() then return end
  blips.clear()
end

AddEventHandler('onClientResourceStart', init_script)
AddEventHandler('onClientResourceStop', deinit_script)

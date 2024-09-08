local duff = duff
local bridge, locale, require, scaleform, streaming = duff.bridge, duff.locale, duff.package.require, duff.scaleform, duff.streaming
local blips = require 'client.blips' --[[@module 'iblips.client.blips']]
local config = require 'shared.config' --[[@module 'iblips.shared.config']]
local LOAD_EVENT <const>, UNLOAD_EVENT <const> = bridge['_DATA']['EVENTS'].LOAD, bridge['_DATA']['EVENTS'].UNLOAD
local TXD <const> = CreateRuntimeTxd 'don_blips'
local RES_NAME <const> = GetCurrentResourceName()
local IMAGE_PATH <const> = 'images/%s.png'
local NUI_PATH <const> = 'https://cfx-nui-%s/%s'
local Images = {}
local t = locale.t
local call_scaleform = scaleform.callfrontend
local can_control, take_control, release_control = IsFrontendReadyForControl, TakeControlOfFrontend, ReleaseControlOfFrontend
local is_mission_creator_blip, get_selected_mission_creator_blip = IsHoveringOverMissionCreatorBlip, GetNewSelectedMissionCreatorBlip
local does_blip_exist = DoesBlipExist

---@param key string?
---@return boolean
local function does_trans_exist(key) return pcall(t, key) end

---@param crew string? 4 Character Crew Tag
---@return string crew_tag {*_CREW}, formatted to be used in blip_creator_options
local function get_crew_tag(crew) return ('{*_%s}'):format(crew or 'NULL') end

---@param data {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: CREATOR_TYPES}
---@return {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: CREATOR_TYPES}?
local function trans_creator_info(data)
  if not data then return end
  if data.title then data.title = does_trans_exist(data.title) and t(data.title) or data.title end
  if data.text then data.text = does_trans_exist(data.text) and t(data.text) or data.text end
  if data.crew then data.crew = get_crew_tag(does_trans_exist(data.crew) and t(data.crew) or data.crew) end
  return data
end

---@param options blip_creator_options
---@return blip_creator_options?
local function trans_creator_data(options)
  if not options then return end
  options.title = does_trans_exist(options.title) and t(options.title) or options.title
  local info = options.info
  if info then
    for i = 1, #info do
      local entry = info[i]
      entry = trans_creator_info(entry) and trans_creator_info(entry) or entry
    end
  end
  return options
end

---@param blip_type BLIP_TYPES
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
---@param options blip_options
---@param creator_options blip_creator_options?
---@return integer blip
local function create_blip(blip_type, data, options, creator_options)
  local blip = blips.create(blip_type, data)
  local name = options.name
  options.name = does_trans_exist(name) and t(name --[[@as string]]) or name
  blips.setoptions(blip, options)
  if creator_options then trans_creator_data(creator_options); blips.setcreatordata(blip, creator_options) end
  return blip
end

---@param resource string?
local function init_script(resource)
  if resource and type(resource) == 'string' and resource ~= RES_NAME then return end
  for category, blip_configs in pairs(config) do
    category = category:lower()
    ---@diagnostic disable-next-line: cast-local-type
    category = category ~= 'other' and category
    for i = 1, #blip_configs do
      local data = blip_configs[i]
      data.options.display.category = category and not data.options.display.category and category or data.options.display.category
      create_blip(data.type, data.data, data.options, data.creator)
    end
  end
end

---@param state boolean
local function show_display(state) call_scaleform('SHOW_COLUMN', 1, state) end

local function clear_display() call_scaleform('SET_DATA_SLOT_EMPTY', 1) end

---@param resource string?
local function deinit_script(resource)
  if resource and type(resource) == 'string' and resource ~= RES_NAME then return end
  show_display(false)
  clear_display()
  release_control()
  SetStreamedTextureDictAsNoLongerNeeded('don_blips')
  blips.clear()
  Images = {}
end

---@param path string
---@param name string
---@param width integer
---@param height integer
---@return integer
local function create_runtime_from_nui(path, name, width, height)
  local obj = CreateDui(path, width, height)
  CreateRuntimeTextureFromDuiHandle(TXD, name, GetDuiHandle(obj))
  return obj
end

---@param title string
---@param verified integer?
---@param rp string?
---@param money string?
---@param ap string?
---@param image string|{resource: string, name: string, width: integer, height: integer}
local function set_creator_title(title, verified, rp, money, ap, image)
  local is_string = type(image) == 'string'
  if image and not Images[is_string and image or image.name] then
    Images[image] = is_string and CreateRuntimeTextureFromImage(TXD, image --[[@as string]], IMAGE_PATH:format(image)) or create_runtime_from_nui(NUI_PATH:format(image.resource, IMAGE_PATH:format(image.name)), image.name, image.width, image.height)
    streaming.async.loadtexturedict('don_blips')
  end
  call_scaleform('SET_COLUMN_TITLE', 1, '', title, verified or 0, {texture = true, name = 'don_blips'}, {texture = true, name = image and (is_string and image or image.name) or ''}, 1, 0, rp == '' and false or rp, money == '' and false or money, ap == '' and false or ap)
  if not image then return end
  SetStreamedTextureDictAsNoLongerNeeded('don_blips')
end

local function update_display() call_scaleform('DISPLAY_DATA_SLOT', 1) end

-------------------------------- EVENTS --------------------------------
AddEventHandler('onResourceStart', init_script)
AddEventHandler('onResourceStop', deinit_script)

RegisterNetEvent(LOAD_EVENT, init_script)
RegisterNetEvent(UNLOAD_EVENT, deinit_script)
-------------------------------- THREADS --------------------------------

---@enum (key) CREATOR_TYP_ARGS
local CREATOR_TYP_ARGS = {
  [0] = {0, 1},
  [1] = {0, 1},
  [2] = {0, 1},
  [3] = {0, 1},
  [4] = {0, 0},
  [5] = {0, 0}
}

CreateThread(function()
  local last_blip, sleep = 0, 3000
  while true do
    Wait(sleep)
    if IsPauseMenuActive() then
      sleep = 500
      if can_control() then
        if is_mission_creator_blip() then
          local blip = get_selected_mission_creator_blip()
          if not does_blip_exist(blip) or blip == 0 or blip == last_blip then goto continue end
          last_blip, sleep = blip, 0
          local blip_data = blips.getcreator(blip)
          if not blip_data then
            show_display(false)
          else
            take_control()
            clear_display()
            set_creator_title(blip_data.title, blip_data.verified, blip_data.rp, blip_data.money, blip_data.ap, blip_data.image)
            for i = 1, #blip_data.info do
              local entry = blip_data.info[i]
              local info_type = entry.type
              local args = CREATOR_TYP_ARGS[info_type]
              local index = i - 1
              call_scaleform('SET_DATA_SLOT', 1, index, 65, index, info_type, args[1], args[2], entry.title or entry.text, entry.text, entry.icon or entry.crew, entry.colour or entry.is_social_club, entry.checked)
            end
            PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            show_display(true)
            update_display()
            release_control()
          end
          ::continue::
        else
          if last_blip ~= 0 then
            last_blip, sleep = 0, 500
            show_display(false)
          end
        end
      end
    else
      sleep = 3000
    end
  end
end)

-------------------------------- EXPORTS --------------------------------

exports('initblip', create_blip)

for k, v in pairs(blips) do exports(k, type(v) == 'function' and v or function() return v end) end

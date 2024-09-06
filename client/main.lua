local duff = duff
local bridge, locale, math, require, streaming = duff.bridge, duff.locale, duff.math, duff.package.require, duff.streaming
local blips = require 'client.blips'
local config = require 'shared.config'
local LOAD_EVENT <const>, UNLOAD_EVENT <const> = bridge['_DATA']['EVENTS'].LOAD, bridge['_DATA']['EVENTS'].UNLOAD
local TXD <const> = CreateRuntimeTxd 'don_blips'
local RES_NAME <const> = GetCurrentResourceName()
local IMAGE_PATH <const> = 'images/%s.png'
local NUI_PATH <const> = 'https://cfx-nui-%s/%s'
local Images = {}
local creator_entries = 0
local t = locale.t

---@param key string
---@return boolean
local function does_trans_exist(key) return pcall(t, key) end

---@param options blip_creator_options
---@return blip_creator_options?
local function trans_creator_data(options)
  if not options then return end
  options.title = does_trans_exist(options.title) and t(options.title) or options.title
  local function parse_title_text(data)
    if not data then return end
    data.title = does_trans_exist(data.title) and t(data.title) or data.title
    data.text = does_trans_exist(data.text) and t(data.text) or data.text
    return data
  end
  if options.text then options.text = parse_title_text(options.text) end
  if options.name then options.name = parse_title_text(options.name) end
  if options.header then options.header = parse_title_text(options.header) end
  if options.icon then options.icon = parse_title_text(options.icon) end
  return options
end

---@param blip_type blip_types
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
---@param options blip_options
---@param creator_options blip_creator_options?
---@return integer blip
local function create_blip(blip_type, data, options, creator_options)
  local blip = blips.create(blip_type, data)
  local name = options.name
  options.name = does_trans_exist(name) and t(name) or name
  blips.setoptions(blip, options)
  if creator_options then trans_creator_data(creator_options); blips.setcreatordata(blip, creator_options) end
  return blip
end

---@param resource string?
local function init_script(resource)
  if resource and type(resource) == 'string' and resource ~= RES_NAME then return end
  for category, blip_configs in pairs(config) do
    category = category:lower()
    for i = 1, #blip_configs do
      local data = blip_configs[i]
      create_blip(data.type, data.data, data.options, data.creator)
    end
  end
end

---@param resource string?
local function deinit_script(resource)
  if resource and type(resource) == 'string' and resource ~= RES_NAME then return end
  blips.clear()
  Images = {}
end

---@param key string
---@param label string
local function add_label(key, label)
  if DoesTextLabelExist(key) and GetLabelText(key) == label then return end
  AddTextEntry(key, label)
end

---@param method string
---@param ... any
---@return any? ret_vals
local function call_scaleform(method, ...)
  if not BeginScaleformMovieMethodOnFrontend(method) then return end
  for i = 1, select('#', ...) do
    local arg = select(i, ...)
    local arg_type = type(arg)
    if arg_type == 'string' then
      local key = 'blips_'..arg
      add_label(key, arg)
      BeginTextCommandScaleformString(key)
      EndTextCommandScaleformString()
    elseif arg_type == 'number' then
      if math.isint(arg) then
        ScaleformMovieMethodAddParamInt(arg)
      else
        ScaleformMovieMethodAddParamFloat(arg)
      end
    elseif arg_type == 'boolean' then
      ScaleformMovieMethodAddParamBool(arg)
    elseif arg_type == 'table' then
      if arg.texture and arg.name then
        ScaleformMovieMethodAddParamTextureNameString(arg.name)
      end
    end
  end
  EndScaleformMovieMethod()
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
---@param verified boolean?
---@param rp string?
---@param money string?
---@param image string|{resource: string, name: string, width: integer, height: integer}
local function set_creator_title(title, verified, rp, money, image)
  local is_string = type(image) == 'string'
  if image and not Images[is_string and image or image.name] then
    Images[image] = is_string and CreateRuntimeTextureFromImage(TXD, image --[[@as string]], IMAGE_PATH:format(image)) or create_runtime_from_nui(NUI_PATH:format(image.resource, IMAGE_PATH:format(image.name)), image.name, image.width, image.height)
    streaming.async.loadtexturedict('don_blips')
  end
  call_scaleform('SET_COLUMN_TITLE', 1, '', title, verified and 1 or 0, {texture = true, name = 'don_blips'}, {texture = true, name = image?.name or image or ''}, 0, 0, rp == '' and false or rp, money == '' and false or money)
  if not image then return end
  SetStreamedTextureDictAsNoLongerNeeded('don_blips')
end

---@param index integer
---@param title string
---@param text string
---@param style integer?
local function set_creator_text(index, title, text, style)
  call_scaleform('SET_DATA_SLOT', 1, index, 65, 3, style or 0, 0, 0, title, text)
end

---@param index integer
---@param title string
---@param text string
---@param icon integer
---@param colour integer
---@param checked boolean
local function set_creator_icon(index, title, text, icon, colour, checked)
  call_scaleform('SET_DATA_SLOT', 1, index, 65, 3, 2, 0, 1, title, text, icon, colour, checked)
end

---@param title string
---@param text string
---@param style integer
local function add_creator_text(title, text, style)
  set_creator_text(creator_entries, title, text, style)
  creator_entries += 1
end

---@param title string
---@param text string
---@param icon integer
---@param colour integer
---@param checked boolean
local function add_creator_icon(title, text, icon, colour, checked)
  set_creator_icon(creator_entries, title, text, icon, colour, checked)
  creator_entries += 1
end

local function clear_display()
  call_scaleform('SET_DATA_SLOT_EMPTY', 1)
  creator_entries = 0
end

local function update_display() call_scaleform('DISPLAY_DATA_SLOT', 1) end

---@param state boolean
local function show_display(state) call_scaleform('SHOW_COLUMN', 1, state) end

-------------------------------- EVENTS --------------------------------
AddEventHandler('onResourceStart', init_script)
AddEventHandler('onResourceStop', deinit_script)

RegisterNetEvent(LOAD_EVENT, init_script)
RegisterNetEvent(UNLOAD_EVENT, deinit_script)
-------------------------------- THREADS --------------------------------

CreateThread(function()
  local last_blip, sleep = 0, 3000
  while true do
    Wait(sleep)
    if IsPauseMenuActive() then
      sleep = 500
      if IsFrontendReadyForControl() then
        if IsHoveringOverMissionCreatorBlip() then
          local blip = GetNewSelectedMissionCreatorBlip()
          if not DoesBlipExist(blip) or blip == 0 or blip == last_blip then goto continue end
          last_blip, sleep = blip, 0
          local blip_data = blips.getcreator(blip)
          if not blip_data then
            show_display(false)
          else
            TakeControlOfFrontend()
            clear_display()
            set_creator_title(blip_data.title, blip_data.verified, blip_data.rp, blip_data.money, blip_data.image)
            for i = 1, #blip_data.data do
              local entry = blip_data.data[i]
              if next(entry) then
                if i == 2 then
                  add_creator_icon(entry.title, entry.text, entry.icon, entry.colour, entry.checked)
                else
                  add_creator_text(entry.title, entry.text, blip_data.style)
                end
              end
            end
            PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            show_display(true)
            update_display()
            ReleaseControlOfFrontend()
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

for k, v in pairs(blips) do
  exports(k, type(v) == 'function' and v or function(...) return v end)
end

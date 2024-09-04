local duff = duff
local locale, math, require, streaming = duff.locale, duff.math, duff.package.require, duff.streaming
local blips = require 'client.blips'
local config = require 'shared.config'
local TXD <const> = CreateRuntimeTxd('don_blips')
local image_path <const> = 'images/%s.png'
local Images = {}
local t = locale.t

local function does_trans_exist(key) return pcall(t, key) end

---@param name string
---@param blip_type blip_types
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
---@param options {colours: {opacity: number, primary: number, secondary: (vector3|{r: integer, g: integer, b: integer})?}?, display: {category: blip_categories, display: blip_displays, priority: integer?}, flashes: {enable: boolean?, interval: integer?, duration: integer?, colour: integer?}?, style: {sprite: integer, scale: number|vector2, friendly: boolean?, bright: boolean, hidden: boolean?, high_detail: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?}?, indicators: {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?}?}
---@return integer blip
local function create_blip(name, blip_type, data, options, creator)
  local blip = blips.create(blip_type, data)
  local colours = options.colours
  local display = options.display
  local flashes = options.flashes
  local style = options.style
  local indicators = options.indicators
  if colours then blips.setcolours(blip, colours.opacity, colours.primary, colours.secondary) end
  if display then blips.setdisplay(blip, display.category, display.display, display.priority) end
  if flashes then blips.setflashes(blip, flashes.enable, flashes.interval, flashes.duration, flashes.colour) end
  if style then blips.setstyle(blip, style.sprite, style.scale, style.friendly, style.bright, style.hidden, style.high_detail, style.show_cone, style.short_range, style.shrink) end
  if indicators then blips.setindicators(blip, indicators.crew, indicators.friend, indicators.completed, indicators.heading, indicators.height, indicators.count, indicators.outline, indicators.tick) end
  blips.setname(blip, name)
  if creator then
    local title = does_trans_exist(creator.title) and t(creator.title) or creator.title
    blips.initcreator(blip, title, creator.verified, creator.image, creator.rp, creator.money, creator.style, creator.data.text, creator.data.name, creator.data.header, creator.data.icon)
  end
  return blip
end

exports('initblip', create_blip)

local function init_script(resource)
  if resource and type(resource) == 'string' and resource ~= RES_NAME then return end
  for category, blip_configs in pairs(config) do
    category = category:lower()
    for i = 1, #blip_configs do
      local data = blip_configs[i]
      local name = does_trans_exist(data.name) and t(data.name) or data.name
      create_blip(name, data.type, data.data, data.options, data.creator)
    end
  end
end

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

local function set_creator_title(title, verified, rp, money, image)
  if image and not Images[image] then
    Images[image] = CreateRuntimeTextureFromImage(TXD, image, image_path:format(image))
    streaming.async.loadtexturedict('don_blips')
  end
  call_scaleform('SET_COLUMN_TITLE', 1, '', title, verified and 1 or 0, {texture = true, name = 'don_blips'}, {texture = true, name = image or ''}, 0, 0, rp == '' and false or rp, money == '' and false or money)
  if not image then return end
  SetStreamedTextureDictAsNoLongerNeeded('don_blips')
end

local function set_creator_text(index, title, text, style)
  call_scaleform('SET_DATA_SLOT', 1, index, 65, 3, style or 0, 0, 0, title, text)
end

local function set_creator_icon(index, title, text, icon, colour, checked)
  call_scaleform('SET_DATA_SLOT', 1, index, 65, 3, 2, 0, 1, title, text, icon, colour, checked)
end

local entries = 0

local function add_creator_text(title, text, style)
  set_creator_text(entries, title, text, style)
  entries += 1
end

local function add_creator_icon(title, text, icon, colour, checked)
  set_creator_icon(entries, title, text, icon, colour, checked)
  entries += 1
end

local function clear_display()
  call_scaleform('SET_DATA_SLOT_EMPTY', 1)
  entries = 0
end

local function update_display() call_scaleform('DISPLAY_DATA_SLOT', 1) end

local function show_display(state) call_scaleform('SHOW_COLUMN', 1, state) end

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

AddEventHandler('onClientResourceStart', init_script)
AddEventHandler('onClientResourceStop', deinit_script)

for k, v in pairs(blips) do
  exports(k, type(v) == 'function' and v or function(...) return v end)
end

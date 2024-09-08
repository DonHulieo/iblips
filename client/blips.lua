---@class blips
---@field Blips table
---@field create fun(type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}): integer
---@field gettype fun(blip: integer): BLIP_TYPE_IDS
---@field getdata fun(blip: integer): {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
---@field setcolours fun(blip: integer, alpha: integer?, primary: integer?, secondary: vector3|{r: integer, g: integer, b: integer}?)
---@field setcoords fun(blip: integer, coords: vector3, heading: number?)
---@field setdisplay fun(blip: integer, category: BLIP_CATEGORIES?, display: BLIP_DISPLAYS?, priority: integer?)
---@field setflashes fun(blip: integer, flashes: boolean, interval: integer?, duration: integer?, colour: integer?)
---@field setstyle fun(blip: integer, sprite: integer, scale: number|vector2, friendly: boolean?, bright: boolean?, hidden: boolean?, high_detail: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?)
---@field setindicators fun(blip: integer, crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?)
---@field setname fun(blip: integer, name: string)
---@field setrange fun(blip: integer, distance: number)
---@field setoptions fun(blip: integer, options: blip_options): blip: integer
---@field updater fun(blip: integer, interval: integer, callback: fun(blip: integer): blip_options): pause: fun(state: boolean?): state: boolean, destroy: fun(), update: fun(new_interval: integer, new_callback: fun(blip: integer): blip_options)
---@field remove fun(blip: integer): boolean
---@field clear fun()
---@field setcreator fun(blip: integer, creator: boolean)
---@field settitle fun(blip: integer, title: string, verified: boolean, style: integer)
---@field setimage fun(blip: integer, image: string|{resource: string, name: string, width: integer, height: integer})
---@field seteconomy fun(blip: integer, rp: string, money: string)
---@field setcreatordata fun(blip: integer, options: blip_creator_options): blip: integer
---@field createupdater fun(blip: integer, interval: integer, callback: fun(blip: integer): blip_creator_options): pause: fun(state: boolean?): state: boolean, destroy: fun(), update: fun(new_interval: integer, new_callback: fun(blip: integer): blip_creator_options)
---@field getcreator fun(blip: integer): {title: string, verified: boolean, image: string|{resource: string, name: string, width: integer, height: integer}, rp: string, money: string, style: integer, data: {title: string, text: string, icon: integer?, colour: integer?, checked: boolean?}[]}}
do
  local duff = duff
  local math, interval = duff.math, duff.interval
  local does_blip_exist, does_entity_exist, does_pickup_exist = DoesBlipExist, DoesEntityExist, DoesPickupExist
  local Blips = {}
  local count = 0

  ---@enum (key) BLIP_TYPES
  local BLIP_TYPES <const> = {
    area = AddBlipForArea,
    coord = AddBlipForCoord,
    entity = AddBlipForEntity,
    ped = AddBlipForEntity,
    vehicle = AddBlipForEntity,
    object = AddBlipForEntity,
    pickup = AddBlipForPickup,
    radius = AddBlipForRadius,
    race = RaceGalleryAddBlip
  }

  ---@enum entity_types
  local entity_types = {[0] = 'none', [1] = 'ped', [2] = 'vehicle', [3] = 'object'}

  ---@param type BLIP_TYPES
  ---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
  ---@return integer
  local function create_blip(type, data)
    if not BLIP_TYPES[type] then error('bad argument #1 to \'createblip\' (invalid blip type)', 2) end
    if not data then error('bad argument #2 to \'createblip\' (table expected, got nil)', 2) end
    local blip = -1
    if type == 'area' then
      local coords, width, height = data.coords, data.width, data.height
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      if not width then error('bad argument #2 to \'createblip\' (width expected, got nil)', 2) end
      if not height then error('bad argument #2 to \'createblip\' (height expected, got nil)', 2) end
      blip = BLIP_TYPES[type](coords.x, coords.y, coords.z, width, height)
    elseif type == 'coord' then
      local coords = data.coords
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      blip = BLIP_TYPES[type](coords.x, coords.y, coords.z)
    elseif type == 'entity' then
      local entity = data.entity
      if not entity or not does_entity_exist(entity) then error('bad argument #2 to \'createblip\' (entity is invalid)', 2) end
      blip = BLIP_TYPES[type](entity)
      type = entity_types[GetEntityType(entity)] --[[@as BLIP_TYPES]] or type
    elseif type == 'pickup' then
      local pickup = data.pickup
      if not pickup or not does_pickup_exist(pickup) then error('bad argument #2 to \'createblip\' (pickup is invalid)', 2) end
      blip = BLIP_TYPES[type](pickup)
    elseif type == 'radius' then
      local coords, radius = data.coords, data.radius
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      if not radius then error('bad argument #2 to \'createblip\' (radius expected, got nil)', 2) end
      blip = BLIP_TYPES[type](coords.x, coords.y, coords.z, radius)
    elseif type == 'race' then
      local coords = data.coords
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      blip = BLIP_TYPES[type](coords.x, coords.y, coords.z)
    elseif type == 'route' then
      local coords = data.coords
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      blip = BLIP_TYPES[type](coords.x, coords.y, coords.z)
    end
    count += 1
    Blips[blip] = {id = count, type = type, data = data}
    return blip
  end

  ---@param blip integer
  ---@return boolean removed
  local function remove_blip(blip)
    if not does_blip_exist(blip) then return false end
    RemoveBlip(blip)
    Blips[blip] = nil
    return true
  end

  local function clear()
    for blip in pairs(Blips) do remove_blip(blip) end
  end


  ---@enum BLIP_TYPE_IDS
  local BLIP_TYPE_IDS <const> = {
    [1] = 'vehicle',
    [2] = 'ped',
    [3] = 'object',
    [4] = 'coord',
    [6] = 'pickup',
    [7] = 'radius',
    [11] = 'area',
    [12] = 'race'
  }

  ---@param blip integer
  ---@return BLIP_TYPES
  local function get_blip_type(blip)
    if not Blips[blip] then
      local blip_type = GetBlipInfoIdType(blip)
      if does_blip_exist(blip) then
        Blips[blip] = {type = BLIP_TYPE_IDS[blip_type] or blip_type}
      else
        error('bad argument #1 to \'getbliptype\' (blip `'..blip..'` doesn\'t exist)', 2)
      end
    end
    return Blips[blip].type
  end

  ---@param blip integer
  ---@return {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
  local function get_blip_data(blip)
    if not Blips[blip] then
      if does_blip_exist(blip) then
        local type = get_blip_type(blip)
        local data = {}
        if type == 'area' then
          local coords, width, height = GetBlipInfoIdCoord(blip)
          data.coords = coords
          data.width, data.height = width, height
        elseif type == 'coord' then
          data.coords = GetBlipInfoIdCoord(blip)
        elseif type == 'entity' then
          local entity = GetBlipInfoIdEntityIndex(blip)
          data.entity = entity
        elseif type == 'pickup' then
          local pickup = GetBlipInfoIdPickupIndex(blip)
          data.pickup = pickup
        elseif type == 'radius' then
          local coords, radius = GetBlipInfoIdCoord(blip)
          data.coords = coords
          data.radius = radius
        elseif type == 'race' then
          local coords = GetBlipInfoIdCoord(blip)
          data.coords = coords
        elseif type == 'route' then
          local coords = GetBlipInfoIdCoord(blip)
          data.coords = coords
        end
        Blips[blip].data = data
      else
        error('bad argument #1 to \'getblipdata\' (blip `'..blip..'` doesn\'t exist)', 2)
      end
    end
    return Blips[blip].data
  end

  local function init_blip(blip)
    if not Blips[blip] then get_blip_type(blip); get_blip_data(blip); count += 1; Blips[blip].id = count end
    return blip
  end

  ---@param blip integer
  ---@param opacity integer?
  ---@param primary integer? See [HUD Colours](https://docs.fivem.net/docs/game-references/blips/#blip-colors).
  ---@param secondary vector3|{r: integer, g: integer, b: integer}? Changes the friend or crew indicator colour or the main colour of the blip if primary is set to `84`.
  local function set_blip_colours(blip, opacity, primary, secondary)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipcolours\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    if opacity then SetBlipAlpha(blip, opacity); Blips[blip].options.opacity = opacity end
    if primary then SetBlipColour(blip, primary); Blips[blip].options.primary = primary end
    if secondary then SetBlipSecondaryColour(blip, secondary.r, secondary.g, secondary.b); Blips[blip].options.secondary = secondary end
  end

  ---@param blip integer
  ---@param coords vector3
  ---@param heading number?
  local function set_blip_coords(blip, coords, heading)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipcoords\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].data.coords = coords
    SetBlipCoords(blip, coords.x, coords.y, coords.z)
    if not heading then
      return
    elseif math.isint(heading) then
      SetBlipRotation(blip, heading)
    else
      SetBlipSquaredRotation(blip, heading)
    end
    Blips[blip].data.coords.w = heading
  end

  ---@enum (key) BLIP_CATEGORIES
  local BLIP_CATEGORIES <const> = {
    --[[
      https://github.com/vhub-team/native-db/blob/f1635dda3a5ac6cda982c97f105c07a341d2c022/enums/BLIP_CATEGORY.md
      https://github.com/scripthookvdotnet/scripthookvdotnet/blob/e219d506b32a2ba9a6676c6eae5d99208a22bff8/source/scripting_v3/GTA/Blip/BlipCategoryType.cs
    ]] --
    nodist = 1,
    dist = 2,
    jobs = 3,
    myjobs = 4,
    mission = 5,
    activity = 6,
    players = 7,
    shops = 8,
    races = 9,
    property = 10,
    ownedproperty = 11,
  }

  ---@enum (key) BLIP_DISPLAYS
  local BLIP_DISPLAYS <const> = {
    --[[
      https://github.com/vhub-team/native-db/blob/main/enums/BLIP_DISPLAY.md
      https://github.com/scripthookvdotnet/scripthookvdotnet/blob/e219d506b32a2ba9a6676c6eae5d99208a22bff8/source/scripting_v3/GTA/Blip/BlipCategoryType.cs
    ]] --
    none = 1,
    all_select = 2,
    pause_select = 3,
    radar_only = 5,
    fullbigmap_only = 7,
    all_noselect = 8,
    all_radar_only = 9
  }

  ---@param blip integer
  ---@param category BLIP_CATEGORIES?
  ---@param display BLIP_DISPLAYS?
  ---@param priority integer?
  local function set_blip_display(blip, category, display, priority)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipdisplay\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    category = category or Blips[blip].options.category or 'nodist'
    display = display or Blips[blip].options.display or 'all_select'
    if Blips[blip].options.category ~= category then SetBlipCategory(blip, BLIP_CATEGORIES[category]) end
    if Blips[blip].options.display ~= display then SetBlipDisplay(blip, BLIP_DISPLAYS[display]) end
    if priority then --[[https://github.com/vhub-team/native-db/blob/main/enums/BLIP_PRIORITY.md]] SetBlipPriority(blip, priority); Blips[blip].options.priority = priority end
    Blips[blip].options.category = category
    Blips[blip].options.display = display
  end

  local function custom_flash_blip(blip, colour)
    if not does_blip_exist(blip) then error('bad argument #1 to \'customflashblip\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    if not Blips[blip].options.flashes then return end
    local colours = {Blips[blip].options.primary, colour}
    local time = Blips[blip].options.flash_interval
    local duration = Blips[blip].options.flash_duration or -1
    local state = false
    local _, idx = interval.create(function(blip_id, interval_id)
      if not does_blip_exist(blip_id) or not Blips[blip_id].options.flashes then interval.stop(interval_id) end
      state = not state
      SetBlipColour(blip_id, colours[state and 1 or 2])
    end, time, duration)
    interval.start(idx, nil, blip, idx)
    Blips[blip].options.flash_interval_idx = idx
  end

  ---@param blip integer
  ---@param flashes boolean
  ---@param time integer?
  ---@param duration integer?
  ---@param colour integer?
  local function set_blip_flashes(blip, flashes, time, duration, colour)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipflashes\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    if not flashes and not Blips[blip].options.flashes then return end
    if time then
      if not colour then SetBlipFlashes(blip, flashes); SetBlipFlashInterval(blip, time) end
      Blips[blip].options.flash_interval = time
    end
    if duration then
      if not colour then SetBlipFlashTimer(blip, duration) end
      Blips[blip].options.flash_duration = duration
    end
    Blips[blip].options.flashes = flashes
    if colour then custom_flash_blip(blip, colour) end
  end

  ---@param blip integer
  ---@param sprite integer
  ---@param scale number|vector2
  ---@param friendly boolean?
  ---@param bright boolean?
  ---@param hidden boolean?
  ---@param high_detail boolean?
  ---@param show_cone boolean?
  ---@param short_range boolean?
  ---@param shrink boolean?
  local function set_blip_style(blip, sprite, scale, friendly, bright, hidden, high_detail, show_cone, short_range, shrink)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipstyle\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    SetBlipSprite(blip, sprite)
    if type(scale) == 'number' then
      SetBlipScale(blip, scale)
    else
      SetBlipScaleTransformation(blip, scale.x, scale.y)
    end
    if friendly ~= nil then SetBlipAsFriendly(blip, friendly); Blips[blip].options.friendly = friendly end
    if bright ~= nil then SetBlipBright(blip, bright); Blips[blip].options.bright = bright end
    if hidden ~= nil then SetBlipHiddenOnLegend(blip, hidden); Blips[blip].options.hidden = hidden end
    if high_detail ~= nil then SetBlipHighDetail(blip, high_detail); Blips[blip].options.high_detail = high_detail end
    if show_cone ~= nil then SetBlipShowCone(blip, show_cone); Blips[blip].options.show_cone = show_cone end
    if short_range ~= nil then SetBlipAsShortRange(blip, short_range); Blips[blip].options.short_range = short_range end
    if shrink ~= nil then SetBlipShrink(blip, shrink); Blips[blip].options.shrink = shrink end
    Blips[blip].options.sprite = sprite
    Blips[blip].options.scale = scale
  end

  ---@param blip integer
  ---@param crew boolean?
  ---@param friend boolean?
  ---@param completed boolean?
  ---@param heading boolean?
  ---@param height boolean?
  ---@param count integer?
  ---@param outline boolean?
  ---@param tick boolean?
  local function set_blip_indicators(blip, crew, friend, completed, heading, height, count, outline, tick)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipindicators\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    if crew ~= nil then ShowCrewIndicatorOnBlip(blip, crew); Blips[blip].options.crew = crew end
    if friend ~= nil then ShowFriendIndicatorOnBlip(blip, friend); Blips[blip].options.friend = friend end
    if completed ~= nil then ShowHasCompletedIndicatorOnBlip(blip, completed); Blips[blip].options.completed = completed end
    if heading ~= nil then ShowHeadingIndicatorOnBlip(blip, heading); Blips[blip].options.heading = heading end
    if height ~= nil then ShowHeightOnBlip(blip, height); Blips[blip].options.height = height end
    if type(count) =='number' and math.isint(count) then ShowNumberOnBlip(blip, count); Blips[blip].options.count = count end
    if outline ~= nil then ShowOutlineIndicatorOnBlip(blip, outline); Blips[blip].options.outline = outline end
    if tick ~= nil then ShowTickOnBlip(blip, tick); Blips[blip].options.tick = tick end
  end

  ---@param key string
  ---@param label string
  local function add_label(key, label)
    if DoesTextLabelExist(key) and GetLabelText(key) == label then return end
    AddTextEntry(key, label)
  end

  ---@param blip integer
  ---@param name string
  local function set_blip_name(blip, name)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipname\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    local key = 'blip_'..Blips[blip].id
    add_label(key, name)
    BeginTextCommandSetBlipName(key)
    EndTextCommandSetBlipName(blip)
    Blips[blip].options = Blips[blip].options or {}
    Blips[blip].options.name = name
  end

  ---@param blip integer
  ---@param distance number
  local function set_blip_range(blip, distance)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipdistance\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    Blips[blip].options.distance = distance
    local ped = PlayerPedId()
    local coords = Blips[blip].data.coords or GetBlipCoords(blip)
    local flash_interval = Blips[blip].options.flash_interval_idx
    local state = nil
    local _, idx = interval.create(function(blip_id, interval_id)
      if not does_blip_exist(blip_id) then interval.stop(interval_id) end
      local in_range = #(GetEntityCoords(ped) - coords) <= distance
      if in_range ~= state then
        set_blip_display(blip_id, nil, in_range and 'all_select' or 'none')
        if state ~= nil and flash_interval then interval.pause(flash_interval, not in_range) end
        state = in_range
      end
    end, 1000)
    interval.start(idx, nil, blip, idx)
    Blips[blip].options.distance_idx = idx
  end

  ---@class blip_options
  ---@field name string?
  ---@field coords vector3|vector4?
  ---@field distance number?
  ---@field colours {opacity: integer?, primary: integer?, secondary: vector3|{r: integer, g: integer, b: integer}?}?
  ---@field display {category: BLIP_CATEGORIES, display: BLIP_DISPLAYS, priority: integer?}?
  ---@field flashes {enable: boolean, interval: integer?, duration: integer?, colour: integer?}?
  ---@field style {sprite: integer, scale: number|vector2, friendly: boolean?, bright: boolean?, hidden: boolean?, high_detail: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?}?
  ---@field indicators {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?}?

  ---@param blip integer
  ---@param options blip_options
  ---@return integer blip
  local function set_blip_options(blip, options)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipoptions\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    if options.coords then set_blip_coords(blip, options.coords, options.coords?.w) end
    if options.colours then set_blip_colours(blip, options.colours?.opacity, options.colours?.primary, options.colours?.secondary) end
    if options.display then set_blip_display(blip, options.display?.category, options.display?.display, options.display?.priority) end
    if options.flashes then set_blip_flashes(blip, options.flashes?.enable, options.flashes?.interval, options.flashes?.duration, options.flashes?.colour) end
    if options.style then set_blip_style(blip, options.style?.sprite, options.style?.scale, options.style?.friendly, options.style?.bright, options.style?.hidden, options.style?.high_detail, options.style?.show_cone, options.style?.short_range, options.style?.shrink) end
    if options.indicators then set_blip_indicators(blip, options.indicators?.crew, options.indicators?.friend, options.indicators?.completed, options.indicators?.heading, options.indicators?.height, options.indicators?.count, options.indicators?.outline, options.indicators?.tick) end
    if options.name then set_blip_name(blip, options.name) end
    if options.distance then set_blip_range(blip, options.distance) end
    return blip
  end

  ---@param blip integer
  ---@param time integer
  ---@param callback fun(blip: integer): blip_options
  ---@return fun(state: boolean?): state: boolean pause, fun() destroy, fun(new_interval: integer, new_callback: fun(blip: integer): blip_options) update
  local function blip_updater(blip, time, callback)
    if not does_blip_exist(blip) then error('bad argument #1 to \'createblipupdater\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    local _, idx = interval.create(function(blip_id, interval_id)
      if not does_blip_exist(blip_id) then interval.stop(interval_id) end
      local data = callback(blip_id)
      return data
    end, time)
    interval.start(idx, function(data)
      if not data then return end
      ---@cast data +blip_options
      if data.coords then set_blip_coords(blip, data.coords, data.coords?.w) end
      if data.distance then set_blip_range(blip, data.distance) end
      if data.colours then set_blip_colours(blip, data.colours?.opacity, data.colours?.primary, data.colours?.secondary) end
      if data.display then set_blip_display(blip, data.display?.category, data.display?.display, data.display?.priority) end
      if data.flashes then set_blip_flashes(blip, data.flashes?.enable, data.flashes?.interval, data.flashes?.duration, data.flashes?.colour) end
      if data.style then set_blip_style(blip, data.style?.sprite, data.style?.scale, data.style?.friendly, data.style?.bright, data.style?.hidden, data.style?.high_detail, data.style?.show_cone, data.style?.short_range, data.style?.shrink) end
      if data.indicators then set_blip_indicators(blip, data.indicators?.crew, data.indicators?.friend, data.indicators?.completed, data.indicators?.heading, data.indicators?.height, data.indicators?.count, data.indicators?.outline, data.indicators?.tick) end
      if data.name then set_blip_name(blip, data.name) end
    end, blip, idx)
    return function(pause)
      return interval.pause(idx, pause)
    end, function()
      interval.destroy(idx)
    end, function(new_interval, new_callback)
      interval.update(idx, function(blip_id, interval_id)
        if not does_blip_exist(blip_id) then interval.stop(interval_id) end
        local data = new_callback(blip_id)
        return data
      end, nil, new_interval)
    end
  end

  ---@enum VERIFIED_TYPES
  local VERIFIED_TYPES <const> = {
    ['none'] = 0,
    ['verified'] = 1,
    ['created'] = 2
  }

  ---@param blip integer
  ---@param creator boolean
  local function set_blip_as_creator(blip, creator)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipascreator\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    SetBlipAsMissionCreatorBlip(blip, creator)
    Blips[blip].options.creator = not creator and nil or {
      title = '',
      verified = 0,
      image = '',
      rp = '',
      money = '',
      ap = '',
      info = {}
    }
  end

  ---@param blip integer
  ---@param title string?
  ---@param verified VERIFIED_TYPES?
  local function set_blip_title(blip, title, verified)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setbliptitle\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    if title then Blips[blip].options.creator.title = title end
    if verified and VERIFIED_TYPES[verified] then Blips[blip].options.creator.verified = VERIFIED_TYPES[verified] end
  end

  ---@param blip integer
  ---@param image string|{resource: string, name: string, width: integer, height: integer}?
  local function set_blip_image(blip, image)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipimage\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    Blips[blip].options.creator.image = image or ''
  end

  ---@param blip integer
  ---@param rp string?
  ---@param money string?
  ---@param ap string?
  local function set_blip_economy(blip, rp, money, ap)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipeconomy\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    if rp then Blips[blip].options.creator.rp = rp end
    if money then Blips[blip].options.creator.money = money end
    if ap then Blips[blip].options.creator.ap = ap end
  end

  ---@param blip integer
  ---@param data {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: integer}[]
  local function add_creator_info(blip, data)
    if not does_blip_exist(blip) then error('bad argument #1 to \'addcreatorinfo\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    local info = Blips[blip].options.creator.info
    for i = 1, #data do info[#info + 1] = data[i] end
  end

  local function update_creator_info(blip, key, data)
    if not does_blip_exist(blip) then error('bad argument #1 to \'updatecreatorinfo\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then return end
    local info = Blips[blip].options.creator.info
    if not info[key] then return end
    info[key] = data
  end

  ---@enum CREATOR_TYPES
  local _ --[[@as CREATOR_TYPES]] <const> = {
    title = 0,
    title_text = 1,
    icon = 2,
    player = 3,
    header = 4,
    text = 5
  }

  ---@class blip_creator_options
  ---@field title string
  ---@field verified VERIFIED_TYPES
  ---@field image string|{resource: string, name: string, width: integer, height: integer}
  ---@field rp string?
  ---@field money string?
  ---@field ap string?
  ---@field info {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: CREATOR_TYPES}[]?

  ---@param blip integer
  ---@param options blip_creator_options
  ---@return integer blip
  local function set_blip_creator_data(blip, options)
    if not does_blip_exist(blip) then error('bad argument #1 to \'initcreatorblip\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    set_blip_title(blip, options.title, options.verified)
    if options.image ~= '' then set_blip_image(blip, options.image) end
    set_blip_economy(blip, options.rp, options.money, options.ap)
    local info = options.info
    if info then add_creator_info(blip, info) end
    return blip
  end

  ---@param blip integer
  ---@param time integer
  ---@param callback fun(blip: integer): blip_creator_options
  ---@return fun(state: boolean?): state: boolean pause, fun() destroy, fun(new_interval: integer, new_callback: fun(blip: integer): blip_creator_options) update
  local function creator_updater(blip, time, callback)
    if not does_blip_exist(blip) then error('bad argument #1 to \'createblipupdater\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    local _, idx = interval.create(function(blip_id, interval_id)
      if not does_blip_exist(blip_id) then interval.stop(interval_id) end
      local data = callback(blip_id)
      return data
    end, time)
    interval.start(idx, function(data)
      if not data then return end
      if data.title then set_blip_title(blip, data.title, data.verified) end
      if data.image then set_blip_image(blip, data.image) end
      if data.rp or data.money then set_blip_economy(blip, data.rp, data.money) end
      local info = data.info
      for i = 1, #info do update_creator_info(blip, i, info[i]) end
    end, blip, idx)
    return function(pause)
      return interval.pause(idx, pause)
    end, function()
      interval.destroy(idx)
    end, function(new_interval, new_callback)
      interval.update(idx, function(blip_id, interval_id)
        if not does_blip_exist(blip_id) then interval.stop(interval_id) end
        local data = new_callback(blip_id)
        return data
      end, nil, new_interval)
    end
  end

  ---@param blip integer
  ---@return {title: string, verified: integer, rp: string, money: string, image: string|{resource: string, name: string, width: integer, height: integer}, ap: string, info: {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: integer}[]}?
  local function get_creator_data(blip)
    if not Blips?[blip]?.options?.creator then return end
    return Blips[blip].options.creator
  end

  return {
    Blips = Blips,
    create = create_blip,
    remove = remove_blip,
    clear = clear,
    gettype = get_blip_type,
    getdata = get_blip_data,
    setcolours = set_blip_colours,
    setcoords = set_blip_coords,
    setdisplay = set_blip_display,
    setflashes = set_blip_flashes,
    setstyle = set_blip_style,
    setindicators = set_blip_indicators,
    setname = set_blip_name,
    setrange = set_blip_range,
    setoptions = set_blip_options,
    updater = blip_updater,
    setcreator = set_blip_as_creator,
    settitle = set_blip_title,
    setimage = set_blip_image,
    seteconomy = set_blip_economy,
    setcreatordata = set_blip_creator_data,
    creatorupdater = creator_updater,
    getcreator = get_creator_data
  }
end
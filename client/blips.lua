---@class blips
---@field Blips table
---@field create fun(type: blip_types, data: {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}): integer
---@field gettype fun(blip: integer): blip_types
---@field getdata fun(blip: integer): {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
---@field setcolours fun(blip: integer, alpha: integer?, primary: integer?, secondary: vector3|{r: integer, g: integer, b: integer}?)
---@field setcoords fun(blip: integer, coords: vector3, heading: number?)
---@field setdisplay fun(blip: integer, category: integer, display: integer, priority: integer?)
---@field setflashes fun(blip: integer, flashes: boolean, interval: integer?, duration: integer?, colour: integer?)
---@field setstyle fun(blip: integer, sprite: integer, scale: number|vector2, friendly: boolean?, bright: boolean?, hidden: boolean?, high_detail: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?)
---@field setindicators fun(blip: integer, crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?)
---@field setname fun(blip: integer, name: string)
---@field remove fun(blip: integer): boolean
---@field clear fun()
---@field setcreator fun(blip: integer, creator: boolean)
---@field settitle fun(blip: integer, title: string, verified: boolean, style: integer)
---@field setimage fun(blip: integer, image: string)
---@field seteconomy fun(blip: integer, rp: string, money: string)
---@field addtext fun(blip: integer, title: string, text: string)
---@field addname fun(blip: integer, title: string, text: string)
---@field addheader fun(blip: integer, title: string, text: string)
---@field addicon fun(blip: integer, title: string, text: string, icon: string, colour: integer, checked: boolean)
---@field initcreator fun(blip: integer, title: string, verified: boolean, image: string, rp: string, money: string, style: integer, text: string, name: string, header: string, icon: string)
---@field createupdater fun(blip: integer, interval: integer, callback: fun(blip: integer): {title: string?, verified: boolean?, rp: string?, money: string?, image: (string|{resource: string, name: string})?, style: integer?, text: {title: string, text: string}?, name: {title: string, text: string}?, header: {title: string, text: string}?, icon: {title: string, text: string, icon: string, colour: integer, checked: boolean}?}): (promise, toggle: fun(), updater: fun(), update: fun(new_callback: fun(blip: integer): {title: string?, verified: boolean?, rp: string?, money: string?, image: (string|{resource: string, name: string})?, style: integer?, text: {title: string, text: string}?, name: {title: string, text: string}?, header: {title: string, text: string}?, icon: {title: string, text: string, icon: string, colour: integer, checked: boolean}?}), new: fun(new_interval: integer, new_callback: fun(blip: integer): {title: string?, verified: boolean?, rp: string?, money: string?, image: (string|{resource: string, name: string})?, style: integer?, text: {title: string, text: string}?, name: {title: string, text: string}?, header: {title: string, text: string}?, icon: {title: string, text: string, icon: string, colour: integer, checked: boolean}?}))
---@field getcreator fun(blip: integer): {title: string, verified: boolean, image: string, rp: string, money: string, style: integer, data: {text: string, name: string, header: string, icon: string}}
do
  local duff = duff
  local math = duff.math
  local does_blip_exist, does_entity_exist, does_pickup_exist = DoesBlipExist, DoesEntityExist, DoesPickupExist
  local Blips = {}
  local count = 0

  ---@enum (key) blip_types
  local blip_types = {
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

  ---@param type blip_types
  ---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
  ---@return integer
  local function create_blip(type, data)
    if not blip_types[type] then error('bad argument #1 to \'createblip\' (invalid blip type)', 2) end
    if not data then error('bad argument #2 to \'createblip\' (table expected, got nil)', 2) end
    local blip = -1
    if type == 'area' then
      local coords, width, height = data.coords, data.width, data.height
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      if not width then error('bad argument #2 to \'createblip\' (width expected, got nil)', 2) end
      if not height then error('bad argument #2 to \'createblip\' (height expected, got nil)', 2) end
      blip = blip_types[type](coords.x, coords.y, coords.z, width, height)
    elseif type == 'coord' then
      local coords = data.coords
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      blip = blip_types[type](coords.x, coords.y, coords.z)
    elseif type == 'entity' then
      local entity = data.entity
      if not entity or not does_entity_exist(entity) then error('bad argument #2 to \'createblip\' (entity is invalid)', 2) end
      blip = blip_types[type](entity)
      type = entity_types[GetEntityType(entity)] --[[@as blip_types]] or type
    elseif type == 'pickup' then
      local pickup = data.pickup
      if not pickup or not does_pickup_exist(pickup) then error('bad argument #2 to \'createblip\' (pickup is invalid)', 2) end
      blip = blip_types[type](pickup)
    elseif type == 'radius' then
      local coords, radius = data.coords, data.radius
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      if not radius then error('bad argument #2 to \'createblip\' (radius expected, got nil)', 2) end
      blip = blip_types[type](coords.x, coords.y, coords.z, radius)
    elseif type == 'race' then
      local coords = data.coords
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      blip = blip_types[type](coords.x, coords.y, coords.z)
    elseif type == 'route' then
      local coords = data.coords
      if not coords then error('bad argument #2 to \'createblip\' (coords expected, got nil)', 2) end
      blip = blip_types[type](coords.x, coords.y, coords.z)
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


  ---@enum blip_type_ids
  local blip_type_ids = {
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
  ---@return blip_type_ids
  local function get_blip_type(blip)
    if not Blips[blip] then
      local blip_type = GetBlipInfoIdType(blip)
      if does_blip_exist(blip) then
        Blips[blip] = {type = blip_type_ids[blip_type] or blip_type}
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

  ---@enum (key) blip_categories
  local blip_categories = {
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

  ---@enum (key) blip_displays
  local blip_displays = {
    none = 1,
    all_select = 2,
    pause_select = 3,
    radar_only = 5,
    fullbigmap_only = 7,
    all_noselect = 8,
    all_radar_only = 9
  }

  ---@param blip integer
  ---@param category blip_categories
  ---@param display blip_displays
  ---@param priority integer?
  local function set_blip_display(blip, category, display, priority)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipdisplay\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    SetBlipCategory(blip, blip_categories[category])
    SetBlipDisplay(blip, blip_displays[display])
    if priority then SetBlipPriority(blip, priority); Blips[blip].options.priority = priority end
    Blips[blip].options.category = category
    Blips[blip].options.display = display
  end

  ---@return promise?
  local function custom_flash_blip(blip, colour)
    if not does_blip_exist(blip) then error('bad argument #1 to \'customflashblip\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    if not Blips[blip].options.flashes then return end
    local colours = {Blips[blip].options.primary, colour}
    local interval = Blips[blip].options.flash_interval
    local duration = Blips[blip].options.flash_duration or -1
    Wait(0)
    local p = promise.new()
    CreateThread(function()
      local start = GetNetworkTimeAccurate()
      local i = 0
      repeat
        SetBlipColour(blip, colours[i % 2 + 1])
        Wait(interval)
        i += 1
      until duration > 0 and GetNetworkTimeAccurate() - start >= duration or not does_blip_exist(blip) or not Blips?[blip]?.options.flashes
      p:resolve()
    end)
    return p
  end

  ---@param blip integer
  ---@param flashes boolean
  ---@param interval integer?
  ---@param duration integer?
  ---@param colour integer?
  local function set_blip_flashes(blip, flashes, interval, duration, colour)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipflashes\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    if not flashes and not Blips[blip].options.flashes then return end
    if interval then
      if not colour then SetBlipFlashes(blip, flashes); SetBlipFlashInterval(blip, interval) end
      Blips[blip].options.flash_interval = interval
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
  ---@param creator boolean
  local function set_blip_as_creator(blip, creator)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipascreator\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    SetBlipAsMissionCreatorBlip(blip, creator)
    Blips[blip].options.creator = not creator and nil or {
      title = '',
      verified = false,
      image = '',
      rp = '',
      money = '',
      style = 1,
      data = {{}, {}, {}, {}, {}, {}} --[[5]]
    }
  end

  ---@param blip integer
  ---@param title string?
  ---@param verified boolean?
  local function set_blip_title(blip, title, verified, style)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setbliptitle\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    if title then Blips[blip].options.creator.title = title end
    if verified then Blips[blip].options.creator.verified = verified end
    if style then Blips[blip].options.creator.style = style end
  end

  ---@param blip integer
  ---@param image string|{resource: string, name: string}?
  local function set_blip_image(blip, image)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipimage\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    Blips[blip].options.creator.image = image or ''
  end

  ---@param blip integer
  ---@param rp string?
  ---@param money string?
  local function set_blip_economy(blip, rp, money)
    if not does_blip_exist(blip) then error('bad argument #1 to \'setblipeconomy\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    if rp then Blips[blip].options.creator.rp = rp end
    if money then Blips[blip].options.creator.money = money end
  end

  ---@param blip integer
  ---@param title string?
  ---@param text string?
  local function add_creator_text(blip, title, text)
    if not does_blip_exist(blip) then error('bad argument #1 to \'addcreatortext\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    local data = Blips[blip].options.creator.data
    title, text = title or '', text or ''
    data[text and text ~= '' and 1 or 5] = {title = title, text = text}
  end

  ---@param blip integer
  ---@param title string?
  ---@param text string?
  local function add_creator_name(blip, title, text)
    if not does_blip_exist(blip) then error('bad argument #1 to \'addcreatorbutton\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    local data = Blips[blip].options.creator.data
    title, text = title or '', text or ''
    data[3] = {title = title, text = text}
  end

  ---@param blip integer
  ---@param title string?
  ---@param text string?
  local function add_creator_header(blip, title, text)
    if not does_blip_exist(blip) then error('bad argument #1 to \'addcreatorbutton\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    local data = Blips[blip].options.creator.data
    title, text = title or '', text or ''
    data[4] = {title = title, text = text}
  end

  ---@param blip integer
  ---@param title string?
  ---@param text string?
  ---@param icon string?
  ---@param colour integer?
  ---@param checked boolean?
  local function add_creator_icon(blip, title, text, icon, colour, checked)
    if not does_blip_exist(blip) then error('bad argument #1 to \'addcreatoritem\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    local data = Blips[blip].options.creator.data
    title, text = title or '', text or ''
    data[2] = {title = title, text = text, icon = icon or '', colour = colour or 0, checked = checked or false}
  end

  ---@param blip integer
  ---@param title string?
  ---@param verified boolean?
  ---@param image string?
  ---@param rp string?
  ---@param money string?
  ---@param style integer?
  ---@param text {title: string, text: string}?
  ---@param name {title: string, text: string}?
  ---@param header {title: string, text: string}?
  ---@param icon {title: string, text: string, icon: string, colour: integer, checked: boolean}?
  ---@return integer blip
  local function init_creator_blip(blip, title, verified, image, rp, money, style, text, name, header, icon)
    if not does_blip_exist(blip) then error('bad argument #1 to \'initcreatorblip\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    if not Blips[blip]?.options.creator then set_blip_as_creator(blip, true) end
    set_blip_title(blip, title, verified, style)
    if image ~= '' then set_blip_image(blip, image) end
    set_blip_economy(blip, rp, money)
    if text then add_creator_text(blip, text.title, text.text) end
    if name then add_creator_name(blip, name.title, name.text) end
    if header then add_creator_header(blip, header.title, header.text) end
    if icon then add_creator_icon(blip, icon.title, icon.text, icon.icon, icon.colour, icon.checked) end
    return blip
  end

  ---@param blip integer
  ---@param interval integer
  ---@param callback fun(blip: integer): {title: string?, verified: boolean?, rp: string?, money: string?, image: (string|{resource: string, name: string})?, style: integer?, text: {title: string, text: string}?, name: {title: string, text: string}?, header: {title: string, text: string}?, icon: {title: string, text: string, icon: string, colour: integer, checked: boolean}?}
  ---@return promise p, fun() toggle, fun() updater, fun(new_callback: fun(blip: integer): {title: string?, verified: boolean?, rp: string?, money: string?, image: (string|{resource: string, name: string})?, style: integer?, text: {title: string, text: string}?, name: {title: string, text: string}?, header: {title: string, text: string}?, icon: {title: string, text: string, icon: string, colour: integer, checked: boolean}?}) update, fun(new_interval: integer, new_callback: fun(blip: integer): {title: string?, verified: boolean?, rp: string?, money: string?, image: (string|{resource: string, name: string})?, style: integer?, text: {title: string, text: string}?, name: {title: string, text: string}?, header: {title: string, text: string}?, icon: {title: string, text: string, icon: string, colour: integer, checked: boolean}?}) new
  local function create_blip_updater(blip, interval, callback)
    if not does_blip_exist(blip) then error('bad argument #1 to \'createblipupdater\' (blip `'..blip..'` doesn\'t exist)', 2) end
    init_blip(blip)
    Blips[blip].options = Blips[blip].options or {}
    local p = promise.new()
    local stop = false
    local function update()
      if stop then return end
      local data = callback(blip)
      if not data then return end
      if data.title then set_blip_title(blip, data.title, data.verified, data.style) end
      if data.image then set_blip_image(blip, data.image) end
      if data.rp or data.money then set_blip_economy(blip, data.rp, data.money) end
      if data.text then add_creator_text(blip, data.text.title, data.text.text) end
      if data.name then add_creator_name(blip, data.name.title, data.name.text) end
      if data.header then add_creator_header(blip, data.header.title, data.header.text) end
      if data.icon then add_creator_icon(blip, data.icon.title, data.icon.text, data.icon.icon, data.icon.colour, data.icon.checked) end
    end
    local function updater()
      update()
      p:resolve()
    end
    local function start_thread()
      return CreateThread(function()
        stop = false
        while not stop do
          update()
          Wait(interval)
        end
      end)
    end
    start_thread()
    return p, function()
      stop = not stop
    end, updater, function(new_callback)
      stop = true
      callback = new_callback
      start_thread()
    end,
    function(new_interval, new_callback)
      stop = true
      interval, callback = new_interval, new_callback
      start_thread()
    end
  end

  ---@param blip integer
  ---@return {title: string, verified: boolean, rp: string, money: string, image: string|{resource: string, name: string}, style: integer, data: {title: string, text: string, icon: string?, colour: integer?, checked: boolean?}[]}?
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
    setcreator = set_blip_as_creator,
    settitle = set_blip_title,
    setimage = set_blip_image,
    seteconomy = set_blip_economy,
    addtext = add_creator_text,
    addname = add_creator_name,
    addheader = add_creator_header,
    addicon = add_creator_icon,
    initcreator = init_creator_blip,
    createupdater = create_blip_updater,
    getcreator = get_creator_data
  }
end
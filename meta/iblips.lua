---@meta

---@class iblips
exports.iblips = {}

---@param blip_type BLIP_TYPES
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
---@param options blip_options
---@param creator_options blip_creator_options?
---@return integer blip
function exports.iblips:initblip(blip_type, data, options, creator_options) end

---@param type BLIP_TYPES
---@param data {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?}
---@return integer
function exports.iblips:create(type, data) end

---@param blip integer
---@return boolean removed
function exports.iblips:remove(blip) end

function exports.iblips:clear() end

---@param blip integer
---@return BLIP_TYPES
function exports.iblips:gettype(blip) end

---@param blip integer
---@return {coords: vector3|vector4?, width: number?, height: number?, entity: integer?, pickup: integer?, radius: number?} data
function exports.iblips:getdata(blip) end

---@param blip integer
---@param coords vector3
---@param heading number?
function exports.iblips:setcoords(blip, coords, heading) end

---@param blip integer
---@param category BLIP_CATEGORIES?
---@param display BLIP_DISPLAYS?
---@param priority integer?
function exports.iblips:setdisplay(blip, category, display, priority) end

---@param blip integer
---@param opacity integer?
---@param primary integer? See [HUD Colours](https://docs.fivem.net/docs/game-references/blips/#blip-colors).
---@param secondary vector3|{r: integer, g: integer, b: integer}? Changes the friend or crew indicator colour or the main colour of the blip if primary is set to `84`.
function exports.iblips:setcolours(blip, opacity, primary, secondary) end

---@param blip integer
---@param enable boolean
---@param time integer?
---@param duration integer?
---@param colour integer?
function exports.iblips:setflashes(blip, enable, time, duration, colour) end

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
function exports.iblips:setstyle(blip, sprite, scale, friendly, bright, hidden, high_detail, show_cone, short_range, shrink) end

---@param blip integer
---@param crew boolean?
---@param friend boolean?
---@param completed boolean?
---@param heading boolean?
---@param height boolean?
---@param count integer?
---@param outline boolean?
---@param tick boolean?
function exports.iblips:setindicators(blip, crew, friend, completed, heading, height, count, outline, tick) end

---@param blip integer
---@param name string
function exports.iblips:setname(blip, name) end

---@param blip integer
---@param distance number
function exports.iblips:setrange(blip, distance) end

---@param blip integer
---@param options blip_options
---@return integer blip
function exports.iblips:setoptions(blip, options) end

---@param blip integer
---@param time integer
---@param callback fun(blip: integer): blip_options
---@return fun(state: boolean?): state: boolean pause, fun() destroy, fun(new_interval: integer, new_callback: fun(blip: integer): blip_options) update
function exports.iblips:updater(blip, time, callback) end

---@param blip integer
---@param creator boolean
function exports.iblips:setcreator(blip, creator) end

---@param blip integer
---@param title string?
---@param verified VERIFIED_TYPES?
function exports.iblips:settitle(blip, title, verified) end

---@param blip integer
---@param image string|{resource: string, name: string, width: integer, height: integer}?
function exports.iblips:setimage(blip, image) end

---@param blip integer
---@param rp string?
---@param money string?
---@param ap string?
function exports.iblips:seteconomy(blip, rp, money, ap) end

---@param blip integer
---@param info {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: CREATOR_TYPES}
---@return integer blip
function exports.iblips:addinfo(blip, info) end

---@param blip integer
---@param key integer
---@param data {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: CREATOR_TYPES}
function exports.iblips:updateinfokey(blip, key, data) end

---@param blip integer
---@param data {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: CREATOR_TYPES}[]
function exports.iblips:setinfo(blip, data) end

---@param blip integer
---@param options blip_creator_options
---@return integer blip
function exports.iblips:setcreatoroptions(blip, options) end

---@param blip integer
---@return {title: string, verified: integer, rp: string, money: string, image: string|{resource: string, name: string, width: integer, height: integer}, ap: string, info: {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: CREATOR_TYPES}[]}?
function exports.iblips:getcreator(blip) end

---@param blip integer
---@param time integer
---@param callback fun(blip: integer): blip_creator_options
---@return fun(state: boolean?): state: boolean pause, fun() destroy, fun(new_interval: integer, new_callback: fun(blip: integer): blip_creator_options) update
function exports.iblips:creatorupdater(blip, time, callback) end

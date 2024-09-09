local duff = duff
local check_version = duff.checkversion
local RES_NAME <const> = GetCurrentResourceName()
local DEBUG_MODE <const> = duff._DEBUG

-------------------------------- FUNCTIONS --------------------------------

---@param text string
local function debug_print(text)
  if not DEBUG_MODE then return end
  print('^3[iblips]^7 - '..text)
end

---@param resource string
local function init_script(resource)
  if resource ~= RES_NAME then return end
  SetTimeout(2000, function()
    local version = GetResourceMetadata(RES_NAME, 'version', 0)
    check_version(resource, version, 'donhulieo')
  end)
end

-------------------------------- HANDLERS --------------------------------

AddEventHandler('onResourceStart', init_script)

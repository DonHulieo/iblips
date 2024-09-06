---@diagnostic disable-next-line: undefined-global
local ivec3 = ivec3 --[[@as fun(x: number, y: number, z: number): vector3]] -- Applies integer-casting rules to the input values
return {
  ['Jobs'] =  {
    {
      type = 'coord',
      data = {coords = vector3(-74.735076904297, -2033.3594970703, 15.7)},
      options = {
        name = 'Jobs.1.name',
        colours = {
          opacity = 150,
          primary = 1
        },
        display = {
          display = 'all_select',
          priority = 2
        },
        flashes = {
          enable = true,
          interval = 500,
          colour = 12
        },
        style = {
          sprite = 1,
          scale = 2.0,
          discoverable = false,
          friendly = false,
          bright = false,
          hidden = false,
          high_detail = false,
          show_cone = false,
          short_range = true,
          shrink = false
        },
        indicators = {
          crew = false,
          friend = false,
          completed = false,
          heading = false,
          height = false,
          count = false,
          outline = false,
          tick = false
        },
        jobs = {},
        items = {},
        distance = 250.0
      }
    },
  },
  ['Mission'] = {},
  ['Activity'] = {},
  ['Shops'] = {},
  ['Races'] = {},
  ['Property'] = {}
}
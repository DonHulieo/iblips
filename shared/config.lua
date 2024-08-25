---@diagnostic disable-next-line: undefined-global
local ivec3 = ivec3 --[[@as fun(x: number, y: number, z: number): vector3]] -- Applies integer-casting rules to the input values
return {
  ['Jobs'] =  {
    {
      name = 'test',
      type = 'coord',
      data = {coords = vector3(-74.735076904297, -2033.3594970703, 15.7)},
      options = {
        colours = {
          opacity = 150,
          primary = 1,
          secondary = false
        },
        display = 'all_select',
        priority = 2,
        sprite = 1,
        scale = 2.0,
        flashes = {
          enable = true,
          interval = 500,
          colour = 12
        },
        style = {
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
        items = {}
      },
      creator = {
        title = 'Test',
        verified = true,
        rp = '',
        money = '',
        image = 'ammunation_logo',
        style = 2,
        data = {
          text = {title = 'Text Title', text = 'Mmm Yes'},
          name = {title = 'Name Title', text = 'Name Mhhhm'},
          header = {title = 'Header Test', text = 'Tests Head'},
          icon = {title = 'Icon Title', text = 'Test my Icon', icon = 25, colour = 6, checked = true}
        }
      }
    },
  },
  ['Mission'] = {},
  ['Activity'] = {},
  ['Shops'] = {},
  ['Races'] = {},
  ['Property'] = {}
}
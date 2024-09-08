---@diagnostic disable-next-line: undefined-global
local ivec3 = ivec3 --[[@as fun(x: number, y: number, z: number): vector3]] -- Applies integer-casting rules to the input values
return {
  ---@type {['Jobs']: {type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
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
        distance = 250.0
      },
      creator = {
        title = 'Jobs.1.creator.title',
        verified = 'none',
        rp = '1000',
        money = '56',
        ap = '100',
        info = {
          {
            title = 'Jobs.1.creator.info.1.title',
            type = 0
          },
          {
            title = 'Jobs.1.creator.info.2.title',
            text = 'Jobs.1.creator.info.2.text',
            type = 1
          },
          {
            title = 'Jobs.1.creator.info.3.title',
            text = 'Jobs.1.creator.info.3.text',
            icon = 1,
            colour = 12,
            checked = true,
            type = 2
          },
          {
            title = 'Jobs.1.creator.info.4.title',
            text = 'Jobs.1.creator.info.4.text',
            crew = 'Jobs.1.creator.info.4.crew',
            is_social_club = false,
            type = 3
          },
          {
            title = 'Jobs.1.creator.info.5.title',
            text = 'Jobs.1.creator.info.5.text',
            type = 4
          },
          {
            text = 'Jobs.1.creator.info.6.text',
            type = 5
          }
        }
      }
    },
  },
  ---@type {['Mission']: {type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Mission'] = {},
  ---@type {['Activity']: {type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Activity'] = {},
  ---@type {['Shops']: {type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Shops'] = {},
  ---@type {['Races']: {type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Races'] = {},
  ---@type {['Property']: {type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Property'] = {},
  ---@type {['Other']: {type: BLIP_TYPES, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Other'] = {}
}
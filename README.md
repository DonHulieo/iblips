# Interactive Blips [iblips]

Don's Interactive Blips for FiveM.

## Description

This is a framework for creating interactive blips on the map, both static and dynamic. Using the MissionCreator Blip Scaleform, you can create UI prompts for the player to interact with the blips.

## Features

- Optimised Code, Resmon of 0~0.02ms. Peaking Whilst Initialising MissionCreator Blip Scaleform Prompts.
- Create Static Blips that are always visible on the map.
- Make Blips Dynamic, so they only appear when the player is close enough, alternate between colours or your own custom logic.
- Add MissionCreator Blip Scaleform prompts to the blips, allowing the player to interact with them.
<!-- [ ] Add All Exported Functions to the Documentation -->
<!-- [ ] Add All Enums to the Documentation -->
<!-- [ ] Make Discoverable blips that can be hidden until the player is close enough, and save whether the player has discovered them -->
<!-- [ ] Make Toggleable blips that can be turned on and off by the player -->

## Table of Contents

- [Interactive Blips \[iblips\]](#interactive-blips-iblips)
  - [Description](#description)
  - [Features](#features)
  - [Table of Contents](#table-of-contents)
    - [Preview](#preview)
    - [Installation](#installation)
      - [Dependencies](#dependencies)
      - [Initial Setup](#initial-setup)
    - [Configuration](#configuration)
      - [Shared](#shared)
    - [Documentation](#documentation)
      - [options](#options)
      - [creator options](#creator-options)
      - [Images](#images)
      - [initblip](#initblip)
      - [setoptions](#setoptions)
      - [setcreatordata](#setcreatordata)

### Preview

### Installation

#### Dependencies

**This script requires the following script to be installed:**

- [duff](https://github.com/DonHulieo/duff)

#### Initial Setup

- Always use the latest FiveM artifacts (tested on 7290), you can find them [here](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/).
- Download the latest version from releases.
- Extract the contents of the zip file into your resources folder, into a folder which starts before any script this is a dependency for, or;
- Ensure the script in your `server.cfg` before any script this is a dependency for.
- Configure `shared/config.lua` & `server/config.lua` to your liking, see [Configuration](#configuration) for more information.

### Configuration

#### Shared

```lua
{
  ---@type {['Jobs']: {type: blip_types, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Jobs'] =  {
    {
      type = 'coord',
      data = {
        coords = vector3(0.0, 0.0, 0.0),
        width = 100.0,
        height = 100.0
        entity = -1,
        pickup = -1,
        radius = 100.0
      },
      options = blip_options,
      creator = blip_creator_options
    },
  },
  ---@type {['Mission']: {type: blip_types, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Mission'] = {},
  ---@type {['Activity']: {type: blip_types, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Activity'] = {},
  ---@type {['Shops']: {type: blip_types, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Shops'] = {},
  ---@type {['Races']: {type: blip_types, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Races'] = {},
  ---@type {['Property']: {type: blip_types, data: {coords: vector3|vector4?, width: number?, height: number?, radius: number?}, options: blip_options, creator: blip_creator_options}[]}
  ['Property'] = {}
}
```

### Documentation

#### options

Options are the base configuration for a blip, this is where you define the blip's properties.

```lua
---@class blip_options
---@field name string?
---@field coords vector3|vector4?
---@field distance number?
---@field colours {opacity: integer?, primary: integer?, secondary: vector3|{r: integer, g: integer, b: integer}?}?
---@field display {category: BLIP_CATEGORIES, display: BLIP_DISPLAYS, priority: integer?}?
---@field flashes {enable: boolean, interval: integer?, duration: integer?, colour: integer?}?
---@field style {sprite: integer, scale: number|vector2, friendly: boolean?, bright: boolean?, hidden: boolean?, high_detail: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?}?
---@field indicators {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?}?
```

- `name` string?: The name of the blip, this is the display name of the blip.
- `coords` vector3|vector4?: The coordinates of the blip, this is where the blip will be displayed on the map.
- `distance` number?: The distance in which the blip will be visible from the player.
- `colours: {opacity: integer?, primary: integer?, secondary: vector3|{r: integer, g: integer, b: integer}?}?`:
  - `opacity` integer?: The opacity of the blip, this is how transparent the blip will be.
  - `primary` integer?: The primary colour of the blip, this is the main colour of the blip.
  - `secondary` vector3|{r: integer, g: integer, b: integer}?: The secondary colour of the blip, this is the secondary colour of the blip.
- `display: {category: BLIP_CATEGORIES, display: BLIP_DISPLAYS, priority: integer?}?`:
  - `category: BLIP_CATEGORIES:` The category of the blip, this is the category of the blip.
    - `nodist` The blip will not have a distance shown in the legend.
    - `dist` The blip will have a distance shown in the legend.
    - `jobs` The blip will be a job blip.
    - `myjobs` The blip will be a personal (mission) job blip.
    - `mission` The blip will be a mission blip.
    - `activity` The blip will be an activity blip.
    - `players` The blip will be a player blip.
    - `shops` The blip will be a shop blip.
    - `races` The blip will be a race blip.
    - `property` The blip will be a property blip.
    - `ownedproperty` The blip will be an owned property blip.
  - `display: BLIP_DISPLAYS:` The display of the blip, this is how the blip will be displayed.
    - `none` The blip will not be displayed.
    - `all_select` The blip is visible on the all the radar views and the map, and is also selectable.
    - `pause_select` The blip is visible on the pause screen map and is selectable.
    - `radar_only` The blip is viisible on the regular and big radar view only.
    - `full_bigmap_only` The blip is visible on the full big radar map only.
    - `all_noselect` The blip is visible on all the radar views and the map, but is not selectable.
    - `all_radar_only` The blip is visible on all the radar views.
  - `priority` integer?: The priority of the blip, this is the priority of the blip.
- `flashes: {enable: boolean, interval: integer?, duration: integer?, colour: integer?}?`:
  - `enable` boolean: Whether the blip will flash or not.
  - `interval` integer?: The interval in which the blip will flash.
  - `duration` integer?: The duration in which the blip will flash.
  - `colour` integer?: The colour of the blip when it flashes.
- `style: {sprite: integer, scale: number|vector2, friendly: boolean?, bright: boolean?, hidden: boolean?, high_detail: boolean?, show_cone: boolean?, short_range: boolean?, shrink: boolean?}?`:
  - `sprite` integer: The sprite of the blip, this is the icon of the blip.
  - `scale` number|vector2: The scale of the blip, this is the size of the blip.
  - `friendly` boolean?: Whether the blip is friendly or not.
  - `bright` boolean?: Whether the blip is bright or not.
  - `hidden` boolean?: Whether the blip is hidden or not.
  - `high_detail` boolean?: Whether the blip is high detail or not.
  - `show_cone` boolean?: Whether the blip shows a cone or not.
  - `short_range` boolean?: Whether the blip is short range or not.
  - `shrink` boolean?: Whether the blip will shrink or not.
- `indicators: {crew: boolean?, friend: boolean?, completed: boolean?, heading: boolean?, height: boolean?, count: integer?, outline: boolean?, tick: boolean?}?`:
  - `crew` boolean?: Whether the blip is a crew blip or not.
  - `friend` boolean?: Whether the blip is a friend blip or not.
  - `completed` boolean?: Whether the blip is a completed blip or not.
  - `heading` boolean?: Whether the blip shows the heading or not.
  - `height` boolean?: Whether the blip shows the height or not.
  - `count` integer?: The count of the blip.
  - `outline` boolean?: Whether the blip shows an outline or not.
  - `tick` boolean?: Whether the blip shows a tick or not.

```lua
options = {
  name = 'Blip Name',
  coords = vector3(0.0, 0.0, 0.0),
  distance = 100.0,
  colours = {
    opacity = 255,
    primary = 0,
    secondary = { r = 0, g = 0, b = 0 }
  },
  display = {
    category = 0,
    display = 0,
    priority = 0
  },
  flashes = {
    enable = false,
    interval = 1000,
    duration = 1000,
    colour = 0
  },
  style = {
    sprite = 1,
    scale = 1.0,
    friendly = false,
    bright = false,
    hidden = false,
    high_detail = false,
    show_cone = false,
    short_range = false,
    shrink = false
  },
  indicators = {
    crew = false,
    friend = false,
    completed = false,
    heading = false,
    height = false,
    count = 0,
    outline = false,
    tick = false
  }
}
```

#### creator options

Creator options are the configuration for the MissionCreator Blip Scaleform, this is where you define the blip's creator properties.

```lua
---@class blip_creator_options
---@field title string
---@field verified boolean
---@field image string|{resource: string, name: string, width: integer, height: integer}
---@field rp string
---@field money string
---@field ap string
---@field info: {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: integer}[]?
```

- `title` string: The title of the blip.
- `verified` boolean: Whether the blip has the rockstar verified badge or not.
- `image: string|{resource: string, name: string, width: integer, height: integer}:` The image name for the blip header. See [here](#images) for more information.
  - `resource` string: The resource the image is housed in.
  - `name` string: The file name of the image.
  - `width` integer: The width of the image.
  - `height` integer: The height of the image.
- `rp` string: The Rp count displayed on the blip.
- `money` string: The money count displayed on the blip.
- ap string: The Ap count displayed on the blip.
- `info: {title: string?, text: string?, icon: integer?, colour: integer?, checked: boolean?, crew: string?, is_social_club: boolean?, type: integer}[]?`:
  - `type` integer: The type of the info.
    - `0` The info is a title info with just a title.
    - `1` The info is a title and text info with a title and text.
    - `2` The info is an icon info with a colour and checkmark.
    - `3` The info is a player info with a crew tag or social club checkmark.
    - `4` The info is a header info (dividing line) with a title and text.
    - `5` The info is a text info with just text.
  - `title` string: The title text.
  - `text` string: The body text.
  - `icon` integer: The icon of the icon.
  - `colour` integer: The colour of the icon. See [here](https://docs.fivem.net/docs/game-references/blips/#blip-colors) for the blip colour ids.
  - `checked` boolean: Whether the icon has a checkmark or not.
  - `crew` string: The 4 character crew tag.
  - `is_social_club` boolean: Whether the entry has a social club checkmark or not.

```lua
creator_options = {
  title = 'Blip Title',
  verified = false,
  image = 'image.png',
  rp = 'RP',
  money = 'Money',
  ap = 'AP',
  info = {
    {
      title = 'This is a Plain Title',
      type = 0
    },
    {
      title = 'This is a Title',
      text = 'This is a Text',
      type = 1
    },
    {
      icon = 1,
      colour = 0,
      checked = false,
      type = 2
    },
    {
      crew = 'CREW',
      is_social_club = false,
      type = 3
    },
    {
      title = 'This is a Header',
      type = 4
    },
    {
      text = 'This is a Text',
      type = 5
    }
  }
}
```

#### Images

Each Creator Blip can have a header image, these can either be stored in this resource or another resource.

- If the image is stored in this resource;
  - The image should be placed in the `images` folder.
  - When setting the image, the image name is the file name (ie. `image`).
- If the image is stored in another resource;
  - The image should be placed in a folder in the top level of the resource called `images`.
  - When setting the image, pass a table with the resource name, the file name and optionally, width and height (ie. `{resource = 'resource', name = 'image', width = 128, height = 128}`).

#### initblip

A blip creation super function, this function will create a blip with the specified options.

```lua
---@param type blip_types
---@param data {coords: vector3|vector4?, width: number?, height: number?, radius: number?}
---@param options blip_options
---@param creator blip_creator_options?
---@return integer blip_id
export.iblips:initblip(type, data, options, creator)
```

- `type` blip_types: The type of the blip.
  - `area` The blip is an area blip.
  - `coord` The blip is a coordinate blip.
  - `entity` The blip is an entity blip.
  - `ped` The blip is a ped blip.
  - `vehicle` The blip is a vehicle blip.
  - `object` The blip is an object blip.
  - `pickup` The blip is a pickup blip.
  - `radius` The blip is a radius blip.
  - `race` The blip is a race gallery blip.
- `data` {coords: vector3|vector4?, width: number?, height: number?, radius: number?}: The data of the blip.
  - `coords` vector3|vector4?: The coordinates of the blip.
  - `width` number?: The width of the blip.
  - `height` number?: The height of the blip.
  - `radius` number?: The radius of the blip.
  - `entity` number?: The entity of the blip.
  - `pickup` number?: The pickup of the blip.
- `options` blip_options: The options of the blip. See [here](#options) for the options.
- `creator` blip_creator_options?: The creator options of the blip. See [here](#creator-options) for the creator options.
- `return` integer: The blip id of the blip.

#### setoptions

A blip options super function, this function will set the options of a blip.

```lua
---@param blip_id integer
---@param options blip_options
---@return integer blip_id
export.iblips:setoptions(blip_id, options)
```

- `blip_id` integer: The blip id of the blip.
- `options` blip_options: The options of the blip.
- `return` integer: The blip id of the blip.

#### setcreatordata

A blip creator data super function, this function will set the creator data of a blip.

```lua
---@param blip_id integer
---@param creator blip_creator_options
---@return integer blip_id
export.iblips:setcreatordata(blip_id, creator)
```

- `blip_id` integer: The blip id of the blip.
- `creator` blip_creator_options: The creator options of the blip. See [here](#creator-options) for the creator options.
- `return` integer: The blip id of the blip.

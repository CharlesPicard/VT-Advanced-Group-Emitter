local constants = require "scripts.constants"
local flib_data_util = require "__flib__.data-util"

local name = constants.ENTITY_NAME
local combi = flib_data_util.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], name)
combi.icon = "__vt-advanced-group-emitter__/graphics/icons/vt-advanced-group-emitter.png"
combi.icon_size = 64
combi.next_upgrade = nil
combi.fast_replaceable_group = "constant-combinator"
combi.sprites = make_4way_animation_from_spritesheet {
  layers = {
    {
      filename = "__vt-advanced-group-emitter__/graphics/entity/combinator/vt-advanced-group-emitter.png",
      scale = 1,
      width = 224, -- 7 tiles * 32px
      height = 224, -- 7 tiles * 32px
      shift = util.by_pixel(0, 0)
    },
    {
      filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
      scale = 1,
      width = 224,
      height = 224,
      shift = util.by_pixel(8.5, 5.5),
      draw_as_shadow = true
    }
  }
}

local combi_item = flib_data_util.copy_prototype(data.raw.item["constant-combinator"], name)
combi_item.icon = "__vt-advanced-group-emitter__/graphics/icons/vt-advanced-group-emitter.png"
combi_item.icon_size = 64
combi_item.subgroup = "logistic-network"
combi_item.place_result = name

local combi_recipe = flib_data_util.copy_prototype(data.raw.recipe["constant-combinator"], name)
combi_recipe.ingredients = {
  { type = "item", name = "radar", amount = 2 },
  { type = "item", name = "processing-unit", amount = 10 }
}
combi_recipe.enabled = false
combi_recipe.subgroup = "logistic-network"

if mods["nullius"] then
  combi.localised_name = { "entity-name." .. name }
  combi.minable.mining_time = 1
  combi_item.order = "nullius-eca-b"
  combi_item.localised_name = { "item-name." .. name }
  combi_recipe.order = "nullius-eca-b"
  combi_recipe.localised_name = { "recipe-name." .. name }
  combi_recipe.category = "tiny-crafting"
  combi_recipe.always_show_made_in = true
  combi_recipe.energy_required = 2
  combi_recipe.ingredients = {
    { "constant-combinator", 1 },
    { "decider-combinator", 1 }
  }
else
  combi_item.order = data.raw.item["constant-combinator"].order .. "-b"
  combi_recipe.order = data.raw.recipe["constant-combinator"].order .. "-b"
end

data:extend {
  combi,
  combi_item,
  combi_recipe
}
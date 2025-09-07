local entity = table.deepcopy(data.raw["constant-combinator"])
entity.type = "constant-combinator"
entity.name = "VT-advanced-group-emitter"
entity.collision_box = {{-0.35, -0.35}, {0.35, 0.35}}
entity.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
entity.minable = {mining_time = 0.1, results = {{type = "item", name = "VT-advanced-group-emitter", amount = 1}}}
entity.collision_mask = {layers = {item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true}}
entity.flags = {"placeable-neutral", "player-creation", "not-flammable"}
entity.icon = data.raw["constant-combinator"]["constant-combinator"].icon
entity.sprites = data.raw["constant-combinator"]["constant-combinator"].sprites
entity.activity_led_light_offsets = data.raw["constant-combinator"]["constant-combinator"].activity_led_light_offsets
entity.activity_led_sprites = data.raw["constant-combinator"]["constant-combinator"].activity_led_sprites
entity.circuit_wire_connection_points = data.raw["constant-combinator"]["constant-combinator"].circuit_wire_connection_points
entity.circuit_wire_max_distance = data.raw["constant-combinator"]["constant-combinator"].circuit_wire_max_distance

data:extend({entity})

local item = table.deepcopy(data.raw["item"]["constant-combinator"])
item.name = "VT-advanced-group-emitter"
item.place_result = "VT-advanced-group-emitter"
item.subgroup = "circuit-network"
item.order = "c[combinators]-d[VT-advanced-group-emitter]"
data:extend({item})

local recipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])
recipe.name = "VT-advanced-group-emitter"
recipe.enabled = true
recipe.subgroup = "circuit-network"
recipe.results = {{type = "item", name = "VT-advanced-group-emitter", amount = 1}}
data:extend({recipe})
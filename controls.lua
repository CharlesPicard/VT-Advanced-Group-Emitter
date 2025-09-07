--[[
    VT Advanced Group Emitter Control Script

    This script manages VT-advanced-group-emitter entities, updating their filters
    based on circuit network signals (both green and red wires) every 30 seconds.
    It handles entity creation, removal, and initialization events.
--]]

local VTAE_UPDATE_INTERVAL = 1800 -- 30 seconds in ticks
local vtae_tick_counter = 0 -- Counter for tick updates

-- Updates all VT-advanced-group-emitter combinators' filters from circuit signals
local function update_vtadvancedemitters()
    -- Iterate over all tracked combinators
    for _, vt_advanced_emitter in pairs(storage.VTAdvancedEmitters or {}) do
        if vt_advanced_emitter.valid then
            local behavior = vt_advanced_emitter.get_control_behavior()
            -- Get both green and red circuit networks
            local networks = {
                vt_advanced_emitter.get_circuit_network(defines.wire_connector_id.circuit_green),
                vt_advanced_emitter.get_circuit_network(defines.wire_connector_id.circuit_red)
            }

            if behavior ~= nil and behavior.sections_count > 0 then
                local section = behavior.get_section(1)
                if section.group ~= "" then
                    -- Reset filters before update
                    section.filters = {}

                    local new_filters = {}      -- List of filters to set
                    local filter_indices = {}  -- Map for quick lookup by signal key

                    -- Temporary table to sum signal counts per key
                    local signal_sums = {}

                    -- Aggregate signals from both networks
                    for _, network in ipairs(networks) do
                        if network and network.signals then
                            for _, net_signal in ipairs(network.signals) do
                                if net_signal.signal.name then
                                    local name = net_signal.signal.name
                                    local type = net_signal.signal.type or "item"
                                    local quality = net_signal.signal.quality or "normal"
                                    local filter_key = type .. "|" .. name .. "|" .. quality

                                    -- Sum signal counts per key, do not accumulate from previous updates
                                    signal_sums[filter_key] = (signal_sums[filter_key] or 0) + net_signal.count
                                end
                            end
                        end
                    end

                    -- Build filter list from summed signals
                    for filter_key, total_count in pairs(signal_sums) do
                        local type, name, quality = filter_key:match("([^|]+)|([^|]+)|([^|]+)")
                        table.insert(new_filters, {
                            value = {
                                comparator = "=",
                                type = type,
                                name = name,
                                quality = quality
                            },
                            min = total_count
                        })
                    end

                    -- Set the filters for the section
                    section.filters = new_filters
                end
            end
        end
    end
end

-- Called every tick; triggers update every LOG_GROUP_UPDATE_INTERVAL ticks
local function on_vtadvancedemitters_tick(event)
    vtae_tick_counter = vtae_tick_counter + 1
    if vtae_tick_counter >= VTAE_UPDATE_INTERVAL then
        update_vtadvancedemitters()
        vtae_tick_counter = 0
    end
end

-- Handles creation of VT-advanced-group-emitter entities
local function on_vtadvancedemitters_entity_created(event)
    local entity = event.created_entity or event.entity
    if entity and entity.valid then
        table.insert(storage.VTAdvancedEmitters, entity)
    end
end

-- Handles removal of VT-advanced-group-emitter entities
local function on_vtadvancedemitters_entity_removed(event)
    local vt_advanced_emitters = {}
    local entity = event.entity
    if entity and entity.valid then
        for _, vt_advanced_emitter in pairs(storage.VTAdvancedEmitters) do
            if vt_advanced_emitter ~= entity then
                table.insert(vt_advanced_emitters, vt_advanced_emitter)
            end
        end
    end
    storage.VTAdvancedEmitters = vt_advanced_emitters
end

do
    -- Initializes the list of VT-advanced-group-emitter combinators on all surfaces
    local function initialise_VTAdvancedEmitters()
        storage.VTAdvancedEmitters = {}

        for _, surface in pairs(game.surfaces) do
            local found_combinators = surface.find_entities_filtered{ name = {
                "VT-advanced-group-emitter",
            } }
            for _, combinator in pairs(found_combinators) do
                table.insert(storage.VTAdvancedEmitters, combinator)
            end
        end
    end

    -- Registers all relevant event handlers for entity creation/removal and ticking
    local function register_log_group_events()
        local entity_filter = {
            { filter="name", name="VT-advanced-group-emitter"},
        }
        script.on_event(defines.events.on_built_entity, on_vtadvancedemitters_entity_created, entity_filter)
        script.on_event(defines.events.on_robot_built_entity, on_vtadvancedemitters_entity_created, entity_filter)
        script.on_event(defines.events.script_raised_built, on_vtadvancedemitters_entity_created, entity_filter)
        script.on_event(defines.events.script_raised_revive, on_vtadvancedemitters_entity_created, entity_filter)
        script.on_event(defines.events.on_space_platform_built_entity, on_vtadvancedemitters_entity_created, entity_filter)
        script.on_event(defines.events.on_tick, on_vtadvancedemitters_tick)
        script.on_event(defines.events.on_player_mined_entity, on_vtadvancedemitters_entity_removed, entity_filter)
        script.on_event(defines.events.on_robot_mined_entity, on_vtadvancedemitters_entity_removed, entity_filter)
        script.on_event(defines.events.on_entity_died, on_vtadvancedemitters_entity_removed, entity_filter)
        script.on_event(defines.events.script_raised_destroy, on_vtadvancedemitters_entity_removed, entity_filter)
        script.on_event(defines.events.on_space_platform_mined_entity, on_vtadvancedemitters_entity_removed, entity_filter)
    end

    -- Register event handlers on load
    script.on_load(function()
        register_log_group_events()
    end)

    -- Initialize combinators and register events on init
    script.on_init(function()
        initialise_VTAdvancedEmitters()
        register_log_group_events()
    end)

    -- Re-initialize combinators and register events on configuration change
    script.on_configuration_changed(function(data)
        initialise_VTAdvancedEmitters()
        register_log_group_events()
    end)
end
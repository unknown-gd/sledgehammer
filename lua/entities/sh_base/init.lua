
---@class Entity
local ENTITY = FindMetaTable( "Entity" )
local ENTITY_Fire = ENTITY.Fire

---@class sh_base.Outputs
---@field entities string
---@field input string
---@field param string
---@field delay number
---@field times number

---@class sh_base : ENT
---@field m_Outputs table<string, sh_base.Outputs[]>
---@field Outputs table<string, boolean>
local ENT = ENT

ENT.Type = "point"

---@param key string
---@param activator Entity
---@param caller Entity
---@param value string
function ENT:AcceptInput( key, activator, caller, value )
    local fn = self[ "In" .. key ]
    if isfunction( fn ) then
        fn( self, activator, caller, value )
    end
end

---@param key string
---@param activator Entity
---@param value string | number | boolean
function ENT:FireOutput( key, activator, value )
    local handlers = self.Outputs
    if handlers == nil or handlers[ key ] == nil then
        return false
    end

    local events = self.m_Outputs
    if events == nil then
        return false
    end

    local outputs = events[ key ]
    if outputs == nil then
        return false
    end

    local count = outputs[ 0 ]
    if count == nil then
        return false
    end

    for i = count, 1, -1 do
        local output = outputs[ i ]

        ---@type Entity[]
        local targets

        ---@type integer
        local target_count = 0

        if output.entities == "!activator" then
            targets, target_count = { activator }, 1
        elseif output.entities == "!self" then
            targets, target_count = { self }, 1
        elseif output.entities == "!player" then
            targets = player.GetAll()
            target_count = #targets
        else
            targets = ents.FindByName( output.entities )
            target_count = #targets
        end

        for j = 1, target_count, 1 do
            ENTITY_Fire( targets[ j ], output.input, value or output.param, output.delay, activator, self )
        end

        local times = output.times
        if times ~= -1 then
            output.times = times - 1

            if times <= 0 then
                table.remove( outputs, i )
                count = count - 1
            end
        end
    end

    outputs[ 0 ] = count
    return true
end

ENT.FireInput = ENTITY_Fire

local metatable = {
    ---@param self table<string, sh_base.Outputs[]>
    ---@param key string
    __index = function( self, key )
        local lst = {}
        self[ key ] = lst
        return lst
    end
}

---@param key string
---@param value string
function ENT:KeyValue( key, value )
    local handlers = self.Outputs
    if handlers == nil or handlers[ key ] == nil then
        return false
    end

    local events = self.m_Outputs
    if events == nil then
        return false
    end

    local data = string.Explode( "\x1B", value )
	if #data < 2 then
        data = string.Explode( ",", value )
	end

    local outputs = events[ key ]
    if outputs == nil then
        outputs = { [ 0 ] = 0 }
        setmetatable( outputs, metatable )
        self.m_Outputs = outputs
    end

    local count = outputs[ 0 ] + 1

    outputs[ count ] = {
        entities = data[ 1 ] or "",
	    input = data[ 2 ] or "",
	    param = data[ 3 ] or "",
	    delay = tonumber( data[ 4 ], 10 ) or 0,
    	times = tonumber( data[ 5 ], 10 ) or -1
    }

    outputs[ 0 ] = count
    return true
end

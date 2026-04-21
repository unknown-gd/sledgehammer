---@alias sh_base.Value string | number | boolean

---@class sh_base.Outputs
---@field target string
---@field input string
---@field delay number
---@field value sh_base.Value
---@field repetitions integer

---@class sh_base : ENT
---@field private m_tOutputs table<string, sh_base.Outputs[]> | nil
local ENT = ENT

ENT.Type = "point"

---@class Entity
local ENTITY = FindMetaTable( "Entity" )
assert( ENTITY, "Failed to find Entity metatable!" )

local ENTITY_Fire = ENTITY.Fire

local string = string
local string_byte = string.byte

local isfunction = isfunction
local tonumber = tonumber

do

    local string_format = string.format
    local cvars_Number = cvars.Number
    local MsgC = MsgC

    local main = Color( 150, 150, 250 )
    local text = Color( 220, 220, 220 )

    local type_colors = {
        info = Color( 70, 135, 255 ),
        warn = Color( 255, 130, 90 ),
        error = Color( 250, 55, 40 ),
        debug = Color( 0, 200, 150 )
    }

    ---@alias sh_base.MessageType
    ---| "info"
    ---| "warn"
    ---| "error"
    ---| "debug"

    ---@param type sh_base.MessageType
    ---@param fmt string
    ---@param ... any
    function ENT:ConsoleMessage( type, fmt, ... )
        if type == "debug" and cvars_Number( "developer", 0 ) < 1 then return end
        MsgC( main, "[Sledgehammer/", type_colors[ type ] or color_white, string.upper( type ) .. "] ", text, string_format( fmt, ... ), "\n" )
    end

end

---@param str string
---@return boolean
local function isInput( str )
    local b1, b2 = string_byte( str, 1, 2 )
    return b1 == 0x49 --[[ I ]] and b2 == 0x6E --[[ n ]]
end

---@param str string
---@return boolean
local function isOutput( str )
    local b1, b2, b3 = string_byte( str, 1, 3 )
    return ( b1 == 0x4F --[[ O ]] and b2 == 0x75 --[[ u ]] and b3 == 0x74 --[[ t ]] ) or
        ( b1 == 0x4F --[[ O ]] and b2 == 0x6E --[[ n ]] )
end

---@param str string
---@return boolean
local function isKeyValue( str )
    return not ( isInput( str ) or isOutput( str ) )
end

---@param key string
---@param activator Entity
---@param caller Entity
---@param value string
function ENT:AcceptInput( key, activator, caller, value )
    if not isInput( key ) then
        self:ConsoleMessage( "error", "'%s' received an invalid input key '%s', from '%s' by '%s'", self, key, activator, caller )
        return
    end

    local fn = self[ key ]
    if isfunction( fn ) then
        fn( self, activator, caller, value )
    else
        self:ConsoleMessage( "warn", "'%s' left input '%s' unhandled from '%s' by '%s", self, key, activator, caller )
    end
end

do

    local player_Iterator = player.Iterator

    ---@param entity Entity
    ---@param output sh_base.Outputs
    ---@param value sh_base.Value
    ---@param activator Entity
    ---@param caller Entity
    local function preform_output( entity, output, value, activator, caller )
        ENTITY_Fire( entity, output.input, value or output.value, output.delay, activator, caller )
    end

    ---@param key string
    ---@param activator Entity
    ---@param value sh_base.Value
    function ENT:FireOutput( key, activator, value )
        if not isOutput( key ) then
            error( "Output key '" .. key .. "' must start with 'On' or 'Out'", 2 )
        end

        local fn = self[ key ]
        if isfunction( fn ) then
            value = fn( self, activator, value ) or value
        end

        local events = self.m_tOutputs
        if events == nil then
            return false
        end

        local outputs = events[ key ]
        if outputs == nil then
            return false
        end

        local count = outputs[ 0 ] or 0
        if count == 0 then
            return false
        end

        for i = count, 1, -1 do
            local output = outputs[ i ]

            if output.target == "!activator" then
                preform_output( activator, output, value, activator, self )
            elseif output.target == "!self" then
                preform_output( self, output, value, activator, self )
            elseif output.target == "!player" then
                for _, pl in player_Iterator() do
                    preform_output( pl, output, value, activator, self )
                end
            else
                local entities = ents.FindByName( output.target )
                for j = 1, #entities, 1 do
                    preform_output( entities[ j ], output, value, activator, self )
                end
            end

            local repetitions = output.repetitions
            if repetitions ~= -1 then
                output.repetitions = repetitions - 1

                if repetitions <= 0 then
                    table.remove( outputs, i )
                    count = count - 1
                end
            end
        end

        outputs[ 0 ] = count
        return true
    end

end

ENT.GetValue = ENTITY.GetInternalVariable
ENT.SetValue = ENTITY.SetKeyValue
ENT.FireInput = ENTITY_Fire

do

    local string_sub = string.sub
    local string_len = string.len

    ---@param str string
    ---@param byte integer
    ---@param length integer
    ---@param limit integer
    ---@return string[]
    ---@return integer
    local function fast_split( str, byte, length, limit )
        ---@type string[]
        local values = {}

        ---@type integer
        local value_count = 0

        local split_position = 0
        local index = 1

        ::byte_split_loop::

        if string_byte( str, index, index ) == byte then
            if split_position ~= index then
                value_count = value_count + 1
                values[ value_count ] = string_sub( str, split_position + 1, index - 1 )
            end

            split_position = index
        end

        if value_count == limit then
            return values, value_count
        end

        if index ~= length then
            index = index + 1
            goto byte_split_loop
        end

        if split_position ~= index then
            value_count = value_count + 1
            values[ value_count ] = string_sub( str, split_position + 1, index )
        end

        return values, value_count
    end

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
        if isOutput( key ) then
            local events = self.m_tOutputs
            if events == nil then
                return false
            end

            local value_length = string_len( value )

            local values, value_count = fast_split( value, 0x1B, value_length, 5 )
            if value_count < 2 then
                values, value_count = fast_split( value, 0x2C, value_length, 5 )
            end

            local outputs = events[ key ]
            if outputs == nil then
                outputs = { [ 0 ] = 0 }
                setmetatable( outputs, metatable )
                self.m_tOutputs = outputs
            end

            local count = outputs[ 0 ] + 1

            outputs[ count ] = {
                target = values[ 1 ] or "",
                input = values[ 2 ] or "",
                value = values[ 3 ] or "",
                delay = tonumber( values[ 4 ], 10 ) or 0,
                repetitions = tonumber( values[ 5 ], 10 ) or -1
            }

            outputs[ 0 ] = count
            return true
        end

        if isKeyValue( key ) then
            local fn = self[ "KeyValue_" .. key ]
            if isfunction( fn ) then
                fn( self, value )
            end

            return false
        end

        self:ConsoleMessage( "error", "'%s' received an invalid key-value key '%s' with value '%s'", self, key, value )
        return true
    end

end

do

    local string_match = string.match
    local Vector = Vector
    local Angle = Angle
    local Color = Color

    function ENT.toVector( str )
        local x, y, z = string_match( str, "^(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)$" )
        return Vector( tonumber( x or 0, 10 ) or 0, tonumber( y or 0, 10 ) or 0, tonumber( z or 0, 10 ) or 0 )
    end

    function ENT.toAngle( str )
        local p, y, r = string_match( str, "^(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)$" )
        return Angle( ( tonumber( p or 0, 10 ) or 0 ) % 360, ( tonumber( y or 0, 10 ) or 0 ) % 360, ( tonumber( r or 0, 10 ) or 0 ) % 360 )
    end

    function ENT.toColor( str )
        local r, g, b, a = string_match( str, "^(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)$" )
        return Color( ( tonumber( r or 0, 10 ) or 0 ) % 255, ( tonumber( g or 0, 10 ) or 0 ) % 255, ( tonumber( b or 0, 10 ) or 0 ) % 255, ( tonumber( a or 0, 10 ) or 255 ) % 255 )
    end

end

local function toNumber( str, default )
    return tonumber( str, 10 ) or default
end

ENT.toNumber = toNumber

function ENT.toInteger( str, default )
    return math.floor( toNumber( str, default ) )
end

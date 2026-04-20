---@class sh_server_command : sh_base
local ENT = ENT

ENT.Base = "sh_base"

function ENT:InExecute( activator, _, value )
    RunConsoleCommand( tostring( value ) )
end

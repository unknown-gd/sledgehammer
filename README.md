# Sledgehammer

A collection of entities that can be used to modify the game in various ways.

Mostly useful for map making in hummer.

## Entities

### `sh_chat`

Chat manipulation entity, allows you to send messages as specific players.

Inputs:

- `InSendMessage` - sends a message as activator (works for players only)

Outputs:

- `OnMessage` - receive messages from players ( activator: player, value: string )
- `OnTeamMessage` - receive team messages from players ( activator: player, value: string )

### `sh_client_command`

Runs a command on the client ( activator )

Inputs:

- `InExecute` - runs a command on the client ( works for players only )

### `sh_server_command`

Runs a command on the server

Inputs:

- `InExecute` - runs a command on the server

### `sh_gravity`

Sets the gravity of the map

Inputs:

- `InDirection` - changes the direction of gravity ( default: `0 0 -1` )
- `InForce` - changes the force of gravity ( default: `600` )

Key-Values:

- `direction` - the direction of gravity ( default: `0 0 -1` )
- `force` - the force of gravity ( default: `600` )

#### `sh_entity_setup`

Sets up an entity ( activator )

Inputs:

- `InSetup` - sets up an entity ( activator )

Key-Values:

- `entity_name` - the new name ( `target_name` ) of the entity ( e.g. `my_cool_name` )
- `model_path` - the new model of the entity ( e.g. `models/props_c17/oildrum001.mdl` )
- `model_material` - the new material path of the entity ( e.g. `materials/models/props_c17/oildrum001` )
- `model_scale` - the new scale of the entity ( e.g. `0.25`, 1/4 of the original size )
- `model_skin` - the new skin of the entity ( e.g. `1`, the second skin of the model (0-...) )
- `model_bodygroups` - the new bodygroups of the entity ( e.g. `0000001` )
- `model_color` - the new color of the entity ( e.g. `255 0 0 255` )
- `position` - the new position of the entity ( e.g. `-111 12.21 0.11` )
- `angles` - the new angles of the entity ( e.g. `0 90 30`, pitch, yaw, roll )
- `parent_name` - the new parent name of the entity ( e.g. `my_cool_parent_name` )
- `collision_group` - the new [COLLISION_GROUP](https://wiki.facepunch.com/gmod/Enums/COLLISION_GROUP) of the entity ( e.g. `0`, the default collision group )
- `move_type` - the new [MOVETYPE](https://wiki.facepunch.com/gmod/Enums/MOVETYPE) of the entity ( e.g. `0`, the default move type )
- `health` - the new health of the entity ( e.g. `100` )
- `max_health` - the new max health of the entity ( e.g. `100` )
- `phys_mass` - the new mass of the entity ( e.g. `100` in kg )
- `phys_buoyancy` - the new buoyancy of the entity ( e.g. `0`, 0 is not buoyant at all (like a rock), and 1 is very buoyant (like wood) )
- `phys_flags` - the new [FVPHYSICS](https://wiki.facepunch.com/gmod/Enums/FVPHYSICS) of the entity ( e.g. `512`, colliding with entities will cause 1000 dissolve damage to the entity )
- `phys_material` - the new [material type](https://developer.valvesoftware.com/wiki/Material_surface_properties) of the entity ( e.g. `Rock` )
- `phys_gravity` - the new gravity of the entity ( e.g. `0`, where `0` is no gravity ( flying in air ), and `1` is normal gravity )
- `phys_collision` - the new collision of the entity ( e.g. `0`, where `0` is no collision ( does not collide with anything ), and `1` is normal collision )
- `phys_motion` - the new motion of the entity ( e.g. `0`, where `0` is static ( does not move/freeze ), and `1` is allows motion )

local arrestLocation = vector3( 1761.49, 2474.7, 49.69 )
local hospitalLocationnorth = vector3( -263.45, 6319.01, 32.40 )
local hospitalLocationsouth = vector3( 312.2, -581.17, 43.28 )
local hospitalLocation

local prisoners = {}
local hospitalizations = {}

--[[function GetPlayerName( player )
    return exports.sample_util:GetPlayerName( player )
end]]--

local function JailCommand( player, args, raw )
	if args[1] == nil or args[2] == nil then
        -- TODO Notify

        return
    end

    local target = tonumber( args[1] )
    local time = tonumber( args[2] )

    if exports["sample_util"]:IsCop( player ) then
        Arrest( target, player, time )
    end
end

RegisterCommand( "jail", JailCommand )

local function HospitalizeCommand( player, args, raw )
    if args[1] == nil or args[2] == nil then
        -- TODO Notify

        return
    end

    local target = tonumber( args[1] )
    local time = tonumber( args[2] )

    if exports["sample_util"]:IsCop( player ) or exports["sample_util"]:IsFire( player ) then
        Hospitalize( target, player, time )
    end
end

RegisterCommand( "hospitalize", HospitalizeCommand )
RegisterCommand( "hosp", HospitalizeCommand )

local function ReleaseCommand( player, args, raw )
    if args[1] == nil then
        -- TODO notify
        return
    end

    if exports["sample_util"]:IsCop( player ) then
        local target = tonumber( args[1] )
        if prisoners[target] then
            ReleasePrisoner( target )
        end

        if hospitalizations[target] then
            ReleasePatient( target )
        end
    end
end

RegisterCommand( "release", ReleaseCommand )
RegisterCommand( "unjail", ReleaseCommand )
RegisterCommand( "unhosp", ReleaseCommand )
RegisterCommand( "unhospitalize", ReleaseCommand )

Citizen.CreateThread( function() 
    while true do
        local timer = GetGameTimer()
		if GlobalState.Aop == 'Southern Map' then
			hospitalLocation = hospitalLocationsouth
        elseif GlobalState.Aop == 'Northern Map' then
			hospitalLocation = hospitalLocationnorth
        else
            hospitalLocation = hospitalLocationnorth
		end

        for k, v in pairs( prisoners ) do
            if v < timer then
                ReleasePrisoner( k )
            else
                local p = GetPlayerPed( k )
                local c = GetEntityCoords( p )

                if #( c - arrestLocation ) > 100 then
                    SetEntityCoords( p, arrestLocation )
                end
            end
        end

        for k, v in pairs( hospitalizations ) do
            if v < timer then
                ReleasePatient( k )
            else
                local p = GetPlayerPed( k )
                local c = GetEntityCoords( p )

                if #( c - hospitalLocation ) > 100 then
                    SetEntityCoords( p, hospitalLocation )
                end
            end
        end

        Citizen.Wait( 250 )
    end
end )

function Arrest( player, cop, time )
    time = math.floor( time )
    time = math.clamp( time, 0, 1000 )

    hospitalizations[player] = nil
    prisoners[player] = GetGameTimer() + ( time * 1000 )

    Player( player ).state.arrested = true
    Player( player ).state.hospitalized = false
    Player( player ).state.releaseTime = prisoners[player]

    TriggerClientEvent( "sample_jail:Admitted", player, time )
    local p = GetPlayerPed( player )
    SetEntityCoords( p, arrestLocation )

	local eID = getEntityID(player)
	 
    TriggerClientEvent( "chat:addMessage", -1, {
        args = { "^1JAIL ^0| " .. GetPlayerName( player ) .. " has been arrested by " .. GetPlayerName( cop ) .. " for " .. time .. " seconds" }
    } )

    local content = {
        username = "Jail Logs",
        content = GetPlayerName( player ) .. " [" .. player .. "] was arrested by " .. GetPlayerName( cop ) .. " [" .. cop .. "] for " .. time .. " seconds." 
    }

    exports.sample_util:FireWebhook( 'Jail / Hospital Logs', content )
end

function Hospitalize( player, cop, time )
    time = math.floor( time )
    time = math.clamp( time, 0, 1000 )

    prisoners[player] = nil
    hospitalizations[player] = GetGameTimer() + ( time * 1000 )

    Player( player ).state.arrested = false
    Player( player ).state.hospitalized = true
    Player( player ).state.releaseTime = hospitalizations[player]

    TriggerClientEvent( "sample_jail:Admitted", player, time )

    local p = GetPlayerPed( player )
    SetEntityCoords( p, hospitalLocation )

    TriggerClientEvent( "chat:addMessage", -1, {
        args = { "^5HOSPITAL ^0| " .. GetPlayerName( player ) .. " has been hospitalized by " .. GetPlayerName( cop ) .. " for " .. time .. " seconds" }
    } )

    
    local content = {
        username = "Hospital Logs",
        content = GetPlayerName( player ) .. " [" .. player .. "] was hospitalized by " .. GetPlayerName( cop ) .. " [" .. cop .. "] for " .. time .. " seconds." 
    }

    exports.sample_util:FireWebhook( 'Jail / Hospital Logs', content )
end

function ReleasePrisoner( player )
    Player( player ).state.arrested = false
    Player( player ).state.hospitalized = false
    Player( player ).state.admittedAt = nil
    Player( player ).state.releaseTime = nil

    prisoners[player] = nil
    TriggerClientEvent( "sample_jail:SpawnOut", player )

    TriggerClientEvent( "chat:addMessage", -1, {
        args = { "^1JAIL ^0| " .. GetPlayerName( player ) .. " has been released from jail." }
    } )
end

function ReleasePatient( player )
    Player( player ).state.arrested = false
    Player( player ).state.hospitalized = false
    Player( player ).state.admittedAt = nil
    Player( player ).state.releaseTime = nil

    hospitalizations[player] = nil
    TriggerClientEvent( "sample_jail:Spawn", player )

    TriggerClientEvent( "chat:addMessage", -1, {
        args = { "^5HOSPITAL ^0| " .. GetPlayerName( player ) .. " has been released from the hospital." }
    } )
end

function math.clamp( number, min, max )
    if number > max then return max end
    if number < min then return min end
    return number
end

function getEntityID(player)
    local ped = GetPlayerPed(player);
    local pedId = NetworkGetNetworkIdFromEntity(ped);
    local entity = pedId
	
	return entity
end

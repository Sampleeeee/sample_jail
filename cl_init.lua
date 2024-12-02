RegisterNetEvent( "sample_jail:Spawn", function()
    exports["spawnmanager"]:spawnPlayer()
	--SetEntityCoords(PlayerPedId(), 1837.34, 2589.32, 46.01)
end )

RegisterNetEvent( "sample_jail:SpawnOut", function()
	SetEntityCoords(PlayerPedId(), 1837.34, 2589.32, 46.01)
end )

local releasedAt = nil
RegisterNetEvent( "sample_jail:Admitted", function( time )
    releasedAt = GetNetworkTime() + time
	DoScreenFadeOut(0)
	Wait(2000)
	DoScreenFadeIn(1000)
    Citizen.CreateThread( function() 
        while true do
            print "still in loop"
            if LocalPlayer.state.arrested or LocalPlayer.state.hospitalized then
                if releasedAt ~= nil then
                    local timeLeft = math.floor( ( releasedAt - GetNetworkTime() ) / 1000 )
        
                    if timeLeft > 0 then
						print("You are " .. ( LocalPlayer.state.arrested and "arrested" or "hospitalized" ) .. ".\nYou will be released in " .. timeLeft .. " seconds")
                        DrawTxt( "You are " .. ( LocalPlayer.state.arrested and "arrested" or "hospitalized" ) .. ".\nYou will be released in " .. timeLeft .. " seconds" )
                    else print( "breaking", timeLeft ) break end
                end
            else print "breaking2" break end
    
            Citizen.Wait( 0 )
        end
    end )
end )





function DrawTxt(text)
    SetTextFont( 4 )
    SetTextProportional(0)
    local scale = 0.4
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextJustification(0)
    SetTextEntry("STRING")
    AddTextComponentString(text)

    DrawText(0.5, 0.2)
end
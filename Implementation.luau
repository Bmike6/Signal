--!strict
local signal=require(script.Parent.ScriptUtillites.Signal)
local oldPlayers=0



local onPlayerAdded = signal.new(function(plr:Player, timeJoined:number) end, {_wait= function(plr:Player):Player
	return plr
end})


onPlayerAdded:connect(function(plr, timeOfJoin)
	print(plr, "joined at "..timeOfJoin)
end)



task.spawn(function()
	while task.wait() do
		if oldPlayers<#game.Players:GetPlayers() then
			onPlayerAdded:fire(game.Players:GetPlayers()[oldPlayers+1], tick())
			oldPlayers+=1
		end
	end
end)

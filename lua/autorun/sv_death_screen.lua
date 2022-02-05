if SERVER then

CreateConVar("sv_respawntime", "30", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE} , "How long time a player have to wait until he respawns.")
CreateConVar("sv_autorespawn_enabled", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE} , "How long time a player have to wait until he respawns.")
CreateConVar("sv_deathscreen_enabled", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Turn this addon on and off.")
CreateConVar("sv_deathscreen_text", "Вы мертвы", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Edit the text that is displayed after death.")

local DARKRP = false
local function checkGamemode()
    if gmod.GetGamemode().Name ~= "DarkRP" then
		DARKRP = false
	else
	    DARKRP = true
	end
end
hook.Add("Initialize", "checkGamemodeDrawHUD", checkGamemode)

--Local vars
local maxdeathtime = 10
local defaultString = "Вы мертвы"

local deathsystem_autorespawn = false
local deathsystem_instantrespawn = false

--Network strings
util.AddNetworkString("enableDrawBlurEffect")
util.AddNetworkString("disableDrawBlurEffect")

--Initialize death
local function initializeCustomThinkDeath(ply, wep, killer)
    if ConVarExists("sv_autorespawn_enabled") then
	    deathsystem_autorespawn = GetConVar("sv_autorespawn_enabled"):GetBool()
	else
	    deathsystem_autorespawn = false
	end

	local deathtime = 0
	if ConVarExists("sv_respawntime") then
	    deathtime = GetConVar("sv_respawntime"):GetInt()
	    if (GetConVar("sv_respawntime"):GetInt() == 0) then
		    deathsystem_instantrespawn = true
		else
		    deathsystem_instantrespawn = false
		end
	else
	    deathtime = maxdeathtime
	end
	
	if (ConVarExists("sv_deathscreen_enabled")) then
	    if (GetConVar("sv_deathscreen_enabled"):GetBool() == true) then
		print("hi")
        net.Start("enableDrawBlurEffect")
	    net.WriteType(true)
	    net.WriteType(deathsystem_autorespawn)
		net.WriteType(deathsystem_instantrespawn)
	    if (ConVarExists("sv_deathscreen_text")) then
		    net.WriteString(GetConVar("sv_deathscreen_text"):GetString())
        else
            net.WriteString(defaultString)
	    end
	    net.Send(ply)
	    end
	end
	
    ply.nextspawn = CurTime() + deathtime
	--ply:SetNWString("deathWeapon", wep:GetName())
	--ply:SetNWString("deathKiller", "killer:Nick()")
	ply.drp_jobswitch = false;
end
hook.Add("PlayerDeath", "initializeCustomThinkDeath", initializeCustomThinkDeath);

local function initializeCustomThinkSilentDeath(ply, wep, killer)
	local deathtime = 0
	if ConVarExists("sv_respawntime") then
	    deathtime = GetConVar("sv_respawntime"):GetInt()
	else
	    deathtime = maxdeathtime
	end
	
    ply.nextspawn = CurTime() + deathtime
	ply.drp_jobswitch = true;
end
hook.Add("PlayerSilentDeath", "initializeCustomThinkSilentDeath", initializeCustomThinkSilentDeath)

local function dev_customThinkDeath(ply)
	--Check if spawn
	if (ConVarExists("sv_deathscreen_enabled")) then
	    if (GetConVar("sv_deathscreen_enabled"):GetBool() == true) then
	        if (deathsystem_instantrespawn == false and ply.drp_jobswitch == false) then
	            ply:SetNWFloat("deathTimeLeft", ply.nextspawn - CurTime())
	            if (CurTime() >= ply.nextspawn + 1) then
				    if (deathsystem_autorespawn == true) then
					    ply:Spawn()
	                    ply.nextspawn = math.huge
					end
	            else
	                return false
	            end
			end
	    end
	end
end
hook.Add("PlayerDeathThink", "dev_customThinkDeath", dev_customThinkDeath)

--Player spawn hook
local function dev_customPlayerSpawn(ply)
    net.Start("disableDrawBlurEffect")
	net.WriteType(false)
	net.Send(ply)
end
hook.Add("PlayerSpawn", "dev_customPlayerSpawn", dev_customPlayerSpawn)

end


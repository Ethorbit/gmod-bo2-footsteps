-- Created by Ethorbit primarily for the nZombies gamemode
-- Thanks to TheDoorMatt655 for porting all the sounds
local BO2Footsteps = CreateClientConVar("bo2_footsteps", "1", true, false, "Whether or not to replace Gmod footsteps with BO2 sounds")
local BO2FootstepSndLevel = CreateClientConVar("bo2_fs_level", "0.3", true, false, "The audio level the footsteps play at", 0, 1)
local snds = {}
local function MakeSnds(maxnum) -- Make integers in a random order from 0-maxnum (This is so sounds are random but don't repeat)
    local startingnums = {}
    local num = maxnum
    while num >= 0 do
        table.insert(startingnums, num)
        num = num - 1
    end

    for k,v in RandomPairs(startingnums) do
        table.insert(snds, v)
    end
end

local function ResetSnds(maxnum)
    table.Empty(snds)
    MakeSnds(maxnum)
end

local playedAlready = ""
local oldProp = ""
local function GetStepSound(preString, maxnum, surfaceProp) 
    -- Reset sounds upon certain conditions so sounds don't fail or repeat:
    if oldProp != surfaceProp then
        oldProp = surfaceProp
        ResetSnds(maxnum)
    end   

    if table.IsEmpty(snds) then MakeSnds(maxnum) end
    
    local guy = game.SinglePlayer() and Entity(1) or LocalPlayer()
    if curAction == "sprint" && !guy:IsSprinting() then ResetSnds(maxnum) end 
    if curAction == "walk" && guy:IsSprinting() then ResetSnds(maxnum) end 
    if snds[1] == playedAlready then 
        ResetSnds(maxnum) 
    end 
    -------------------------------------------------------------------------
    local sound = "bo2/footsteps/" .. preString .. "_0" .. snds[1] .. ".wav" -- To reduce on copy pasting
    return sound
end

local rocks = {"concrete", "boulder", "brick", "rock", "baserock", "asphalt", "default", "tile"}
local footstepDelay = CurTime() + 0.1
hook.Add("PlayerFootstep", "BO2Footstep", function(ply, pos, foot, sound, volume)
    if (BO2Footsteps:GetInt() < 1) then 
        ply:EmitSound(sound, 75, 100, GetConVar("bo2_fs_level"):GetFloat()) 
    return end

    local footTrace = util.TraceLine({
        start = ply:GetPos(),
        endpos = ply:GetPos() + Vector(0, 0, -30),
        filter = ply
    })

    if footTrace.Hit then
        local surfaceProp = util.GetSurfacePropName(footTrace.SurfaceProps)
        local snd = nil
        curAction = ply:IsSprinting() and "sprint" or "walk"
        if table.HasValue(rocks, surfaceProp) then snd = ply:IsSprinting() and GetStepSound("concrete/concrete_sprint", 4, surfaceProp) or GetStepSound("concrete/concrete_run", 5, surfaceProp) end
        if surfaceProp == "carpet" then snd = ply:IsSprinting() and GetStepSound("carpet/carpet_sprint", 4, surfaceProp) or GetStepSound("carpet/carpet_run", 6, surfaceProp) end
        if surfaceProp == "dirt" then snd = ply:IsSprinting() and GetStepSound("dirt/dirt_sprint", 2, surfaceProp) or GetStepSound("dirt/dirt_run", 3, surfaceProp) end
        if surfaceProp == "grass" then snd = ply:IsSprinting() and GetStepSound("grass/grass_sprint", 4, surfaceProp) or GetStepSound("grass/grass_run", 4, surfaceProp) end
        if surfaceProp == "metalgrate" then snd = ply:IsSprinting() and GetStepSound("grate/mtl_grate_step", 3, surfaceProp) or GetStepSound("grate/mtl_grate_step_walk", 3, surfaceProp) end
        if string.find(surfaceProp, "metal") && surfaceProp != "metalgrate" then snd = ply:IsSprinting() and GetStepSound("metal/metal_sprint", 4, surfaceProp) or GetStepSound("metal/metal_run", 4, surfaceProp) end
        if surfaceProp == "mud" then snd = ply:IsSprinting() and GetStepSound("mud/mud_walk", 3, surfaceProp) or GetStepSound("mud/mud_run", 3, surfaceProp) end
        if string.find(surfaceProp, "sand") then snd = ply:IsSprinting() and GetStepSound("sand/sand_sprint", 5, surfaceProp) or GetStepSound("sand/sand_run", 3, surfaceProp) end
        if surfaceProp == "snow" then snd = ply:IsSprinting() and GetStepSound("snow/snow_run", 4, surfaceProp) or GetStepSound("snow/snow_walk", 4, surfaceProp) end
        if string.find(surfaceProp, "wood") then snd = ply:IsSprinting() and GetStepSound("wood/wood_sprint", 4, surfaceProp) or GetStepSound("wood/wood_run", 5, surfaceProp) end
        if string.find(surfaceProp, "ice") then snd = ply:IsSprinting() and GetStepSound("ice/ice_run", 3, surfaceProp) or GetStepSound("ice/ice_run", 3, surfaceProp) end

        local guy = game.SinglePlayer() and ply or LocalPlayer()
        if guy:WaterLevel() >= 1 then return false end 
        if snd and CurTime() < footstepDelay then return true end
        footstepDelay = CurTime() + 0.1

        if !snd then volume = 1.0 return false end
        if snd then 
            if snds[1] then      
                ply:EmitSound(snd, 75, 100, BO2FootstepSndLevel:GetFloat()) 
                playedAlready = snds[1]
                table.remove(snds, 1)
            end
        return true end
    end
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ==========================================
-- CONFIGURATION
-- ==========================================
-- Put the names of the 2 specific NPCs here
local TARGET_NPCS = {"White Boss", "Muscle Boss"} 
local DETECTION_RANGE = 500 -- Max distance to look for them

-- ==========================================
-- LOOP
-- ==========================================
RunService.Heartbeat:Connect(function()
    local character = player.Character
    
    -- Ensure your character and its root part exist
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
        
        local closestNPC = nil
        local shortestDistance = math.huge -- Start with an infinitely large distance
        
        -- Loop through the names in our target list
        for _, npcName in ipairs(TARGET_NPCS) do
            local targetNPC = workspace:FindFirstChild(npcName)
            
            -- If the NPC exists in the workspace
            if targetNPC and targetNPC:FindFirstChild("HumanoidRootPart") then
                
                -- Calculate distance to this specific NPC
                local distance = (character.HumanoidRootPart.Position - targetNPC.HumanoidRootPart.Position).Magnitude
                
                -- If this NPC is the closest one we've found so far, save it
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestNPC = targetNPC
                end
            end
        end
        
        -- If we found an NPC and they are within our detection range, walk to them
        if closestNPC and shortestDistance <= DETECTION_RANGE then
            character.Humanoid:MoveTo(closestNPC.HumanoidRootPart.Position)
        end
        
    end
end)

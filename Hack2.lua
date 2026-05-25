local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================
-- CONFIGURATION
-- ==========================================
local NPC_NAME = "White Boss" -- Change to your NPC's exact name
local DETECTION_RANGE = 500 -- Distance to start walking towards the NPC
local CLICK_RANGE = 10 -- Distance to trigger the tap
local CLICK_COOLDOWN = 0.5 -- How often to tap in seconds (prevents lag)

local lastClickTime = 0

-- ==========================================
-- LOOP
-- ==========================================
RunService.Heartbeat:Connect(function()
    local character = player.Character
    
    -- Ensure your character and its root part exist
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
        
        -- Look for the NPC directly in the Workspace
        local targetNPC = workspace:FindFirstChild(NPC_NAME)
        
        if targetNPC and targetNPC:FindFirstChild("HumanoidRootPart") then
            -- Calculate distance between you and the NPC
            local distance = (character.HumanoidRootPart.Position - targetNPC.HumanoidRootPart.Position).Magnitude
            
            -- If the NPC is close enough, walk to it
            if distance <= DETECTION_RANGE then
                character.Humanoid:MoveTo(targetNPC.HumanoidRootPart.Position)
                
                -- If we are within striking range, trigger the center screen tap
                if distance <= CLICK_RANGE then
                    
                    if tick() - lastClickTime >= CLICK_COOLDOWN then
                        lastClickTime = tick()
                        
                        -- Calculate the exact middle of the screen
                        local viewport = camera.ViewportSize
                        local centerX = viewport.X / 2
                        local centerY = viewport.Y / 2
                        
                        -- Simulate Finger Touch Down (State 0)
                        VirtualInputManager:SendTouchEvent(1, 0, centerX, centerY)
                        
                        -- Wait a tiny fraction of a second
                        task.wait(0.05)
                        
                        -- Simulate Finger Lift Off (State 2)
                        VirtualInputManager:SendTouchEvent(1, 2, centerX, centerY)
                    end
                end
            end
        end
    end
end)

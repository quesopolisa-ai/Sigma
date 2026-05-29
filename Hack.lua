-- ==========================================
-- CONFIGURATION
-- ==========================================
local PART_NAME = "str15ic" -- CHANGE THIS to the exact name of the part!

-- ==========================================
-- 1. RESET ONCE AT THE START
-- ==========================================
local player = game:GetService("Players").LocalPlayer
if player and player.Character then
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0 -- Resets the character
    else
        player.Character:BreakJoints() -- Fallback reset method
    end
end

-- Safely waits for your character to fully respawn before starting the loops
print("[Script] Waiting for respawn...")
player.CharacterAdded:Wait()
task.wait(1) -- Extra safety cushion for your character to fully load in
print("[Script] Respawn complete. Launching both loops.")

-- ==========================================
-- 2. THE LOOP BRING PART (Runs in Background)
-- ==========================================
local RunService = game:GetService("RunService")

local function findTarget()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == PART_NAME then
            return obj
        end
    end
    return nil
end

-- Anti-lag guard: stops old bring loops if you re-execute
local scriptId = os.clock()
_G.CurrentBringScript = scriptId

task.spawn(function()
    print("[Loop Bring] Active and searching for: " .. PART_NAME)
    
    while _G.CurrentBringScript == scriptId do
        task.wait() -- Ultra-fast yield to keep your game stable
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            local targetPart = findTarget()
            if targetPart then
                -- Teleports the part exactly 3 studs in front of your character
                targetPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
                
                -- Freezes physics velocity to stop the server from rubber-banding it away
                targetPart.AssemblyLinearVelocity = Vector3.zero
                targetPart.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end)

-- ==========================================
-- 3. THE PERSISTENT BOSS LOOP (With Delays)
-- ==========================================
print("[Boss Loop] Persistent loop started.")
while true do
    -- Spawn the White Boss
    game:GetService("ReplicatedStorage").BossSpawnRequest:FireServer("White Boss")
    task.wait(2)
    
end

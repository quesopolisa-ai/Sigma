-- ==========================================
-- CONFIGURATION
-- ==========================================
local PART_NAME = "str15ic"      -- Exact name of the part to bring
local BOSS_NAME = "White Boss"   -- Exact name of the boss model
local SAFE_DISTANCE = 100        -- How many studs away you must be to allow a new spawn

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
task.wait(1) 
print("[Script] Respawn complete. Launching loops.")

-- ==========================================
-- 2. THE LOOP BRING PART (Background Thread)
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

local scriptId = os.clock()
_G.CurrentBringScript = scriptId

task.spawn(function()
    print("[Loop Bring] Active and searching for: " .. PART_NAME)
    
    while _G.CurrentBringScript == scriptId do
        task.wait() 
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            local targetPart = findTarget()
            if targetPart then
                targetPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
                targetPart.AssemblyLinearVelocity = Vector3.zero
                targetPart.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end)

-- ==========================================
-- 3. PROXIMITY CHECKER
-- ==========================================
local function isBossNearby()
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then 
        return false 
    end

    -- Scan workspace for the boss
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == BOSS_NAME and obj:IsA("Model") then
            local bossRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if bossRoot then
                -- Calculate distance between you and the boss
                local distance = (rootPart.Position - bossRoot.Position).Magnitude
                if distance <= SAFE_DISTANCE then
                    return true -- Boss is too close!
                end
            end
        end
    end
    return false -- No boss found nearby
end

-- ==========================================
-- 4. THE PERSISTENT BOSS LOOP
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bossRemote = ReplicatedStorage:WaitForChild("BossSpawnRequest")
local cooldownRemote = ReplicatedStorage:WaitForChild("CooldownReady")

local canSpawnBoss = true

-- Listen for the server cooldown
cooldownRemote.OnClientEvent:Connect(function()
    canSpawnBoss = true
end)

print("[Boss Loop] Persistent loop started with Cooldown & Proximity Validation.")
while true do
    -- Only spawn if cooldown is ready AND the boss isn't already breathing down your neck
    if canSpawnBoss and not isBossNearby() then
        canSpawnBoss = false 
        bossRemote:FireServer(BOSS_NAME)
    end
    
    task.wait(0.1) -- Slightly slower loop here prevents CPU throttle while checking distance
end

-- ==========================================
-- CONFIGURATION
-- ==========================================
local PART_NAME = "str15ic"      -- Exact name of the part to bring
local BOSS_NAME = "White Boss"   -- Exact name of the boss model
local NEXT_BOSS = "Muscle Boss"  -- Next boss to spawn upon victory
local BLOCK_DISTANCE = 250       -- Block the remote if within this many studs
local AUTO_WALK = true           -- Set to false to disable auto-walking to the boss
local AUTO_WALK_RADIUS = 1000    -- The stud area/range to start auto-walking to the closest boss

-- ==========================================
-- 1. INITIALIZATION & SAFETY RESET
-- ==========================================
local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if player and player.Character then
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0 
    else
        player.Character:BreakJoints() 
    end
end

print("[System] Waiting for initial character asset replication...")
player.CharacterAdded:Wait()
task.wait(1.5) -- Safe synchronization cushion
print("[System] Environment stable. Initializing automation pipelines.")

-- Resolve Network Remotes
local bossRemote = ReplicatedStorage:WaitForChild("BossSpawnRequest", 15)
local cooldownRemote = ReplicatedStorage:WaitForChild("CooldownReady", 15)

-- Global State Machine
local scriptId = os.clock()
_G.CurrentBringScript = scriptId
local canSpawnBoss = true

if cooldownRemote then
    cooldownRemote.OnClientEvent:Connect(function()
        canSpawnBoss = true
    end)
end

-- ==========================================
-- HELPER FUNCTIONS (Optimized Scanners)
-- ==========================================
local function findNPCTarget()
    local containers = {
        workspace,
        workspace:FindFirstChild("NPCs"),
        workspace:FindFirstChild("Enemies"),
        workspace:FindFirstChild("Characters")
    }

    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                    local targetPart = obj:FindFirstChild(PART_NAME)
                    if targetPart and targetPart:IsA("BasePart") then
                        return targetPart
                    end
                end
            end
        end
    end
    return nil
end

-- Scans for BOTH bosses and returns whichever single one is currently closest
local function getAbsoluteClosestBossRoot(playerRoot)
    local closestDistance = math.huge
    local closestRoot = nil

    for _, obj in ipairs(workspace:GetChildren()) do
        -- Match either the primary boss or the secondary boss
        if (obj.Name == BOSS_NAME or obj.Name == NEXT_BOSS) and obj:IsA("Model") then
            local bossRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if bossRoot then
                local distance = (playerRoot.Position - bossRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestRoot = bossRoot
                end
            end
        end
    end
    
    return closestRoot, closestDistance
end

local function isBossNearby()
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    -- Check if ANY boss configuration is within blocking range
    local bossRoot, distance = getAbsoluteClosestBossRoot(rootPart)
    if bossRoot and distance <= BLOCK_DISTANCE then
        return true 
    end
    return false 
end

-- ==========================================
-- Thread A: THE LOOP BRING SERVICE (0 Delay)
-- ==========================================
task.spawn(function()
    print("[Pipeline A] Loop Bring engine online.")
    while _G.CurrentBringScript == scriptId do
        task.wait() 
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            local targetPart = findNPCTarget()
            if targetPart then
                targetPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
                targetPart.AssemblyLinearVelocity = Vector3.zero
                targetPart.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end)

-- ==========================================
-- Thread B: PROGRESSIVE BOSS TRACKING (Health Event Hook)
-- ==========================================
task.spawn(function()
    print("[Pipeline B] Boss Lifespan Observation engine online.")
    
    while _G.CurrentBringScript == scriptId do
        task.wait(0.5) 
        local whiteBoss = workspace:FindFirstChild(BOSS_NAME)
        
        if whiteBoss and bossRemote then
            local humanoid = whiteBoss:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                humanoid.Died:Wait()
                print("[Event] " .. BOSS_NAME .. " cleared. Waiting 3 seconds before challenge evolution sequence.")
                
                task.wait(3)
                pcall(function()
                    bossRemote:FireServer(NEXT_BOSS)
                end)
                task.wait(4) 
            elseif not humanoid then
                while whiteBoss.Parent == workspace do
                    task.wait(0.1)
                end
                print("[Event] " .. BOSS_NAME .. " structural deletion noted. Waiting 3 seconds before escalating threat vector.")
                
                task.wait(3)
                pcall(function()
                    bossRemote:FireServer(NEXT_BOSS)
                end)
                task.wait(4)
            end
        end
    end
end)

-- ==========================================
-- Thread C: MASTER INVOCATION REPEATER (0.05s Gated Spawn)
-- ==========================================
task.spawn(function()
    print("[Pipeline C] Main remote dispatch channel open.")
    if not bossRemote then
        warn("[Fatal] Target Remote Event unresolved. Halting invocation loop.")
        return
    end

    while _G.CurrentBringScript == scriptId do
        if canSpawnBoss and not isBossNearby() then
            canSpawnBoss = false 
            pcall(function()
                bossRemote:FireServer(BOSS_NAME)
            end)
        end
        task.wait(0.05) 
    end
end)

-- ==========================================
-- Thread D: MULTI-TARGET AUTO-WALK ENGINE (Closest Active Target)
-- ==========================================
task.spawn(function()
    print("[Pipeline D] Multi-Target Auto-Walk system active.")
    while _G.CurrentBringScript == scriptId do
        task.wait(0.2)
        if AUTO_WALK then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and playerRoot then
                -- Finds the overall closest target between White Boss and Muscle Boss
                local bossRoot, distance = getAbsoluteClosestBossRoot(playerRoot)
                
                -- Pathfind to it if it falls inside our stud perimeter
                if bossRoot and distance <= AUTO_WALK_RADIUS then
                    humanoid:MoveTo(bossRoot.Position)
                end
            end
        end
    end
end)

print("[Success] All automated layers running concurrently without lock contention.")

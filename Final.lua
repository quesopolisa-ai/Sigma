local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

-- We wrap the core script AND the 3 external scripts inside the string
local scriptString = [[
    -- ==========================================
    -- 1. EXECUTE YOUR 3 EXTERNAL SCRIPTS
    -- ==========================================
    -- We use task.spawn and pcall so if one script crashes or takes a long time to load, 
    -- it won't break the auto-rejoin script or stop the other scripts from running.

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
    -- 2. AUTO-REJOIN LOGIC
    -- ==========================================
    local TeleportService = game:GetService("TeleportService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")

    local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' then
            task.wait(2)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        end
    end)
]]

-- Function to run the logic and queue it for the next server hop
local function applyScriptsAndRejoin()
    -- 1. Queue this exact same file to run again in the next server
    if queue_on_teleport then
        local recursiveCode = "local queue_on_teleport = queue_on_teleport or queueonteleport\nlocal scriptString = [[" .. scriptString .. "]]\n loadstring(scriptString)()\n queue_on_teleport(scriptString)"
        queue_on_teleport(recursiveCode)
    end
    
    -- 2. Run the script for the current server
    loadstring(scriptString)()
end

-- Execute everything
applyScriptsAndRejoin()

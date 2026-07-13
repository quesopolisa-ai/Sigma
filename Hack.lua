-- ==========================================
-- 5. BOSS DEATH TRACKER (White Boss -> Muscle Boss)
-- ==========================================
task.spawn(function()
    print("[Boss Tracker] Active. Waiting for White Boss to spawn and die...")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local spawnRemote = ReplicatedStorage:WaitForChild("BossSpawnRequest")

    while true do
        task.wait(0.5) -- Scan every half-second so it doesn't cause lag
        
        -- Look for the White Boss
        local whiteBoss = workspace:FindFirstChild("White Boss")
        
        if whiteBoss then
            local humanoid = whiteBoss:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                -- Yields (pauses) this specific thread until the health hits exactly 0
                humanoid.Died:Wait()
                
                print("[Boss Tracker] White Boss defeated! Spawning Muscle Boss.")
                
                pcall(function()
                    spawnRemote:FireServer("Muscle Boss")
                end)
                
                -- Wait a few seconds before scanning again so it doesn't double-fire 
                -- if the corpse takes a moment to disappear from the map.
                task.wait(3) 
            elseif not humanoid then
                -- Fallback: If the game doesn't use a standard Humanoid, wait for the boss model to despawn
                while whiteBoss.Parent do
                    task.wait(0.1)
                end
                
                print("[Boss Tracker] White Boss removed! Spawning Muscle Boss.")
                pcall(function()
                    spawnRemote:FireServer("Muscle Boss")
                end)
                
                task.wait(3)
            end
        end
    end
end)

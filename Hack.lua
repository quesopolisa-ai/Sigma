while true do
    -- 1. Spawn the White Boss immediately at the start of the loop
    local args1 = {
        [1] = "White Boss"
    }
    game:GetService("ReplicatedStorage").BossSpawnRequest:FireServer(unpack(args1))
    
    -- 2. Wait 2 seconds
    task.wait(2)
    
    -- 3. Spawn the Muscle Boss
    local args2 = {
        [1] = "Muscle Boss"
    }
    game:GetService("ReplicatedStorage").BossSpawnRequest:FireServer(unpack(args2))
    
    -- 4. Wait 20 seconds so the entire loop cycle takes exactly 22 seconds total
    task.wait(20)
end

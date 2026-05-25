while true do
    -- 1. Spawn the White Boss immediately at the start of the loop
    local args1 = {
        [1] = "White Boss"
    }
    game:GetService("ReplicatedStorage").BossSpawnRequest:FireServer(unpack(args1))
    

    -- 4. Wait 20 seconds so the entire loop cycle takes exactly 22 seconds total
    task.wait(2)
end

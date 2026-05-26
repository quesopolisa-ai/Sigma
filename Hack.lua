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

-- Wait 3 seconds for your character to respawn before starting the loop
task.wait(3)

-- ==========================================
-- 2. THE PERSISTENT BOSS LOOP (2s Cycle)
-- ==========================================
while true do
    -- Spawn the White Boss immediately
    local args1 = {
        [1] = "White Boss"
    }
    game:GetService("ReplicatedStorage").BossSpawnRequest:FireServer(unpack(args1))

    -- Wait 2 seconds to finish the 2 second cycle
    task.wait(2)
end

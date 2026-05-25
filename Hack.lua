_G.autotp = true;
        while _G.autotp == true do

local args = {
    [1] = "White Boss"
}

game:GetService("ReplicatedStorage").BossSpawnRequest:FireServer(unpack(args))

       wait(2)
end

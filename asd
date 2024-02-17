local http_request = syn and syn.request or request
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

local beta = http_request({
    Url = "https://raw.githubusercontent.com/jelqmaster/beta/main/testers",
    Method = 'GET'
})

local tester = beta and beta.Body or ""
local testerTable = {}

for entry in tester:gmatch("[^\r\n]+") do
    table.insert(testerTable, entry)
end

local isTester = table.find(testerTable, HWID) ~= nil

if isTester then
    local site = workspace.__THINGS.Instances[TP].Teleports.Enter
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = site.CFrame
    getgenv().Config = {}
    repeat
        task.wait()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:connect(
            function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        )
    until game:IsLoaded()

    local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Library.lua'))()
    Library.Theme = "Dark"
    local Flags = Library.Flags

    local Window = Library:Window({
        Text = "Lenut Auto Dig (Beta)"
    })

    local Tab = Window:Tab({
        Text = "Main"
    })

    local Tab2 = Window:Tab({
        Text = "Misc"
    })

    local Section = Tab:Section({
        Text = "Advanced"
    })

    local Section2 = Tab:Section({
        Text = "Normal"
    })

    local Section3 = Tab:Section({
        Text = "Advanced Auto Shovels"
    })

    local Section4 = Tab:Section({
        Text = "Orbs"
    })

    local Section5 = Tab:Section({
        Text = "Hidden Presents"
    })

    local Section6 = Tab2:Section({
        Text = "AntiIDLE"
    })

    local heartbeatConnection = nil

    local function toggleAutoDig(v)
        Config.autoDig = v
        if not v and heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        elseif v and not heartbeatConnection then
            spawn(autoDig)
        end
    end
    
    Section:Button({
        Text = "TP Mining Area",
        Callback = function()
            advancedTP()
        end
    })

    Section:Toggle({
        Text = "Auto Dig",
        Callback = toggleAutoDig
    })

    Section:Input({
        Text = "Digsite Start Level (3-128)",
        Callback = function(level)
            selectedLayer = tonumber(level)
        end
     })

    Section3:Toggle({
        Text = "Farm & Buy All",
        Callback = function(v)
            Config.autoShovel1 = v
            spawn(autoShovel1)
        end
    })

    Section3:Toggle({
        Text = "Farm & Buy Amethyst",
        Callback = function(v)
            Config.autoShovel2 = v
            spawn(autoShovel2)
        end
    })

    Section3:Input({
        Text = "Farm Layer Limit",
        Callback = function(threshold)
            layerLimit = tonumber(threshold)
        end
    })

    Section4:Toggle({
        Text = "Auto Collect Orbs",
        Callback = function(v)
            Config.autoOrbs = v
            spawn(autoOrbs)
        end
    })

    Section5:Toggle({
        Text = "Auto Hidden Presents",
        Callback = function(v)
            Config.presentHunter = v
            spawn(presentHunter)
        end
    })

    local heartbeatConnection2 = nil

    local function toggleAutoDig2(v)
        Config.autoDig2 = v
        if not v and heartbeatConnection2 then
            heartbeatConnection2:Disconnect()
            heartbeatConnection2 = nil
        elseif v and not heartbeatConnection2 then
            spawn(autoDig2)
        end
    end
     
    Section2:Button({
        Text = "TP Mining Area",
        Callback = function()
            normalTP()
        end
    })

    Section2:Toggle({
        Text = "Auto Dig",
        Callback = toggleAutoDig2
    })
 
    Section2:Input({
        Text = "Digsite Start Level (3-128)",
        Callback = function(level)
            selectedLayerN = tonumber(level)
        end
    })

    Section6:Button({
        Text = "AntiAFK",
        Callback = function()
            antiAFK()
        end
    })

    Tab:Select()

    function advancedTP()
        local n = workspace.__THINGS.Instances.AdvancedDigsite.Teleports.Enter
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = n.CFrame
    end

    function normalTP()
        local n = workspace.__THINGS.Instances.Digsite.Teleports.Enter
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = n.CFrame
    end

    function antiAFK()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        while task.wait() do
            VirtualInputManager:SendKeyEvent(true, "Space", false, game)
            task.wait(.2)
            VirtualInputManager:SendKeyEvent(false, "Space", false, game)
            task.wait(300)
        end
    end

    function autoDig()
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        
        local lp = Players.LocalPlayer

        getgenv().targetLayer = selectedLayer

        local function onHeartbeat()
            if not Config.autoDig then return end
            local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
            if h then h:ChangeState(14) end
        
            local foundBlockOrChest = false
        
            if getgenv().targetLayer > 1 then
                local deepestBlock = nil
                for _, v in pairs(game.Workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedDigsite.Important.ActiveBlocks:GetChildren()) do
                    if v:IsA("Part") and v.BrickColor ~= BrickColor.new("Royal purple") and v.BrickColor ~= BrickColor.new("Really black") then
                        deepestBlock = deepestBlock or v
                        if v:GetAttribute("Coord").Y > deepestBlock:GetAttribute("Coord").Y then
                            deepestBlock = v
                        end
                    end
                end
        
                if deepestBlock and deepestBlock:GetAttribute("Coord").Y < getgenv().targetLayer then
                    lp.Character.HumanoidRootPart.CFrame = deepestBlock.CFrame + Vector3.new(1, 7, 0)
                    local args = {
                        [1] = "AdvancedDigsite",
                        [2] = "DigBlock",
                        [3] = Vector3.new(deepestBlock:GetAttribute("Coord").X, deepestBlock:GetAttribute("Coord").Y, deepestBlock:GetAttribute("Coord").Z)
                    }
                    ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                    foundBlockOrChest = true
                end
            end
        
            if not foundBlockOrChest then
                local currentBlock, currentChest = nil, nil
        
                for _, v in pairs(game.Workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedDigsite.Important.ActiveChests:GetDescendants()) do
                    if v.Name == "Bottom" then
                        currentChest = v
                        break
                    end
                end
        
                if currentChest then
                    lp.Character.HumanoidRootPart.CFrame = currentChest.CFrame + Vector3.new(1, 1, 0)
                    local args = {
                        [1] = "AdvancedDigsite",
                        [2] = "DigChest",
                        [3] = currentChest.Parent:GetAttribute("Coord")
                    }
                    ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                    Config.autoDig = false
                    task.wait(0.5)
                    Config.autoDig = true
                else
                    for _, v in pairs(game.Workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedDigsite.Important.ActiveBlocks:GetChildren()) do
                        if v:IsA("Part") and v:GetAttribute("Coord").Y == getgenv().targetLayer and v.BrickColor ~= BrickColor.new("Royal purple") and v.BrickColor ~= BrickColor.new("Really black") then
                            currentBlock = v
                            break
                        end
                    end
        
                    if currentBlock then
                        lp.Character.HumanoidRootPart.CFrame = currentBlock.CFrame + Vector3.new(1, 7, 0)
                        local args = {
                            [1] = "AdvancedDigsite",
                            [2] = "DigBlock",
                            [3] = currentBlock:GetAttribute("Coord")
                        }
                        ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                    else
                        getgenv().targetLayer = getgenv().targetLayer + 1
                    end
                end
            end
        end
        heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)        
    end

    function autoDig2()
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        
        local lp = Players.LocalPlayer

        getgenv().targetLayer = selectedLayerN

        local function onHeartbeat()
            if not Config.autoDig2 then return end
            local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
            if h then h:ChangeState(14) end
        
            local foundBlockOrChest = false
        
            if getgenv().targetLayer > 1 then
                local deepestBlock = nil
                for _, v in pairs(game.Workspace.__THINGS.__INSTANCE_CONTAINER.Active.Digsite.Important.ActiveBlocks:GetChildren()) do
                    if v:IsA("Part") and v.BrickColor ~= BrickColor.new("Royal purple") and v.BrickColor ~= BrickColor.new("Really black") then
                        deepestBlock = deepestBlock or v
                        if v:GetAttribute("Coord").Y > deepestBlock:GetAttribute("Coord").Y then
                            deepestBlock = v
                        end
                    end
                end
        
                if deepestBlock and deepestBlock:GetAttribute("Coord").Y < getgenv().targetLayer then
                    lp.Character.HumanoidRootPart.CFrame = deepestBlock.CFrame + Vector3.new(1, 7, 0)
                    local args = {
                        [1] = "Digsite",
                        [2] = "DigBlock",
                        [3] = Vector3.new(deepestBlock:GetAttribute("Coord").X, deepestBlock:GetAttribute("Coord").Y, deepestBlock:GetAttribute("Coord").Z)
                    }
                    ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                    foundBlockOrChest = true
                end
            end
        
            if not foundBlockOrChest then
                local currentBlock, currentChest = nil, nil
        
                for _, v in pairs(game.Workspace.__THINGS.__INSTANCE_CONTAINER.Active.Digsite.Important.ActiveChests:GetDescendants()) do
                    if v.Name == "Bottom" then
                        currentChest = v
                        break
                    end
                end
        
                if currentChest then
                    lp.Character.HumanoidRootPart.CFrame = currentChest.CFrame + Vector3.new(1, 1, 0)
                    local args = {
                        [1] = "Digsite",
                        [2] = "DigChest",
                        [3] = currentChest.Parent:GetAttribute("Coord")
                    }
                    ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                    Config.autoDig2 = false
                    task.wait(0.5)
                    Config.autoDig2 = true
                else
                    for _, v in pairs(game.Workspace.__THINGS.__INSTANCE_CONTAINER.Active.Digsite.Important.ActiveBlocks:GetChildren()) do
                        if v:IsA("Part") and v:GetAttribute("Coord").Y == getgenv().targetLayer and v.BrickColor ~= BrickColor.new("Royal purple") and v.BrickColor ~= BrickColor.new("Really black") then
                            currentBlock = v
                            break
                        end
                    end
        
                    if currentBlock then
                        lp.Character.HumanoidRootPart.CFrame = currentBlock.CFrame + Vector3.new(1, 7, 0)
                        local args = {
                            [1] = "Digsite",
                            [2] = "DigBlock",
                            [3] = currentBlock:GetAttribute("Coord")
                        }
                        ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                    else
                        getgenv().targetLayer = getgenv().targetLayer + 1
                    end
                end
            end
        end
        heartbeatConnection2 = RunService.Heartbeat:Connect(onHeartbeat)        
    end

    function autoShovel1()
        task.spawn(function()
            while task.wait() and Config.autoShovel1 do
                local lp = game.Players.LocalPlayer
                local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
                if h then h:ChangeState(14) end
            end
        end)
        
        if Config.autoShovel1 then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(546.089661, 61.437355, -2574.47388, 0.931819618, 8.99646846e-09, -0.362921745, 1.14344276e-08, 1, 5.41474634e-08, 0.362921745, -5.46054721e-08, 0.931819618)
        
            task.wait(0.5)
        
            local shovelsFrame = game:GetService("Players").LocalPlayer.PlayerGui._INSTANCES.AdvancedDigsiteMerchant.Frame
            shovelsFrame.Visible = false
        
            local shovels = {
                "Platinum Shovel",
                "Emerald Shovel",
                "Sapphire Shovel",
                "Amethyst Shovel"
            }
        
            local function checkShovelVisibility(shovelName)
                local shovelGui = game:GetService("Players").LocalPlayer.PlayerGui._INSTANCES.AdvancedDigsiteMerchant.Frame.ItemsFrame.Items[shovelName].Buy.Cost.SoldOut
                return not shovelGui.Visible
            end
        
            local function farmCoins()
                for _, v in pairs(workspace.__THINGS.Orbs:GetChildren()) do
                    if v:isA("Part") and string.len(v.Name) >= 7 then
                        v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    end
                end
        
                local block = nil
                for _, v in ipairs(workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedDigsite.Important.ActiveBlocks:GetChildren()) do
                    if v:isA("Part") and v:GetAttribute("Coord").Y <= layerLimit and v.BrickColor ~= BrickColor.new("Royal purple") and v.BrickColor ~= BrickColor.new("Really black") then
                        block = v
                        break
                    end
                end
        
                if block then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = block.CFrame + Vector3.new(0, 5, 0)
                    local args = {
                        [1] = "AdvancedDigsite",
                        [2] = "DigBlock",
                        [3] = block:GetAttribute("Coord")
                    }
                    game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                end
            end
        
            local function attemptPurchase(shovelName)
                local success, response = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("DigsiteMerchant_PurchaseShovel"):InvokeServer(shovelName)
        
                if success then
                    print(shovelName .. " purchase successful.")
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(546.866516, 61.437355, -2487.18066, 1.21815688e-14, 5.90767102e-10, 1, -3.33945338e-09, 1, -5.90767102e-10, -1, -3.33945338e-09, 1.21835415e-14)
                    return true
                else
                    print(shovelName .. " purchase failed: ", response)
                    return false
                end
            end
        
            local function performAutoShovelTasks()
                for _, shovelName in ipairs(shovels) do
                    if checkShovelVisibility(shovelName) then
                        repeat
                            farmCoins()
                            task.wait()
                        until attemptPurchase(shovelName) or not Config.autoShovel1
                    else
                        print(shovelName .. " is sold out.")
                    end
                end
                print("All shovels purchased! :D")
            end
        
            performAutoShovelTasks()
        end
    end

    function autoShovel2()
        if Config.autoShovel2 then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(546.089661, 61.437355, -2574.47388, 0.931819618, 8.99646846e-09, -0.362921745, 1.14344276e-08, 1, 5.41474634e-08, 0.362921745, -5.46054721e-08, 0.931819618)
        
            task.wait(0.5)
        
            local shovelsFrame = game:GetService("Players").LocalPlayer.PlayerGui._INSTANCES.AdvancedDigsiteMerchant.Frame
            shovelsFrame.Visible = false
        
            local function checkShovelVisibility()
                local aShovel = game:GetService("Players").LocalPlayer.PlayerGui._INSTANCES.AdvancedDigsiteMerchant.Frame.ItemsFrame.Items["Amethyst Shovel"].Buy.Cost.SoldOut
                return aShovel.Visible ~= true
            end
        
            local function performAutoShovelTasks()
                while checkShovelVisibility() and Config.autoShovel2 do
                    local success, response = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("DigsiteMerchant_PurchaseShovel"):InvokeServer("Amethyst Shovel")
        
                    if success then
                        print("Shovel purchase successful.")
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(546.866516, 61.437355, -2487.18066, 1.21815688e-14, 5.90767102e-10, 1, -3.33945338e-09, 1, -5.90767102e-10, -1, -3.33945338e-09, 1.21835415e-14)
                        break
                    else
                        print("Shovel purchase failed.", response)
                    end
        
                    local lp = game.Players.LocalPlayer
                    local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
                    if h then h:ChangeState(14) end
        
                    for _, v in pairs(workspace.__THINGS.Orbs:GetChildren()) do
                        if v:isA("Part") and string.len(v.Name) >= 7 then
                            v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        end
                    end
        
                    local block = nil
                    for _, v in ipairs(workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedDigsite.Important.ActiveBlocks:GetChildren()) do
                        if v:isA("Part") and v:GetAttribute("Coord").Y <= layerLimit and v.BrickColor ~= BrickColor.new("Royal purple") and v.BrickColor ~= BrickColor.new("Really black") then
                            block = v
                            break
                        end
                    end
        
                    if block then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = block.CFrame + Vector3.new(0,5,0)
                        local args = {
                            [1] = "AdvancedDigsite",
                            [2] = "DigBlock",
                            [3] = block:GetAttribute("Coord")
                        }
                        game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                    end
                end
            end
        
            if checkShovelVisibility() then
                task.spawn(performAutoShovelTasks)
            else
                print("Already own shovel.")
            end
        end
    end
    
    function autoOrbs()
        while task.wait(0.5) and Config.autoOrbs do
            for _, v in pairs(workspace.__THINGS.Orbs:GetChildren()) do
                if v:isA("Part") and string.len(v.Name) >= 7 then
                    local args = {
                        [1] = {
                            [1] = {
                                [1] = v.Name
                            }
                        }
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Orbs_ClaimMultiple"):FireServer(unpack(args))                    
                end
            end
        end
    end

    function presentHunter()
        while Config.presentHunter do
            local saveModule = require(game:GetService("ReplicatedStorage").Library.Client.Save)
            local result = saveModule.Get()

            local hiddenPresents = result.HiddenPresents

            for _, present in pairs(hiddenPresents) do
                local id = present.ID
                if id then
                    game:GetService("ReplicatedStorage").Network:FindFirstChild("Hidden Presents: Found"):InvokeServer(id)
                end
                task.wait(0.5)
            end
        end
    end
else
    local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
    local Window = OrionLib:MakeWindow({Name = "Get HWID", HidePremium = false, SaveConfig = false, ConfigFolder = "OrionTest"})
    local Tab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    Tab:AddButton({
        Name = "Copy HWID to Clipboard",
        Callback = function()
            local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
            setclipboard(HWID)
            OrionLib:MakeNotification({
                Name = "Copied to clipboard",
                Content = "HWID copied to clipboard, if you purchased send to owner on discord.",
                Image = "rbxassetid://4483345998",
                Time = 15
            })
        end    
    })
    OrionLib:Init()
end

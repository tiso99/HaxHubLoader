local whitelist = {
    onlywooska = "owner",
    butterflybams = "tiso",
    Wildman_TheGoat = "DWQJU238432Bcifohj",
    TREFUEGO98 = "IUROHGPUY845njbio",
	hibro221234 = "IUROaIKD82wg894w",
	AloomCore = "tiso",
	writemyalbum = "y5u8923g6818904kms",
	Mynameis_blazer = "da7815rdfsaijn",
	zayjohncena = "5hy5riju89234iu890",
	MyGIockss = "4386856kgfoptrmef2",
	JLRCOOLDOGALT1 = "mxznbayuas82561",
	BlockSpinnaWick = "grh8289by8qw",
	mrcoolkid4277 = "gdwe23r13r3",
	llllll111111LLLLLLL7 = "NSKjdospsn1",
	DARKxXENO06 = "haxhqq",
	veriflixtwin = "buyhaxhq",
	deegotexotic = "bw233321",
    TIN_KOSAY = "greger7823h",
	Oldmanfranknpc = "jdbdhxud",
	FATZAY_2144 = "43t32dsffxc3",
    Roanchannel07 = "shdiekeb28",
    ABZUES_RTX = "kdosmpsjwu29",
	euejduq = "dwa3r23cdsa129",

    -- Add more usernames and keys as needed
}

-- Get the current player
local player = game.Players.LocalPlayer

-- Function to check if a player's username is whitelisted
local function isPlayerWhitelisted(player)
    return whitelist[player.Name] ~= nil
end

-- Function to check if the entered key matches the stored key for the username
local function isKeyValid(username, enteredKey)
    return whitelist[username] == enteredKey
end



-- Function to execute the main script if the key is valid
local function executeMainScript()
    print("Whitelisted! Loading...")
    wait(2.3)
    print("Loaded 100/100")

 
    loadstring(game:HttpGet('https://pastebin.com/raw/nu52vv0E'))()

end

-- Function to handle access denial
local function handleAccessDenied()
    player:Kick("Not Whitelisted")
    -- Optionally, display a message to the user or prevent further actions
end

-- Function to prompt the user to enter their key
local function promptForKey()
    -- Create the GUI elements
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, -20)
    title.Text = "HAXHUB Key System"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundColor3 = Color3.new(0, 0, 0)
    title.Parent = frame
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
    
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragInput = nil
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    local KeySystem = Instance.new("TextBox")
    KeySystem.Size = UDim2.new(1, 0, 0.5, 0)
    KeySystem.Position = UDim2.new(0, 0, 0, 0)
    KeySystem.Text = "Enter the Key"
    KeySystem.TextColor3 = Color3.new(0, 0, 0)
    KeySystem.BackgroundTransparency = 0.5
    KeySystem.BackgroundColor3 = Color3.new(1, 1, 1)
    KeySystem.TextWrapped = true
    KeySystem.Parent = frame
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(0.5, 0, 0.5, 0)
    SubmitButton.Position = UDim2.new(0, 0, 0.5, 0)
    SubmitButton.Text = "Submit"
    SubmitButton.Parent = frame
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -20, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.BackgroundColor3 = Color3.new(1, 0, 0)
    CloseButton.Parent = frame
    
    CloseButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Size = UDim2.new(0.5, 0, 0.5, 0)
    GetKeyButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    GetKeyButton.Text = "Get Key"
    GetKeyButton.Parent = frame

    -- Event to handle key submission
    SubmitButton.MouseButton1Click:Connect(function()
        local enteredKey = KeySystem.Text
        if isKeyValid(player.Name, enteredKey) then
            screenGui:Destroy()
            executeMainScript()
        else
            handleAccessDenied()
        end
    end)
    
    GetKeyButton.MouseButton1Click:Connect(function()
        setclipboard("Paste here your link to get the key")
    end)
end

-- Check whitelist status and prompt for key if the player is whitelisted
if isPlayerWhitelisted(player) then
    promptForKey()
else
    handleAccessDenied()
end

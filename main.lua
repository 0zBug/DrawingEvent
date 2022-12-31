
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local function ContainsMouse(Object)
	if Object.__OBJECT_EXISTS then
        local MousePosition = UserInputService:GetMouseLocation()
        local Position = Object.Position
        local Size = Position 

        if typeof(Object.Size) == "Vector2" then
            Size = Size + Object.Size
        else
            Size = Size + Object.TextBounds
        end
        
        if MousePosition.X >= Position.X and MousePosition.Y >= Position.Y and MousePosition.X <= Size.X and MousePosition.Y <= Size.Y then
            return true
        end

		return false
	else
		return false
	end
end

local Events = {
	"MouseButton1Click",
	"MouseButton1Click",
	"MouseButton2Click",
	"MouseButton1Down",
	"MouseButton1Up",
	"MouseButton2Down",
	"MouseButton2Up",
	"MouseEnter",
	"MouseLeave",
	"MouseMoved",
	"InputBegan",
	"InputEnded",
	"InputChanged"
}

local Draw = Drawing.new

Drawing.new = function(Class)
	local Object = Draw(Class)
	rawset(Object, "Name", Class)
	rawset(Object, "ClassName", Class)
	Object.Visible = true

	local MouseEntered = false
	local Mouse1Held = false
	local Mouse2Held = false

	for _, Event in next, Events do
		rawset(Object, Event, {
            Connections = {},
            Connect = function(Signal, Function)
				local Id = HttpService:GenerateGUID(false)
				Signal.Connections[Id] = Function

				return {
					Disconnect = function(self)
						Signal.Connections[Id] = nil
					end
				}
            end,
            Fire = function(Signal, ...)
            	for _, Function in pairs(Signal.Connections) do
            		Function(...)
            	end
            end
        })
	end
	
	UserInputService.InputBegan:Connect(function(Input)
		if ContainsMouse(Object) then
			Object.InputBegan:Fire(Input)
		end

		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if ContainsMouse(Object) then
				Mouse1Held = true
				Object.MouseButton1Down:Fire()
			end
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
			if ContainsMouse(Object) then
				Mouse2Held = true
				Object.MouseButton2Down:Fire()
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if ContainsMouse(Object) then
			Object.InputEnded:Fire(Input)
		end

		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if ContainsMouse(Object) then
				if Mouse1Held then
					Object.MouseButton1Click:Fire()
				end

				Object.MouseButton1Up:Fire()
			end

			Mouse1Held = false
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
			if ContainsMouse(Object) then
				if Mouse2Held then
					Object.MouseButton1Click:Fire()
				end

				Object.MouseButton2Up:Fire()
			end

			Mouse2Held = false
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType ~= Enum.UserInputType.Keyboard and Input.UserInputType ~= Enum.UserInputType.TextInput then
			if ContainsMouse(Object) then
				Object.InputChanged:Fire(Input)
			end
		end

		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if ContainsMouse(Object) then
				Object.MouseMoved:Fire()

				if not MouseEntered then
					Object.MouseEnter:Fire()
					MouseEntered = true
				end
			else
				if MouseEntered then
					Object.MouseLeave:Fire()
					Object.InputEnded:Fire(Input)
					MouseEntered = false
				end
			end
		end
	end)

	return Object
end

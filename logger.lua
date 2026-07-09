----- || LIBRARY || -----

local clonefunction = (clonefunction or function(fn: any) return fn end);
local cloneref = (cloneref or function(instance: any) return instance end);

local RunService = cloneref(game:GetService("RunService"));
local CoreGui = cloneref(game:GetService("CoreGui"));

local new_print = clonefunction(print);

getgenv().Logger = getgenv().Logger or {

	["EVENT"] = {

		Icon = "info"; AltIcon = "rbxassetid://11422155687";
		Color = Color3.fromRGB(255, 255, 0);
	};

	["WARN"] = {

		Icon = "triangle-alert"; AltIcon = "rbxassetid://11419713314";
		Color = Color3.fromRGB(255, 170, 00);
	};

	["ERROR"] = {

		Icon = "circle-x"; AltIcon = "rbxassetid://11419709766";
		Color = Color3.fromRGB(255, 0, 0);
	};

	["SUCCESS"] = {

		Icon = "circle-check"; AltIcon = "rbxassetid://11419719540";
		Color = Color3.fromRGB(0, 255, 0);
	};

	["DEBUG"] = {

		Icon = "bug"; AltIcon = "rbxassetid://11419714821";
		Color = Color3.fromRGB(125, 125, 125);
	};

	["INFO"] = {

		Icon = "circle-question-mark"; AltIcon = "rbxassetid://11432859220";
		Color = Color3.fromRGB(255, 255, 255);
	};

	["WAITING"] = {

		Icon = "clock-fading"; AltIcon = "rbxassetid://11963371162";
		Color = Color3.fromRGB(255, 255, 127);
	};

	["READY"] = {

		Icon = "circle-check"; AltIcon = "rbxassetid://11419719540";
		Color = Color3.fromRGB(0, 170, 255);
	};

	["LOADING"] = {
		Icon = "loader"; AltIcon = "rbxassetid://11293978505";
	};

	ClassName = "Logger";
	IconsEnabled = true;

	ConsoleLogs = true;
	SaveLogs = false;
	
	NewLogSignals = {};
	current_logs = {};
};

local Methods = {};	
Logger.__index = Logger; Methods.__index = Methods;

local current_date = os.date("*t");
current_date = string.format("%02d-%02d-%04d", current_date.month, current_date.day, current_date.year);

type IconModule = { Icons: { string }; GetAsset: (Name: string) -> Icon?; };

local __s, __d = pcall(function()
	return (loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")) :: () -> IconModule)();
end);

if Logger.logger_connection then Logger.logger_connection:Disconnect(); Logger.logger_connection = nil; end;

----- || METHODS || -----

function Methods:CustomPrint(_type: string, str: string, custom_color: Color3)
	
	local custom_print = {
		
		custom_icon = Methods:GetCustomIcon(Logger[_type].Icon or Logger[_type].AltIcon);
		UUID = Methods:CreateId(); timestamp = Methods:GetCurrentDate(); _type = _type;
	};
	
	custom_print.text_color = custom_color or Logger[custom_print._type].Color or Color3.fromRGB(255, 255, 255);
	custom_print.message = ('[%s]: [%s] %s (%s)'):format(custom_print.timestamp, custom_print._type, tostring(str), custom_print.UUID);
	
	custom_print.update = function(ClientLog)
		
		local log_txt = nil;
		
		for _, v in pairs(ClientLog:GetChildren()) do
			
			local current_msg = v:FindFirstChild("msg");
			if not current_msg then continue; end;
			
			if (current_msg.Text:find(custom_print.UUID, 1, true)) then
				log_txt = current_msg; break;
			end;
		end;
		
		if not log_txt then return; end;

		log_txt.RichText = true; log_txt.TextColor3 = custom_print.text_color; log_txt.Text = tostring(custom_print.message);
		log_txt.Parent.AutomaticSize = Enum.AutomaticSize.Y; log_txt.AutomaticSize = Enum.AutomaticSize.Y;

		log_txt.Parent.image.Image = Logger.IconsEnabled and custom_print.custom_icon.Url or ""; log_txt.Parent.image.ImageColor3 = custom_print.text_color;
		log_txt.Parent.image.ImageRectOffset = custom_print.custom_icon.ImageRectOffset; log_txt.Parent.image.ImageRectSize = custom_print.custom_icon.ImageRectSize;	
	end;
	
	table.insert(Logger.current_logs, custom_print);
	if Logger.ConsoleLogs then new_print(custom_print.UUID); end;
	
	Methods:CreateFileLog(custom_print.timestamp, _type, str, custom_print.UUID);
	local log_module = setmetatable({}, { __index = custom_print });
	
	task.spawn(function()
		
		for _, callback in pairs(Logger.NewLogSignals) do
			if callback then Methods:SafeCallback(callback, tostring(custom_print.message), custom_print.text_color); end;
		end;
	end);
	
	log_module.update_message = function(...)
		
		local update_timestamp = true;

		if typeof(select(1, ...)) == "table" then
			
			local data = select(1, ...);	

			if typeof(data.message) == "string" then
				custom_print.message = ('[%s]: [%s] %s (%s)'):format(custom_print.timestamp, custom_print._type, tostring(data.message), custom_print.UUID);
			end;
			
			if typeof(data.type) == "string" then
				custom_print._type = data.type;
			end;
			
			if typeof(data.color) == "Color3" then
				custom_print.text_color = data.color;
			end;

			if typeof(data.update_timestamp) == "boolean" then
				update_timestamp = data.update_timestamp;
			end;
			
		else
			
			local _type, msg, color, update = select(1, ...), select(2, ...), select(3, ...), select(4, ...);

			if typeof(msg) == "string" then
				custom_print.message = ('[%s]: [%s] %s (%s)'):format(custom_print.timestamp, custom_print._type, tostring(msg), custom_print.UUID);
			end;
			
			if typeof(_type) == "string" then
				custom_print._type = _type;
			end;
			
			if typeof(color) == "Color3" then
				custom_print.text_color = color;
			end;

			if typeof(update) == "boolean" then
				update_timestamp = update;
			end;
		end

		if update_timestamp then
			custom_print.timestamp = Methods:GetCurrentDate();
		end;
	end;
	
	log_module.cleanup = function()
		
		for i, print_data in pairs(Logger.current_logs) do
			if print_data.UUID == custom_print.UUID then table.remove(Logger.current_logs, i); break; end;
		end;

		custom_print.update = function() end;
	end;
	
	return log_module;
end;

function Methods:SafeCallback(__func, ...)
	
	if not (__func and typeof(__func) == "function") then return; end;

	local Result = table.pack(xpcall(__func, function(__err)
		
		task.defer(error, debug.traceback(__err, 2))
		return __err;
		
	end, ...))

	if not Result[1] then return nil; end;
	return table.unpack(Result, 2, Result.n);
end;

function Methods:CreateFileLog(timestamp, _type, str, UUID)
	
	if not Logger.SaveLogs or not (isfile and readfile and writefile) then return; end;
	local saveLocation = Logger.SaveLocation or "";

	local lastLog = isfile(('%s%s.log'):format(saveLocation, current_date)) and readfile(('%s%s.log'):format(saveLocation, current_date)) .. '\n' or "";
	writefile(('%s%s.log'):format(saveLocation, current_date), ('%s[%s]: [%s] %s (%s)'):format(lastLog, timestamp, _type, tostring(str), UUID));
end;

function Methods:GetCustomIcon(IconName: string)

	local CustomIcon = Methods:IsValidCustomIcon(IconName);

	if CustomIcon then
		return { Url = IconName; ImageRectOffset = Vector2.zero; ImageRectSize = Vector2.zero; Custom = true; };
	end;

	local LucideIcon = Methods:GetIcon(IconName);
	if LucideIcon then return LucideIcon; end;

	return { Url = tonumber(IconName) and string.format("rbxassetid://%s", tostring(IconName)) or IconName; ImageRectOffset = Vector2.zero; ImageRectSize = Vector2.zero; Custom = true; };
end;

function Methods:GetIcon(IconName: string)

	if not __s then return; end;
	local success, icon_data = pcall(__d.GetAsset, IconName);

	if not success then return; end;
	return icon_data;
end;

function Methods:GetCurrentDate()

	local date = os.date("*t");
	return string.format("%02d-%02d-%04d %02d:%02d:%02d", date.month, date.day, date.year, date.hour, date.min, date.sec);
end;

function Methods:CreateId()
	return string.format("0x%06x", math.random(0, 0xFFFFFF));
end;

function Methods:IsValidCustomIcon(Icon: string)
	return typeof(Icon) == "string" and (Icon:match("rbxasset") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="));
end;

function Methods:IsString(str: string)
	return typeof(str) == "string" and str:match("^%s*(.-)%s*$") ~= "";
end;

----- || CALLBACKS || -----

function Logger:CreateLoading(options: table)

	local loader_obj = {}
	options = options or {};

	loader_obj.Color = options.Color or Color3.fromRGB(170, 255, 255);	

	loader_obj.FillSymbol = options.Symbol or "█";
	loader_obj.EmptySymbol = options.Symbol or "░";

	loader_obj.CurrentStep = options.CurrentStep or 0;
	loader_obj.TotalSteps = options.TotalSteps or 10;
	
	assert(typeof(loader_obj.Color) == "Color3", 'Invalid argument Color to "CreateLoading" (Color3 expected, got ' .. typeof(loader_obj.Color) .. ')');

	assert(Methods:IsString(loader_obj.FillSymbol), 'Invalid argument FillSymbol to "CreateLoading" (string expected, got ' .. typeof(loader_obj.FillSymbol) .. ')');
	assert(Methods:IsString(loader_obj.EmptySymbol), 'Invalid argument EmptySymbol to "CreateLoading" (string expected, got ' .. typeof(loader_obj.EmptySymbol) .. ')');
	
	assert(typeof(loader_obj.CurrentStep) == "number" and loader_obj.CurrentStep == loader_obj.CurrentStep, 'Invalid argument CurrentStep to "CreateLoading" (number expected, got ' .. typeof(loader_obj.CurrentStep) .. ')');
	assert(typeof(loader_obj.TotalSteps) == "number" and loader_obj.TotalSteps == loader_obj.TotalSteps, 'Invalid argument TotalSteps to "CreateLoading" (number expected, got ' .. typeof(loader_obj.TotalSteps) .. ')');
	
	local filled = math.floor((loader_obj.CurrentStep / loader_obj.TotalSteps) * 40);
	local progress = string.rep(loader_obj.FillSymbol, filled) .. string.rep(loader_obj.EmptySymbol, 40 - filled);
	
	local loading_instance = Methods:CustomPrint("LOADING", ('[%s] - %s'):format(progress, math.floor((loader_obj.CurrentStep / loader_obj.TotalSteps) * 100) .. '%'), loader_obj.Color);
	
	local function UpdateProgress(color)
		
		filled = math.floor((loader_obj.CurrentStep / loader_obj.TotalSteps) * 40); progress = string.rep(loader_obj.FillSymbol, filled) .. string.rep(loader_obj.EmptySymbol, 40 - filled);
		loading_instance.update_message("LOADING", ('[%s] - %s%%'):format(progress, math.floor((loader_obj.CurrentStep / loader_obj.TotalSteps) * 100)), color);
		
		if loader_obj.CurrentStep < loader_obj.TotalSteps then return; end;
		Methods:CreateFileLog(loading_instance.timestamp, loading_instance._type, ('[%s] - %s%%'):format(progress, math.floor((loader_obj.CurrentStep / loader_obj.TotalSteps) * 100)), loading_instance.UUID);
	end;
	
	function loader_obj:SetColor(color: Color3)

		assert(typeof(color) == "Color3", 'Invalid argument #1 to "SetColor" (Color3 expected, got ' .. typeof(color) .. ')');
		UpdateProgress(color); return loader_obj;
	end;

	function loader_obj:SetTotalSteps(step: number)

		assert(typeof(step) == "number" and step == step, 'Invalid argument #1 to "SetTotalSteps" (number expected, got ' .. typeof(step) .. ')');
		loader_obj.TotalSteps = step; UpdateProgress(); return loader_obj;
	end;

	function loader_obj:SetCurrentStep(step: number)

		assert(typeof(step) == "number" and step == step, 'Invalid argument #1 to "SetCurrentStep" (number expected, got ' .. typeof(step) .. ')');
		loader_obj.CurrentStep = math.clamp(step, 0, loader_obj.TotalSteps); UpdateProgress(); return loader_obj;
	end;
	
	task.wait(.1);
	return loader_obj;
end;

function Logger.event(str: string)
	
	assert(Methods:IsString(str), 'Invalid argument #1 to "event" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("EVENT", str);
end;

function Logger.warn(str: string)

	assert(Methods:IsString(str), 'Invalid argument #1 to "warn" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("WARN", str);
end;

function Logger.error(str: string)

	assert(Methods:IsString(str), 'Invalid argument #1 to "error" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("ERROR", str);
end;

function Logger.success(str: string)

	assert(Methods:IsString(str), 'Invalid argument #1 to "success" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("SUCCESS", str);
end;

function Logger.debug(str: string)

	assert(Methods:IsString(str), 'Invalid argument #1 to "debug" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("DEBUG", str);
end;

function Logger.info(str: string)

	assert(Methods:IsString(str), 'Invalid argument #1 to "info" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("INFO", str);
end;

function Logger.wait(str: string)

	assert(Methods:IsString(str), 'Invalid argument #1 to "wait" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("WAITING", str);
end;

function Logger.ready(str: string)

	assert(Methods:IsString(str), 'Invalid argument #1 to "ready" (string expected, got ' .. typeof(str) .. ')');
	return Methods:CustomPrint("READY", str);
end;

function Logger:SetSaveLocation(str: string)

	if str == nil then Logger.SaveLocation = nil; return; end;

	assert(Methods:IsString(str), "Invalid string.");
	Logger.SaveLocation = str;
end;

function Logger:ToggleIcons(value: boolean)

	assert(typeof(value) == "boolean", 'Invalid argument #1 to "ToggleIcons" (boolean expected, got ' .. typeof(value) .. ')');
	Logger.IconsEnabled = value;
end;

function Logger:ToggleLogs(value: boolean)

	assert(typeof(value) == "boolean", 'Invalid argument #1 to "ToggleLogs" (boolean expected, got ' .. typeof(value) .. ')');
	Logger.SaveLogs = value;
end;

function Logger:ToggleConsoleLogs(value: boolean)

	assert(typeof(value) == "boolean", 'Invalid argument #1 to "ToggleConsoleLogs" (boolean expected, got ' .. typeof(value) .. ')');
	Logger.ConsoleLogs = value;
end;

function Logger:Destroy()
	
	if Logger.logger_connection then Logger.logger_connection:Disconnect(); Logger.logger_connection = nil; end;
	
	for _, log_data in pairs(Logger.current_logs) do
		if log_data.cleanup then log_data.cleanup(); end;	
	end;
end;

function Logger:OnNewLog(callback)
	table.insert(Logger.NewLogSignals, callback);
end;

----- || SIGNALS || -----

Logger.logger_connection = RunService.Heartbeat:Connect(function()
	
	if not CoreGui:FindFirstChild("DevConsoleMaster") then return; end;
	
	local DevConsoleUI = CoreGui.DevConsoleMaster.DevConsoleWindow:FindFirstChild("DevConsoleUI");
	if not DevConsoleUI then return; end;

	if not DevConsoleUI:FindFirstChild("MainView") then return; end;
	local ClientLog = DevConsoleUI.MainView.ClientLog;

	for _, log_data in Logger.current_logs do
		if log_data.update then log_data.update(ClientLog); end;	
	end;
end);

return Logger;

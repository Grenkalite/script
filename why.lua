script_name("WHY.Lua")
script_description("")
script_author("")
script_url("")
script_version("0.1.0")
script_version_number(0)

local imgui = require("imgui")
local cjson = require("cjson")
local dlstatus = require('moonloader').download_status
local k = require("vkeys")

local main_window_state = imgui.ImBool(false)
local json = {}
local jsonPath = getWorkingDirectory() .. "\\why.json"



function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	jsonLoad("https://pastebin.com/raw/q1Zd5nJE", jsonPath)

	while true do wait(0)
		if not isSampfuncsConsoleActive() and not sampIsChatInputActive() and not sampIsDialogActive() then
			if isKeyDown(k.VK_SHIFT) and wasKeyPressed(k.VK_R) then
				reloadScript()
			elseif wasKeyPressed(k.VK_R) then
				main_window_state.v = not main_window_state.v
			end
		end
		imgui.Process = main_window_state.v
	end
end


function imgui.OnDrawFrame()
	imgui.SetNextWindowSize(imgui.ImVec2(800, 600), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(250, 250), imgui.Cond.FirstUseEver)
	imgui.Begin("WHY???", main_window_state)
		local windowSize = imgui.GetWindowSize()
		local windowPos = imgui.GetWindowPos()
		if imgui.Button("Reload script") then
			reloadScript()
		end
		imgui.SameLine(); if imgui.Button("Хуйня") then
			sampAddChatMessage(string.format("x: %s, y: %s", windowPos.x, windowPos.y), 0xFFFFFF)
			sampAddChatMessage(string.format("w: %s, h: %s", windowSize.x, windowSize.y), 0xFFFFFF)
			print(windowSize)
		end

		imgui.Text('#')
		imgui.SameLine(48); imgui.Text('Скрипт')
		imgui.SameLine(273); imgui.Text('Ваша версия')
		imgui.SameLine(373); imgui.Text('Последняя версия')
		imgui.Separator()
		imgui.BeginChild('DB', imgui.ImVec2(windowSize.x - 15, windowSize.y - 135))

			local clipper = imgui.ImGuiListClipper(#json)
			while clipper:Step() do
				for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
					local entry = json[i]
					imgui.Selectable(tostring(i))
					if imgui.BeginPopupContextItem() then
						imgui_db_contextMenu(i, entry)
					end
					if entry then
						imgui.SameLine(40); imgui.Text(entry.name)
						imgui.SameLine(265); imgui.Text("hz lol")
						imgui.SameLine(365); imgui.Text(os.date('%x %X', entry.version))
					end
				end
			end

		imgui.EndChild()
	imgui.End()
end

function jsonLoad(url, path)
	sampAddChatMessage("Starting download...", 0x00FFFF)
	downloadUrlToFile(url, path, function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			sampAddChatMessage("Download finished!", 0x00FF00)
			local file = io.open(path, "r")
			if not file then
				sampAddChatMessage("File doesn't exist D:", 0xFF0000)
				return
			end
			local input = file:read("*a")
			file:close()
			os.remove(path)
			sampAddChatMessage("File read", 0x00FF00)
			json = cjson.decode(input)
			sampAddChatMessage("JSON decoded", 0x00FF00)
		end
	end)
end

function reloadScript()
	main_window_state.v = false
	imgui.Process = false
	imgui.ShowCursor = false
	lua_thread.create(function() wait(0); thisScript():reload() end)
end



--[[


{
	"name": script_name, // Название скрипта
	"version": timestamp, // Последняя версия
	"hash": file_hash, // md5?
	"category": category // cat
	"download_link": link,
	"dependencies": wut
}


"categories": [
	"МЗ", "СМИ", "ДРУГОЕ"
]


--]]

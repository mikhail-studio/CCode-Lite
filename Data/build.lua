return ' ' .. UTF8.trimFull([===[
    display.setStatusBar(display.HiddenStatusBar)
    display.setStatusBar(display.TranslucentStatusBar)
    display.setStatusBar(display.HiddenStatusBar)

    timer.performWithDelay(100, function()
        display.setStatusBar(display.HiddenStatusBar)
        display.setStatusBar(display.TranslucentStatusBar)
        display.setStatusBar(display.HiddenStatusBar)

        local CAMERA = (function()
            local lib_perspective = {}

            local display_newGroup = display.newGroup
            local display_remove = display.remove
            local type = type
            local table_insert = table.insert
            local math_huge = math.huge
            local math_nhuge = -math.huge

            local clamp = function(v, l, h) return (v < l and l) or (v > h and h) or v end

            lib_perspective.createView = function(layerCount)
            	local view = display_newGroup()
            	view.damping = 1
            	view.snapWhenFocused = true

            	local isTracking
            	local prependedLayers = 0

            	local internal
            	internal = {
            		trackingLevel = 1,
            		damping = 1,
            		scaleBoundsToScreen = true,
            		xScale = 1,
            		yScale = 1,
            		xOffset = 0,
            		yOffset = 0,
            		addX = CENTER_X,
            		addY = CENTER_Y,
            		bounds = {
            			xMin = math_nhuge,
            			xMax = math_huge,
            			yMin = math_nhuge,
            			yMax = math_huge
            		},
            		scaledBounds = {
            			xMin = math_nhuge,
            			xMax = math_huge,
            			yMin = math_nhuge,
            			yMax = math_huge
            		},
            		trackFocus = true,
            		focus = nil,
            		viewX = 0,
            		viewY = 0,
            		getViewXY = function() if internal.focus then return internal.focus.x, internal.focus.y else return internal.viewX, internal.viewY end end,
            		layer = {},
            		updateAddXY = function() internal.addX = CENTER_X / view.xScale internal.addY = CENTER_Y / view.yScale end
            	}

            	local layers = {}

            	internal.scaleBounds = function(doX, doY)
            		if internal.scaleBoundsToScreen then
            			local xMin = internal.bounds.xMin
            			local xMax = internal.bounds.xMax
            			local yMin = internal.bounds.yMin
            			local yMax = internal.bounds.yMax

            			local doX = doX and not ((xMin == math_nhuge) or (xMax == math_huge))
            			local doY = doY and not ((yMin == math_nhuge) or (yMax == math_huge))

            			if doX then
            				local scaled_xMin = xMin / view.xScale
            				local scaled_xMax = xMax - (scaled_xMin - xMin)

            				if scaled_xMax < scaled_xMin then
            					local hopDist = scaled_xMin - scaled_xMax
            					local halfDist = hopDist * 0.5
            					scaled_xMax = scaled_xMax + halfDist
            					scaled_xMin = scaled_xMin - halfDist
            				end

            				internal.scaledBounds.xMin = scaled_xMin
            				internal.scaledBounds.xMax = scaled_xMax
            			end

            			if doY then
            				local scaled_yMin = yMin / view.yScale
            				local scaled_yMax = yMax - (scaled_yMin - yMin)

            				if scaled_yMax < scaled_yMin then
            					local hopDist = scaled_yMin - scaled_yMax
            					local halfDist = hopDist * 0.5
            					scaled_yMax = scaled_yMax + halfDist
            					scaled_yMin = scaled_yMin - halfDist
            				end

            				internal.scaledBounds.yMin = scaled_yMin
            				internal.scaledBounds.yMax = scaled_yMax
            			end
            		else
            			camera.scaledBounds.xMin, camera.scaledBounds.xMax, camera.scaledBounds.yMin, camera.scaledBounds.yMax = camera.bounds.xMin, camera.bounds.xMax, camera.bounds.yMin, camera.bounds.yMax
            		end
            	end

            	internal.processViewpoint = function()
            		if internal.damping ~= view.damping then internal.trackingLevel = 1 / view.damping internal.damping = view.damping end
            		if internal.trackFocus then
            			local x, y = internal.getViewXY()

            			if view.xScale ~= internal.xScale or view.yScale ~= internal.yScale then internal.updateAddXY() end
            			if view.xScale ~= internal.xScale then internal.xScale = view.xScale internal.scaleBounds(true, false) end
            			if view.yScale ~= internal.yScale then internal.yScale = view.yScale internal.scaleBounds(false, true) end

            			x = clamp(x, internal.scaledBounds.xMin, internal.scaledBounds.xMax)
            			y = clamp(y, internal.scaledBounds.yMin, internal.scaledBounds.yMax)
            			internal.viewX, internal.viewY = x, y
            		end
            	end

            	view.appendLayer = function()
            		local layer = display_newGroup()
            		layer.xParallax, layer.yParallax = 1, 1
            		view:insert(layer)
            		layer:toBack()
            		table_insert(layers, layer)

            		layer._perspectiveIndex = #layers

            		internal.layer[#layers] = {
            			x = 0,
            			y = 0,
            			xOffset = 0,
            			yOffset = 0
            		}

            		function layer:setCameraOffset(x, y) internal.layer[layer._perspectiveIndex].xOffset, internal.layer[layer._perspectiveIndex].yOffset = x, y end
            	end

            	view.prependLayer = function()
            		view.appendLayer()

            		layers[#layers]:toFront()
            		layers[-prependedLayers] = layers[#layers]
            		internal.layer[-prependedLayers] = internal.layer[#internal.layer]
            		table.remove(layers, #layers)
            		table.remove(internal.layer, #internal.layer)
            		layers[-prependedLayers]._perspectiveIndex = -prependedLayers

            		prependedLayers = prependedLayers + 1
            	end

            	function view:add(obj, l, isFocus)
            		local l = l or 4
            		layers[l]:insert(obj)
            		obj._perspectiveLayer = l

            		if isFocus then view:setFocus(obj) end
            		function obj:toLayer(newLayer) if layer[newLayer] then layer[newLayer]:insert(obj) obj._perspectiveLayer = newLayer end end
            		function obj:back() if layer[obj._perspectiveLayer + 1] then layer[obj._perspectiveLayer + 1]:insert(obj) obj._perspectiveLayer = obj.layer + 1 end end
            		function obj:forward() if layer[obj._perspectiveLayer - 1] then layer[obj._perspectiveLayer - 1]:insert(obj) obj._perspectiveLayer = obj.layer - 1 end end
            		function obj:toCameraFront() layer[1]:insert(obj) obj._perspectiveLayer = 1 obj:toFront() end
            		function obj:toCameraBack() layer[#layers]:insert(obj) obj._perspectiveLayer = #layers obj:toBack() end
            	end

            	function view:trackFocus()
            		internal.processViewpoint()
            		local viewX, viewY = internal.viewX, internal.viewY

            		layers[1].xParallax, layers[1].yParallax = 1, 1

            		for i = -prependedLayers + 1, #layers do
            			local addX, addY = internal.addX, internal.addY
            			local layerX, layerY = internal.layer[i].x, internal.layer[i].y

            			local diffX = (-viewX - layerX)
            			local diffY = (-viewY - layerY)
            			local incrX = diffX
            			local incrY = diffY
            			internal.layer[i].x = layerX + incrX + internal.layer[i].xOffset + internal.xOffset
            			internal.layer[i].y = layerY + incrY + internal.layer[i].yOffset + internal.yOffset

            			layers[i].x = (layers[i].x - (layers[i].x - (internal.layer[i].x + addX) * layers[i].xParallax) * internal.trackingLevel)
            			layers[i].y = (layers[i].y - (layers[i].y - (internal.layer[i].y + addY) * layers[i].yParallax) * internal.trackingLevel)
            		end

            		view.scrollX, view.scrollY = layers[1].x, layers[1].y
            	end

            	function view:setBounds(x1, x2, y1, y2)
            		local xMin, xMax, yMin, yMax

            		if x1 ~= nil then if not x1 then xMin = math_nhuge else xMin = x1 end end
            		if x2 ~= nil then if not x2 then xMax = math_huge else xMax = x2 end end
            		if y1 ~= nil then if not y1 then yMin = math_nhuge else yMin = y1 end end
            		if y2 ~= nil then if not y2 then yMax = math_huge else yMax = y2 end end

            		internal.bounds.xMin = xMin
            		internal.bounds.xMax = xMax
            		internal.bounds.yMin = yMin
            		internal.bounds.yMax = yMax
            		internal.scaleBounds(true, true)
            	end

            	function view:track() if not isTracking then Runtime:addEventListener("enterFrame", view.trackFocus) isTracking = true end end
            	function view:cancel() if isTracking then Runtime:removeEventListener("enterFrame", view.trackFocus) isTracking = false end end
            	function view:remove(obj) if obj and obj._perspectiveLayer then layers[obj._perspectiveLayer]:remove(obj) end end
            	function view:setFocus(obj) if obj then internal.focus = obj end if view.snapWhenFocused then view.snap() end end
            	function view:snap() local t = internal.trackingLevel local d = internal.damping internal.trackingLevel = 1 internal.damping = view.damping view:trackFocus() internal.trackingLevel = t internal.damping = d end
            	function view:toPoint(x, y) view:cancel() local newFocus = {x = x, y = y} view:setFocus(newFocus) view:track() return newFocus end
            	function view:layer(n) return layers[n] end
            	function view:layers() return layers end
            	function view:destroy() view:cancel() for i = 1, #layers do display_remove(layers[i]) end display_remove(view) view = nil return true end
            	function view:setParallax(...) for i = 1, #arg do if type(arg[i]) == "table" then layers[i].xParallax, layers[i].yParallax = arg[i][1], arg[i][2] else layers[i].xParallax, layers[i].yParallax = arg[i], arg[i] end end end
            	function view:layerCount() return #layers end
            	function view:setMasterOffset(x, y) internal.xOffset, internal.yOffset = x, y end

            	for i = layerCount or 8, 1, -1 do view.appendLayer() end

            	return view
            end

            return lib_perspective
        end)()

        local NOISE = (function()
            local rseed = math.randomseed
            local rand = math.random
            local floor = math.floor
            local max = math.max

            local MT = {
            	__index = function(t, i)
            		return t[i - 256]
            	end
            }

            local Perms = setmetatable({
            	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225,
            	140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148,
            	247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
            	57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68,	175,
            	74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111,	229, 122,
            	60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54,
            	65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169,
            	200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64,
            	52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212,
            	207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213,
            	119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
            	129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104,
            	218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241,
            	81,	51, 145, 235, 249, 14, 239,	107, 49, 192, 214, 31, 181, 199, 106, 157,
            	184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93,
            	222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
            }, MT)

            local Perms12 = setmetatable({}, MT)

            for i = 1, 256 do
            	Perms12[i] = Perms[i] % 12 + 1
            	Perms[i] = Perms[i] + 1
            end

            local Grads3 = {
            	{ 1, 1, 0 }, { -1, 1, 0 }, { 1, -1, 0 }, { -1, -1, 0 },
            	{ 1, 0, 1 }, { -1, 0, 1 }, { 1, 0, -1 }, { -1, 0, -1 },
            	{ 0, 1, 1 }, { 0, -1, 1 }, { 0, 1, -1 }, { 0, -1, -1 }
            }

            local function GetN(ix, iy, x, y)
                local t = 0.5 - x ^ 2 - y ^ 2
                local index = Perms12[ix + Perms[iy + 1]]
                local grad = Grads3[index]

                return max(0, t ^ 4) * (grad[1] * x + grad[2] * y)
            end

            local F = (math.sqrt(3) - 1) / 2
            local G = (3 - math.sqrt(3)) / 6
            local G2 = 2 * G - 1

            local function SampleNoise(x, y, seed)
            	local rdm = 0
                local x = x or 0
                local y = y or 0

                if seed then
                    rseed(seed)
            		rdm = rand(seed, seed * 2)
                    x = x + 100000 + rdm
                    y = y + 100000 + rdm
                end

                local s = (x + y) * F
                local ix, iy = floor(x + s), floor(y + s)

                local t = (ix + iy) * G
                local x0 = x + t - ix
                local y0 = y + t - iy

                ix, iy = ix % 256, iy % 256

                local n0 = GetN(ix, iy, x0, y0)
                local n2 = GetN(ix + 1, iy + 1, x0 + G2, y0 + G2)
                local xi = x0 > y0 and 1 or 0
                local n1 = GetN(ix + xi, iy + (1 - xi), x0 + G - xi, y0 + G - (1 - xi))

                return 70.1480580019 * (n0 + n1 + n2)
            end

            return {new = SampleNoise}
        end)()

        local SERVER = (function()
            local socket = require 'socket'
            local json = require 'json'
            local mime = require 'mime'
            local M = {}

            M.getOnline = function()
                local isNetworkAvailable = false
                if not M.online then M.online = socket.tcp() M.online:settimeout(0) end
                local con, err = M.online:connect('www.google.com', 80)
                isNetworkAvailable = con ~= nil or err == 'already connected'
                return isNetworkAvailable
            end

            M.getIP = function()
                local s = socket.udp()
                s:setpeername('74.125.115.104', 80)
                return select(1, s:getsockname())
            end

            M.createServer = function(port, serverListener)
                if not M.serverIsCreated then
                    local serverListener = serverListener or (function() return {} end)
                    local tcp, err = socket.bind(M.getIP(), port) tcp:settimeout(0)
                    local clientList, clientBuffer = {}, {} M.serverIsCreated = true

                    local function sPulse()
                        pcall(function()
                            local newClientList = {}

                            repeat
                                local client = tcp:accept()
                                if client then
                                    client:settimeout(0)
                                    newClientList[#newClientList + 1] = client
                                end
                            until not client

                            local ready, writeReady, err = socket.select(clientList, clientList, 0)
                            if err == nil then
                                for i = 1, #ready do
                                    local client, sess_hash = ready[i]
                                    local data, err = client:receive()

                                    if data then
                                        data = json.decode(data)

                                        if data._sess_hash and clientBuffer[data._sess_hash] then
                                            sess_hash = data._sess_hash
                                        end
                                    else
                                        for key, buffer in pairs(clientBuffer) do
                                            if buffer[2] == client then
                                                sess_hash = key
                                                break
                                            end
                                        end data = {}
                                    end

                                    local _data = serverListener(data)

                                    if sess_hash then
                                        clientBuffer[sess_hash][1] = json.encode2(type(_data) == 'table' and _data or {})
                                        clientBuffer[sess_hash][3] = _data
                                    end
                                end

                                for _, buffer in pairs(clientBuffer) do
                                    buffer[2]:send(buffer[1] .. '\n')
                                    buffer[1] = '{}\n'
                                end
                            end

                            if #newClientList > 0 then
                                local _ready, _writeReady, _err = socket.select(newClientList, newClientList, 0)
                                if _err == nil then
                                    for i = 1, #_ready do
                                        local client = _ready[i]
                                        local data, err = client:receive()

                                        if data then
                                            local _data = json.decode(data)

                                            if _data._sess_hash then
                                                if clientBuffer[_data._sess_hash] then
                                                    local index = table.indexOf(clientList, clientBuffer[_data._sess_hash][2])
                                                    if index then table.remove(clientList, index) end

                                                    clientList[#clientList + 1] = client
                                                    clientBuffer[_data._sess_hash][2] = client
                                                end
                                            else
                                                local ip = client:getpeername()
                                                local encodedData = CRYPTO.hmac(CRYPTO.md5, ip .. ':' .. math.random(111111, 999999), '?.сс_ode')

                                                clientList[#clientList + 1] = client
                                                clientBuffer[encodedData] = {json.encode2({_sess_hash = encodedData}) .. '\n', client, {}}
                                            end
                                        else
                                            local ip = client:getpeername()
                                            local encodedData = CRYPTO.hmac(CRYPTO.md5, ip .. ':' .. math.random(111111, 999999), '?.сс_ode')

                                            clientList[#clientList + 1] = client
                                            clientBuffer[encodedData] = {json.encode2({_sess_hash = encodedData}), client, {}}
                                        end
                                    end

                                    for _, buffer in pairs(clientBuffer) do
                                        buffer[2]:send(buffer[1] .. '\n')
                                        buffer[1] = '{}\n'
                                    end
                                end
                            end
                        end)
                    end

                    local serverPulse = timer.performWithDelay(100, sPulse, 0)

                    local function stopServer()
                        timer.cancel(serverPulse)
                        tcp:close() M.serverIsCreated = nil
                        if M.online then M.online:close() end
                        for i, v in pairs(clientList) do
                            v:close()
                        end
                    end

                    return stopServer
                end
            end

            return M
        end)()

        local CLIENT = (function()
            local server = SERVER
            local socket = require 'socket'
            local json = require 'json'
            local mime = require 'mime'
            local M = {}

            M.createClientLoop = function(ip, port, clientListener)
                local clientListener = clientListener or (function() return {} end)
                local sock, clientTable, clientPulse = M.connectToServer(ip, port), {}

                local function cPulse()
                    pcall(function()
                        if server.getOnline() then
                            local data, err = sock:receive()

                            if err == 'closed' and clientPulse then
                                sock = M.connectToServer(ip, port, clientTable._sess_hash)
                                local data = sock and sock:receive() or nil
                            end

                            if data then
                                data = json.decode(data)

                                if data._sess_hash and not clientTable._sess_hash then
                                    clientTable._sess_hash = data._sess_hash
                                elseif not data._sess_hash and clientTable._sess_hash then
                                    data._sess_hash = clientTable._sess_hash
                                end data._device_id = DEVICE_ID or system.getInfo('deviceID')
                            else
                                data = {
                                    _device_id = DEVICE_ID or system.getInfo('deviceID')
                                }
                            end

                            local _data = clientListener(data)

                            if type(_data) == 'table' then
                                if clientTable._sess_hash then
                                    _data._sess_hash = clientTable._sess_hash
                                end _data._device_id = DEVICE_ID or system.getInfo('deviceID')
                            end

                            local msg = json.encode2(type(_data) == 'table' and _data or {_device_id = DEVICE_ID or system.getInfo('deviceID')}) .. '\n'

                            local data, err = sock:send(msg)
                            if err == 'closed' and clientPulse then
                                sock = M.connectToServer(ip, port, clientTable._sess_hash)
                                if sock then sock:send(msg) end
                            end
                        end
                    end)
                end


                clientPulse = timer.performWithDelay(100, cPulse, 0)

                local function stopClient()
                    pcall(function()
                        timer.cancel(clientPulse) clientPulse = nil sock:close()
                        if server.online then server.online:close() end
                    end)
                end

                return stopClient
            end

            M.connectToServer = function(ip, port, sess_hash)
                local sock = socket.connect(ip, port)
                if sock == nil then return false end

                sock:settimeout(0)
                sock:setoption('tcp-nodelay', true)
                sock:send(json.encode2({_sess_hash = sess_hash}) .. '\n')

                return sock
            end

            return M
        end)()

        local function getGlobal()
            local function appResize(type, listener)
                if CURRENT_ORIENTATION ~= type then
                    CENTER_X, CENTER_Y = CENTER_Y, CENTER_X
                    DISPLAY_WIDTH, DISPLAY_HEIGHT = DISPLAY_HEIGHT, DISPLAY_WIDTH
                    TOP_HEIGHT, LEFT_HEIGHT = LEFT_HEIGHT, TOP_HEIGHT
                    BOTTOM_HEIGHT, RIGHT_HEIGHT = RIGHT_HEIGHT, BOTTOM_HEIGHT

                    ZERO_X = CENTER_X - DISPLAY_WIDTH / 2 + LEFT_HEIGHT
                    ZERO_Y = CENTER_Y - DISPLAY_HEIGHT / 2 + TOP_HEIGHT
                    MAX_X = CENTER_X + DISPLAY_WIDTH / 2 - RIGHT_HEIGHT
                    MAX_Y = CENTER_Y + DISPLAY_HEIGHT / 2 - BOTTOM_HEIGHT
                end

                CURRENT_ORIENTATION = type
                ORIENTATION.lock(CURRENT_ORIENTATION)
                if listener then listener({orientation = type}) end
            end

            function setOrientationApp(event)
                appResize(event.type, event.lis)
            end

            NOTIFICATIONS = require 'plugin.notifications.v2'
            BITMAP = require 'plugin.memoryBitmap'
            FILE = require 'plugin.cnkFileManager'
            FILEPICKER = require 'plugin.androidFilePicker'
            EXPORT = require 'plugin.exportFile'
            PASTEBOARD = require 'plugin.pasteboard'
            ORIENTATION = require 'plugin.orientation'
            IMPACK = require 'plugin.impack'
            SVG = require 'plugin.nanosvg'
            UTF8 = require 'plugin.utf8'
            ZIP = require 'plugin.zip'
            PHYSICS = require 'physics'
            JSON = require 'json'
            LFS = require 'lfs'
            WIDGET = require 'widget'
            CRYPTO = require 'crypto'

            SEED = os.time()
            ORIENTATION.init()
            CURRENT_LINK = 'App'
            CURRENT_ORIENTATION = 'portrait'
            CENTER_X = display.contentCenterX
            CENTER_Y = display.contentCenterY
            DISPLAY_WIDTH = display.actualContentWidth
            DISPLAY_HEIGHT = display.actualContentHeight
            TOP_HEIGHT, LEFT_HEIGHT, BOTTOM_HEIGHT, RIGHT_HEIGHT = display.getSafeAreaInsets()
            ZERO_X = CENTER_X - DISPLAY_WIDTH / 2 + LEFT_HEIGHT
            ZERO_Y = CENTER_Y - DISPLAY_HEIGHT / 2 + TOP_HEIGHT
            MAX_X = CENTER_X + DISPLAY_WIDTH / 2 - RIGHT_HEIGHT
            MAX_Y = CENTER_Y + DISPLAY_HEIGHT / 2 - BOTTOM_HEIGHT

            GET_GL_NUM = function(name)
                return ({
                    GL_ZERO = 0,
                    GL_ONE = 1,
                    GL_DST_COLOR = 774,
                    GL_ONE_MINUS_DST_COLOR = 775,
                    GL_SRC_ALPHA = 770,
                    GL_ONE_MINUS_SRC_ALPHA = 771,
                    GL_DST_ALPHA = 772,
                    GL_ONE_MINUS_DST_ALPHA = 773,
                    GL_SRC_ALPHA_SATURATE = 776,
                    GL_SRC_COLOR = 768,
                    GL_ONE_MINUS_SRC_COLOR = 769
                })[name] or 0
            end

            READ_FILE = function(path, bin)
                local file, data = io.open(path or '', bin and 'rb' or 'r'), nil

                if file then
                    data = file:read('*a')
                    io.close(file)
                end

                return data
            end

            WRITE_FILE = function(path, data, bin)
                local file = io.open(path, bin and 'wb' or 'w')

                if file then
                    file:write(tostring(data))
                    io.close(file)
                end
            end

            GIVE_PERMISSION_DATA = function()
                GANIN.perm()
                native.showPopup('requestAppPermission', {appPermission = 'Storage', urgency = 'Normal'})
                native.showPopup('requestAppPermission', {appPermission = 'Location', urgency = 'Normal'})
            end

            FILE.pickFile = function(path, listener, file, p1, mime)
                GIVE_PERMISSION_DATA()
                FILEPICKER.show(mime, path .. '/' .. file, function(e)
                    listener({done = e.isError and 'error' or 'ok', origFileName = e.filename})
                end)
            end

            IS_ZERO_TABLE = function(t)
                local result = true

                pcall(function()
                    for key, value in pairs(t) do
                        result = false
                        break
                    end
                end)

                return result
            end

            COPY_TABLE = function(t, isSim)
                local result = {}

                pcall(function() if t then
                    for key, value in pairs(t) do
                        if type(value) == 'table' and key ~= '_class' and key ~= '_tableListeners' then
                            result[key] = COPY_TABLE(value, isSim)
                        elseif (not isSim) or (key ~= '_tableListeners' and key ~= '_class') then
                            result[key] = value
                        end
                    end
                end end)

                return result
            end

            COPY_TABLE_P = function(t, isSim)
                local result = {}

                pcall(function()
                    if type(t[1]) == 'table' and #t == 1 then
                        result = COPY_TABLE(t[1], isSim)
                    else
                        result = COPY_TABLE(t, isSim)
                    end
                end)

                return result
            end

            IS_FOLDER = function(path)
                return LFS.attributes(path, 'mode') == 'directory'
            end

            GET_SIZE = function(path, baseDir, width, height, count)
                local onComplete, result = pcall(function()
                    local image = display.newImage(path, baseDir)
                    local width, height = image.width / count, image.height image:removeSelf()
                    return {width, height, count}
                end) if onComplete then return result end return {width, height, count}
            end

            SET_X = function(x, obj)
                if obj and (obj._isGroup or obj._snapshot or obj._container) then return x end
                return type(x) == 'number' and ((obj and obj._scroll and GAME.group.widgets[obj._scroll]
                and GAME.group.widgets[obj._scroll].wtype == 'scroll')
                and x + GAME.group.widgets[obj._scroll].width / 2 or CENTER_X + x) or 0
            end

            SET_Y = function(y, obj)
                if obj and obj._isGroup then return type(y) == 'number' and ((obj and obj._scroll and GAME.group.widgets[obj._scroll]
                and GAME.group.widgets[obj._scroll].wtype == 'scroll') and 0 - y - CENTER_Y or 0 - y ) or 0 end
                return type(y) == 'number' and (((obj and obj._scroll and GAME.group.widgets[obj._scroll]
                and GAME.group.widgets[obj._scroll].wtype == 'scroll') or (obj and (obj._snapshot or obj._container))) and 0 - y or CENTER_Y - y) or 0
            end

            GET_X = function(x, obj)
                if obj and (obj._isGroup or obj._snapshot or obj._container) then return x end
                return type(x) == 'number' and ((obj and obj._scroll and GAME.group.widgets[obj._scroll]
                and GAME.group.widgets[obj._scroll].wtype == 'scroll')
                and x - GAME.group.widgets[obj._scroll].width / 2 or x - CENTER_X) or 0
            end

            GET_Y = SET_Y

            GET_GAME_SAVE = function(link)
                local path = DOC_DIR .. '/' .. link .. '/save.json'
                local file, data = io.open(path, 'r'), {}

                if file then
                    data = JSON.decode(file:read('*a'))
                    io.close(file)
                end

                return data
            end

            SET_GAME_SAVE = function(link, data)
                local path = DOC_DIR .. '/' .. link .. '/save.json'
                local file = io.open(path, 'w')

                if file then
                    file:write(JSON.encode(data))
                    io.close(file)
                end
            end

            OS_MOVE = function(link, link2)
                if system.getInfo 'environment' == 'simulator' then
                    link = UTF8.gsub(link, '/', '\\')
                    link2 = UTF8.gsub(link2, '/', '\\')
                    os.execute('move /y "' .. link .. '" "' .. link2 .. '"')
                else
                    os.execute('mv -f "' .. link .. '" "' .. link2 .. '"')
                end
            end

            PHYSICS.setAverageCollisionPositions(true)
            WIDGET.setTheme('widget_theme_android_holo_dark')
            UNPACK = function(t) if #t > 0 then return unpack(t) end return t end
            PHYSICS.setReportCollisionsInContentCoordinates(true) math.randomseed(SEED)
            JSON.decode2, JSON.decode = JSON.decode, function(str) return type(str) == 'string' and (JSON.decode2(str) or {}) or nil end
            math.factorial = function(num) if num == 0 then return 1 else return num * math.factorial(num - 1) end end
            math.hex = function(hex) local r, g, b = hex:match('(..)(..)(..)') return {tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)} end
            UTF8.split = function(text, sep) local result = {} for s in text:gmatch('[^' .. sep .. ']+') do result[#result + 1] = s end return result end
            UTF8.trim = function(s) return UTF8.gsub(UTF8.gsub(s, '^%s+', ''), '%s+$', '') end
            UTF8.trimLeft = function(s) return UTF8.gsub(s, '^%s+', '') end
            UTF8.trimRight = function(s) return UTF8.gsub(s, '%s+$', '') end
            UTF8.trimFull = function(s) return UTF8.trim(UTF8.gsub(s, '%s+', ' ')) end
            timer.new = function(sec, rep, lis) return timer.performWithDelay(sec, lis, rep) end
            math.sum = function(...) local args, num = {...}, 0 for i = 1, #args do num = num + args[i] end return num end
            math.getMaskBits = function(t) local s = 0 for j = 1, #t do s = s + math.getBit(t[j]) end return s end
            math.getBit = function(i) return 2 ^ (i-1) end
            table.len, math.round, table.merge = function(t)
                return type(t) == 'table' and ((type(#t) == 'number' and #t > 0) and #t
                or (function() local i = 0 for k in pairs(t) do i = i + 1 end return i end)()) or 0
            end, function(num, exp)
                if (not exp) or (not tonumber(exp)) then return tonumber(string.match(tostring(num), '(.*)%.')) or num
                else local isMinus, oldNum = tonumber(num) and tonumber(num) < 0, tonumber(num) or 0
                local exps, factor = string.match(tostring(num), '%.(.*)'), tonumber(exp) == 0 and '0.' or '0.0'
                if not exps then return num end for i = 1, tonumber(exp) - 1 do factor = factor .. '0' end factor = factor .. '5' num = tonumber(num)
                and num + factor or 0 exp = string.match(tostring(num), '%.(.*)') and string.match(tostring(num), '%.(.*)'):sub(1, tonumber(exp))
                or '0' num = string.match(tostring(num), '(.*)%.') or tostring(num) num = tonumber(num .. '.' .. exp)
                return isMinus and (oldNum > -0.5 and 0 or num - 1) or num end
            end, function(t1, t2)
                for k, v in pairs(t2) do if (type(v) == 'table') and (type(t1[k] or false) == 'table')
                then table.merge(t1[k], t2[k]) else t1[k] = v end end return t1
            end

            display.newImage2, display.newImage = display.newImage, function(link, ...)
                local image = display.newImage2(link, ...)

                if image and not (type(image) == 'table' and image.width > 0 and image.height > 0) then
                    local args = {...} image = SVG.newImage({
                        filename = link, baseDir = args[1],
                        x = type(args[1]) == 'userdata' and (args[2] or 0) or (args[1] or 0),
                        y = type(args[1]) == 'userdata' and (args[3] or 0) or (args[2] or 0)
                    })
                end

                return (type(image) == 'table' and image.width > 0 and image.height > 0) and image or nil
            end

            GET_GLOBAL_TABLE = function()
                return {
                    sendLaunchAnalytics = sendLaunchAnalytics, transition = transition, tostring = tostring, tonumber = tonumber,
                    gcinfo = gcinfo, assert = assert, debug = debug, GAME = GAME, collectgarbage = collectgarbage, GANIN = GANIN,
                    os = os, display = display, module = module, media = media, OS_REMOVE = OS_REMOVE, funsS = G_funsS, funsP = G_funsP,
                    native = native, coroutine = coroutine, CENTER_X = CENTER_X, CENTER_Y = CENTER_Y, JSON = JSON, ipairs = ipairs,
                    TOP_HEIGHT = TOP_HEIGHT, network = network, _network_pathForFile = _network_pathForFile, print5 = require,
                    pcall = pcall, BUILD = BUILD, MAX_Y = MAX_Y, MAX_X = MAX_X, string = string, SIZE = SIZE,
                    xpcall = xpcall, ZERO_Y = ZERO_Y, ZERO_X = ZERO_X, package = package, OS_MOVE = OS_MOVE, RENDER = RENDER,
                    table = table, lpeg = lpeg, COPY_TABLE = COPY_TABLE, DISPLAY_HEIGHT = DISPLAY_HEIGHT, OS_COPY = OS_COPY,
                    unpack = unpack, setmetatable = setmetatable, next = next, RIGHT_HEIGHT = RIGHT_HEIGHT,
                    graphics = graphics, system = system, rawequal = rawequal,  getmetatable = getmetatable, FILE = FILE,
                    timer = timer, BOTTOM_HEIGHT = BOTTOM_HEIGHT, newproxy = newproxy, metatable = metatable, NOISE = NOISE,
                    al = al, rawset = rawset, easing = easing, coronabaselib = coronabaselib, DOC_DIR = DOC_DIR,
                    LEFT_HEIGHT = LEFT_HEIGHT, cloneArray = cloneArray, DISPLAY_WIDTH = DISPLAY_WIDTH, type = type,
                    audio = audio, pairs = pairs, select = select, rawget = rawget, Runtime = Runtime, error = error,
                    fun = G_fun, math = G_math, other = G_other, device = G_device, prop = G_prop, PASTEBOARD = PASTEBOARD,
                    varsE = G_varsE, varsS = G_varsS, varsP = G_varsP, tablesE = G_tablesE, tablesS = G_tablesS, tablesP = G_tablesP
                }
            end

            OS_REMOVE(MY_PATH, true) LFS.mkdir(MY_PATH)
            Runtime:addEventListener('unhandledError', function(event) return true end)
        end getGlobal()

        local function getDevice()
            local M = {}

            M['device_id'] = function()
                return DEVICE_ID
            end

            M['get_device'] = function()
                GIVE_PERMISSION_DATA()
                return JSON.decode(GANIN.bluetooth('device'))
            end

            M['get_devices'] = function()
                GIVE_PERMISSION_DATA()
                return JSON.decode(GANIN.bluetooth('devices'))
            end

            M['width_screen'] = function()
                return DISPLAY_WIDTH
            end

            M['height_screen'] = function()
                return DISPLAY_HEIGHT
            end

            M['top_point_screen'] = function()
                return DISPLAY_HEIGHT / 2
            end

            M['bottom_point_screen'] = function()
                return -DISPLAY_HEIGHT / 2
            end

            M['right_point_screen'] = function()
                return DISPLAY_WIDTH / 2
            end

            M['left_point_screen'] = function()
                return -DISPLAY_WIDTH / 2
            end

            M['height_top'] = function()
                return TOP_HEIGHT == 0 and display.topStatusBarContentHeight or TOP_HEIGHT
            end

            M['height_bottom'] = function()
                local _, _, bottom_height = display.getSafeAreaInsets()
                return bottom_height
            end

            M['finger_touching_screen'] = function()
                return GAME.group.const.touch
            end

            M['finger_touching_screen_x'] = function()
                return GAME.group.const.touch_x - CENTER_X
            end

            M['finger_touching_screen_y'] = function()
                return CENTER_Y - GAME.group.const.touch_y
            end

            M['fps'] = function()
                return M.FPS
            end

            M.start = function()
                M.FPS, M._FPS = 60, 0 timer.performWithDelay(0, function() M._FPS = M._FPS + 1 end, 0)
                timer.performWithDelay(1000, function() M.FPS, M._FPS = M._FPS > 60 and 60 or M._FPS, 0 end, 0)
            end

            return M
        end

        local function getFun()
            local M = {}

            M['get_text'] = function(name)
                local isComplete, result = pcall(function()
                    return GAME.group.texts[name or '0'] and GAME.group.texts[name or '0'].text or ''
                end) return isComplete and result or ''
            end

            M['read_save'] = function(key)
                local isComplete, result = pcall(function()
                    return GET_GAME_SAVE(CURRENT_LINK)[tostring(key)]
                end) return isComplete and result or nil
            end

            M['random_str'] = function(...)
                local args = {...}

                local isComplete, result = pcall(function()
                    if #args > 0 then
                        return args[math.random(1, #args)]
                    else
                        return nil
                    end
                end) return isComplete and result or ''
            end

            M['concat'] = function(...)
                local args, str = {...}, ''

                local isComplete, result = pcall(function()
                    for i = 1, #args do
                        str = str .. args[i]
                    end

                    return str
                end) return isComplete and result or ''
            end

            M['tonumber'] = function(str)
                local isComplete, result = pcall(function()
                    return tonumber(str) or 0
                end) return isComplete and result or 0
            end

            M['tostring'] = function(any)
                return tostring(any)
            end

            M['totable'] = function(str)
                return JSON.decode(str)
            end

            M['len_table'] = function(t)
                return table.len(t)
            end

            M['exists_in_table'] = function(t, value)
                local isComplete, result = pcall(function()
                    if _G.type(t) == 'table' and #t > 0 then
                        return table.indexOf(t, value)
                    end
                end) return isComplete and result or nil
            end

            M['noise'] = function(x, y, seed)
                return NOISE.new(x, y, seed)
            end

            M['encode'] = function(t, prettify, validate)
                local isComplete, result = pcall(function()
                    if type(t) == 'table' and t._ccode_event then
                        t = COPY_TABLE(t)
                        t._ccode_event = nil
                    end

                    if validate then
                        local t = COPY_TABLE(t)

                        for k, v in pairs(t) do
                            if type(k) ~= 'string' and type(k) ~= 'number' then
                                t[k], t[tostring(k)] = nil, v
                            end
                        end

                        return JSON[prettify and 'encode' or 'prettify'](t)
                    end

                    return JSON[prettify and 'encode' or 'prettify'](t)
                end) return isComplete and result or '{}'
            end

            M['gsub'] = function(str, pattern, replace, n)
                local isComplete, result = pcall(function()
                    return UTF8.gsub(str, pattern, replace, n)
                end) return isComplete and result or str
            end

            M['sub'] = function(str, i, j)
                local isComplete, result = pcall(function()
                    return UTF8.sub(str, i, j)
                end) return isComplete and result or str
            end

            M['len'] = function(str)
                local isComplete, result = pcall(function()
                    return UTF8.len(str)
                end) return isComplete and result or 0
            end

            M['find'] = function(str, pattern, i, plain)
                local isComplete, result = pcall(function()
                    return UTF8.find(str, pattern, i, plain)
                end) return isComplete and result or nil
            end

            M['split'] = function(str, sep)
                local isComplete, result = pcall(function()
                    return UTF8.split(str, sep)
                end) return isComplete and result or {}
            end

            M['match'] = function(str, pattern, i)
                local isComplete, result = pcall(function()
                    return UTF8.match(str, pattern, i)
                end) return isComplete and result or nil
            end

            M['rep'] = function(str, count)
                local isComplete, result = pcall(function()
                    return str:rep(count)
                end) return isComplete and result or str
            end

            M['reverse'] = function(str)
                local isComplete, result = pcall(function()
                    return UTF8.reverse(str)
                end) return isComplete and result or str
            end

            M['upper'] = function(str)
                local isComplete, result = pcall(function()
                    return UTF8.upper(str)
                end) return isComplete and result or str
            end

            M['lower'] = function(str)
                local isComplete, result = pcall(function()
                    return UTF8.lower(str)
                end) return isComplete and result or str
            end

            M['byte'] = function(str, noSum)
                local isComplete, result = pcall(function()
                    if noSum then
                        return UTF8.trim((function(s) for i = 1, UTF8.len(str) do s = s .. ' ' .. UTF8.byte(UTF8.sub(str, i, i)) end return s end)(''))
                    end return math.sum(UTF8.byte(str, 1, UTF8.len(str)))
                end) return isComplete and result or nil
            end

            M['char'] = function(byte, noSum)
                local isComplete, result = pcall(function()
                    if noSum then
                        local result = '' while UTF8.find(byte, ' ') do
                            result, byte = result .. UTF8.char(UTF8.sub(byte, 1, UTF8.find(byte, ' ') - 1)), UTF8.sub(byte, UTF8.find(byte, ' ') + 1)
                        end return result .. UTF8.char(byte)
                    end return UTF8.char(byte)
                end) return isComplete and result or nil
            end

            M['get_ip'] = function(any)
                local isComplete, result = pcall(function()
                    return SERVER.getIP()
                end) return isComplete and result or nil
            end

            M['color_pixel'] = function(x, y)
                local isComplete, result = pcall(function()
                    local x = x or 0
                    local y = y or 0
                    local colors = {0, 0, 0, 0}

                    display.colorSample(CENTER_X + x, CENTER_Y - y, function(e)
                        colors = {math.round(e.r * 255), math.round(e.g * 255), math.round(e.b * 255), math.round(e.a * 255)}
                    end)

                    return colors
                end) return isComplete and result or {0, 0, 0, 0}
            end

            M['timer'] = function()
                return system.getTimer() - GAME.timer
            end

            M['unix_time'] = function()
                return os.time()
            end

            M['parameter'] = function(name, type, parameter)
                local isComplete, result = pcall(function()
                    if name == nil and type ~= nil then
                        return GAME.group[type]
                    elseif name == nil then
                        return GAME.group
                    elseif parameter == nil then
                        return GAME.group[type][name or '0']
                    else
                        return GAME.group[type][name or '0'] and GAME.group[type][name or '0'][parameter] or nil
                    end
                end) return isComplete and result or nil
            end

            return M
        end

        local function getMath()
            local M = {}

            local sin = math.sin
            local cos = math.cos
            local tan = math.tan
            local asin = math.asin
            local acos = math.acos
            local atan = math.atan
            local atan2 = math.atan2
            local random = math.random
            local factorial = math.factorial
            local radical = math.sqrt
            local log10 = math.log10
            local log0 = math.log
            local getMaskBits = math.getMaskBits
            local getBit = math.getBit
            local round = math.round

            M.randomseed = math.randomseed
            M.sum = math.sum
            M.pi = math.pi

            M.module = math.abs
            M.power = math.pow
            M.hex = math.hex
            M.exp = math.exp
            M.max = math.max
            M.min = math.min

            M['round'] = function(num, exp)
                local isComplete, result = pcall(function()
                    return round(num, exp)
                end) return isComplete and result or 0
            end

            M['getMaskBits'] = function(t)
                local isComplete, result = pcall(function()
                    return getMaskBits(t)
                end) return isComplete and result or 0
            end

            M['getBit'] = function(num)
                local isComplete, result = pcall(function()
                    return getBit(num)
                end) return isComplete and result or 0
            end

            M['log10'] = function(num)
                local isComplete, result = pcall(function()
                    return log10(num)
                end) return isComplete and result or 0
            end

            M['log0'] = function(num)
                local isComplete, result = pcall(function()
                    return log0(num)
                end) return isComplete and result or 0
            end

            M['radical'] = function(num)
                local isComplete, result = pcall(function()
                    return radical(num)
                end) return isComplete and result or 0
            end

            M['factorial'] = function(num)
                local isComplete, result = pcall(function()
                    return factorial(num)
                end) return isComplete and result or 0
            end

            M['random'] = function(num1, num2)
                local isComplete, result = pcall(function()
                    return random(num1, num2)
                end) return isComplete and result or 0
            end

            M['remainder'] = function(num, count)
                local isComplete, result = pcall(function()
                    return num % count
                end) return isComplete and result or 0
            end

            M['raycast'] = function(x1, y1, x2, y2, behavior)
                local isComplete, result = pcall(function()
                    local rayT = PHYSICS.rayCast(CENTER_X + x1, CENTER_Y - y1, CENTER_X + x2, CENTER_Y - y2, behavior or 'closest')
                    local returnRayT = {}

                    for i = 1, #rayT do
                        returnRayT[i] = {
                            x = rayT[i].position.x, y = rayT[i].position.y, name = rayT[i].object.name,
                            normalX = rayT[i].normal.x, normalY = rayT[i].normal.y, fraction = rayT[i].fraction
                        }
                    end

                    if #returnRayT == 1 then
                        returnRayT = returnRayT[1]
                    end

                    return returnRayT
                end) return isComplete and result or {}
            end

            M['asin'] = function(num)
                local isComplete, result = pcall(function()
                    return asin(num) * 180 / M.pi
                end) return isComplete and result or 0
            end

            M['acos'] = function(num)
                local isComplete, result = pcall(function()
                    return acos(num) * 180 / M.pi
                end) return isComplete and result or 0
            end

            M['atan'] = function(num)
                local isComplete, result = pcall(function()
                    return atan(num) * 180 / M.pi
                end) return isComplete and result or 0
            end

            M['atan2'] = function(y, x)
                local isComplete, result = pcall(function()
                    return atan2(y, x) * 180 / M.pi
                end) return isComplete and result or 0
            end

            M['sin'] = function(num)
                local isComplete, result = pcall(function()
                    return tonumber(string.format('%.4f', sin(num * M.pi / 180)))
                end) return isComplete and result or 0
            end

            M['cos'] = function(num)
                local isComplete, result = pcall(function()
                    return tonumber(string.format('%.4f', cos(num * M.pi / 180)))
                end) return isComplete and result or 0
            end

            M['tan'] = function(num)
                local isComplete, result = pcall(function()
                    return tonumber(string.format('%.4f', tan(num * M.pi / 180)))
                end) return isComplete and result or 0
            end

            M['ctan'] = function(num)
                local isComplete, result = pcall(function()
                    return tonumber(string.format('%.4f', 1 / tan(num * M.pi / 180)))
                end) return isComplete and result or 0
            end

            return M
        end

        local function getProp()
            local M = {}

            if 'Объект' then
                M['obj.touch'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GAME.group.objects[name]._touch or false
                    end) return isComplete and result
                end

                M['obj.var'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GAME.group.objects[name]._data or {}
                    end) return isComplete and result or {}
                end

                M['obj.tag'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GAME.group.objects[name]._tag or ''
                    end) return isComplete and result or ''
                end

                M['obj.pos_x'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GET_X(GAME.group.objects[name].x, GAME.group.objects[name]) or 0
                    end) return isComplete and result or 0
                end

                M['obj.pos_y'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GET_Y(GAME.group.objects[name].y, GAME.group.objects[name]) or 0
                    end) return isComplete and result or 0
                end

                M['obj.width'] = function(name)
                    local isComplete, result = pcall(function()
                        return (GAME.group.objects[name] and GAME.group.objects[name]._radius)
                        and (GAME.group.objects[name].path.radius or 0) or (GAME.group.objects[name] and GAME.group.objects[name].width or 0)
                    end) return isComplete and result or 0
                end

                M['obj.height'] = function(name)
                    local isComplete, result = pcall(function()
                        return (GAME.group.objects[name] and GAME.group.objects[name]._radius)
                        and (GAME.group.objects[name].path.radius or 0) or (GAME.group.objects[name] and GAME.group.objects[name].height or 0)
                    end) return isComplete and result or 0
                end

                M['obj.rotation'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GAME.group.objects[name].rotation or 0
                    end) return isComplete and result or 0
                end

                M['obj.alpha'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GAME.group.objects[name].alpha * 100 or 100
                    end) return isComplete and result or 100
                end

                M['obj.distance'] = function(name1, name2)
                    local isComplete, result = pcall(function()
                        return _G.math.sqrt(((GAME.group.objects[name1].x - GAME.group.objects[name2].x) ^ 2)
                        + ((GAME.group.objects[name1].y - GAME.group.objects[name2].y) ^ 2))
                    end) return isComplete and result or 0
                end

                M['obj.name_texture'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name] and GAME.group.objects[name]._name or ''
                    end) return isComplete and result or ''
                end

                M['obj.velocity_x'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name]._body ~= '' and select(1, GAME.group.objects[name]:getLinearVelocity()) or 0
                    end) return isComplete and result or 0
                end

                M['obj.velocity_y'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name]._body ~= '' and 0 - select(2, GAME.group.objects[name]:getLinearVelocity()) or 0
                    end) return isComplete and result or 0
                end

                M['obj.angular_velocity'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.objects[name]._body ~= '' and GAME.group.objects[name].angularVelocity or 0
                    end) return isComplete and result or 0
                end
            end

            if 'Текст' then
                M['text.get_text'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name or '0'] and GAME.group.texts[name or '0'].text or ''
                    end) return isComplete and result or ''
                end

                M['text.tag'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name] and GAME.group.texts[name]._tag or ''
                    end) return isComplete and result or ''
                end

                M['text.pos_x'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name] and GET_X(GAME.group.texts[name].x, GAME.group.texts[name]) or 0
                    end) return isComplete and result or 0
                end

                M['text.pos_y'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name] and GET_Y(GAME.group.texts[name].y, GAME.group.texts[name]) or 0
                    end) return isComplete and result or 0
                end

                M['text.width'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name] and GAME.group.texts[name].width or 0
                    end) return isComplete and result or 0
                end

                M['text.height'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name] and GAME.group.texts[name].height or 0
                    end) return isComplete and result or 0
                end

                M['text.rotation'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name] and GAME.group.texts[name].rotation or 0
                    end) return isComplete and result or 0
                end

                M['text.alpha'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.texts[name] and GAME.group.texts[name].alpha * 100 or 100
                    end) return isComplete and result or 100
                end
            end

            if 'Группа' then
                M['group.tag'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.groups[name] and GAME.group.groups[name]._tag or ''
                    end) return isComplete and result or ''
                end

                M['group.pos_x'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.groups[name] and GAME.group.groups[name].x or 0
                    end) return isComplete and result or 0
                end

                M['group.pos_y'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.groups[name] and 0 - GAME.group.groups[name].y or 0
                    end) return isComplete and result or 0
                end

                M['group.width'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.groups[name] and GAME.group.groups[name].width or 0
                    end) return isComplete and result or 0
                end

                M['group.height'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.groups[name] and GAME.group.groups[name].height or 0
                    end) return isComplete and result or 0
                end

                M['group.rotation'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.groups[name] and GAME.group.groups[name].rotation or 0
                    end) return isComplete and result or 0
                end

                M['group.alpha'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.groups[name] and GAME.group.groups[name].alpha * 100 or 100
                    end) return isComplete and result or 100
                end
            end

            if 'Виджет' then
                M['widget.tag'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.widgets[name] and GAME.group.widgets[name]._tag or ''
                    end) return isComplete and result or ''
                end

                M['widget.pos_x'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.widgets[name] and GET_X(GAME.group.widgets[name].x, GAME.group.widgets[name]) or 0
                    end) return isComplete and result or 0
                end

                M['widget.pos_y'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.widgets[name] and GET_Y(GAME.group.widgets[name].y, GAME.group.widgets[name]) or 0
                    end) return isComplete and result or 0
                end

                M['widget.value'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.widgets[name] and (GAME.group.widgets[name].wtype == 'slider' and GAME.group.widgets[name].value or 0) or 50
                    end) return isComplete and result or 50
                end

                M['widget.state'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.widgets[name]
                            and (GAME.group.widgets[name].wtype == 'switch' and GAME.group.widgets[name].isOn or false) or false
                    end) return isComplete and result
                end

                M['widget.text'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.widgets[name] and (GAME.group.widgets[name].wtype == 'field' and GAME.group.widgets[name].text or '') or ''
                    end) return isComplete and result or ''
                end

                M['widget.link'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.widgets[name] and (GAME.group.widgets[name].wtype == 'webview' and GAME.group.widgets[name].url or '') or ''
                    end) return isComplete and result or ''
                end
            end

            if 'Медиа' then
                M['media.current_time'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.media[name] and GAME.group.media[name].currentTime or 0
                    end) return isComplete and result or 0
                end

                M['media.total_time'] = function(name)
                    local isComplete, result = pcall(function()
                        return GAME.group.media[name] and GAME.group.media[name].totalTime or 0
                    end) return isComplete and result or 0
                end

                M['media.sound_volume'] = function(name)
                    local isComplete, result = pcall(function()
                        return audio.getVolume((GAME.group.media[name] and GAME.group.media[name][2]) and {channel=GAME.group.media[name][2]} or nil)
                    end) return isComplete and result or 0
                end

                M['media.sound_total_time'] = function(name)
                    local isComplete, result = pcall(function()
                        return (GAME.group.media[name] and GAME.group.media[name][1]) and audio.getDuration(GAME.group.media[name][1]) or 0
                    end) return isComplete and result or 0
                end

                M['media.sound_pause'] = function(name)
                    local isComplete, result = pcall(function()
                        return (GAME.group.media[name] and GAME.group.media[name][2]) and audio.isChannelPaused(GAME.group.media[name][2]) or nil
                    end) return isComplete and result or nil
                end

                M['media.sound_play'] = function(name)
                    local isComplete, result = pcall(function()
                        return (GAME.group.media[name] and GAME.group.media[name][2]) and audio.isChannelPlaying(GAME.group.media[name][2]) or nil
                    end) return isComplete and result or nil
                end
            end

            if 'Файлы' then
                M['files.length'] = function(path, isTemp) print(path, isTemp)
                    local isComplete, result = pcall(function()
                        return GANIN.file('length', DOC_DIR .. '/' .. CURRENT_LINK .. '/' .. (isTemp and 'Temps' or 'Documents') .. '/' .. path)
                    end) return isComplete and result or 0
                end

                M['files.is_file'] = function(path, isTemp)
                    local isComplete, result = pcall(function()
                        return GANIN.file('is_file', DOC_DIR .. '/' .. CURRENT_LINK .. '/' .. (isTemp and 'Temps' or 'Documents') .. '/' .. path)
                    end) return isComplete and result or false
                end

                M['files.is_folder'] = function(path, isTemp)
                    local isComplete, result = pcall(function()
                        return GANIN.file('is_folder', DOC_DIR .. '/' .. CURRENT_LINK .. '/' .. (isTemp and 'Temps' or 'Documents') .. '/' .. path)
                    end) return isComplete and result or false
                end

                M['files.length_folder'] = function(path, isTemp)
                    local isComplete, result = pcall(function()
                        return GANIN.file('length_folder', DOC_DIR .. '/' .. CURRENT_LINK .. '/' .. (isTemp and 'Temps' or 'Documents') .. '/' .. path)
                    end) return isComplete and result or 0
                end

                M['files.last_modified'] = function(path, isTemp)
                    local isComplete, result = pcall(function()
                        return GANIN.file('last_modified', DOC_DIR .. '/' .. CURRENT_LINK .. '/' .. (isTemp and 'Temps' or 'Documents') .. '/' .. path)
                    end) return isComplete and result or 0
                end
            end

            return M
        end

        local function getSelect()
            local M = {}

            M['dynamic'] = function()
                return 'dynamic'
            end

            M['static'] = function()
                return 'static'
            end

            M['forward'] = function()
                return 'forward'
            end

            M['bounce'] = function()
                return 'bounce'
            end

            M['backgroundTrue'] = function()
                return true
            end

            M['backgroundFalse'] = function()
                return false
            end

            M['canvasModeAppend'] = function()
                return 'append'
            end

            M['canvasModeDiscard'] = function()
                return 'discard'
            end

            M['snapshotGroup'] = function()
                return 'group'
            end

            M['snapshotCanvas'] = function()
                return 'canvas'
            end

            M['ruleTrue'] = function()
                return true
            end

            M['ruleFalse'] = function()
                return false
            end

            M['alignLeft'] = function()
                return 'left'
            end

            M['alignRight'] = function()
                return 'right'
            end

            M['alignCenter'] = function()
                return 'center'
            end

            M['inputDefault'] = function()
                return 'default'
            end

            M['inputNumber'] = function()
                return 'number'
            end

            M['inputDecimal'] = function()
                return 'decimal'
            end

            M['inputPhone'] = function()
                return 'phone'
            end

            M['inputUrl'] = function()
                return 'url'
            end

            M['inputEmail'] = function()
                return 'email'
            end

            M['inputNoEmoji'] = function()
                return 'noemoji'
            end

            M['pic'] = function()
                return 'objects'
            end

            M['obj'] = function()
                return 'objects'
            end

            M['text'] = function()
                return 'texts'
            end

            M['group'] = function()
                return 'groups'
            end

            M['widget'] = function()
                return 'widgets'
            end

            M['snapshot'] = function()
                return 'snapshots'
            end

            M['tag'] = function()
                return 'tags'
            end

            M['switchRadio'] = function()
                return 'radio'
            end

            M['switchToggle'] = function()
                return 'onOff'
            end

            M['switchCheckbox'] = function()
                return 'checkbox'
            end

            M['switchOn'] = function()
                return true
            end

            M['switchOff'] = function()
                return false
            end

            M['fileTypeBin'] = function()
                return true
            end

            M['fileTypeNonBin'] = function()
                return false
            end

            M['docTypeDocs'] = function()
                return 'Documents'
            end

            M['docTypeTemps'] = function()
                return 'Temps'
            end

            M['spriteTypeLinear'] = function()
                return 'linear'
            end

            M['spriteTypePixel'] = function()
                return 'nearest'
            end

            M['adsInterstitial'] = function()
                return 'interstitial'
            end

            M['adsRewardedVideo'] = function()
                return 'rewardedVideo'
            end

            M['adsVideo'] = function()
                return 'video'
            end

            return M
        end

        local function getOther()
            local M = {}

            M.getBitmapTexture = function(link, name)
                local data, width, height = IMPACK.image.load(link, system.DocumentsDirectory, {req_comp = 3})
                local x, y, size = 1, 1, width * height

                GAME.group.bitmaps[name] = BITMAP.newTexture({width = width, height = height})

                for i = 1, size do
                    local args = {data:byte(i * 3 - 2, i * 3)}
                    GAME.group.bitmaps[name]:setPixel(x, y, args[1] / 255, args[2] / 255, args[3] / 255, 1)
                    x = x == width and 1 or x + 1
                    y = x == 1 and y + 1 or y
                end

                GAME.group.bitmaps[name]:invalidate()
            end

            M.getPhysicsParams = function(friction, bounce, density, hitbox, filter)
                local params = {friction = friction, bounce = bounce, density = density}
                local hitbox = COPY_TABLE(hitbox)

                if filter and filter[1] and filter[2] then
                    params.filter = {
                        categoryBits = math.getBit(filter[1]),
                        maskBits = math.getMaskBits(filter[2])
                    }
                end

                if hitbox.type == 'box' then
                    params.box = {
                        halfWidth = hitbox.halfWidth, halfHeight = hitbox.halfHeight,
                        x = hitbox.offsetX, y = hitbox.offsetY, angle = hitbox.rotation
                    }
                elseif hitbox.type == 'circle' then
                    params.radius = hitbox.radius
                elseif hitbox.type == 'mesh' then
                    params.outline = hitbox.outline
                elseif hitbox.type == 'polygon' then
                    if type(hitbox.shape) == 'table' then
                        if type(hitbox.shape[1]) == 'table' then
                            local _params = COPY_TABLE(params) params = {}

                            for i = 1, #hitbox.shape do
                                params[i] = COPY_TABLE(_params)

                                for j = 1, #hitbox.shape[i] do
                                    if j % 2 == 0 then
                                        hitbox.shape[i][j] = -hitbox.shape[i][j]
                                    end
                                end

                                params[i].shape = hitbox.shape[i]
                            end
                        else
                            for i = 1, #hitbox.shape do
                                if i % 2 == 0 then
                                    hitbox.shape[i] = -hitbox.shape[i]
                                end
                            end

                            params.shape = hitbox.shape
                        end
                    else
                        params.shape = hitbox.shape
                    end
                end

                return params
            end

            M.getPath = function(path, docType, isShort, isFolder)
                if UTF8.find(path, '%.%.') then return nil end
                return (isShort and '' or (DOC_DIR .. '/')) .. CURRENT_LINK .. '/' .. docType .. (isFolder and '' or '/' .. path)
            end

            M.getResource = function(link)
                for i = 1, #GAME.RESOURCES.others do
                    if GAME.RESOURCES.others[i][1] == link then
                        return CURRENT_LINK .. '/Resources/' .. GAME.RESOURCES.others[i][2]
                    elseif GAME.RESOURCES.others[i][1] == 'Documents:' .. link or GAME.RESOURCES.others[i][1] == 'Temps:' .. link then
                        return GAME.RESOURCES.others[i][2]
                    end
                end
            end

            M.getSound = function(link)
                for i = 1, #GAME.RESOURCES.sounds do
                    if GAME.RESOURCES.sounds[i][1] == link then
                        return CURRENT_LINK .. '/Sounds/' .. GAME.RESOURCES.sounds[i][2]
                    elseif GAME.RESOURCES.sounds[i][1] == 'Documents:' .. link or GAME.RESOURCES.sounds[i][1] == 'Temps:' .. link then
                        return GAME.RESOURCES.sounds[i][2]
                    end
                end
            end

            M.getVideo = function(link)
                for i = 1, #GAME.RESOURCES.videos do
                    if GAME.RESOURCES.videos[i][1] == link then
                        return CURRENT_LINK .. '/Videos/' .. GAME.RESOURCES.videos[i][2]
                    elseif GAME.RESOURCES.videos[i][1] == 'Documents:' .. link or GAME.RESOURCES.videos[i][1] == 'Temps:' .. link then
                        return GAME.RESOURCES.videos[i][2]
                    end
                end
            end

            M.getImage = function(link)
                for i = 1, #GAME.RESOURCES.images do
                    if GAME.RESOURCES.images[i][1] == link then
                        return CURRENT_LINK .. '/Images/' .. GAME.RESOURCES.images[i][3], GAME.RESOURCES.images[i][2] or 'nearest'
                    elseif GAME.RESOURCES.images[i][1] == 'Documents:' .. link or GAME.RESOURCES.images[i][1] == 'Temps:' .. link then
                        return GAME.RESOURCES.images[i][3], GAME.RESOURCES.images[i][2] or 'nearest'
                    end
                end
            end

            M.getFont = function(font)
                for i = 1, #GAME.RESOURCES.fonts do
                    if GAME.RESOURCES.fonts[i][1] == font then
                        if CURRENT_LINK ~= 'App' then
                            local new_font = io.open(DOC_DIR .. '/' .. CURRENT_LINK .. '/Fonts/' .. GAME.RESOURCES.fonts[i][2], 'rb')
                            local main_font = io.open(RES_PATH .. '/' .. CURRENT_LINK .. '_' .. GAME.RESOURCES.fonts[i][2], 'wb')

                            if new_font and main_font then
                                main_font:write(new_font:read('*a'))
                                io.close(main_font)
                                io.close(new_font)
                            end

                            return CURRENT_LINK .. '_' .. GAME.RESOURCES.fonts[i][2]
                        end

                        return GAME.RESOURCES.fonts[i][2]
                    elseif GAME.RESOURCES.fonts[i][1] == 'Documents:' .. font or GAME.RESOURCES.fonts[i][1] == 'Temps:' .. font then
                        local rfilename = UTF8.reverse(GAME.RESOURCES.fonts[i][2])
                        local filename = UTF8.reverse(UTF8.sub(rfilename, 1, UTF8.find(rfilename, '%/') - 1))
                        local new_font = io.open(GAME.RESOURCES.fonts[i][2], 'rb')
                        local main_font = io.open(RES_PATH .. '/' .. CURRENT_LINK .. '_' .. filename, 'wb')

                        if new_font and main_font then
                            main_font:write(new_font:read('*a'))
                            io.close(main_font)
                            io.close(new_font)
                        end

                        return CURRENT_LINK .. '_' .. filename
                    end
                end

                return font
            end

            return M
        end

        DEVICE_ID = CRYPTO.hmac(CRYPTO.sha256, system.getInfo('deviceID'), system.getInfo('deviceID') .. 'md5')
        local fun, device, other, select, math, prop = getFun(), getDevice(), getOther(), getSelect(), getMath(), getProp()
]===])

local BLOCK = require 'Core.Modules.interface-block'
local M = {}

GANIN.az(DOC_DIR, BUILD)

local genBlocks = function()
    local data, index = GET_GAME_CODE(CURRENT_LINK), 0
    -- local rightScripts = {}

    for i = 1, #data.folders.scripts do
        M.folder(data.folders.scripts[i][1], #M.group.blocks + 1, i, data.folders.scripts[i][3])

        for j = 1, #data.folders.scripts[i][2] do
            -- table.insert(rightScripts, data.folders.scripts[i][2][j])

            if not data.folders.scripts[i][3] then
                local script = GET_GAME_SCRIPT(CURRENT_LINK, index + j, data)
                if script then M.new(script.title, #M.group.blocks + 1, script.comment) end
            end
        end

        index = index + #data.folders.scripts[i][2]
    end

    -- if JSON.encode(rightScripts) ~= JSON.encode(data.scripts) then
    --     data.scripts = rightScripts SET_GAME_CODE(CURRENT_LINK, data)
    --     SCRIPTS.group:removeSelf() SCRIPTS.group = nil
    --     SCRIPTS.create() SCRIPTS.group.isVisible = true
    -- end
end

M.folder = function(title, index, indexFolder, commentFolder)
    BLOCK.new(title, M.scroll, M.group, 'scripts', index, nil, nil, false, indexFolder, commentFolder)
end

M.new = function(title, index, comment)
    BLOCK.new(title, M.scroll, M.group, 'scripts', index, nil, nil, comment)
end

M.create = function()
    M.group = display.newGroup()
    M.group.isVisible = false
    M.group.data = {}
    M.group.blocks = {}

    local bg = display.newImage(THEMES.bg(), CENTER_X, CENTER_Y)
        bg.width = CENTER_X == 641 and DISPLAY_HEIGHT or DISPLAY_WIDTH
        bg.height = CENTER_X == 641 and DISPLAY_WIDTH or DISPLAY_HEIGHT
        bg.rotation = CENTER_X == 641 and 90 or 0
    M.group:insert(bg)

    local title = display.newText(STR['program.' .. (NOOBMODE and 'scenarios' or 'scripts')], ZERO_X + 40, ZERO_Y + 30, 'ubuntu', 50)
        title:setFillColor(unpack(LOCAL.themes.text))
        title.anchorX = 0
        title.anchorY = 0
        title.button = 'but_title'
        title:addEventListener('touch', require 'Core.Interfaces.scripts')
    M.group:insert(title)

    local title_list = display.newText('', CENTER_X, ZERO_Y + 62, 'ubuntu', 26)
        title_list:setFillColor(unpack(LOCAL.themes.text))
        title_list.x = (title.x + title.width + MAX_X) / 2
        title_list.isVisible = false
    M.group:insert(title_list)

    local but_add = display.newImage(THEMES.add(), ZERO_X + 190, MAX_Y - 95)
        but_add.alpha = 0.9
        but_add.button = 'but_add'
        but_add:addEventListener('touch', require 'Core.Interfaces.scripts')
    M.group:insert(but_add)

    local but_play = display.newImage(THEMES.play(), MAX_X - 190, MAX_Y - 95)
        but_play.alpha = 0.9
        but_play.button = 'but_play'
        but_play:addEventListener('touch', require 'Core.Interfaces.scripts')
    M.group:insert(but_play)

    local but_list = display.newImage(THEMES.listopenbut(), MAX_X - 80, ZERO_Y + 62)
        but_list.width, but_list.height = 60, 60
        but_list.button = 'but_list'
        but_list:addEventListener('touch', require 'Core.Interfaces.scripts')
    M.group:insert(but_list)

    local but_okay = display.newImage(THEMES.okay(), MAX_X - 190, MAX_Y - 95)
        but_okay.alpha = 0.9
        but_okay.isVisible = false
        but_okay.button = 'but_okay'
        but_okay:addEventListener('touch', require 'Core.Interfaces.scripts')
    M.group:insert(but_okay)

    M.scroll = WIDGET.newScrollView({
            x = CENTER_X, y = (but_add.y - but_add.height / 2 - 30 + but_list.y + 72) / 2,
            width = DISPLAY_WIDTH, height = but_add.y - but_add.height / 2 - but_list.y - 102,
            hideBackground = true, hideScrollBar = true, friction = tonumber(LOCAL.scroll_friction) / 1000,
            horizontalScrollDisabled = true, isBounceEnabled = true
        })
    M.group:insert(M.scroll)

    genBlocks()
end

return M

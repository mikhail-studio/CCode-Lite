local LOCAL_STR = {
    'program.scripts',
    'program.images',
    'program.levels',
    'program.sounds',
    'program.videos',
    'program.fonts',
    'program.resources',
    'menu.settings',
    'program.export',
    'program.build',
    'program.aab'
}

GANIN.az(DOC_DIR, BUILD)

local BLOCK = require 'Core.Modules.interface-block'
local M = {}

local genBlocks = function()
    for i = 1, #LOCAL_STR do
        BLOCK.new(STR[LOCAL_STR[i]], M.scroll, M.group, 'program', #M.group.blocks + 1)
    end
end

local lastMin = ''
local backupTimerFunc = function()
    local date = os.date('*t')
    local hour, minute = tostring(date.hour), tostring(date.min)
    local diff = tonumber(LOCAL.backup_frequency)
    local minutes, checkMin = {}, 0

    while checkMin < 60 do
        minutes[tostring(checkMin)] = true
        checkMin = checkMin + diff
    end

    if LOCAL.auto_ad and tonumber(minute) % 10 == 0 and minute ~= lastMin then
        if not IS_WIN and not IS_SIM then
            lastMin = minute
            GANIN.ads('show', 'video')
        end
    end

    if minutes[minute] then
        local minute = minute == '0' and '00' or minute
        local path = DOC_DIR .. '/' .. CURRENT_LINK .. '/Backups/' .. hour .. '.' .. minute
        local pathData = DOC_DIR .. '/' .. CURRENT_LINK .. '/Backups/data.json'
        local pathScript = DOC_DIR .. '/' .. CURRENT_LINK .. '/Scripts'

        if not IS_FOLDER(DOC_DIR .. '/' .. CURRENT_LINK .. '/Backups') then
            LFS.mkdir(DOC_DIR .. '/' .. CURRENT_LINK .. '/Backups')
        end

        if not IS_FOLDER(path) then
            local data = READ_FILE(pathData) LFS.mkdir(path)
            local gameData = GET_GAME_CODE(CURRENT_LINK)
            local scripts = gameData.scripts
            local folders = gameData.folders.scripts

            for file in LFS.dir(pathScript) do
                if file ~= '.' and file ~= '..' then
                    OS_COPY(pathScript .. '/' .. file, path .. '/' .. file)
                end
            end

            if data then
                local data = JSON.decode(data)

                if #data == 8 then
                    OS_REMOVE(DOC_DIR .. '/' .. CURRENT_LINK .. '/Backups/' .. data[8][1], true)
                    table.remove(data, 8)
                end

                table.insert(data, 1, {hour .. '.' .. minute, scripts, folders})
                WRITE_FILE(pathData, JSON.encode(data))
            else
                WRITE_FILE(pathData, JSON.encode({{hour .. '.' .. minute, scripts, folders}}))
            end
        end
    end
end

M.startTimer = function()
    M.backupTimer = timer.new(45000, 0, backupTimerFunc)
    backupTimerFunc()
end

M.create = function(app, noobmode)
    M.group = display.newGroup()
    M.group.isVisible = false
    M.group.data = {}
    M.group.blocks = {}

    if noobmode then
        LOCAL_STR[1] = 'program.scenarios'
        LOCAL_STR[2] = 'program.pictures'

        if LOCAL_STR[5] == 'program.videos' then
            table.remove(LOCAL_STR, 11)
            table.remove(LOCAL_STR, 7)
            table.remove(LOCAL_STR, 5)
        end

        if NEW_BLOCK and not NEW_BLOCK.noobmode then
            pcall(function() NEW_BLOCK.remove() end)
        end
    else
        LOCAL_STR[1] = 'program.scripts'
        LOCAL_STR[2] = 'program.images'

        if LOCAL_STR[5] ~= 'program.videos' then
            table.insert(LOCAL_STR, 5, 'program.videos')
            table.insert(LOCAL_STR, 7, 'program.resources')
            table.insert(LOCAL_STR, 11, 'program.aab')
        end

        if NEW_BLOCK and NEW_BLOCK.noobmode then
            pcall(function() NEW_BLOCK.remove() end)
        end
    end NOOBMODE = noobmode

    local bg = display.newImage(THEMES.bg(), CENTER_X, CENTER_Y)
        bg.width = CENTER_X == 641 and DISPLAY_HEIGHT or DISPLAY_WIDTH
        bg.height = CENTER_X == 641 and DISPLAY_WIDTH or DISPLAY_HEIGHT
        bg.rotation = CENTER_X == 641 and 90 or 0
    M.group:insert(bg)

    local title = display.newText(app, ZERO_X + 40, ZERO_Y + 30, 'ubuntu', 50)
        title:setFillColor(unpack(LOCAL.themes.text))
        title.anchorX = 0
        title.anchorY = 0
        title.button = 'but_title'
        title:addEventListener('touch', require 'Core.Interfaces.program')
    M.group:insert(title)

    local but_play = display.newImage(THEMES.play(), MAX_X - 190, MAX_Y - 95)
        but_play.alpha = 0.9
        but_play.button = 'but_play'
        but_play:addEventListener('touch', require 'Core.Interfaces.program')
    M.group:insert(but_play)

    M.scroll = WIDGET.newScrollView({
            x = CENTER_X, y = (but_play.y - but_play.height / 2 - 30 + (ZERO_Y + 62) + 72) / 2,
            width = DISPLAY_WIDTH, height = but_play.y - but_play.height / 2 - (ZERO_Y + 62) - 102,
            hideBackground = true, hideScrollBar = true, isBounceEnabled = true, horizontalScrollDisabled = true
        })
    M.group:insert(M.scroll)

    genBlocks()
    M.startTimer()
end

return M

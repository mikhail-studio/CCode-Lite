local listeners = {}
local FOLDER = require 'Core.Modules.interface-folder'
local LIST = require 'Core.Modules.interface-list'
local MOVE = require 'Core.Modules.interface-move'
local FILTER = require 'Core.Modules.name-filter'

GANIN.az(DOC_DIR, BUILD)

listeners.but_title = function(target)
    EXITS.levels()
end

listeners.but_add = function(target)
    LEVELS.group[8]:setIsLocked(true, 'vertical')
    if LEVELS.group.isVisible then
        local data = GET_GAME_CODE(CURRENT_LINK)
        INPUT.new(STR['levels.entername'], function(event)
            if (event.phase == 'ended' or event.phase == 'submitted') and not ALERT then
                FILTER.check(event.target.text, function(ev)
                    if ev.isError then
                        INPUT.remove(false)
                        WINDOW.new(STR['errors.' .. ev.typeError], {STR['button.close'], STR['button.okay']}, function() end, 5)
                    else
                        INPUT.remove(true, ev.text)
                    end
                end, LEVELS.group.blocks, data, 'levels')
            end
        end, function(e)
            LEVELS.group[8]:setIsLocked(false, 'vertical')

            if e.input then
                if not e.checkbox then
                    local numLevel = 1
                    local path = DOC_DIR .. '/' .. CURRENT_LINK .. '/Levels'

                    while true do
                        local file = io.open(path .. '/Level' .. numLevel, 'r')
                        if file then
                            numLevel = numLevel + 1
                            io.close(file)
                        else
                            local path = path .. '/Level' .. numLevel
                            local folderIsComment = data.folders.levels[1][3]

                            if folderIsComment then
                                FOLDER.show(LEVELS.group.blocks[1], LEVELS.group, 'levels', data, 1, 1)
                            end

                            table.insert(data.resources.levels, 1, {e.text, 'Level' .. numLevel})
                            table.insert(data.folders.levels[1][2], 1, data.resources.levels[1])

                            SET_GAME_CODE(CURRENT_LINK, data)
                            WRITE_FILE(path, JSON.encode3({title = e.text, params = {
                                {
                                    _id = 'test',
                                    _w = 200,
                                    _h = 200,
                                    _x = 0,
                                    _y = 0,
                                    _r = 45
                                }
                            }}))
                            LEVELS.new(e.text, 2, 'Level' .. numLevel)

                            if folderIsComment then
                                FOLDER.hide(nil, LEVELS.group, 'levels', nil, 1, 1, data)
                            end

                            break
                        end
                    end
                else
                    table.insert(data.folders.levels, {e.text, {}, false}) SET_GAME_CODE(CURRENT_LINK, data)
                    LEVELS.folder(e.text, #LEVELS.group.blocks + 1, #data.folders.levels, false)
                end
            end
        end, nil, STR['scripts.folder'])
    else
        LEVELS.group[8]:setIsLocked(false, 'vertical')
    end
end

listeners.but_play = function(target)
    GAME_GROUP_OPEN = LEVELS
    LEVELS.group.isVisible = false
    GAME = require 'Core.Simulation.start'
    GAME.new()
end

listeners.but_list = function(target)
    local list = #LEVELS.group.blocks == 0 and {} or {STR['button.remove'], STR['button.rename']}

    LEVELS.group[8]:setIsLocked(true, 'vertical')
    if LEVELS.group.isVisible then
        LIST.new(list, MAX_X, target.y - target.height / 2, 'down', function(e)
            LEVELS.group[8]:setIsLocked(false, 'vertical')

            if e.index ~= 0 and e.text ~= STR['button.find'] then
                ALERT = false
                INDEX_LIST = e.index
                EXITS.add(listeners.but_okay_end)
                LEVELS.group[3].isVisible = true
                LEVELS.group[4].isVisible = false
                LEVELS.group[5].isVisible = false
                LEVELS.group[6].isVisible = false
                LEVELS.group[7].isVisible = true
            end

            if e.text == STR['button.remove'] then
                MORE_LIST = true
                LEVELS.group[3].text = '(' .. STR['button.remove'] .. ')'

                for i = 1, #LEVELS.group.blocks do
                    pcall(function() LEVELS.group.blocks[i].checkbox.isVisible = true end)
                end
            elseif e.text == STR['button.rename'] then
                MORE_LIST = false
                LEVELS.group[3].text = '(' .. STR['button.rename'] .. ')'

                for i = 1, #LEVELS.group.blocks do
                    pcall(function() LEVELS.group.blocks[i].checkbox.isVisible = true end)
                end
            elseif e.text == STR['button.find'] then
                LEVELS.group[8]:setIsLocked(true, 'vertical')
                INPUT.new(STR['levels.entername'], function(event)
                    if (event.phase == 'ended' or event.phase == 'submitted') and not ALERT then
                        INPUT.remove(true, event.target.text)
                    end
                end, function(e)
                    LEVELS.group[8]:setIsLocked(false, 'vertical')

                    if e.input then
                        local data = GET_GAME_CODE(CURRENT_LINK)

                        for i = #LEVELS.group.data, 1, -1 do
                            LEVELS.group.blocks[i].remove(i)
                        end

                        for index, resource_config in pairs(data.resources.levels) do
                            if UTF8.find(UTF8.lower(resource_config[1]), UTF8.lower(e.text)) then
                                LEVELS.new(resource_config[1], #LEVELS.group.blocks + 1, resource_config[2])
                            end
                        end
                    end
                end)
            end
        end, nil, nil, 1)
    else
        LEVELS.group[8]:setIsLocked(false, 'vertical')
    end
end

listeners.but_okay_end = function()
    ALERT = true
    LEVELS.group[3].text = ''
    LEVELS.group[3].isVisible = false
    LEVELS.group[4].isVisible = true
    LEVELS.group[5].isVisible = true
    LEVELS.group[6].isVisible = true
    LEVELS.group[7].isVisible = false

    for i = 1, #LEVELS.group.blocks do
        pcall(function()
            LEVELS.group.blocks[i].checkbox.isVisible = false
            LEVELS.group.blocks[i].checkbox:setState({isOn = false})
        end)
    end
end

listeners.but_okay = function(target)
    ALERT = true
    EXITS.remove()
    LEVELS.group[3].text = ''
    LEVELS.group[3].isVisible = false
    LEVELS.group[4].isVisible = true
    LEVELS.group[5].isVisible = true
    LEVELS.group[6].isVisible = true
    LEVELS.group[7].isVisible = false

    if INDEX_LIST == 1 then
        local function deleteBlock()
            local data = GET_GAME_CODE(CURRENT_LINK)

            for i = #LEVELS.group.data, 1, -1 do
                if not LEVELS.group.blocks[i].indexFolder then
                    LEVELS.group.blocks[i].checkbox.isVisible = false

                    if LEVELS.group.blocks[i].checkbox.isOn then
                        local indexReal, indexInFolder = LEVELS.group.blocks[i].getRealIndex(LEVELS.group.blocks[i], data, 'levels')
                        local indexFolder = LEVELS.group.blocks[i].getFolderIndex(LEVELS.group.blocks[i])

                        table.remove(data.resources.levels, indexReal)
                        table.remove(data.folders.levels[indexFolder][2], indexInFolder)

                        OS_REMOVE(DOC_DIR .. '/' .. CURRENT_LINK .. '/Levels/' .. LEVELS.group.blocks[i].link)
                        LEVELS.group.blocks[i].remove(i)
                    end
                end
            end

            for j = 1, #LEVELS.group.blocks do
                local y = j == 1 and 25 or LEVELS.group.data[j - 1].y + 150
                pcall(function() LEVELS.group.blocks[j].y = y end)
                pcall(function() LEVELS.group.blocks[j].text.y = y end)
                pcall(function() LEVELS.group.blocks[j].polygon.y = y end)
                pcall(function() LEVELS.group.blocks[j].checkbox.y = y end)
                pcall(function() LEVELS.group.blocks[j].container.y = y end)
                pcall(function() LEVELS.group.data[j].y = y end)
            end

            SET_GAME_CODE(CURRENT_LINK, data)
            LEVELS.group[8]:setScrollHeight(150 * #LEVELS.group.data)
            LEVELS.group[8]:setIsLocked(false, 'vertical')
        end

        if LOCAL.confirm then
            LEVELS.group[8]:setIsLocked(true, 'vertical')
            WINDOW.new(STR['blocks.sure?'], {STR['blocks.delete.no'], STR['blocks.delete.yes']}, function(e)
                if e.index == 2 then
                    deleteBlock()
                else
                    LEVELS.group[8]:setIsLocked(false, 'vertical')
                    for i = 1, #LEVELS.group.blocks do
                        if not LEVELS.group.blocks[i].indexFolder then
                            LEVELS.group.blocks[i].checkbox.isVisible = false

                            if LEVELS.group.blocks[i].checkbox.isOn then
                                LEVELS.group.blocks[i].checkbox:setState({isOn = false})
                            end
                        end
                    end
                end
            end, 4)
        else
            deleteBlock()
        end
    elseif INDEX_LIST == 2 then
        local data = GET_GAME_CODE(CURRENT_LINK)

        for i = #LEVELS.group.blocks, 1, -1 do
            if not LEVELS.group.blocks[i].indexFolder then
                LEVELS.group.blocks[i].checkbox.isVisible = false

                if LEVELS.group.blocks[i].checkbox.isOn then
                    LEVELS.group.blocks[i].checkbox:setState({isOn = false})
                    INPUT.new(STR['levels.changename'], function(event)
                        if (event.phase == 'ended' or event.phase == 'submitted') and not ALERT then
                            FILTER.check(event.target.text, function(ev)
                                if ev.isError then
                                    INPUT.remove(false)
                                    WINDOW.new(STR['errors.' .. ev.typeError], {STR['button.close'], STR['button.okay']}, function() end, 5)
                                else
                                    INPUT.remove(true, ev.text)
                                end
                            end, LEVELS.group.blocks, data, 'levels')
                        end
                    end, function(e)
                        if e.input then
                            local indexReal, indexInFolder = LEVELS.group.blocks[i].getRealIndex(LEVELS.group.blocks[i], data, 'levels')
                            local indexFolder = LEVELS.group.blocks[i].getFolderIndex(LEVELS.group.blocks[i])
                            data.resources.levels[indexReal][1] = e.text
                            data.folders.levels[indexFolder][2][indexInFolder][1] = e.text
                            LEVELS.group.blocks[i].text.text = e.text
                            SET_GAME_CODE(CURRENT_LINK, data)
                        end
                    end, LEVELS.group.blocks[i].text.text)
                end
            end
        end
    end
end

return function(e)
    if LEVELS.group.isVisible and (ALERT or e.target.button == 'but_okay') then
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            e.target.click = true
            if e.target.button == 'but_list'
                then e.target.width, e.target.height = 52, 52
            else e.target.alpha = 0.6 end
        elseif e.phase == 'moved' and (math.abs(e.x - e.xStart) > 30 or math.abs(e.y - e.yStart) > 30) then
            e.target.click = false
            if e.target.button == 'but_list'
                then e.target.width, e.target.height = 60, 60
            elseif e.target.button == 'but_title'
                then e.target.alpha = 1
            else e.target.alpha = 0.9 end
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            if e.target.click then
                e.target.click = false
                if e.target.button == 'but_list'
                    then e.target.width, e.target.height = 60, 60
                elseif e.target.button == 'but_title'
                    then e.target.alpha = 1
                else e.target.alpha = 0.9 end
                listeners[e.target.button](e.target)
            end
        end
        return true
    end
end

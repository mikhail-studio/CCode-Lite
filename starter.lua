local function simStarter()
    MENU.group.isVisible = true
end

local function selectLanguage(listener)
    local langScroll = WIDGET.newScrollView({
        width = DISPLAY_WIDTH, height = 100 * #LANGS_TRANSLATE,
        x = CENTER_X, y = CENTER_Y, hideScrollBar = true,
        horizontalScrollDisabled = true, isBounceEnabled = true,
        hideBackground = true
    })

    local y = 50
    for i = 1, #LANGS_TRANSLATE do
        local langBlock = display.newRect(CENTER_X, y, DISPLAY_WIDTH, 100)
        langBlock:setFillColor(unpack(LOCAL.themes.bg))

        local langText = display.newText(LANGS_TRANSLATE[i], CENTER_X, y, 'ubuntu', 40)
        langBlock:addEventListener('touch', function(e)
            if e.phase == 'began' then
                display.getCurrentStage():setFocus(e.target)
                e.target:setFillColor(unpack(LOCAL.themes.bgAdd3Color))
                e.target.click = true
            elseif e.phase == 'moved' and (math.abs(e.yDelta) > 30 or math.abs(e.xDelta) > 30) then
                langScroll:takeFocus(e)
                e.target.click = false
                e.target:setFillColor(unpack(LOCAL.themes.bg))
            elseif e.phase == 'ended' or e.phase == 'cancelled' then
                display.getCurrentStage():setFocus(nil)
                e.target:setFillColor(unpack(LOCAL.themes.bg))
                if e.target.click then
                    e.target.click = false
                    LOCAL.lang = LANGS[i]
                    STR = LANG[LOCAL.lang]

                    for k, v in pairs(LANG.ru) do
                        if not STR[k] then
                            STR[k] = LANG.en[k] or v
                        elseif type(STR[k]) == 'table' then
                            for k2, v2 in ipairs(LANG.ru[k]) do
                                if not STR[k][k2] then
                                    STR[k][k2] = (LANG.en[k] and LANG.en[k][k2]) and LANG.en[k][k2] or v2
                                end
                            end
                        end
                    end

                    NEW_DATA()
                    MENU.group:removeSelf() MENU.group = nil
                    MENU.create() MENU.group.isVisible = true
                    langScroll:removeSelf() listener()
                end
            end
            return true
        end)

        langScroll:insert(langBlock)
        langScroll:insert(langText)

        y = y + 100
    end
end

local function checkFirstLaunch(listener, listenerFirstLaunch)
    if IS_SIM and LOCAL and LOCAL.first_launch then
        listener()
        return
    end

    timer.new(2, 1, function()
        if LOCAL.first_launch then
            if LOCAL.age and LOCAL.age >= 13 and LOCAL.age <= 90 then
                MENU.group.isVisible = true
                listener()
            else
                WINDOW.new(STR['beginner.age.banned'], {STR['button.okay']}, function(e)
                    native.requestExit()
                end)

                WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
            end
        else
            selectLanguage(function()
                MENU.group.isVisible = true
                WINDOW.new(STR['beginner.start.message'], {STR['beginner.start.button.anonim'], STR['button.okay']}, function(e)
                    if e.index == 1 then
                        LOCAL.name = STR['beginner.start.button.anonim']
                        LOCAL.gender = 'man' LOCAL.age = 18 LOCAL.first_launch = true
                        NEW_DATA()
                    elseif e.index == 2 then
                        timer.new(1, 1, function()
                            WINDOW.new(STR['beginner.gender.what'], {STR['beginner.gender.woman'], STR['beginner.gender.man']}, function(e)
                                if e.index ~= 0 then
                                    LOCAL.gender = e.index == 1 and 'woman' or 'man'
                                    timer.new(1, 1, function()
                                        WINDOW.new(STR['beginner.age.what'], {STR['button.okay']}, function(e)
                                            INPUT.new(STR['beginner.age'], function(e)
                                                if (e.phase == 'ended' or e.phase == 'submitted') and not ALERT then
                                                    INPUT.remove(true, e.target.text)
                                                end
                                            end, function(e)
                                                local age = tonumber(e.text)

                                                if age and age >= 13 and age <= 90 then
                                                    WINDOW.new(STR['beginner.name.what'], {STR['button.okay']}, function(e)
                                                        INPUT.new(STR['beginner.name'], function(e)
                                                            if (e.phase == 'ended' or e.phase == 'submitted') and not ALERT then
                                                                INPUT.remove(true, e.target.text)
                                                            end
                                                        end, function(e)
                                                            LOCAL.name = e.text
                                                            LOCAL.first_launch = true
                                                            NEW_DATA()

                                                            timer.new(1, 1, function()
                                                                WINDOW.new(STR['beginner.entrance'], {STR['button.okay']}, function(e)
                                                                    listenerFirstLaunch()
                                                                end)

                                                                WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                                                WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                                            end)
                                                        end)
                                                    end)

                                                    LOCAL.age = age
                                                    WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                                    WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                                else
                                                    WINDOW.new(STR['beginner.age.banned'], {STR['button.okay']}, function(e)
                                                        native.requestExit()
                                                    end)

                                                    WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                                    WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                                end
                                            end, '14')
                                        end)

                                        WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                        WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                    end)
                                else
                                    native.requestExit()
                                end
                            end)
                        end)
                    end
                end)
            end)
        end
    end)
end

if IS_SIM then
    MENU.create()
    checkFirstLaunch(simStarter, simStarter)
end

if not IS_SIM and not LIVE and false then
    local function testersListener()
        DEVICE_ID = CRYPTO.hmac(CRYPTO.sha256, system.getInfo('deviceID'), system.getInfo('deviceID') .. 'md5')
        MENU.create() MENU.group.isVisible = false

        pcall(function()
            OS_REMOVE(RES_PATH .. '/Core')
            OS_REMOVE(RES_PATH .. '/Data')
            OS_REMOVE(RES_PATH .. '/Interfaces')
            OS_REMOVE(RES_PATH .. '/Network')
            OS_REMOVE(RES_PATH .. '/Strings')
            OS_REMOVE(RES_PATH .. '/Sprites')
            OS_REMOVE(RES_PATH .. '/Emitter')
            OS_REMOVE(RES_PATH .. '/main.lua')
            OS_REMOVE(RES_PATH .. '/starter.lua')
        end)

        GANIN.ads('init', function(e)
            if e.result == 'finish' and e.adType == 'video' then
                CCOIN.set(tonumber(LOCAL.niocc) + 20)
            elseif e.adType == 'video' and (e.result == 'failLoad' or e.result == 'failShow') then
                LOCAL.ads_time = 0 NEW_DATA()
            end
        end)

        local perms = system.getInfo('grantedAppPermissions')
        local cdog = display.newImage('Sprites/Face/cdogFace1.png', 10000, 10000)
        local anime = display.newImage('Sprites/anime.png', 10000, 10000)
        local package = system.getInfo('androidAppPackageName')

        GIVE_PERMISSION_DATA()

        pcall(function()
            if cdog and anime then cdog:removeSelf() anime:removeSelf()
                for i = 1, #perms do
                    if perms[i] == 'android.permission.INTERNET' then
                        if package == 'com.ganin.ccode' then
                            GANIN.az(DOC_DIR, BUILD)

                            checkFirstLaunch(function()
                                if ARGS and _G.type(ARGS.url) == 'string' and ARGS.url ~= '' then
                                    MENU.group.isVisible = false
                                    FILE.getFileFromUri(DOC_DIR, ARGS.url, function(import)
                                        if type(import) == 'table' and import.done and import.done == 'ok' then
                                            PROGRAMS = require 'Interfaces.programs'
                                            PROGRAMS.create() ALERT = false
                                            PROGRAMS.group.isVisible = true
                                            PROGRAMS.group[8]:setIsLocked(true, 'vertical')
                                            require('Core.Share.import').new(function(e)
                                                ALERT = true PROGRAMS.group[8]:setIsLocked(false, 'vertical')
                                                if e.isError then WINDOW.new(STR['import.error'] .. e.idError,
                                                {STR['button.close'], STR['button.okay']}, function() end, 5)
                                                else WINDOW.new(STR['import.successfully'],
                                                {STR['button.close'], STR['button.okay']}, function() end, 2) end
                                            end, import)
                                        else MENU.group.isVisible = true end
                                    end, 'import.ccode')
                                end
                            end, function() end)
                        end

                        break
                    end
                end
            end
        end)

        if DEVICE_ID ~= '059dbe8863f1fa261b23001dfa8af8e37e857df22252ebbe301a9ab5d40ad740' then
            network.request('https://drive.google.com/uc?export=download&confirm=no_antivirus&id=1Cigzy-fFJywTnGpY1PLyWN3E67uZNSaE', 'GET', function(e)
                pcall(function()
                    if e.phase == 'ended' and not e.isError then
                        local response = JSON.decode(e.response)
                        local name = response[DEVICE_ID]
                        local version = response.version
                        local link = response.link

                        if LOCAL.name_tester == '' and name then
                            LOCAL.name_tester = name NEW_DATA()
                            if DEVELOPERS[name] then
                                MENU.group[3].text = STR['menu.developers'] .. '  ' .. name
                            elseif LOCAL.name_tester ~= '' then
                                MENU.group[3].text = STR['menu.testers'] .. '  ' .. name
                            end
                        end

                        -- if LOCAL.name_tester == '' then
                        --     DEVICE_ID = CRYPTO.hmac(CRYPTO.sha256, system.getInfo('deviceID'), system.getInfo('deviceID') .. 'md5')
                        --     if not IS_SIM then PASTEBOARD.copy('string', tostring(DEVICE_ID)) end
                        --     display.newText('DeviceID скопирован в буфер обмена', CENTER_X, CENTER_Y, 'ubuntu', 30)
                        --     display.newImage('Sprites/amogus.png', ZERO_X + 75, ZERO_Y + 75)
                        -- end

                        -- if version > BUILD then
                        --     WINDOW.new(STR['menu.version.new'], {STR['button.download']}, function(event)
                        --         network.download(link, 'GET', function(e)
                        --             if e.isError then
                        --                 system.openURL(link)
                        --                 native.requestExit()
                        --             elseif e.phase == 'progress' then
                        --                 local text = STR['menu.version.wait'] .. '\n' .. STR['menu.version.download'] .. ': '
                        --                 local text = text .. math.round(e.bytesTransferred / 1048576, 2) .. 'mb / '
                        --                 local text = text .. math.round(e.bytesEstimated / 1048576, 2) .. 'mb'
                        --                 WINDOW.remove() WINDOW.new(text, {}, function() end, 3)
                        --             elseif e.phase == 'ended' then
                        --                 WINDOW.remove()
                        --
                        --                 if LOCAL.old_update then
                        --                     EXPORT.export({
                        --                         path = DOC_DIR .. '/tester.apk', name = 'CCode b' .. version .. '.apk',
                        --                         listener = function(event)
                        --                             OS_REMOVE(DOC_DIR .. '/tester.apk')
                        --                             native.requestExit()
                        --                         end
                        --                     })
                        --                 else
                        --                     OS_MOVE(DOC_DIR .. '/tester.apk', MY_PATH .. '/tester.apk')
                        --                     GANIN.update(MY_PATH .. '/tester.apk')
                        --                 end
                        --             end
                        --         end, {progress = true}, 'tester.apk', system.DocumentsDirectory)
                        --     end, 2)
                        --     WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                        --     WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                        -- end
                    end
                end)
            end)
        end

        if false then
            MENU.group.isVisible = false

            timer.new(1000, 1, function()
                MENU.group.isVisible = false
            end)

            PROGRAMS = require 'Interfaces.programs'
            PROGRAMS.create()

            local data = GET_GAME_CODE(CURRENT_LINK)
            local script = GET_GAME_SCRIPT(CURRENT_LINK, 1, data)

            PROGRAM = require 'Interfaces.program'
            PROGRAM.create('App', data.noobmode)

            if script and script.custom then
                DEL_GAME_SCRIPT(CURRENT_LINK, 1, data)
                table.remove(data.scripts, 1)
                SET_GAME_CODE(CURRENT_LINK, data)
            end

            SCRIPTS = require 'Interfaces.scripts'
            SCRIPTS.create()

            LEVELS = require 'Interfaces.levels'
            LEVELS.create()

            LEVELS_VIEW = require 'Core.Levels.view'
            LEVELS_VIEW:create()
        end
    end

    -- display.newImageRect('Sprites/nolik.png', DISPLAY_WIDTH, DISPLAY_HEIGHT):translate(CENTER_X, CENTER_Y)
    pcall(function() OS_REMOVE(MY_PATH .. '/tester.apk') end) testersListener()
end

local LISTENER = require 'Core.Interfaces.robodog'
local M = {}

M.getPath = function(type, id)
    local ids = {'Face', 'Eyes', 'Ears', 'Mouth', 'Accessories'}
    if not id then id = LOCAL.dog[ids[type]:lower()] end
    return 'Sprites/' .. ids[type] .. '/cdog' .. ids[type] .. id .. '.png'
end

M.setAccess = function(type, id)
    LOCAL.dogs[({'face', 'eyes', 'ears', 'mouth', 'accessories'})[type]][id] = true
end

M.getAccess = function(type, id)
    local ids = {'face', 'eyes', 'ears', 'mouth', 'accessories'}
    return LOCAL.dogs[ids[type]][id] or LOCAL.dogs[ids[type]][tostring(id)]
end

M.getDog = function(x, y, width, height, num)
    local dog, a, i, j = display.newGroup()

    if type(num) == 'table' then
        i, j = num[1], num[2]
    end

    if LOCAL.old_dog and _G.type(num) == 'number' then
        a = display.newImage(dog, 'Sprites/ccdog' .. num .. '.png', x, y)
        pcall(function() a.width, a.height = width, height end)
    else
        a = display.newImage(dog, M.getPath(1, i == 1 and j or nil), x, y)
        pcall(function() a.width, a.height = width, height end)
        a = display.newImage(dog, M.getPath(2, i == 2 and j or nil), x, y)
        pcall(function() a.width, a.height = width, height end)
        a = display.newImage(dog, M.getPath(3, i == 3 and j or (i == 1 and (j == 3 or j == 15)) and 0 or nil), x, y)
        pcall(function() a.width, a.height = width, height end)
        a = display.newImage(dog, M.getPath(4, i == 4 and j or nil), x, y)
        pcall(function() a.width, a.height = width, height end)
        a = display.newImage(dog, M.getPath(5, i == 5 and j or nil), x, y)
        pcall(function() a.width, a.height = width, height end)
    end

    return dog
end

M.getPrice = function(type, id)
    return M.prices[({'face', 'eyes', 'ears', 'mouth', 'accessories'})[type]][id]
end

M.getCCoin = function(x, y, size)
    local ccoin = display.newImage('Sprites/ccoin.png', x, y)
    ccoin.width, ccoin.height = size, size
    return ccoin
end

M.create = function()
    M.group = display.newGroup()
    M.group.isVisible = false
    M.group.isOpen = false
    M.group.dogsGroup = display.newGroup()
    M.group.themeGroup = display.newGroup()
    M.group.learnGroup = display.newGroup()

    GANIN.az(DOC_DIR, BUILD)

    local bg = display.newImage(THEMES.bg(), CENTER_X, CENTER_Y)
        bg.width = CENTER_X == 641 and DISPLAY_HEIGHT or DISPLAY_WIDTH
        bg.height = CENTER_X == 641 and DISPLAY_WIDTH or DISPLAY_HEIGHT
        bg.rotation = CENTER_X == 641 and 90 or 0
    M.group:insert(bg)

    local width = DISPLAY_WIDTH - RIGHT_HEIGHT - 60
    local width3 = (DISPLAY_WIDTH - RIGHT_HEIGHT - 60) / 3

    local buttonDogs = display.newRect(CENTER_X - width / 2 + width3 / 2, ZERO_Y + 50, width3, 56)
        buttonDogs:setFillColor(unpack(LOCAL.themes.toolbar))
        buttonDogs.isOn = true
        buttonDogs.alpha = 0.3
        buttonDogs.tag = 'dogs'
        buttonDogs:addEventListener('touch', function(e) LISTENER(e, 'toolbar') end)
    M.group:insert(buttonDogs)

    local buttonDogsText = display.newText(STR['menu.dogs'], buttonDogs.x, buttonDogs.y, 'ubuntu', 28)
        buttonDogsText:setFillColor(unpack(LOCAL.themes.text))
    M.group:insert(buttonDogsText)

    local buttonTheme = display.newRect(buttonDogs.x + width3, ZERO_Y + 50, width3, 56)
        buttonTheme:setFillColor(unpack(LOCAL.themes.toolbar))
        buttonTheme.isOn = false
        buttonTheme.alpha = 0.1
        buttonTheme.tag = 'theme'
        buttonTheme:addEventListener('touch', function(e) LISTENER(e, 'toolbar') end)
    M.group:insert(buttonTheme)

    local buttonThemeText = display.newText(STR['robodog.themes'], buttonTheme.x, buttonTheme.y, 'ubuntu', 28)
        buttonThemeText:setFillColor(unpack(LOCAL.themes.text))
    M.group:insert(buttonThemeText)

    local buttonLearn = display.newRect(buttonTheme.x + width3, ZERO_Y + 50, width3, 56)
        buttonLearn:setFillColor(unpack(LOCAL.themes.toolbar))
        buttonLearn.isOn = false
        buttonLearn.alpha = 0.1
        buttonLearn.tag = 'learn'
        buttonLearn:addEventListener('touch', function(e) LISTENER(e, 'toolbar') end)
    M.group:insert(buttonLearn)

    local buttonLearnText = display.newText(STR['robodog.learning'], buttonLearn.x, buttonLearn.y, 'ubuntu', 28)
        buttonLearnText:setFillColor(unpack(LOCAL.themes.text))
    M.group:insert(buttonLearnText)

    M.ccoin = M.getCCoin(buttonDogs.x - buttonDogs.width / 2 + 40, buttonTheme.y + 80, 50)
        timer.new(1, 1, function() M.ccoin.text.text = LOCAL.niocc end)
    M.group.dogsGroup:insert(M.ccoin)

    M.ccoin.text = display.newText('...', M.ccoin.x + 40, M.ccoin.y, 'ubuntu', 36)
        M.ccoin.text:setFillColor(unpack(LOCAL.themes.text))
        M.ccoin.text.anchorX = 0
    M.group.dogsGroup:insert(M.ccoin.text)

    M.ccoin.showAd = display.newText(STR['robodog.showAd'], MAX_X - 40, M.ccoin.y, 'ubuntu', 34)
        M.ccoin.showAd:setFillColor(unpack(LOCAL.themes.text))
        M.ccoin.showAd.anchorX = 1
    M.group.dogsGroup:insert(M.ccoin.showAd)

    M.ccoin.autoAd = display.newText(STR['robodog.autoAd'], MAX_X - 40, M.ccoin.y + 60, 'ubuntu', 34)
        M.ccoin.autoAd:setFillColor(unpack(LOCAL.themes.text))
        M.ccoin.autoAd.anchorX = 1
    M.group.dogsGroup:insert(M.ccoin.autoAd)

    M.ccoin.autoAd:addEventListener('touch', function(e)
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            e.target.alpha = 0.6
            e.target.click = true
        elseif e.phase == 'moved' and (e.xDelta > 20 or e.yDelta > 20) then
            display.getCurrentStage():setFocus(nil)
            e.target.alpha = 1
            e.target.click = false
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            e.target.alpha = 1
            if e.target.click then
                e.target.click = false
                WINDOW.new(STR['robodog.autoAd.title'], {STR['button.comment'], STR['button.uncomment']}, function(e)
                    if e.index == 1 then
                        LOCAL.auto_ad = false
                    elseif e.index == 2 then
                        LOCAL.auto_ad = true
                    end

                    if e.index ~= 0 then
                        NEW_DATA()
                    end
                end)
            end
        end

        return true
    end)

    M.ccoin.showAd:addEventListener('touch', function(e)
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            e.target.alpha = 0.6
            e.target.click = true
        elseif e.phase == 'moved' and (e.xDelta > 20 or e.yDelta > 20) then
            display.getCurrentStage():setFocus(nil)
            e.target.alpha = 1
            e.target.click = false
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            e.target.alpha = 1
            if e.target.click then
                e.target.click = false
                WINDOW.new(STR['robodog.showAd.title'], {STR['robodog.showAd.promo'], STR['robodog.showAd.watch']}, function(e)
                    if e.index == 1 then
                        if DEVELOPERS[LOCAL.name_tester]
                        or DEVICE_ID == ''
                        or DEVICE_ID == ''
                        or DEVICE_ID == ''
                        or DEVICE_ID == '20036611d40a5d1d1b3b0df1628cdf2cdca95c8a5af6a16b470d70bb5b9ba082' then
                            CCOIN.set(tonumber(LOCAL.niocc) + 1000)
                        end
                    elseif e.index == 2 then
                        -- GET_UNIX_MINUTE(function(minutes)
                            -- if minutes == 0 then
                            --     WINDOW.new(STR['robodog.showAd.error'], {STR['button.okay']}, function() end)
                            --     WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                            --     WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                            -- else
                            timer.new(1, 1, function()
                                local minutes = math.round(os.time() / 60)
                                if minutes >= LOCAL.ads_time + 5 then
                                    if not IS_WIN and not IS_SIM then
                                        if GANIN.ads('isLoaded') then
                                            LOCAL.ads_time = minutes NEW_DATA()
                                            GANIN.ads('show', 'video')
                                        else
                                            WINDOW.new(STR['robodog.showAd.error'], {STR['button.okay']}, function() end)
                                            WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                            WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                        end
                                    end
                                else
                                    local time = tostring(LOCAL.ads_time - minutes + 5)
                                    local message = STR['robodog.showAd.time'] .. time
                                    WINDOW.new(message, {STR['button.okay']}, function() end)
                                    WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                    WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                end
                            end)
                            -- end
                        -- end)
                    end
                end)
            end
        end

        return true
    end)

    M.dog = {LOCAL.dog.face, LOCAL.dog.eyes, LOCAL.dog.ears, LOCAL.dog.mouth, LOCAL.dog.accessories}
    M.face = display.newImage(M.getPath(1), CENTER_X - 18, buttonTheme.y + 360)
    M.eyes = display.newImage(M.getPath(2), CENTER_X - 18, buttonTheme.y + 360)
    M.ears = display.newImage(M.getPath(3), CENTER_X - 18, buttonTheme.y + 360)
    M.mouth = display.newImage(M.getPath(4), CENTER_X - 18, buttonTheme.y + 360)
    M.accessories = display.newImage(M.getPath(5), CENTER_X - 18, buttonTheme.y + 360)

    if M.face then M.group.dogsGroup:insert(M.face) end
    if M.eyes then M.group.dogsGroup:insert(M.eyes) end
    if M.ears then M.group.dogsGroup:insert(M.ears) end
    if M.mouth then M.group.dogsGroup:insert(M.mouth) end
    if M.accessories then M.group.dogsGroup:insert(M.accessories) end

    M.frames = {}
    local x_frame = ZERO_X + (DISPLAY_WIDTH - 580) / 2 + 50
    local y_frame = 0

    M.group.dogsGroup.frameGroup = {}
    M.group.dogsGroup.framesGroup = display.newGroup()
    M.group.dogsGroup:insert(M.group.dogsGroup.framesGroup)
    M.group.dogsGroup.framesGroup.y = M.face.y + M.face.height / 2 + 50

    for i = 1, 5 do
        M.frames[i] = display.newImage('Sprites/ccdogBg.png', x_frame, y_frame)
            M.frames[i].width = 100
            M.frames[i].height = 100
        M.group.dogsGroup.framesGroup:insert(M.frames[i])

        M.frames[i].content = display.newImage(M.getPath(i), x_frame - 3, y_frame - 3)
            if M.frames[i].content then M.frames[i].content.width = 100 end
            if M.frames[i].content then M.frames[i].content.height = 100 end
        if M.frames[i].content then M.group.dogsGroup.framesGroup:insert(M.frames[i].content) end

        x_frame = x_frame + 120
        M.frames[i]:addEventListener('touch', function(e) e.i = i LISTENER(e, 'frame') end)

        M['frames' .. i] = {}
        local _x_frame = ZERO_X + (DISPLAY_WIDTH - 600 - 25) / 2 + 50
        local _y_frame = 0

        M.group.dogsGroup.frameGroup[i] = display.newGroup()
        M.group.dogsGroup:insert(M.group.dogsGroup.frameGroup[i])
        M.group.dogsGroup.frameGroup[i].y = MAX_Y + DISPLAY_HEIGHT / 2

        for j = 1, (i == 1 and 28 or i == 2 and 40 or i == 3 and 39 or i == 4 and 36 or 29) do
            M['frames' .. i][j] = display.newImage('Sprites/ccdogBg.png', _x_frame, _y_frame)
                M['frames' .. i][j].width = 100
                M['frames' .. i][j].height = 100
            M.group.dogsGroup.frameGroup[i]:insert(M['frames' .. i][j])

            if M.getAccess(i, j) then
                M['frames' .. i][j]:setFillColor(1)
            else
                M['frames' .. i][j]:setFillColor(1, 0.4, 0.4)
            end

            M['frames' .. i][j].content = display.newImage(M.getPath(i, j), _x_frame - 3, _y_frame - 3)
                if M['frames' .. i][j].content then M['frames' .. i][j].content.width = 100 end
                if M['frames' .. i][j].content then M['frames' .. i][j].content.height = 100 end
            if M['frames' .. i][j].content then M.group.dogsGroup.frameGroup[i]:insert(M['frames' .. i][j].content) end

            _x_frame = j % 6 == 0 and ZERO_X + (DISPLAY_WIDTH - 600 - 25) / 2 + 50 or _x_frame + 105
            _y_frame = j % 6 == 0 and _y_frame + 105 or _y_frame
            M['frames' .. i][j]:addEventListener('touch', function(e) e.j, e.i = j, i LISTENER(e, 'frames') end)
        end
    end

    local y = buttonTheme.y + (400 * ((DISPLAY_WIDTH - 40) / 1860)) / 2 + 85

    for i = 1, #THEMES.array do
        local themeBlock = display.newImage('Sprites/' .. THEMES.array[i] .. 'Theme.png', CENTER_X, y)
            themeBlock.height = 400 * ((DISPLAY_WIDTH - 40) / 1860)
            themeBlock.width = DISPLAY_WIDTH - 40
            themeBlock.strokeWidth = 10
            themeBlock.type = THEMES.array[i]
            themeBlock:setStrokeColor(unpack(LOCAL.themes.strokeColor))
            themeBlock:addEventListener('touch', function(e) THEMES.touch(e) end)
        M.group.themeGroup:insert(themeBlock) y = y + themeBlock.height + 50
    end

    local y = 100
    local learns = JSON.decode(READ_FILE(system.pathForFile('Emitter/learns.json')))
    local learnScroll = WIDGET.newScrollView({
        x = CENTER_X,
        y = (buttonLearn.y + 80 + MAX_Y) / 2,
        width = DISPLAY_WIDTH,
        height = MAX_Y - buttonLearn.y - 80,
        hideBackground = true,
        hideScrollBar = false,
        horizontalScrollDisabled = true,
        isBounceEnabled = true,
        friction = tonumber(LOCAL.scroll_friction) / 1000
    }) M.group.learnGroup:insert(learnScroll)

    for i = #learns, 1, -1 do
        local v = learns[i]

        local learnBlock = display.newRect(DISPLAY_WIDTH / 2, y, DISPLAY_WIDTH - 40, 200)
            learnBlock:setFillColor(unpack(LOCAL.themes.bgAdd5Color))
            learnBlock:addEventListener('touch', function(e)
                e.scroll = learnScroll e.learns = learns
                e.i = i LISTENER(e, 'video') return true
            end)
        learnScroll:insert(learnBlock)

        local previewImage = display.newImage('Sprites/Previews/preview' .. i .. '.jpg', DISPLAY_WIDTH / 2, y)
            previewImage.height = 200
            previewImage.width = learnBlock.width / 2
            previewImage.x = previewImage.x - previewImage.width / 2
        learnScroll:insert(previewImage)

        local titleVideo = display.newText({
                text = v.title, fontSize = 30, font = 'ubuntu',
                x = previewImage.x + previewImage.width, y = y,
                width = learnBlock.width / 2 - 40, height = 180,
                align = 'center'
            }) titleVideo:setFillColor(unpack(LOCAL.themes.text))
        learnScroll:insert(titleVideo)

        y = y + learnBlock.height + 50
    end

    M.group:insert(M.group.dogsGroup)
    M.group:insert(M.group.themeGroup)
    M.group:insert(M.group.learnGroup)

    M.group.dogsGroup.isOn = true
    M.group.themeGroup.isOn = false
    M.group.learnGroup.isOn = false

    M.group.dogsGroup.isVisible = true
    M.group.themeGroup.isVisible = false
    M.group.learnGroup.isVisible = false

    M.group.themeGroup.x = DISPLAY_WIDTH
    M.group.learnGroup.x = DISPLAY_WIDTH

    M.face:addEventListener('touch', function(e) LISTENER(e, 'face') end)
end

M.prices = {
    face = {
        '0', '100', '3000', '500', '500', '1500',
        '100', '1000', '150', '500', '300', '300',
        '150', '300', '1000', '750', '300', '150',
        '100', '100', '100', '300', '300', '500',
        '1000', '2000', '100', '2000'
    },
    eyes = {
        '0', '100', '300', '200', '200', '100',
        '1000', '500', '500', '300', '300', '500',
        '1500', '500', '1000', '300', '100', '200',
        '300', '300', '500', '300', '500', '200',
        '200', '200', '300', '300', '200', '200',
        '100', '200', '100', '100', '1000', '200',
        '200', '200', '200', '1000'
    },
    ears = {
        '0', '300', '750', '1500', '200', '100',
        '500', '100', '300', '500', '300', '1000',
        '100', '1500', '100', '500', '300', '1000',
        '500', '300', '300', '200', '200', '200',
        '100', '100', '200', '300', '100', '500',
        '100', '300', '100', '200', '200', '1000',
        '500', '300', '1500'
    },
    mouth = {
        '0', '750', '300', '200', '200', '200',
        '100', '100', '200', '300', '300', '300',
        '750', '300', '200', '100', '100', '300',
        '200', '100', '300', '100', '1000', '200',
        '200', '200', '200', '200', '200', '200',
        '200', '200', '200', '200', '750', '750'
    },
    accessories = {
        '0', '2000', '1000', '1500', '1500', '1000',
        '1500', '1500', '1000', '1000', '1000', '1500',
        '1000', '1000', '1500', '2000', '1000', '1000',
        '1500', '1500', '1000', '2000', '1500', '2000',
        '1000', '2000', '1500', '2000', '1000'
    }
}

return M

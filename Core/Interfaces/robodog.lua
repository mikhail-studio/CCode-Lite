local listeners = {}

GANIN.az(DOC_DIR, BUILD)

listeners.title = function()
    EXITS.robodog()
end

listeners.toolbar = function(e)
    if e.target.tag then
        local index = ({dogs = 2, theme = 4, learn = 6})[e.target.tag]

        for i = 2, 6, 2 do
            if ROBODOG.group[i].isOn and i ~= index then
                ROBODOG.group[i].isOn = false
                ROBODOG.group[i].alpha = 0.1
                break
            elseif ROBODOG.group[i].isOn and i == index then
                return
            end
        end

        e.target.isOn = true
        e.target.alpha = 0.3

        pcall(function() timer.cancel(ROBODOG.group.dogsGroup.transition) end)
        pcall(function() timer.cancel(ROBODOG.group.themeGroup.transition) end)
        pcall(function() timer.cancel(ROBODOG.group.learnGroup.transition) end)

        listeners[e.target.tag](e)
    end
end

listeners.dogs = function(e)
    ROBODOG.group.dogsGroup.isOn = true
    ROBODOG.group.learnGroup.isOn = false
    ROBODOG.group.themeGroup.isOn = false
    ROBODOG.group.dogsGroup.isVisible = true

    ROBODOG.group.dogsGroup.transition
        = transition.to(ROBODOG.group.dogsGroup, {time = 150, x = 0})
    ROBODOG.group.themeGroup.transition
        = transition.to(ROBODOG.group.themeGroup, {time = 150, x = DISPLAY_WIDTH, onComplete = function(target) target.isVisible = false end})
    ROBODOG.group.learnGroup.transition
        = transition.to(ROBODOG.group.learnGroup, {time = 150, x = DISPLAY_WIDTH, onComplete = function(target) target.isVisible = false end})
end

listeners.theme = function(e)
    ROBODOG.group.themeGroup.isOn = true
    ROBODOG.group.dogsGroup.isOn = false
    ROBODOG.group.learnGroup.isOn = false
    ROBODOG.group.themeGroup.isVisible = true

    ROBODOG.group.themeGroup.transition
        = transition.to(ROBODOG.group.themeGroup, {time = 150, x = 0})
    ROBODOG.group.dogsGroup.transition
        = transition.to(ROBODOG.group.dogsGroup, {time = 150, x = -DISPLAY_WIDTH, onComplete = function(target) target.isVisible = false end})
    ROBODOG.group.learnGroup.transition
        = transition.to(ROBODOG.group.learnGroup, {time = 150, x = DISPLAY_WIDTH, onComplete = function(target) target.isVisible = false end})
end

listeners.learn = function(e)
    ROBODOG.group.learnGroup.isOn = true
    ROBODOG.group.dogsGroup.isOn = false
    ROBODOG.group.themeGroup.isOn = false
    ROBODOG.group.learnGroup.isVisible = true

    ROBODOG.group.learnGroup.transition
        = transition.to(ROBODOG.group.learnGroup, {time = 150, x = 0})
    ROBODOG.group.dogsGroup.transition
        = transition.to(ROBODOG.group.dogsGroup, {time = 150, x = -DISPLAY_WIDTH, onComplete = function(target) target.isVisible = false end})
    ROBODOG.group.themeGroup.transition
        = transition.to(ROBODOG.group.themeGroup, {time = 150, x = -DISPLAY_WIDTH, onComplete = function(target) target.isVisible = false end})
end

listeners.face = function()
    if ROBODOG.group.dogsGroup.isOn then
        local y_frame = ROBODOG.face.y + ROBODOG.face.height / 2 + 50

        pcall(function() transition.to(ROBODOG.group.dogsGroup.framesGroup, {y = y_frame}) end)

        for i = 1, 5 do
            pcall(function() transition.to(ROBODOG.group.dogsGroup.frameGroup[i], {y = MAX_Y + DISPLAY_HEIGHT / 2}) end)
        end

        ROBODOG.group.isOpen = false
    end
end

listeners.frame = function(e)
    if ROBODOG.group.dogsGroup.isOn then
        if not ((LOCAL.dog.face == 3 or LOCAL.dog.face == 15) and e.i == 3) then
            local y_frame = ROBODOG.face.y + ROBODOG.face.height / 2 + 50

            pcall(function() transition.to(ROBODOG.group.dogsGroup.framesGroup, {y = MAX_Y + DISPLAY_HEIGHT / 2}) end)
            pcall(function() transition.to(ROBODOG.group.dogsGroup.frameGroup[e.i], {y = y_frame}) end)

            ROBODOG.group.isOpen = true
        end
    end
end

listeners.frames = function(e)
    if ROBODOG.group.dogsGroup.isOn then
        if ROBODOG.getAccess(e.i, e.j) then
            if (LOCAL.dog.face == 3 or LOCAL.dog.face == 15) then
                if e.i == 1 and not (e.j == 3 or e.j == 15) then
                    ROBODOG.ears.fill = {
                        type = 'image', filename = ROBODOG.getPath(3, 1)
                    } ROBODOG.frames[3].content.fill = {
                        type = 'image', filename = ROBODOG.getPath(3, 1)
                    } LOCAL.dog.ears = 1
                end
            end

            ROBODOG[({'face', 'eyes', 'ears', 'mouth', 'accessories'})[e.i]].fill = {
                type = 'image', filename = ROBODOG.getPath(e.i, e.j)
            } ROBODOG.frames[e.i].content.fill = {
                type = 'image', filename = ROBODOG.getPath(e.i, e.j)
            } LOCAL.dog[({'face', 'eyes', 'ears', 'mouth', 'accessories'})[e.i]] = e.j

            if e.i == 1 and (e.j == 3 or e.j == 15) then
                ROBODOG.ears.fill = {
                    type = 'image', filename = ROBODOG.getPath(3, 40)
                } ROBODOG.frames[3].content.fill = {
                    type = 'image', filename = ROBODOG.getPath(3, 40)
                } LOCAL.dog.ears = 40
            end

            CCOIN.setKeys() NEW_DATA()
        else
            local buttons = {STR['button.close'], STR['robodog.buy']}
            WINDOW.new(STR['robodog.want.buy.' .. e.i] .. ROBODOG.getPrice(e.i, e.j) .. ' ccoin', buttons, function(ev)
                if ev.index == 2 then
                    if CCOIN.buy(ROBODOG.getPrice(e.i, e.j)) then
                        ROBODOG['frames' .. e.i][e.j]:setFillColor(1)
                        ROBODOG.setAccess(e.i, e.j) WINDOW.remove()
                        timer.new(1, 1, function()
                            WINDOW.new(STR['robodog.successful.purchase.' .. e.i], {STR['button.okay']}, function(ev) end, 2)
                            WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                            WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                        end)
                    else
                        WINDOW.remove()
                        timer.new(1, 1, function()
                            WINDOW.new(STR['robodog.not.enough.ccoin'], {STR['button.close']}, function(ev) end, 5)
                            WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                            WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                        end)
                    end
                end
            end, {e.i, e.j})
        end
    end
end

listeners.video = function(e)
    system.openURL(e.learns[e.i].link)
end

return function(e, type)
    if ALERT then
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            if type == 'title' then e.target.alpha = 0.6 end
            e.target.click = true
        elseif e.phase == 'moved' and (math.abs(e.x - e.xStart) > 30 or math.abs(e.y - e.yStart) > 30) then
            if type == 'video' then e.scroll:takeFocus(e)
            else display.getCurrentStage():setFocus(nil) end
            if type == 'title' then e.target.alpha = 1 end
            e.target.click = false
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            if type == 'title' then e.target.alpha = 1 end
            if e.target.click then
                e.target.click = false
                listeners[type](e)
            end
        end
    end

    return true
end

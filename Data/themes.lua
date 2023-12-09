local M = {}

M.list = {
    default = {
        bg = {0.15, 0.15, 0.17, 1},
        bgAddColor = {0.2, 0.2, 0.22},
        bgAdd2Color = {0.22, 0.22, 0.24},
        bgAdd3Color = {0.18, 0.18, 0.2},
        bgAdd4Color = {0.16, 0.16, 0.18},
        bgAdd5Color = {0.24, 0.24, 0.26},
        levelColor = {0.37, 0.37, 0.39},
        levelAddColor = {0.05, 0.05, 0.07},
        editor = {0.11, 0.11, 0.13},
        editorAddColor = {0.14, 0.14, 0.16},
        editorAdd2Color = {0.17, 0.17, 0.19},
        toolbar = {1}, folderOpen = {1}, folderClose = {0.4},
        interfaceColors = {r = {1, 0, 0}, g = {0, 1, 0}, b = {0, 0, 1}},
        text = {1}, fieldColor = {0.9}, blockText = {1}, strokeColor = {0.3},
        block = {25/255, 26/255, 32/255}, find = {0.9}, line = {0.45},
        -- logicStroke = {
        --     events = {0.25, 0.25, 0.25},
        --     vars = {0.25, 0.25, 0.25},
        --     objects = {0.25, 0.25, 0.25},
        --     media = {0.25, 0.25, 0.25},
        --     control = {0.25, 0.25, 0.25},
        --     physics = {0.25, 0.25, 0.25},
        --     transition = {0.25, 0.25, 0.25},
        --     groups = {0.25, 0.25, 0.25},
        --     shapes = {0.25, 0.25, 0.25},
        --     widgets = {0.25, 0.25, 0.25},
        --     snapshot = {0.25, 0.25, 0.25},
        --     network = {0.25, 0.25, 0.25},
        --     objects2 = {0.25, 0.25, 0.25},
        --     everyone = {0.25, 0.25, 0.25},
        --     custom = {0.25, 0.25, 0.25}
        -- },
        logicBlock = {
            events = {0.0, 0.0, 0.0}, vars = {0.0, 0.0, 0.0},
            objects = {0.0, 0.0, 0.0}, media = {0.0, 0.0, 0.0},
            control = {0.0, 0.0, 0.0}, physics = {0.0, 0.0, 0.0},
            transition = {0.0, 0.0, 0.0}, groups = {0.0, 0.0, 0.0},
            shapes = {0.0, 0.0, 0.0}, widgets = {0.0, 0.0, 0.0},
            snapshot = {0.0, 0.0, 0.0}, network = {0.0, 0.0, 0.0},
            objects2 = {0.0, 0.0, 0.0}, everyone = {0.0, 0.0, 0.0}, custom = {0.0, 0.0, 0.0}
        }
    },
    light = {
        bg = {220/255, 220/255, 225/255, 1},
        bgAddColor = {200/255, 200/255, 205/255},
        bgAdd2Color = {210/255, 210/255, 215/255},
        bgAdd3Color = {195/255, 195/255, 200/255},
        bgAdd4Color = {185/255, 185/255, 190/255},
        bgAdd5Color = {220/255, 220/255, 225/255},
        editor = {240/255, 240/255, 245/255},
        editorAddColor = {225/255, 225/255, 230/255},
        editorAdd2Color = {190/255, 190/255, 195/255},
        toolbar = {0.4}, folderOpen = {0}, folderClose = {0.7},
        interfaceColors = {r = {0.7, 0, 0}, g = {0, 0.7, 0}, b = {0, 0, 0.7}},
        text = {0}, fieldColor = {0.1}, blockText = {1}, strokeColor = {0.5},
        block = {177/255, 178/255, 184/255}, find = {0.4}, line = {0.2},
        logicStroke = {
            events = {0.25, 0.25, 0.25},
            vars = {0.25, 0.25, 0.25},
            objects = {0.25, 0.25, 0.25},
            media = {0.25, 0.25, 0.25},
            control = {0.25, 0.25, 0.25},
            physics = {0.25, 0.25, 0.25},
            transition = {0.25, 0.25, 0.25},
            groups = {0.25, 0.25, 0.25},
            shapes = {0.25, 0.25, 0.25},
            widgets = {0.25, 0.25, 0.25},
            snapshot = {0.25, 0.25, 0.25},
            network = {0.25, 0.25, 0.25},
            objects2 = {0.25, 0.25, 0.25},
            everyone = {0.25, 0.25, 0.25},
            custom = {0.25, 0.25, 0.25}
        },
        logicBlock = {
            events = {0.05, 0.05, 0.05}, vars = {0.05, 0.05, 0.05},
            objects = {0.05, 0.05, 0.05}, media = {0.05, 0.05, 0.05},
            control = {0.05, 0.05, 0.05}, physics = {0.05, 0.05, 0.05},
            transition = {0.05, 0.05, 0.05}, groups = {0.05, 0.05, 0.05},
            shapes = {0.05, 0.05, 0.05}, widgets = {0.05, 0.05, 0.05},
            snapshot = {0.05, 0.05, 0.05}, network = {0.05, 0.05, 0.05},
            objects2 = {0.05, 0.05, 0.05}, everyone = {0.05, 0.05, 0.05}, custom = {0.05, 0.05, 0.05}
        }
    }
}

M.array = {
    'default', 'light'
}

M.touch = function(e)
    if ALERT then
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            e.target:setFillColor(0.75)
            e.target.click = true
        elseif e.phase == 'moved' and (math.abs(e.x - e.xStart) > 30 or math.abs(e.y - e.yStart) > 30) then
            display.getCurrentStage():setFocus(nil)
            e.target:setFillColor(1)
            e.target.click = false
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            e.target:setFillColor(1)
            if e.target.click then
                e.target.click = false
                if e.target.type ~= LOCAL.theme then
                    WINDOW.new(STR['robodog.want.set.theme'], {STR['button.no'], STR['button.yes']}, function(ev)
                        if ev.index == 2 then
                            LOCAL.theme = e.target.type
                            LOCAL.themes = M.list[LOCAL.theme]
                            NEW_DATA() GANIN.relaunch()
                        end
                    end, 4)
                end
            end
        end
    end

    return true
end

M.bg = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/bg.png'
end

M.discord = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/discord.png'
end

M.menubut = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/menubut.png'
end

M.listopenbut = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/listopenbut.png'
end

M.add = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/add.png'
end

M.import = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/import.png'
end

M.okay = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/okay.png'
end

M.play = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/play.png'
end

M.iconScript = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconScript.png'
end

M.iconSprite = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconSprite.png'
end

M.iconLevel = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconLevel.png'
end

M.iconSound = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconSound.png'
end

M.iconVideo = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconVideo.png'
end

M.iconFont = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconFont.png'
end

M.iconRes = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconRes.png'
end

M.iconSetting = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconSetting.png'
end

M.iconExport = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconExport.png'
end

M.iconBuild = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconBuild.png'
end

M.iconAab = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconAab.png'
end

M.iconComment = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/iconComment.png'
end

M.eyeLevel = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/eyeLevel.png'
end

M.addLevel = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/addLevel.png'
end

M.plusLevel = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/plusLevel.png'
end

M.minusLevel = function()
    return 'Sprites/Themes/' .. LOCAL.theme .. '/minusLevel.png'
end

M.menu = function()
    return LOCAL.theme == 'default' and 'Sprites/menu.png' or 'Sprites/Themes/' .. LOCAL.theme .. '/bg.png'
end

return M

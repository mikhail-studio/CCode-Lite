local LAST_CURRENT_LINK

return {
    new = function(link, isAab)
        if (pcall(function()
            LAST_CURRENT_LINK = CURRENT_LINK
            GAME = require 'Core.Simulation.start'
            CURRENT_LINK = 'App'
            OS_REMOVE(DOC_DIR .. '/Build', true)
            LFS.mkdir(DOC_DIR .. '/Build')
            LFS.mkdir(DOC_DIR .. '/Build/Resources')
            LFS.mkdir(DOC_DIR .. '/Build/Images')
            LFS.mkdir(DOC_DIR .. '/Build/Sounds')
            LFS.mkdir(DOC_DIR .. '/Build/Videos')
            LFS.mkdir(DOC_DIR .. '/Build/Fonts')

            GANIN.az(DOC_DIR, BUILD)
            PROGRAMS.group[8]:setIsLocked(true, 'vertical')
            WINDOW.new(STR['build.start' .. (isAab and '.aab' or '')], {}, function() PROGRAMS.group[8]:setIsLocked(false, 'vertical') end, 1)

            timer.performWithDelay(100, function()
                local flds = {'Resources', 'Images', 'Sounds', 'Videos', 'Fonts'}
                local icons = {'mipmap-hdpi-v4', 'mipmap-mdpi-v4', 'mipmap-ldpi-v4', 'mipmap-xhdpi-v4', 'mipmap-xxhdpi-v4', 'mipmap-xxxhdpi-v4'}
                -- local icons = {'mipmap-hdpi', 'mipmap-mdpi', 'mipmap-xhdpi', 'mipmap-xxhdpi', 'mipmap-xxxhdpi'}

                for i = 1, #flds do
                    for file in LFS.dir(DOC_DIR .. '/' .. link .. '/' .. flds[i]) do
                        if file ~= '.' and file ~= '..' then
                            OS_COPY(DOC_DIR .. '/' .. link .. '/' .. flds[i] .. '/' .. file, DOC_DIR .. '/Build/' .. flds[i] .. '/' .. file)
                        end
                    end
                end

                WRITE_FILE(DOC_DIR .. '/Build/game.lua', GAME.new(link))

                local title = GAME.data.title
                local build = GAME.data.settings.build
                local version = GAME.data.settings.version
                local package = GAME.data.settings.package
                local alias = LOCAL.keystore[1] == 'custom' and LOCAL.keystore[2] or 'testkey'
                local pass = LOCAL.keystore[1] == 'custom' and LOCAL.keystore[3] or 'androidkey'

                GAME = nil
                GANIN.compress(DOC_DIR .. '/Build', DOC_DIR .. '/game.cc', SOLAR .. _G.A .. _G.C, function()
                    OS_REMOVE(DOC_DIR .. '/game.lua')
                    OS_REMOVE(DOC_DIR .. '/list.json')
                    OS_REMOVE(DOC_DIR .. '/Build', true)
                    OS_MOVE(DOC_DIR .. '/game.cc', MY_PATH .. '/assets/Emitter/game.cc')

                    for i = 1, #icons do
                        OS_COPY(DOC_DIR .. '/' .. link .. '/icon.png', MY_PATH .. '/res/' .. icons[i] .. '/ic_launcher.png')
                        OS_COPY(DOC_DIR .. '/' .. link .. '/icon.png', MY_PATH .. '/res/' .. icons[i] .. '/ic_launcher_foreground.png')
                    end

                    CURRENT_LINK = LAST_CURRENT_LINK
                    GANIN.build(MY_PATH, package, title, build, version, isAab, DOC_DIR, alias, pass)
                end, true)
            end)
        end)) == false then
            GAME = nil
            OS_REMOVE(DOC_DIR .. '/game.cc')
            OS_REMOVE(DOC_DIR .. '/game.lua')
            OS_REMOVE(DOC_DIR .. '/list.json')
            OS_REMOVE(DOC_DIR .. '/Build', true)
            CURRENT_LINK = LAST_CURRENT_LINK or CURRENT_LINK
            CCOIN.set(tonumber(LOCAL.niocc) + (isAab and 100 or 10))
            pcall(function() PROGRAMS.group[8]:setIsLocked(false, 'vertical') end)
        end
    end,

    reset = function()
        os.execute('rm -rf "' .. MY_PATH .. '"')
        LFS.mkdir(MY_PATH)
        LFS.mkdir(MY_PATH .. '/res')
        LFS.mkdir(MY_PATH .. '/assets')
        LFS.mkdir(MY_PATH .. '/assets/Emitter')

        -- LFS.mkdir(MY_PATH .. '/res/mipmap-hdpi')
        -- LFS.mkdir(MY_PATH .. '/res/mipmap-mdpi')
        -- LFS.mkdir(MY_PATH .. '/res/mipmap-xhdpi')
        -- LFS.mkdir(MY_PATH .. '/res/mipmap-xxhdpi')
        -- LFS.mkdir(MY_PATH .. '/res/mipmap-xxxhdpi')

        LFS.mkdir(MY_PATH .. '/res/mipmap-hdpi-v4')
        LFS.mkdir(MY_PATH .. '/res/mipmap-mdpi-v4')
        LFS.mkdir(MY_PATH .. '/res/mipmap-ldpi-v4')
        LFS.mkdir(MY_PATH .. '/res/mipmap-xhdpi-v4')
        LFS.mkdir(MY_PATH .. '/res/mipmap-xxhdpi-v4')
        LFS.mkdir(MY_PATH .. '/res/mipmap-xxxhdpi-v4')
    end
}

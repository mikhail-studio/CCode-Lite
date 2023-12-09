return {
    new = function(listener, import)
        local completeImportProject = function(import)
            if type(import) == 'table' and import.done and import.done == 'ok' then
                local numApp = 1
                while true do
                    local file = io.open(DOC_DIR .. '/App' .. numApp .. '/game.json', 'r')
                    if file then
                        numApp = numApp + 1
                        io.close(file)
                    else
                        local link = 'App' .. numApp
                        GANIN.uncompress(DOC_DIR .. '/import.ccode', DOC_DIR .. '/' .. link, function()
                            local changeDataCustom, data = {}, GET_GAME_CODE(link)
                            local hash = READ_FILE(DOC_DIR .. '/' .. link .. '/hash.txt')
                            local new_custom = JSON.decode(READ_FILE(DOC_DIR .. '/' .. link .. '/custom.json'))
                            local code = JSON.encode3(data, {keyorder = KEYORDER}) .. JSON.encode3(new_custom, {keyorder = KEYORDER})
                            for i = 1, #data.scripts do code = code .. JSON.encode3(GET_GAME_SCRIPT(link, i, data), {keyorder = KEYORDER}) end
                            local current_hash = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, code, '?-+.сс_ode-123%'), '%^(=)*cc.оde_?')
                            local custom, dataCustom = GET_GAME_CUSTOM(), {} current_hash = hash

                            if current_hash == hash then
                                pcall(function()
                                    NEW_BLOCK.remove()
                                end)
                                
                                for index, block in pairs(new_custom) do
                                    if tonumber(index) then
                                        local new_index, change_custom = tostring(custom.len + 1)

                                        for i = 1, custom.len do
                                            if not custom[tostring(i)] then
                                                new_index = tostring(i) break
                                            end
                                        end

                                        for _index, _block in pairs(custom) do
                                            if tonumber(_index) and _block[1] == block[1] then
                                                local t1, t2 = _block[3], block[3]

                                                if _G.type(_block[3]) == 'table' and _G.type(block[3]) == 'table' then
                                                    t1 = JSON.encode3(_block[3], {keyorder = KEYORDER})
                                                    t2 = JSON.encode3(block[3], {keyorder = KEYORDER})
                                                end

                                                if t1 == t2 then
                                                    if _block[4] < block[4] then
                                                        custom[_index] = COPY_TABLE(block)
                                                        custom[_index][4] = os.time()
                                                    end

                                                    dataCustom[index] = _index
                                                    change_custom = true break
                                                end
                                            end
                                        end

                                        if not change_custom then
                                            custom.len = custom.len + 1
                                            custom[new_index] = COPY_TABLE(block)
                                            custom[new_index][4] = os.time()
                                            dataCustom[index] = new_index
                                            changeDataCustom[new_index] = true
                                        end
                                    end
                                end

                                for _, index in pairs(dataCustom) do
                                    local block = custom[index]
                                    local typeBlock = 'custom' .. index
                                    local blockParams = {} for i = 1, #block[2] do blockParams[i] = {'value', block[6] and block[6][i] or nil} end

                                    STR['blocks.' .. typeBlock] = block[1]
                                    STR['blocks.' .. typeBlock .. '.params'] = block[2]
                                    LANG.ru['blocks.' .. typeBlock] = block[1]
                                    LANG.ru['blocks.' .. typeBlock .. '.params'] = block[2]
                                    INFO.listName[typeBlock] = {'custom', unpack(blockParams)}

                                    if changeDataCustom[index] then
                                        table.insert(INFO.listBlock.custom, 1, typeBlock)
                                        table.insert(INFO.listBlock.everyone, typeBlock)
                                    end
                                end

                                for i = 1, #data.scripts do
                                    local script, nestedInfo, isChange = GET_FULL_DATA(GET_GAME_SCRIPT(link, i, data))
                                    for j = 1, #script.params do
                                        local name = script.params[j].name

                                        if UTF8.sub(name, 1, 6) == 'custom' then
                                            local index = UTF8.sub(name, 7, UTF8.len(name)) isChange = true
                                            script.params[j].name = 'custom' .. (dataCustom[index] or index or '1')
                                        end

                                        for u = 1, #script.params[j].params do
                                            for o = #script.params[j].params[u], 1, -1 do
                                                if script.params[j].params[u][o][2] == 'fC' then
                                                    local name = script.params[j].params[u][o][1]
                                                    local index = UTF8.sub(name, 7, UTF8.len(name)) isChange = true
                                                    script.params[j].params[u][o][1] = 'custom' .. (dataCustom[index] or index or '1')
                                                end
                                            end
                                        end
                                    end if isChange then SET_GAME_SCRIPT(link, GET_NESTED_DATA(script, nestedInfo, INFO), i, data) end
                                end

                                LOCAL.apps[#LOCAL.apps + 1], data.link = link, link
                                LFS.mkdir(DOC_DIR .. '/' .. link .. '/Documents')
                                LFS.mkdir(DOC_DIR .. '/' .. link .. '/Temps')

                                NEW_DATA()
                                SET_GAME_CUSTOM(custom)
                                SET_GAME_SAVE(link, {})
                                SET_GAME_CODE(link, data)
                                PROGRAMS.new(data.title, link)

                                OS_REMOVE(DOC_DIR .. '/' .. link .. '/hash.txt')
                                OS_REMOVE(DOC_DIR .. '/' .. link .. '/custom.json')
                                OS_REMOVE(DOC_DIR .. '/import.ccode')
                                listener({isError = false})
                            else
                                OS_REMOVE(DOC_DIR .. '/' .. link, true)
                                OS_REMOVE(DOC_DIR .. '/import.ccode')
                                listener({isError = true, idError = 2})
                            end
                        end) break
                    end
                end
            else
                listener({isError = true, idError = 1})
            end
        end

        GANIN.az(DOC_DIR, BUILD)

        if import then
            completeImportProject(import)
        else
            GIVE_PERMISSION_DATA()
            FILE.pickFile(DOC_DIR, completeImportProject, 'import.ccode', '', (IS_SIM or IS_WIN) and 'ccode/*' or '*/*', nil, nil, nil)
        end
    end
}

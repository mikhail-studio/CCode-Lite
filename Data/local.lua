local data, custom = CLASS(), {}
local file = io.open(system.pathForFile('local.json', system.DocumentsDirectory), 'r')

CCOIN = require 'Core.Share.ccoin'
timer.new(1, 1, function() CCOIN.init() end)

if file then
    local dataRead = file:read('*a') if dataRead:sub(1, 1) ~= '{' then dataRead = ENCRYPT(dataRead, true) end
    data = table.merge(data, JSON.decode(dataRead)) io.close(file)
    if data.autoplace == nil then data.autoplace = true end
    if data.ads_time == nil then data.ads_time = 0 end
    if data.scroll_friction == nil then data.scroll_friction = 972 end
    if data.backup_frequency == nil then data.backup_frequency = 15 end
    if data.bottom_height == nil then data.bottom_height = 0 end
    if data.old_dog == nil then data.old_dog = false end
    if data.auto_ad == nil then data.auto_ad = false end
    if data.old_update == nil then data.old_update = false end
    if data.keystore == nil then data.keystore = {'testkey'} end data.back = 'System'
    if data.theme == nil then data.theme = 'default' end data.themes = THEMES.list[data.theme]
    local _data = COPY_TABLE(data) _data.__table__.niocc__set = '<type \'function\' is not supported by JSON.>'
    WRITE_FILE(system.pathForFile('local.json', system.DocumentsDirectory), ENCRYPT(JSON.encode3(_data)))
else
    data, custom = table.merge(data, {
        lang = system.getPreference('locale', 'language'),
        last = '',
        last_link = '',
        orientation = 'portrait',
        back = 'System',
        keystore = {'testkey'},
        ads_time = 0,
        auto_ad = false,
        scroll_friction = 972,
        backup_frequency = 15,
        bottom_height = 0,
        autoplace = true,
        show_ads = true,
        pos_top_ads = true,
        confirm = true,
        first = true,
        ui = true,
        apps = {},
        repository = {},
        name_tester = '',
        old_update = false,
        old_dog = false,
        theme = 'default',
        themes = THEMES.list.default
    }), {len = 0}

    SET_GAME_CUSTOM(custom)
    WRITE_FILE(system.pathForFile('local.json', system.DocumentsDirectory), ENCRYPT(JSON.encode(data)))
end

return data

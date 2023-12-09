local M = {}

local function fuckCheater()
    LOCAL.niocc = '0'
    LOCAL.key = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, LOCAL.niocc, 'sha256ключ'), 'md5ключ')

    LOCAL.dog = {face = 1, ears = 1, eyes = 1, mouth =  1, accessories = 1}
    LOCAL.dogs = {face = {true}, ears = {true}, eyes = {true}, mouth = {true}, accessories = {true}}

    M.setKeys() NEW_DATA()

    ROBODOG.group:removeSelf()
    ROBODOG.group = nil
    ROBODOG.create()
    ROBODOG.group.isVisible = true
end

local function checkCheater()
    if not LOCAL.niocc then return end

    local dogData = JSON.encode3(LOCAL.dog, {keyorder = KEYORDER})
    local dogsData = JSON.encode3(LOCAL.dogs, {keyorder = KEYORDER})

    local key = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, LOCAL.niocc, 'sha256ключ'), 'md5ключ')
    local key2 = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, dogData, 'sha256ключ2'), 'md5ключ2')
    local key3 = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, dogsData, 'sha256ключ3'), 'md5ключ3')

    -- print(key, LOCAL.key)
    -- print(key2, LOCAL.key2)
    -- print(key3, LOCAL.key3)

    if key ~= LOCAL.key or key2 ~= LOCAL.key2 or key3 ~= LOCAL.key3 or LOCAL.niocc ~= LOCAL.speed then fuckCheater() return true end
end

M.set = function(count)
    if not checkCheater() then
        LOCAL.niocc = tostring(count)
        LOCAL.speed = LOCAL.niocc
        LOCAL.key = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, LOCAL.niocc, 'sha256ключ'), 'md5ключ')
        NEW_DATA()
    end
end

M.setKeys = function()
    local dogData = JSON.encode3(LOCAL.dog, {keyorder = KEYORDER})
    local dogsData = JSON.encode3(LOCAL.dogs, {keyorder = KEYORDER})

    LOCAL.key2 = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, dogData, 'sha256ключ2'), 'md5ключ2')
    LOCAL.key3 = CRYPTO.hmac(CRYPTO.sha256, CRYPTO.hmac(CRYPTO.md5, dogsData, 'sha256ключ3'), 'md5ключ3')

    NEW_DATA()
end

M.init = function()
    GANIN.az(DOC_DIR, BUILD)

    if LOCAL.niocc == nil then
        LOCAL.dog = {face = 1, ears = 1, eyes = 1, mouth =  1, accessories = 1}
        LOCAL.dogs = {face = {true}, ears = {true}, eyes = {true}, mouth = {true}, accessories = {true}}
        M.setKeys() M.set(0)
    end

    if LOCAL.speed == nil then
        LOCAL.speed = LOCAL.niocc
    end

    LOCAL.niocc__set = function()
        pcall(function()
            if ROBODOG and ROBODOG.group and ROBODOG.group.isVisible then
                ROBODOG.ccoin.text.text = LOCAL.niocc
            end
        end)
    end

    checkCheater()
end

M.buy = function(price)
    GANIN.az(DOC_DIR, BUILD)

    if LOCAL.niocc then
        if not checkCheater() then
            if tonumber(LOCAL.niocc) >= tonumber(price) then
                M.set(tonumber(LOCAL.niocc) - tonumber(price))
                timer.new(1, 1, function() M.setKeys() end)
                return true
            end
        end
    end
end

return M

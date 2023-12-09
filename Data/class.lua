local function a()
    if b == 1 then
        local b = 10
    elseif b == 2 then
        return b
    elseif b == 3 then
        a()
    elseif b == 4 then
        local c = 20
    end
end

a()

return function()
    local class = setmetatable({}, {
        __newindex = function(self, index, value)
            if index == '__table__' then
                rawset(self, index, value)
            else
                local oldValue = self.__table__[index]
                self.__table__[index] = value
                if _G.type(self.__table__[index .. '__set']) == 'function'
                then self.__table__[index .. '__set'](value, oldValue) end
            end
        end,

        __index = function(self, index)
            if index == '__table__' then
                return rawget(self, index)
            else
                return self.__table__[index]
            end
        end
    }) class.__table__ = {} return class
end

local M = {}

local function str(s)
    local s = UTF8.sub(s, 1, UTF8.len(s) - 1)
    return UTF8.find(s, '%(') and UTF8.sub(s, 1, UTF8.find(s, '%(') - 1) or s
end

function M:listenerObjects(e)
    if e.phase == 'began' then
        display.getCurrentStage():setFocus(e.target)
        e.target.click = true
    elseif e.phase == 'moved' and (math.abs(e.yDelta) > 30 or math.abs(e.xDelta) > 30) then
        display.getCurrentStage():setFocus(nil)
        e.target.click = nil

        if self.isMoveActive then
            display.getCurrentStage():setFocus(self.group[2])
            self.group[2].click = true
            self.level.xStart = self.level.x
            self.level.yStart = self.level.y
        end
    elseif e.phase == 'ended' or e.phase == 'cancelled' then
        display.getCurrentStage():setFocus(nil)
        if e.target.click then
            e.target.click = nil
            self:createSidebar(e.target.object)
        end
    end
end

function M:listenerToolbar(e, type)
    if e.phase == 'began' then
        display.getCurrentStage():setFocus(e.target)
        e.target.click = true
        e.target.alpha = 0.1
    elseif e.phase == 'moved' and (math.abs(e.yDelta) > 30 or math.abs(e.xDelta) > 30) then
        display.getCurrentStage():setFocus(nil)
        e.target.click = nil
        e.target.alpha = self.isMoveActive and 0.1 or 0.005
    elseif e.phase == 'ended' or e.phase == 'cancelled' then
        display.getCurrentStage():setFocus(nil)
        e.target.alpha = 0.005
        if e.target.click then
            e.target.click = nil
            if type == 'eye' then
                self.isMoveActive = not self.isMoveActive
                e.target.alpha = self.isMoveActive and 0.1 or 0.005
            elseif type == 'plus' then
                self.level.size = self.level.size - 0.1
                self:resizeLevel(self.params)
            elseif type == 'minus' then
                self.level.size = self.level.size + 0.1
                self:resizeLevel(self.params)
            end
        end
    end
end

function M:createToolbar()
    self.toolbar = display.newGroup()

    self.toolbar.bg = display.newRoundedRect(CENTER_X, CENTER_Y - DISPLAY_HEIGHT / 2 + TOP_HEIGHT, DISPLAY_WIDTH, 200 + TOP_HEIGHT*2, 40)
        self.toolbar.bg:setFillColor(unpack(LOCAL.themes.editorAddColor))
    self.toolbar:insert(self.toolbar.bg)

    self.toolbar.minus = display.newRoundedRect(MAX_X - 50, ZERO_Y + 50, 80, 80, 16)
        self.toolbar.minus:setFillColor(1)
        self.toolbar.minus.alpha = 0.005

        self.toolbar.minus.icon = display.newImage(THEMES.minusLevel(), self.toolbar.minus.x, ZERO_Y + 50)
            self.toolbar.minus.icon:setFillColor(unpack(LOCAL.themes.levelColor))
            self.toolbar.minus.icon.width = 60
            self.toolbar.minus.icon.height = 60
        self.toolbar:insert(self.toolbar.minus.icon)

        self.toolbar.minus:addEventListener('touch', function(e) self:listenerToolbar(e, 'minus') return true end)
    self.toolbar:insert(self.toolbar.minus)

    self.toolbar.plus = display.newRoundedRect(self.toolbar.minus.x - 80, ZERO_Y + 50, 80, 80, 16)
        self.toolbar.plus:setFillColor(1)
        self.toolbar.plus.alpha = 0.005

        self.toolbar.plus.icon = display.newImage(THEMES.plusLevel(), self.toolbar.plus.x, ZERO_Y + 50)
            self.toolbar.plus.icon:setFillColor(unpack(LOCAL.themes.levelColor))
            self.toolbar.plus.icon.width = 60
            self.toolbar.plus.icon.height = 60
        self.toolbar:insert(self.toolbar.plus.icon)

        self.toolbar.plus:addEventListener('touch', function(e) self:listenerToolbar(e, 'plus') return true end)
    self.toolbar:insert(self.toolbar.plus)

    self.toolbar.eye = display.newRoundedRect(self.toolbar.plus.x - 80, ZERO_Y + 50, 80, 80, 16)
        self.toolbar.eye:setFillColor(1)
        self.toolbar.eye.alpha = 0.005

        self.toolbar.eye.icon = display.newImage(THEMES.eyeLevel(), self.toolbar.eye.x, ZERO_Y + 50)
            self.toolbar.eye.icon:setFillColor(unpack(LOCAL.themes.levelColor))
            self.toolbar.eye.icon.width = 60
            self.toolbar.eye.icon.height = 60
        self.toolbar:insert(self.toolbar.eye.icon)

        self.toolbar.eye:addEventListener('touch', function(e) self:listenerToolbar(e, 'eye') return true end)
    self.toolbar:insert(self.toolbar.eye)

    self.toolbar.add = display.newRoundedRect(self.toolbar.eye.x - 80, ZERO_Y + 50, 80, 80, 16)
        self.toolbar.add:setFillColor(1)
        self.toolbar.add.alpha = 0.005

        self.toolbar.add.icon = display.newImage(THEMES.addLevel(), self.toolbar.add.x, ZERO_Y + 50)
            self.toolbar.add.icon:setFillColor(unpack(LOCAL.themes.levelColor))
            self.toolbar.add.icon.width = 60
            self.toolbar.add.icon.height = 60
        self.toolbar:insert(self.toolbar.add.icon)

        self.toolbar.add:addEventListener('touch', function(e) self:listenerToolbar(e, 'add') return true end)
    self.toolbar:insert(self.toolbar.add)
end

function M:getObjects(id)
    return id and self.objects[id] or self.objects
end

M.sidebarButtons = {
    {id = '_id', text = str(STR['blocks.newObject.params'][1]), func = function(object, id)
        if not M.ids[object._id] then
            M.ids[object._id] = true M.ids[id] = nil
            M.params[object._id] = COPY_TABLE(M.params[id]) M.params[id] = nil
            M.objects[object._id] = M:getObjects(id) M.objects[id] = nil
        end
    end},
    {id = '_w', text = str(STR['blocks.setWidth.params'][2]), func = function(object)
        M:getObjects(object._id).width = M:setSize(object._w)
    end},
    {id = '_h', text = str(STR['blocks.setHeight.params'][2]), func = function(object)
        M:getObjects(object._id).height = M:setSize(object._h)
    end},
    {id = '_x', text = str(STR['blocks.setPosX.params'][2]) .. 'X', func = function(object)
        M:getObjects(object._id).x = M:setX(object._x)
    end, visual = function() end},
    {id = '_y', text = str(STR['blocks.setPosY.params'][2]) .. 'Y', func = function(object)
        M:getObjects(object._id).y = M:setY(object._y)
    end, visual = function() end},
    {id = '_r', text = str(STR['blocks.setRotation.params'][2]), func = function(object)
        M:getObjects(object._id).rotation = object._r
    end}
}

function M:hideSidebar()
    if self.sidebar then
        -- self.sidebar.scroll:removeSelf()
        self.sidebar.bg:removeSelf()
        self.sidebar:removeSelf()

        self.sidebar.scroll = nil
        self.sidebar.bg = nil
        self.sidebar = nil

        native.setKeyboardFocus(nil)
    end
end

function M:createSidebar(object)
    self:hideSidebar()
    self.sidebar = display.newGroup()

    self.sidebar.bg = display.newRoundedRect(CENTER_X, CENTER_Y + DISPLAY_HEIGHT / 2 - BOTTOM_HEIGHT, DISPLAY_WIDTH, 200 + BOTTOM_HEIGHT*2, 40)
        self.sidebar.bg:setFillColor(unpack(LOCAL.themes.editorAddColor))
    self.sidebar:insert(self.sidebar.bg)

    self.sidebar.bg.line = display.newRoundedRect(CENTER_X, self.sidebar.bg.y - self.sidebar.bg.height / 2 + 50, DISPLAY_WIDTH / 4, 6, 100)
        self.sidebar.bg.line:setFillColor(unpack(LOCAL.themes.levelColor))
    self.sidebar:insert(self.sidebar.bg.line)

    -- self.sidebar.scroll = WIDGET.newScrollView({
    --         x = self.sidebar.bg.x, y = self.sidebar.bg.y,
    --         width = self.sidebar.bg.width, height = self.sidebar.bg.height,
    --         hideScrollBar = false, horizontalScrollDisabled = true,
    --         isBounceEnabled = true, hideBackground = true
    --     })
    -- self.sidebar:insert(self.sidebar.scroll)
    --
    -- local y = 75 - 120
    -- for _, button in ipairs(self.sidebarButtons) do y = y + 120
    --     self.sidebar[button.id] = native.newTextField(10000, y, 160, 50)
    --         self.sidebar[button.id].hasBackground = false
    --         self.sidebar[button.id]:setTextColor(IS_SIM and 0 or 1)
    --         self.sidebar[button.id].font = native.newFont('ubuntu', 28)
    --         self.sidebar[button.id].text = tostring(object[button.id])
    --
    --         timer.new(100, 1, function()
    --             pcall(function() self.sidebar[button.id].x = 100 end)
    --         end)
    --
    --         self.sidebar[button.id].line = display.newRect(100, y + 30, 164, 3)
    --         self.sidebar[button.id].title = display.newText(button.text, 100, y - 45, 'ubuntu', 24)
    --
    --         self.sidebar[button.id]:addEventListener('userInput', function(e)
    --             if e.phase == 'editing' then
    --                 if button.id == '_id' and M.ids[e.text] then
    --                     e.target.exists = true
    --                     return true
    --                 end
    --
    --                 self.params[object._id][button.id] = tonumber(e.text) or e.text
    --                 self.objects[object._id].object[button.id] = tonumber(e.text) or e.text
    --                 button.func(self.params[object._id], object._id)
    --
    --                 if button.id == '_id' then
    --                     object._id = e.text
    --                     e.target.exists = nil
    --                 end
    --             elseif e.phase == 'ended' or e.phase == 'submitted' then
    --                 native.setKeyboardFocus(nil)
    --
    --                 if e.target.exists then
    --                     e.target.text = object._id
    --                 end
    --             end
    --         end)
    --
    --         if button.visual then
    --             --
    --         end
    --
    --         self.sidebar.scroll:insert(self.sidebar[button.id].line)
    --         self.sidebar.scroll:insert(self.sidebar[button.id].title)
    --     self.sidebar.scroll:insert(self.sidebar[button.id])
    -- end
end

function M:setSize(size)
    if not tonumber(size) then return 1 end
    return size / self.level.size
end

function M:setX(x)
    if not tonumber(x) then return CENTER_X end
    return SET_X(x / self.level.size)
end

function M:setY(y)
    if not tonumber(y) then return CENTER_Y end
    return SET_Y(y / self.level.size)
end

function M:resizeLevel(objects)
    self.level[1].width = 720 / self.level.size
    self.level[1].height = 1280 / self.level.size

    for _, object in pairs(objects) do
        self.objects[object._id].x = self:setX(object._x)
        self.objects[object._id].y = self:setY(object._y)
        self.objects[object._id].width = self:setSize(object._w)
        self.objects[object._id].height = self:setSize(object._h)
        self.objects[object._id].rotation = object._r
    end
end

function M:createLevel(objects)
    local size = self.level and self.level.size or 1.2
    local x = self.level and self.level.x or 0 - self.group[3].width / 2
    local y = self.level and self.level.y or 0 - self.group[3].height / 2

    if self.level then
        self.level:removeSelf()
        self.level = nil

        for _, object in pairs(self.objects) do
            object:removeSelf()
            object = nil
        end
    end

    self.level = display.newGroup()
    self.level.size = size
    self.level.x = x
    self.level.y = y
    self.objects = {}
    self.params = {}

    local app = display.newRect(CENTER_X, CENTER_Y, 720 / self.level.size, 1280 / self.level.size)
        app:setFillColor(0, 0, 0, 0)
        app:setStrokeColor(1)
        app.strokeWidth = IS_SIM and 2 or 1
    self.level:insert(app)

    for _, object in ipairs(objects) do
        self.objects[object._id] = display.newRect(self:setX(object._x), self:setY(object._y), self:setSize(object._w), self:setSize(object._h))
        self.objects[object._id]:addEventListener('touch', function(e) self:listenerObjects(e) return true end)
        self.objects[object._id]:setFillColor(unpack(object._c))
        self.objects[object._id].rotation = object._r
        self.objects[object._id].object = object
        self.params[object._id] = object
        self.ids[object._id] = true
        self.level:insert(self.objects[object._id])
    end

    self.group[3]:insert(self.level)
end

function M:create()
    self.group = display.newGroup()
    self.ids = {}

    local level = JSON.decode(READ_FILE(DOC_DIR .. '/' .. CURRENT_LINK .. '/Levels/Level1'))

    local bg = display.newRect(CENTER_X, CENTER_Y, DISPLAY_WIDTH, DISPLAY_HEIGHT)
        bg:setFillColor(unpack(LOCAL.themes.levelAddColor))
        bg.width = DISPLAY_WIDTH
        bg.height = DISPLAY_HEIGHT
    self.group:insert(bg)

    local canvas = display.newRect(CENTER_X, CENTER_Y + TOP_HEIGHT / 2 + 50, DISPLAY_WIDTH, DISPLAY_HEIGHT - TOP_HEIGHT - 100)
        canvas:setFillColor(unpack(LOCAL.themes.levelAddColor))
    self.group:insert(canvas)

    local container = display.newContainer(canvas.width, canvas.height)
        container:translate(canvas.x, canvas.y)
    self.group:insert(container)

    canvas:addEventListener('touch', function(e)
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            e.target.click = true

            if self.isMoveActive then
                self.level.xStart = self.level.x
                self.level.yStart = self.level.y
            end
        elseif e.phase == 'moved' and e.target.click then
            e.target.isMove = math.abs(e.xDelta) > 10 or math.abs(e.yDelta) > 10

            if self.isMoveActive then
                self.level.x = self.level.xStart + e.xDelta
                self.level.y = self.level.yStart + e.yDelta
            end
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)

            if not e.target.isMove then
                self:hideSidebar()
            end

            if e.target.click then
                e.target.click = nil
                e.target.isMove = nil
            end
        end
        return true
    end)

    self:createToolbar()
    self:createLevel(level.params)
    self:createSidebar(level.params[3])
end

return M

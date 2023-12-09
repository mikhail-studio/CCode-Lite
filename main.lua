ARGS = ...

display.setStatusBar(display.HiddenStatusBar)
display.setStatusBar(display.TranslucentStatusBar)
display.setStatusBar(display.HiddenStatusBar)

timer.performWithDelay(system.getInfo 'environment' == 'simulator' and 0 or 100, function()
    display.setStatusBar(display.HiddenStatusBar)
    display.setStatusBar(display.TranslucentStatusBar)
    display.setStatusBar(display.HiddenStatusBar)

    GLOBAL = require 'Data.global'
    MENU = require 'Interfaces.menu'
    ROBODOG = require 'Interfaces.robodog'

    if not LIVE and (system.getInfo('deviceID') == 'ad086e7885c038ac78cc320bee71fdab' or not IS_SIM) then
        require 'starter'
    else
        MENU.create()
        MENU.group.isVisible = true
    end
end)

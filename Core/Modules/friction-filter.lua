return {
    check = function(text, listener)
        local text = UTF8.trim(text)
        local text = tonumber(text)

        if text and text >= 10 and text <= 1000 then
            listener({isError = false, text = text}) return
        end

        listener({isError = true, typeError = 'scroll_friction'})
    end
}

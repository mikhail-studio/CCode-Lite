return {
    check = function(text, listener)
        local text = UTF8.trim(text)
        local text = tonumber(text)

        if text and text >= 1 and text <= 59 then
            listener({isError = false, text = text}) return
        end

        listener({isError = true, typeError = 'backup_frequency'})
    end
}

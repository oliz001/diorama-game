--------------------------------------------------
local MenuItemBase = require ("resources/mods/diorama/frontend_menus/menu_items/menu_item_base")
local Mixin = require ("resources/mods/diorama/frontend_menus/mixin")

--------------------------------------------------
local c = {}

--------------------------------------------------
function c:onUpdate (menu, x, y, was_left_clicked)

    if self.isSelected then

        self.flashCount = self.flashCount < 16 and self.flashCount + 1 or 0

    else
        self.isHighlighted = 
                x >= 0 and
                x <= menu.width and
                y >= self.y and 
                y < self.y + self.height

        if was_left_clicked and self.isHighlighted then
            if not self.isSelected then
                -- somehow stop the menu from doing other things!
                --menu:lockHighlightToMenuItem (self)
                self.flashCount = 0
                self.initial_value = self.value
                self.isSelected = true

                menu:setUpdateOnlySelectedMenuItems (true)
            end
        end
    end
end

--------------------------------------------------
function c:onRender (font, menu)

    local itemWidth = menu.width - 200
    local x = 100

    local color = self.isHighlighted and 0xffffffff or 0x00ffffff
    color = self.isSelected and 0xff0000ff or color

    if self.isHighlighted or self.isSelected then
        dio.drawing.font.drawBox (0, self.y, menu.width, self.height, 0x000000ff)
    end

    font.drawString (x, self.y, self.text, color)

    if self.isHighlighted then
        local width = font.measureString (">>>>    ")
        font.drawString (x - width, self.y, ">>>>    ", color)
        font.drawString (x + itemWidth, self.y, "    <<<<", color)
    end

    local value = self.value
    local width = font.measureString (value)    
    if self.isSelected then
        width = width + font.measureString ("_")
        if self.flashCount < 8 then
            value = value .. "_"
        end
    end
    font.drawString (itemWidth + x - width, self.y, value, color)
end

--------------------------------------------------
function c:onKeyClicked (menu, keyCode, keyCharacter, keyModifiers)

    assert (self.isSelected)

    local keyCodes = dio.inputs.keyCodes

    if keyCharacter then

        local isDigit = (keyCharacter >= string.byte ("0") and keyCharacter <= string.byte ("9"))
        local isPeriod = (keyCharacter == string.byte (".") and not self.isInteger)
        local isNegative = (keyCharacter == string.byte ("-"))
        if isPeriod then
            isPeriod = (not string.find (self.value, "%.") and self.value:len () > 0)
        end
        if isNegative then
            isNegative = (self.value:len () == 0)
        end

        if isDigit or isPeriod or isNegative then

            self.value = self.value .. string.char (keyCharacter)
            if self.onTextChanged then
                self:onTextChanged (menu)
            end
        end

        return true

    elseif keyCode == keyCodes.ESCAPE then

        self.value = self.initial_value
        self.initial_value = nil
        self.isSelected = false
        menu:setUpdateOnlySelectedMenuItems (false)
        if self.onTextChanged then
            self:onTextChanged (menu)
        end

    elseif keyCode == keyCodes.ENTER or 
            keyCode == keyCodes.KP_ENTER then
            
        self.initial_value = nil
        self.isSelected = false
        menu:setUpdateOnlySelectedMenuItems (false)
        if self.onTextChangeConfirmed then
            self:onTextChangeConfirmed (menu)
        end

    elseif keyCode == keyCodes.BACKSPACE then

        local stringLen = self.value:len ()
        if stringLen > 0 then
            self.value = self.value:sub (1, -2)
            if self.onTextChanged then
                self:onTextChanged (menu)
            end
        end
    end
end

--------------------------------------------------
function c:getValueAsNumber ()
    return tonumber (self.value)
end

--------------------------------------------------
return function (text, onTextChanged, onTextChangeConfirmed, initialValue, isInteger)

    local instance = MenuItemBase ()

    local properties =
    {
        text = text,
        value = tostring (initialValue),
        isInteger = isInteger,
        flashCount = 0,
        isSelected = false,
        onTextChanged = onTextChanged,
        onTextChangeConfirmed = onTextChangeConfirmed
    }

    Mixin.CopyTo (instance, properties)
    Mixin.CopyTo (instance, c)

    return instance
end

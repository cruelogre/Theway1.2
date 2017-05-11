-----------------------------------------
-- comment:
--    如果CheckBox的样式比较通用，即可考虑使用StyleCheckBox。提高编码效率，也增强可配置性便于统一管理。
--    请参考样式配置管理StyleUIMgr。
--    例子：
--           --CheckBox样式，如需增加请在gCheckBoxStyleConf全局表中配置
--           --gCheckBoxStyleConf中的Style_Test是通过StyleUIMgr.loadRes添加的。请参考StyleUIMgr
--           local CheckBoxStyle = gCheckBoxStyleConf.Style_Test

--           --CheckBox上的内容，cc.Node即可,CheckBoxTxt可不传
--           local CheckBoxTxt = cc.Sprite:create(src)

--           --CheckBox的点击回调
--           local function selectedEvent(sender,eventType)
--              if eventType == ccui.CheckBoxEventType.selected then
--                  assert("selected")
--              elseif eventType == ccui.CheckBoxEventType.unselected then
--                  assert("unselected")
--              end
--           end
--           local StyleCheckBox = StyleCheckBox:create(CheckBoxStyle，callback,CheckBoxTxt)::addTo(node)
--           --默认CheckBoxTxt在CheckBox中间。可通过setTxtOffset微调。参数代表相对于初始位置的偏移量。比如(10,10)表示偏移初始位置x，y方向各10个单位
--           StyleCheckBox:setTxtOffset(10,10)
--           --快速将CheckBox添加到Menu中，简化代码。酌情使用。
--           StyleCheckBox:addTo(node)
-- author: Jackie刘龙
-----------------------------------------
local StyleCheckBox = class("StyleCheckBox", ccui.CheckBox)

local errorStyleHint = [[
**********************
the style of StyleCheckBox must be a table like below:
{
    ["background"] = "common/btn_style_1_normal.png"
    ["backgroundSelected"] = "common/btn_style_1_selected.png"
    ["backgroundDisabled"] = "common/btn_style_1_disabled.png"
    ["cross"] = "common/btn_style_1_normal.png"
    ["frontCrossDisabled"] = "common/btn_style_1_normal.png"
    ["clickEffect"] = "common/btn_style_1_normal.png"   ----optional
},
**********************
]]

-- style：样式ID，
-- cbTxt：cc.Node即可
-- selectEvent: checkBox回调，例子如下：
-- local function selectedEvent(sender,eventType)
--        if eventType == ccui.CheckBoxEventType.selected then
--            self._displayValueLabel:setString("Selected")
--        elseif eventType == ccui.CheckBoxEventType.unselected then
--            self._displayValueLabel:setString("Unselected")
--        end
--    end
function StyleCheckBox:ctor(style, selectEvent, cbTxt)
    self:init(style, selectEvent, cbTxt)
end

function StyleCheckBox:init(style, selectEvent, cbTxt)
    self:setStyle(style)
    self:setTouchEnabled(true)
    if selectEvent then
        self:addEventListener(selectEvent)
    end
    if cbTxt then
        self:setTxt(cbTxt)
    end
end

function StyleCheckBox:setStyle(style)
    if style then
        local background = style[gUIBeanStyleConfField.KeyCb_Bg]
        local backgroundSelected = style[gUIBeanStyleConfField.KeyCb_BgSelected]
        local cross = style[gUIBeanStyleConfField.KeyCb_Crs]
        local backgroundDisabled = style[gUIBeanStyleConfField.KeyCb_BgDisabled]
        local frontCrossDisabled = style[gUIBeanStyleConfField.KeyCb_FrntCrsDisabled]
        local clickEffect = style[gUIBeanStyleConfField.KeyCb_ClickEffect]
        local anchorPoint = style[gUIBeanStyleConfField.Key_AnchorP]
        if background and backgroundSelected and cross and backgroundDisabled and frontCrossDisabled then
            self:loadTextureBackGround(background)
            self:loadTextureBackGroundSelected(backgroundSelected)
            self:loadTextureFrontCross(cross)
            self:loadTextureBackGroundDisabled(backgroundDisabled)
            self:loadTextureFrontCrossDisabled(frontCrossDisabled)
            if clickEffect then

            end
            if anchorPoint then
                self:setAnchorPoint(anchorPoint)
            end
        else
            error(errorStyleHint)
        end
    else
        error("StyleCheckBox:setStyle, the target style is not in gUIBeanStyleConf,you can add it by StyleUIMgr.load")
    end
end

function StyleCheckBox:addTo(node)
    if node then
        node:addChild(self)
        return self
    end
    return nil
end

function StyleCheckBox:setTxt(CheckBoxTxt)
    assert(CheckBoxTxt, "StyleCheckBox:setTxt,txt must be not nil");
    CheckBoxTxt:setPosition(cc.p(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5))
    CheckBoxTxt:setCascadeColorEnabled(true)
    CheckBoxTxt:setCascadeOpacityEnabled(true)
    self:addChild(CheckBoxTxt)
    self._CheckBoxTxt = CheckBoxTxt
end

function StyleCheckBox:setTxtOffset(x, y)
    if self._CheckBoxTxt and type(x) == "number" and type(y) == "number" then
        local tmpX, tmpY = self._CheckBoxTxt:getPosition()
        self._CheckBoxTxt:setPosition(cc.p(tmpX + x, tmpY + y))
    end
end

cc.exports.StyleCheckBox = cc.exports.StyleCheckBox or StyleCheckBox

return StyleCheckBox

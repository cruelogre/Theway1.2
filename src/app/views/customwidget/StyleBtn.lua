-----------------------------------------
-- comment:
--    提高编码效率，也增强可配置性便于统一管理。
--    请参考样式配置管理StyleUIMgr。
--    例子：
--           --按钮样式，如需增加请在gBtnStyleConf全局表中配置
--           --gBtnStyleConf中的Style_Test是通过StyleUIMgr.loadRes添加的。请参考StyleUIMgr
--           local btnStyle = gBtnStyleConf.Style_Test
--           --按钮上的内容，cc.Node即可。这个可为空
--           local btnTxt = cc.Sprite:create(src)
--           --按钮的点击回调
--           local function callback(sender, eventType)
--               if eventType == ccui.TouchEventType.began then
--                   assert(false,"began")
--               elseif eventType == ccui.TouchEventType.moved then
--                   assert(false,"moved")
--               elseif eventType == ccui.TouchEventType.ended then
--                    assert(false,"ended")
--               elseif eventType == ccui.TouchEventType.canceled then
--                   assert(false,"canceled")
--               end
--           end
--           local styleBtn = StyleBtn:create(btnStyle,callback,btnTxt)
--           --默认btnTxt在按钮中间。可通过setTxtOffset微调。参数代表相对于初始位置的偏移量。比如(10,10)表示偏移初始位置x，y方向各10个单位
--           styleBtn:setTxtOffset(10,10)
--           --快速将btn添加到Menu中，简化代码。酌情使用。
--           styleBtn:addTo(node)
-- author: Jackie刘龙
-----------------------------------------
-- 样式按钮配置，“日”后根据需求可添加新属性
local StyleBtn = class("StyleBtn", ww.NewButton)

local invalidStyleHint = [[
**********************
the style of StyleBtn must be a table like below:
{
    ["normal"] = "common/btn_style_1_normal.png"
    ["selected"] = "common/btn_style_1_selected.png"    ---optional
    ["disabled"] = "common/btn_style_1_disabled.png"    ---optional
    ["clickEffect"] = "common/btn_style_1_normal.png"   ---optional
}
disabled and clickEffect is optional
all styles are controlled by StyleUIMgr.go for it for more info.
**********************]]

-- style：样式ID，
-- btnTxt：cc.Node,可为空
function StyleBtn:ctor(style, callback, btnTxt)
    self:setBtnStyle(style)
    local function btnCallback(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            ccexp.AudioEngine:play2d(style[gUIBeanStyleConfField.KeyBtn_ClickEffect], false, 1.0)
            --        elseif eventType == ccui.TouchEventType.moved then
            --        elseif eventType == ccui.TouchEventType.ended then
            --        elseif eventType == ccui.TouchEventType.canceled then
        end
        if callback then
            callback(sender, eventType)
        end
    end
    self:addTouchEventListener(btnCallback)
    if btnTxt then
        self:setTxt(btnTxt)
    end
end

function StyleBtn:setBtnStyle(style)
    local gotIt = false
    if style then
        local normal = style[gUIBeanStyleConfField.KeyBtn_Normal]
        local selected = style[gUIBeanStyleConfField.KeyBtn_Selected]
        local disabled = style[gUIBeanStyleConfField.KeyBtn_Disabled]
        local clickEffect = style[gUIBeanStyleConfField.KeyBtn_ClickEffect]
        local anchorPoint = style[gUIBeanStyleConfField.Key_AnchorP]
        if normal then
            self:setPosition(cc.p(0, 0))
            self:loadTextureNormal(normal)
            if selected then
                self:loadTexturePressed(selected)
            end
            if disabled then
                self:loadTextureDisabled(disabled)
            end
            if anchorPoint then
                self:setAnchorPoint(anchorPoint)
            end
            gotIt = true
        else
            error(invalidStyleHint)
        end
    else
        error("style is nil")
    end
end

function StyleBtn:addTo(node)
    if node then
        node:addChild(self)
        return self
    end
    return nil
end

-- 继承自UIButton，所以StyleBtn也可以通过setTitleText,setTitleColor,setTitleFontName,setTitleFontSize来设置按钮上的文字
-- 本函数则更灵活，btnTxt是个Node。
-- 当setTitleText可以解决的时候，请优先使用
function StyleBtn:setTxt(btnTxt)
    assert(btnTxt, "StyleBtn:setTxt,txt must be not nil");
    btnTxt:setPosition(cc.p(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5))
    btnTxt:setCascadeColorEnabled(true)
    btnTxt:setCascadeOpacityEnabled(true)
    self:addChild(btnTxt)
    self._btnTxt = btnTxt
end

function StyleBtn:setTxtOffset(x, y)
    if self._btnTxt and type(x) == "number" and type(y) == "number" then
        local tmpX, tmpY = self._btnTxt:getPosition()
        self._btnTxt:setPosition(cc.p(tmpX + x, tmpY + y))
    end
end

cc.exports.StyleBtn = cc.exports.StyleBtn or StyleBtn

return StyleBtn

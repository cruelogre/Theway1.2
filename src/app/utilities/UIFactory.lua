-----------------------------------------------------------
-- Desc:     地方棋牌
-- Author:   diyal.yin
-- Date:  	 2016/08/13
-- Last: 	
-- Content:  UIFactory UI工厂类  通过配表的方式生成布局文件
--           相比Cocossudio来讲，这种更符合程序来生成布局，轻量级
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------
local UIFactory = class("UIFactory")

--[[
根据配置表生成布局文件
@param ustb 布局table
@param parent 父节点
sp 
{
    n name
    t 控件类型
    layoutPos 相对布局坐标
    x, y 坐标
    od  order
    res  资源路径  注意，如果是plist的话，在路径前加#
    arc  锚点
    hd   是否隐藏
    scale 缩放
    rotate 旋转
}
--]]
function UIFactory:createLayoutNode(ustb, parent, pathflag)
    if pathflag == nil then
        pathflag = ""
    end
    local uis = { }
    for _, ps in pairs(ustb) do
        local t = ps.t
        local parentNode =(ps.ftg and ps.ftg > 0) and parent:getChildByTag(ps.ftg) or parent
        if (t == "sp") then
            if ps.size then --九宫格方式创建
                uis[ps.n] = ccui.Scale9Sprite:create(pathflag .. ps.res)
                uis[ps.n]:setContentSize(cc.size(ps.size[1], ps.size[2]))
            else
                if ps.res then
                    uis[ps.n] = display.newSprite(pathflag .. ps.res)
                else
                    uis[ps.n] = display.newSprite()
                end
            end

            if (uis[ps.od]) then
                uis[ps.od]:setOrderOfArrival(ps.od)
            end

            if (uis[ps.n] and ps.od) then
                if (ps.arc) then --锚点
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end

                if ps.x then
                    uis[ps.n]:setPositionX(ps.x)
                end
                if ps.y then
                    uis[ps.n]:setPositionY(ps.y)
                end
     
                if (ps.hd) then --是否显示
                    uis[ps.n]:setVisible(false)
                end
                if ps.scale then
                    uis[ps.n]:setScale(ps.scale)
                end
                if ps.rotate then
                    uis[ps.n]:setRotation(ps.rotate)
                end
            end
        elseif (t == "btn") then
            if (ps.res[4]) then
                uis[ps.n] = ccui.Button:create(ps.res[1] or "", ps.res[2] or "", ps.res[3] or "", ps.res[4])
            else
                uis[ps.n] = ccui.Button:create(ps.res[1] or "", ps.res[2] or "", ps.res[3] or "")            
            end
            
            if (uis[ps.n]) then
                if (ps.arc) then
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end
                uis[ps.n]:setPosition(ps.x, ps.y)
                if (ps.hd) then
                    uis[ps.n]:setVisible(false)
                end
                if (ps.zd) then
                    uis[ps.n]:setZOrder(ps.zd)
                end
                if ps.scale then
                    uis[ps.n]:setScale(ps.scale)
                end
                if ps.TitleText then
                    uis[ps.n]:setTitleText(ps.TitleText)
                    if ps.TitleColor then
                        uis[ps.n]:setTitleColor(ps.TitleColor)
                    end              
                    if ps.TitleFontSize then
                        uis[ps.n]:setTitleFontSize(ps.TitleFontSize)
                    end

                end
            end
        elseif (t == "txt") then
            if (ps.rect) then
                local align = ps.align or cc.TEXT_ALIGNMENT_CENTER
                local valign = ps.valign or cc.VERTICAL_TEXT_ALIGNMENT_CENTER
                uis[ps.n] = cc.LabelTTF:create(ps.txt, CFG_SYSTEM_FONT, ps.size, cc.size(ps.rect[1], ps.rect[2]), align, valign)
            else
                uis[ps.n] = cc.LabelTTF:create(ps.txt, CFG_SYSTEM_FONT, ps.size or 25)
            end
            if ps.x then
                uis[ps.n]:setPositionX(ps.x)
            end
            if ps.y then
                uis[ps.n]:setPositionY(ps.y)
            end
            if (ps.color) then
                uis[ps.n]:setColor(cc.c3b(ps.color[1], ps.color[2], ps.color[3]))
            end
            if (ps.hd) then
                uis[ps.n]:setVisible(false)
            end
            if (ps.arc) then
                uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
            end
        elseif (t == "font") then
            if ps.fnt and ps.txt then
                uis[ps.n] = cc.LabelBMFont:create(ps.txt, ps.fnt);
            end
            if uis[ps.n] then
                if (ps.arc) then
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end
                uis[ps.n]:setPosition(ps.x, ps.y);
            end
        elseif (t == "color") then
            local defalpha = ps.alpha or 128
            local color = cc.c4b(0, 0, 0, defalpha)
            if (ps.color) then
                color = cc.c4b(ps.color[1], ps.color[2], ps.color[3], ps.color[4])
            end
            if ps.size then
                uis[ps.n] = display.newLayer(color, cc.size(ps.size[1], ps.size[2]))
            else
                uis[ps.n] = display.newLayer(color)
            end
            uis[ps.n]:setPosition(ps.x, ps.y)
            if (ps.hd) then
                uis[ps.n]:setVisible(false)
            end
            if (ps.arc) then
                uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
            end
        elseif (ps.t == "node") then
            uis[ps.n] = display.newNode()
            if (uis[ps.n]) then
                if (ps.arc) then
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end
                if (ps.rect) then
                    uis[ps.n]:setContentSize(cc.size(ps.rect[1], ps.rect[2]))
                    uis[ps.n]:ignoreAnchorPointForPosition(false)
                end
                if ps.x then
                    uis[ps.n]:setPositionX(ps.x)
                end
                if ps.y then
                    uis[ps.n]:setPositionY(ps.y)
                end
                -- print("GenUiUtil:genUi node",uis[ps.n]:getPosition(),ps.x,ps.y)
                if (ps.hd) then
                    uis[ps.n]:setVisible(false)
                end
            end
        elseif (ps.t == "clipnode") then
            if ps.rect then
                -- rect = {x,y,width,height}
                uis[ps.n] = cc.ClippingRectangleNode:create(cc.rect(ps.rect[1], ps.rect[2], ps.rect[3], ps.rect[4]))
            else
                uis[ps.n] = cc.ClippingNode:create()
                if ps.stencil then
                    -- 严禁在UI table中添加。请在代码手动添加
                    uis[ps.n]:setStencil(ps.stencil)
                end
            end
            if (uis[ps.n]) then
                if (ps.arc) then
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end
                if ps.x then
                    uis[ps.n]:setPositionX(ps.x)
                end
                if ps.y then
                    uis[ps.n]:setPositionY(ps.y)
                end
                if (ps.rect) then
                    --                    uis[ps.n]:setContentSize(cc.size(ps.rect[1], ps.rect[2]))
                    uis[ps.n]:ignoreAnchorPointForPosition(false)
                end
                if (ps.hd) then
                    uis[ps.n]:setVisible(false)
                end
                if ps.inverted then
                    uis[ps.n]:setInverted(ps.inverted)
                end
            end

        elseif (ps.t == "editbox") then
            cclog(ps.res)
            uis[ps.n] = cc.EditBox:create(cc.size(ps.rect[1], ps.rect[2]), ps.res)
            if (uis[ps.n]) then
                if (ps.arc) then
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end
                uis[ps.n]:setPosition(cc.p(ps.x, ps.y))
                if (ps.hd) then
                    uis[ps.n]:setVisible(false)
                end
                if (ps.txt) then
                    uis[ps.n]:setText(ps.txt)
                end
                if (ps.font and ps.size) then
                    uis[ps.n]:setFont(ps.font, ps.size)
                end
                if (ps.fontcolor) then
                    uis[ps.n]:setFontColor(cc.c3b(ps.fontcolor[1], ps.fontcolor[2], ps.fontcolor[3]))
                end
                if (ps.phtxt) then
                    uis[ps.n]:setPlaceHolder(ps.phtxt)
                end
                if (ps.phsize) then
                    uis[ps.n]:setPlaceholderFontSize(ps.phsize);
                end
                if (ps.phcolor) then
                    uis[ps.n]:setPlaceholderFontColor(cc.c3b(ps.phcolor[1], ps.phcolor[2], ps.phcolor[3]))
                end
                if (ps.maxlen) then
                    uis[ps.n]:setMaxLength(ps.maxlen)
                end
                if (mode) then
                    uis[ps.n]:setInputMode(ps.mode)
                end
            end
        elseif (t == "checkbox") then
            uis[ps.n] = ccui.CheckBox:create(ps.res[1], ps.res[2])
            if (uis[ps.n]) then
                if (ps.arc) then
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end
                uis[ps.n]:setPosition(ps.x, ps.y)
                if (ps.hd) then
                    uis[ps.n]:setVisible(false)
                end
                if ps.scale then
                    uis[ps.n]:setScale(ps.scale)
                end
            end
            -- by Jackie start
        elseif t == "sp9" then
            if ps.capInsets then
                uis[ps.n] = ccui.Scale9Sprite:create(ps.capInsets, ps.res)
            else
                uis[ps.n] = ccui.Scale9Sprite:create(ps.res)
            end
            if uis[ps.n] then
                local sizeW = ps.width and ps.width or uis[ps.n]:width()
                local sizeH = ps.height and ps.height or uis[ps.n]:height()
                uis[ps.n]:setPreferredSize( { width = sizeW, height = sizeH })
            end
        elseif t == "LabelAtlas" then
            uis[ps.n] = cc.LabelAtlas:_create(ps.txt, ps.charmap, ps.itemwidth, ps.itemheight, ps.start)
            if uis[ps.n] then
                if ps.arc then
                    uis[ps.n]:setAnchorPoint(cc.p(ps.arc[1], ps.arc[2]))
                end
                if ps.x and ps.y then
                    uis[ps.n]:setPosition(ps.x, ps.y)
                end
            end
        elseif t == "StyleBtn" then
            uis[ps.n] = StyleBtn:create(ps.style, ps.callback, ps.txt)
            if uis[ps.n] then
                if ps.rotation then
                    uis[ps.n]:setRotation(ps.rotation)
                end
            end
        elseif t == "StyleLabel" then
            uis[ps.n] = StyleLabel:create(ps.style, ps.txt)
        elseif t == "StyleCheckBox" then
            uis[ps.n] = StyleCheckBox:create(ps.style, ps.selEvent, ps.txt)
        elseif t == "UIButton" then
            uis[ps.n] = ccui.Button:create(ps.normal, ps.selected, ps.disabled)
            if uis[ps.n] then
                if ps.callback then
                    uis[ps.n]:addTouchEventListener(ps.callback)
                end
                uis[ps.n]:setPressedActionEnabled(true)
                if ps.pressAction ~= nil then
                    uis[ps.n]:setPressedActionEnabled(ps.pressAction)
                end
                if ps.scale9 ~= nil then
                    uis[ps.n]:setScale9Enabled(ps.scale9)
                end
                if ps.txt then
                    uis[ps.n]:setTitleText(ps.txt)
                end
                if ps.color then
                    uis[ps.n]:setTitleColor(ps.color)
                end
                if ps.size then
                    uis[ps.n]:setTitleFontSize(ps.size)
                end
                if ps.fnt then
                    uis[ps.n]:setTitleFontName(ps.fnt)
                end
                if ps.zoomScale then
                    uis[ps.n]:setZoomScale(ps.zoomScale)
                end
            end
        elseif t == "CustomUI" then
            uis[ps.n] = ps.ref
        elseif t == "slider" then
            uis[ps.n] = ccui.Slider:create()
            local slider = uis[ps.n]
            slider:setTouchEnabled(false)
            if ps.barbg then
                slider:loadBarTexture(ps.barbg)
            end
            if ps.bar then
                slider:loadProgressBarTexture(ps.bar)
            end
            if ps.thumb then
                slider:loadSlidBallTextures(ps.thumb, ps.thumb, "")
            end
            if ps.percent then
                slider:setPercent(ps.percent)
            end
        elseif t == "controlslider" then
            uis[ps.n] = cc.ControlSlider:create(ps.bg,ps.progress,ps.thumb)
            local slider = uis[ps.n]
            slider:setMaximumValue(ps.max or 100)
            slider:setMinimumValue(ps.min or 0)
            slider:setValue(ps.val or 0)
            slider:setEnabled(false)
            slider:getThumbSprite():setOpacity(255)
        elseif t == "progress" then
            uis[ps.n] = cc.ProgressTimer:create(cc.Sprite:create(ps.progress))
            if ps.type then
                uis[ps.n]:setType(ps.type)
            else
                uis[ps.n]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            end
            if ps.percent then
                uis[ps.n]:setPercentage(30)
            end
            uis[ps.n]:setMidpoint(cc.p(0.5, 0.5))
            uis[ps.n]:setBarChangeRate(cc.p(1, 1))
        end
        --节点层次
        if (uis[ps.n] and parentNode) then
            local target = uis[ps.n]
            local targetparent = ps.parent and uis[ps.parent] or parentNode
            if ps.cntsize then
                -- contentSize
                target:setContentSize(ps.cntsize)
            end
            if ps.scale then
                target:setScale(ps.scale)
            end
            if ps.x then
                target:setPositionX(ps.x)
            end
            if ps.y then
                target:setPositionY(ps.y)
            end
            if ps.top then
                target:top(uis[ps.top], targetparent)
            end
            if ps.top1 then
                target:top(uis[ps.top1], targetparent)
                target:offsetY(- target:height2())
            end
            if ps.bottom then
                target:bottom(uis[ps.bottom], targetparent)
            end
            if ps.bottom1 then
                target:bottom(uis[ps.bottom1], targetparent)
                target:offsetY(target:height2())
            end
            if ps.left then
                target:left(uis[ps.left], targetparent)
            end
            if ps.left1 then
                target:left(uis[ps.left1], targetparent)
                target:offsetX(target:width2())
            end
            if ps.right then
                target:right(uis[ps.right], targetparent)
            end
            if ps.right1 then
                target:right(uis[ps.right1], targetparent)
                target:offsetX(- target:width2())
            end
            if ps.centerX then
                target:centerX(uis[ps.centerX], targetparent)
            end
            if ps.centerY then
                target:centerY(uis[ps.centerY], targetparent)
            end
            if ps.center then
                target:center(uis[ps.center], targetparent)
            end
            if ps.innerBottom then
                target:innerBottom(uis[ps.innerBottom], targetparent)
            end
            if ps.innerTop then
                target:innerTop(uis[ps.innerTop], targetparent)
            end
            if ps.innerLeft then
                target:innerLeft(uis[ps.innerLeft], targetparent)
            end
            if ps.innerRight then
                target:innerRight(uis[ps.innerRight], targetparent)
            end
            if ps.offsetX then
                target:offsetX(ps.offsetX)
            end
            if ps.offsetY then
                target:offsetY(ps.offsetY)
            end
            if ps.offset then
                target:offset(unpack(ps.offset))
            end
            if ps.flipX then
                target:setFlippedX(ps.flipX)
            end
            if ps.flipY then
                target:setFlippedY(ps.flipY)
            end
            if ps.visibility ~= nil then
                target:setVisible(ps.visibility)
            end
            if ps.enable ~= nil then
                target:setEnabled(ps.enable)
            end
            if ps.order then
                target:setLocalZOrder(ps.order)
            end
            if ps.color and ps.color.r and ps.color.g and ps.color.b then
                target:setColor(ps.color)
            end
            if ps.cascadeOp ~= nil then
                target:setCascadeOpacityEnabled(checkbool(ps.cascadeClr))
            end
            if ps.cascadeClr ~= nil then
                target:setCascadeColorEnabled(checkbool(ps.cascadeOp))
            end

            --是否有父节点
            if ps.parent then
                if ps.t == "StyleBtn" then
                    target:addTo(uis[ps.parent])
                else
                    target:addTo(uis[ps.parent], ps.od or 0, ps.tg)
                end
                -- 没有parent字段
            else
                target:addTo(parentNode, ps.od or 0, ps.tg)
            end
            -- by Jackie end
        end
    end
    return uis
end

cc.exports.UIFactory = cc.exports.UIFactory or UIFactory:new()
return cc.exports.UIFactory
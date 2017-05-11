-----------------------------------------
-- comment:一些常用函数
-- author: Jackie刘龙
-----------------------------------------
local StyleLabel = class("StyleLabel", cc.Label)

function StyleLabel:ctor(style, txt)
    self:init(style, txt)
end

function StyleLabel:init(style, txt)
    -- 必须是Label的style
    if style and style[gUIBeanStyleConfField.KeyType] == gUIBeanConstant.Label then
        local labelType = style[gUIBeanStyleConfField.KeyLbl_Type]
        if labelType == gUIBeanConstant.Label_TTF then
            -- TTF类型
            local ttfConf = style[gUIBeanStyleConfField.KeyLbl_TTFConf]
            local txtClr = style[gUIBeanStyleConfField.KeyLbl_TxtClr]
            if ttfConf then
                self:setTTFConfig(ttfConf)
            end
            if txtClr then
                self:setTextColor(txtClr)
            end
        elseif labelType == gUIBeanConstant.Label_SysFnt then
            -- SysFnt类型
            local sysFnt = style[gUIBeanStyleConfField.KeyLbl_SysFnt]
            local fntSize = style[gUIBeanStyleConfField.KeyLbl_FntSize] or 24
            if sysFnt then
                self:setSystemFontName(sysFnt)
            end
            if fntSize then
                self:setSystemFontSize(fntSize)
            end
            local txtClr = style[gUIBeanStyleConfField.KeyLbl_TxtClr]
            if txtClr then
                self:setTextColor(txtClr)
            end
        elseif labelType == gUIBeanConstant.Label_BMFnt then
            -- BMFnt类型
            local bmFnt = style[gUIBeanStyleConfField.KeyLbl_BMFnt]
            local fntSize = style[gUIBeanStyleConfField.KeyLbl_FntSize]
            local txtClr = style[gUIBeanStyleConfField.KeyLbl_TxtClr]
            if bmFnt then
                self:setBMFontFilePath(bmFnt)
            end
            if txtClr then
                self:setColor(txtClr)
            end
        elseif labelType == gUIBeanConstant.Label_CharMap then
            -- CharMap类型
            local charMap = style[gUIBeanStyleConfField.KeyLbl_CharMap]
            local charMapPlist = style[gUIBeanStyleConfField.KeyLbl_CharMapPlist]
            local ItemW = style[gUIBeanStyleConfField.KeyLbl_ItemW]
            local ItemH = style[gUIBeanStyleConfField.KeyLbl_ItemH]
            local start = style[gUIBeanStyleConfField.KeyLbl_Strt]
            local txtClr = style[gUIBeanStyleConfField.KeyLbl_TxtClr]
            if charMap and ItemW and ItemH and start then
                self:setCharMap(charMap, ItemW, ItemH, start)
            elseif charMapPlist then
                self:setCharMap(charMapPlist)
            end
            if txtClr then
                self:setColor(txtClr)
            end
        end
        -- 荧光
        local glow = style[gUIBeanStyleConfField.KeyLbl_GlowClr]
        -- 阴影
        local shadowClr = style[gUIBeanStyleConfField.KeyLbl_ShdwClr]
        local shadowOffset = style[gUIBeanStyleConfField.KeyLbl_ShdwOffset]
        -- 描边
        local outLineClr = style[gUIBeanStyleConfField.KeyLbl_OutLineClr]
        local outLineSize = style[gUIBeanStyleConfField.KeyLbl_OutLineSize]
        local alignmentH = style[gUIBeanStyleConfField.KeyLbl_HAlgn]
        local alignmentV = style[gUIBeanStyleConfField.KeyLbl_VAlgn]
        local dimensions = style[gUIBeanStyleConfField.KeyLbl_Dimens]
        local width = style[gUIBeanStyleConfField.KeyLbl_Width]
        local maxLineWidth = style[gUIBeanStyleConfField.KeyLbl_MaxLineW]
        local clipMargin = style[gUIBeanStyleConfField.KeyLbl_ClipMargin]
        local lineHeight = style[gUIBeanStyleConfField.KeyLbl_LineHeight]
        local lineBreakWithoutSpace = style[gUIBeanStyleConfField.KeyLbl_LineBreakWithOutSpace]
        local anchorPoint = style[gUIBeanStyleConfField.KeyAnchorP]
        local opacity = style[gUIBeanStyleConfField.KeyOpacity]
        if txt then
            self:setString(txt)
        end
        if alignmentH then
            self:setHorizontalAlignment(alignmentH)
        end
        if alignmentV then
            self:setVerticalAlignment(alignmentV)
        end
        if dimensions then
            self:setDimensions(dimensions.width, dimensions.height)
        end
        if width then
            self:setWidth(width)
        end
        if maxLineWidth then
            self:setMaxLineWidth(maxLineWidth)
        end
        if clipMargin then
            self:setClipMarginEnabled(clipMargin)
        end
        if lineHeight then
            self:setLineHeight(lineHeight)
        end
        if lineBreakWithoutSpace then
            self:setLineBreakWithoutSpace(lineBreakWithoutSpace)
        end
        if glow then
            self:enableGlow(glow)
        end
        if outLineClr and outLineSize then
            self:enableOutline(outLineClr, outLineSize)
        end
        if shadowClr and shadowOffset then
            self:enableShadow(shadowClr, shadowOffset)
        end
        if anchorPoint then
            self:setAnchorPoint(anchorPoint)
        end
        if opacity then
            self:setOpacity(opacity)
        end
    else
        error("StyleLabel:init,the target style is not in gUIBeanStyleConf,you can add it by StyleUIMgr.load");
    end
end

function StyleLabel:addTo(node)
    if node then
        node:addChild(self)
        return self
    end
    return nil
end

cc.exports.StyleLabel = cc.exports.StyleLabel or StyleLabel

return cc.exports.StyleLabel

-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  富文本
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SimpleRichText = class("SimpleRichText",ccui.RichText)

local function splitStr(content, token)  
    if not content or content == '' or not token then return end  
    local strArray = {}  
    local i = 1  
    local contentLen = string.len(content)  
    while true do  
        -- true是用来避开string.find函数对特殊字符检查 特殊字符 "^$*+?.([%-"  
        local beginPos, endPos = string.find(content, token, 1, true)   
        if not beginPos then  
            strArray[i] = string.sub(content, 1, contentLen)  
            break  
        end  
        strArray[i] = string.sub(content, 1, beginPos-1)  
        content = string.sub(content, endPos+1, contentLen)  
        contentLen = contentLen - endPos  
        i = i + 1  
    end  
    return strArray  
end 


function SimpleRichText:ctor( richText,fontSize,fontColor,fontName )
	-- body
	self.defaultFontSize = fontSize or 24
	self.defaultFontColor =  fontColor or cc.c3b(255,255,255)
	self.defaultfontName = fontName or "FZZhengHeiS-B-GB.ttf"
	
	self:setString( richText,fontSize,fontColor,fontName)
	
end


function SimpleRichText:addString(richText,fontSize,fontColor,fontName)
	local defaultFontSize = fontSize or self.defaultFontSize
	local defaultFontColor = fontColor or self.defaultFontColor
	local defaultfontName = fontName or self.defaultfontName
	if richText == "" then
		return
	end
	--拆分每行数据
	local lines = splitStr(richText, "/n");
	for k,v in pairs(lines) do
		--拆分子串
		local vecSubStr = splitStr(v, "|")
		if vecSubStr and type(vecSubStr) == "table" then
			--构造富文本
			for m,n in pairs(vecSubStr) do
				local element = false
				if string.len(n) > 0 then
					local textBeginPos, textEndPos = string.find(n, '::', 1, true)   
					if not textBeginPos then 
						local imgBeginPos, imgEndPos = string.find(n, ';;', 1, true)   --图片专用 哈哈
						if not imgBeginPos then
							element = ccui.RichElementText:create(m, defaultFontColor, 255, n, defaultfontName, defaultFontSize);
						else
							local fileName = string.sub(n, 1, imgBeginPos-1)
							element = ccui.RichElementImage:create(m,cc.c3b(255,255,255),255,fileName)
						end
					else
						local colorStr = string.sub(n, 1, textBeginPos-1)
						local contentStr = string.sub(n,textEndPos+1)
						local color = splitStr(colorStr, ",")
						local color3B = cc.c3b(color[1],color[2],color[3])
						element = ccui.RichElementText:create(m, color3B, 255, contentStr, defaultfontName, defaultFontSize);
					end

					if element then
						self:pushBackElement(element)
					end
				end
			end
		else
			local element = ccui.RichElementText:create(k, defaultFontColor, 255, v, defaultfontName, defaultFontSize);
			self:pushBackElement(element)
		end

		--最后一行不加换行
		if k < #lines - 1 then
			local element = ccui.RichElementNewLine:create()
			self:pushBackElement(element)
		end
	end
end

function SimpleRichText:newLine()
	self:pushBackElement(ccui.RichElementNewLine:create(1,self.defaultFontColor,255))
end
function SimpleRichText:setString(richText,fontSize,fontColor,fontName)
--清空富文本元素
	self:removeAllElements()
	self:addString(richText,fontSize,fontColor,fontName)
end
return SimpleRichText
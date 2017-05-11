--
-- 文字图片
--
local CMImageFont = class("CMImageFont", function()
    return display.newNode()
end)

function CMImageFont:ctor(fileName, data)
	-- print("data", data)
	local tmpList = string.split(data, ",")
	-- dump(tmpList, "tmpList")
	self.fontDataList = {}
	for i=1,#tmpList do
		self.fontDataList[tmpList[i]] = i
	end	 

	self.fontnumb = #tmpList
	-- dump(self.fontDataList, "self.fontDataList")
	self.fontDataFileName = fileName
	self:setCascadeOpacityEnabled(true) 
	self:ignoreAnchorPointForPosition(false)
	self.fontsp={}
	self.str=""
end

-- function CMImageFont:setOpacity(opa)
-- 	for _,sp in pairs(self.fontsp) do
-- 		sp:setOpacity(opa)
-- 	end
-- 	-- if self.mySp then
-- 	-- 	self.mySp:setOpacity(opa)
-- 	-- end	
-- end
function CMImageFont:getString()
	return self.str
end

--获取数字图片 (0123456789排列)
function CMImageFont:createNumSprite(filename, num,max)
    local tmpSprite = display.newSprite(filename)
    local tmpSize = tmpSprite:getContentSize()
    max = max or 10
    tmpSize.width = tmpSize.width/max
    tmpSprite:setTextureRect(CCRectMake(tmpSize.width*(num-1), 0, tmpSize.width, tmpSize.height))

    return tmpSprite
end

function CMImageFont:setString(Str)
	self.str = str
	self:removeAllChildren(true)
	local tmpW = 0
	local tmpH = 0
	-- print("self.fontDataList[tmpChar] num",#Str)
	if #Str > 0 then 
		for i=1,#Str do
			local tmpChar = string.sub(Str, i, i)
			-- print("tmpChar", tmpChar)
			if self.fontDataList[tmpChar] then
				-- print("self.fontDataList[tmpChar]",self.fontDataList[tmpChar])
				local tmpSprite = self:createNumSprite(self.fontDataFileName, self.fontDataList[tmpChar],self.fontnumb)
				if tmpW<=0 then
					tmpW = tmpSprite:getContentSize().width
					tmpH = tmpSprite:getContentSize().height
				end
				tmpSprite:setAnchorPoint(ccp(0,0))
				tmpSprite:setPosition(ccp((i-1)*tmpW, 0))
				
				self:addChild(tmpSprite)
				-- tmpW = tmpW+tmpSprite:getContentSize().width
				self.fontsp[i]=tmpSprite
			end
		end
		self:setContentSize(CCSizeMake(tmpW*#Str, tmpH))
	end
end

return CMImageFont
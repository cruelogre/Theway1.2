-----------------------------------------------------------
-- Desc:     地方棋牌
-- Author:   cruelogre
-- Date:     2016.09.14
-- Last:    
-- Content: 头像
-- Detail：
--			2016.09.14 创建 仅支持本地文件
--			2016.11.25 适配原图尺寸
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------
--[[
使用方式
WWHeadSprite.createHead(param)
其中param 是table类型参数：
			headFile 头像文件路径
			maskFile 头像文件背景
			headType 头像剪切类型
			如果 headType= 1 圆形
			radius  头像剪切半径
				headType= 2  矩形
			width,.height 头像长宽--]]
			
--[[
		使用案列:
	local param = {
	headFile="HelloWorld.png",
	maskFile="",
	frameFile = "common/common_userhead_frame.png",
	headType=1,
	radius=60,
	width = 120,
	height = 120, 
	headIconType = 11, --(如果是11 则是默认头像，101，是自己审核头像（网络获取）， 102是待审核头像)
	userID = 10010001,
	}
	local sp = WWHeadSprite:create(param)
	sp:setPosition(display.center)
	self.scene:addChild(sp,100)--]]
local WWHeadSprite = class("WWHeadSprite",
	cc.Node,
	require("packages.mvc.Mediator"))
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")

local WWNetSprite = require("app.views.customwidget.WWNetSprite")

WWHeadSprite.HeadTypeDef = {
	HEAD_CIRCLE = 1,
	HEAD_RECTANGLE = 2,
}

function WWHeadSprite:ctor(param)
	self._parem = param
	-- wwdump(self._parem, "日了狗")
	self:init()

	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
end

function WWHeadSprite:onEnter()

	local eventDispatcher = self:getEventDispatcher()

	local function eventCustomListener1(event)
	    -- local str = "Custom event 1 received, "..event._usedata.." times"
	    --事件通知到，C++调用Lua不能带参，所以这里，收到通知后，根据UserID规则去获取

	    --清理纹理缓存
	    cc.Director:getInstance():getTextureCache():removeTextureForKey(ToolCom:getHeadNativePath())

	    wwlog("选择相册或拍照照片成功")
	    
	    self:removeAllChildren()
	    local headFile = ToolCom:getHeadNativePath()
	    self._parem.headFile = headFile
	    self:init()
	end

	self.listener1 = cc.EventListenerCustom:create(COMMON_EVENTS.C_REFLASH_HEAD_NATIVE, eventCustomListener1)
	eventDispatcher:addEventListenerWithFixedPriority(self.listener1, 1)
end


function WWHeadSprite:onExit()
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:removeEventListener(self.listener1)
	if isLuaNodeValid(headNode) then
		headNode:release()
		headNode:revemoveFromparent()
	end
end

function WWHeadSprite:init()

	self.needDownload = false --默认当做不需要下载
	self.headType = self._parem.headType
	local pHeadIconType = self._parem.headIconType
	self.remoteURL = ""

	if pHeadIconType then
		-- wwlog("头像", "%d %d", self.headType, pHeadIconType)
		local myUserID = ww.WWGameData:getInstance():getIntegerForKey("userid",0)
		if (myUserID == self._parem.userID) then
			--先看本地是否存在缓存文件
			if (self._parem.headIconType == ww.HeadType.Normal) then
			else
				local localFilePath = ToolCom:getHeadNativePath()
				if localFilePath and cc.FileUtils:getInstance():isFileExist(localFilePath) then
					self._parem.headFile = localFilePath
					-- wwlog("头像", "本地存在图片文件 %s", self._parem.headFile or "")
				else
					self.needDownload = true
					self.remoteURL = ToolCom:getRemoteHeadURL(1, self._parem.userID)
					-- wwlog("头像","获取远程头像 %s － %s" , self._parem.headFile, self.remoteURL)
				end
			end
			  
		else
			if (self._parem.headIconType == ww.HeadType.Normal) then
				-- wwlog("普通头像创建", self._parem.headFile)
			else
				self.needDownload = true
				self.remoteURL = ToolCom:getRemoteHeadURL(1, self._parem.userID)
				-- wwlog("头像","获取远程头像 %s － %s" , self._parem.headFile, self.remoteURL)
			end
		end
		
		-- self.needDownload = true
		-- self.remoteURL = ToolCom:getRemoteHeadURL(1, self._parem.userID)
		-- wwlog("头像","获取远程头像 %s － %s" , self._parem.headFile, self.remoteURL)
	end

	if self.headType == WWHeadSprite.HeadTypeDef.HEAD_CIRCLE then --圆形
		self:initCircle()
		if self._parem.frameFile then
			local framebg = display.newSprite(self._parem.frameFile)
			local frameSize = framebg:getContentSize()
			local paramAvr = self._parem.radius and self._parem.radius*2 or (self._parem.width+self._parem.height)/2
			paramAvr = paramAvr*1.1
			local frameAvr = (frameSize.width+frameSize.height)/2
			framebg:setScale(paramAvr/frameAvr)

			self:addChild(framebg,2)
		end
	
	elseif self.headType == WWHeadSprite.HeadTypeDef.HEAD_RECTANGLE then --矩形
		--param.width,param.height
		self:initRect()
	end	

end

-- --根据用户中心的，头像数据判断是否上传头像
-- function WWHeadSprite:netHeadHandle()

-- end

--初始化圆形裁剪区域
function WWHeadSprite:initCircle(param)
	
	-- local imgHeadFile = param.headFile
	

	local imgHeadFile = self._parem.headFile
	local imgMaskFile = self._parem.maskFile

	local headType = self._parem.headType
	local clipNode = cc.ClippingNode:create()
	-- local headNode = cc.Sprite:create(imgHeadFile)
	wwlog("WWHeadSprite:initCircle", imgHeadFile)
	local headNode
	if self.needDownload and (self.remoteURL ~= "") and (self.remoteURL ~= nil)  then
		if self.remoteURL == nil then
			wwlog("我勒个去，这里wnil")
		end
		headNode = WWNetSprite:create(imgHeadFile, self.remoteURL)
		headNode:retain()
	else
		headNode = display.newSprite(imgHeadFile)
		

		headNode:getTexture():setAntiAliasTexParameters()
	end
	local medium2 = math.min(headNode:getContentSize().width,headNode:getContentSize().height)
	headNode:setScale(self._parem.radius*2/medium2)
	if not imgMaskFile or string.len(imgMaskFile)==0 then
	
		local circleNode = cc.DrawNode:create()
		
		circleNode:drawSolidCircle(cc.p(0,0),self._parem.radius,math.angle2radian(90),100,cc.c4f(1,1,0,1))
		clipNode:setStencil(circleNode)
	else
		-- local maskNode = cc.Sprite:create(imgMaskFile)
		local maskNode = display.newSprite(imgMaskFile)
		clipNode:setAlphaThreshold(0)
		clipNode:setStencil(maskNode)
		maskNode:getTexture():setAntiAliasTexParameters()
		local medium = (maskNode:getContentSize().width+maskNode:getContentSize().height)/2
		maskNode:setScale(self._parem.radius*2/medium)
	end
	
	clipNode:addChild(headNode)
	self:addChild(clipNode)
end
--初始化矩形裁剪区域
function WWHeadSprite:initRect()
	local imgHeadFile = self._parem.headFile
	
	local headNode
	if self.needDownload and (self.remoteURL ~= "") and (self.remoteURL ~= nil) then
		if self.remoteURL == nil then
			wwlog("我勒个去，这里wnil")
		end
		headNode = WWNetSprite:create(imgHeadFile, self.remoteURL)
		headNode:retain()
	else
		headNode = display.newSprite(imgHeadFile)
	end
	
	local medium2 = math.min(headNode:getContentSize().width,headNode:getContentSize().height)
	headNode:setScale(self._parem.radius*2/medium2)
	
	local headSize = headNode:getContentSize()
	local clipNode = cc.ClippingRectangleNode:create(cc.rect(
	-self._parem.width/2,-self._parem.height/2,self._parem.width,self._parem.height))
	clipNode:addChild(headNode)
	self:addChild(clipNode)
	
end
return WWHeadSprite
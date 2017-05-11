-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  文字动画播放模型
--	Modify:
--			2016.11.25 修改字体
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local CharacterAnimator = class("CharacterAnimator",import(".ChatAnimatorBase","hall.animator."))
local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")

local Chat_TextMsg = require("csb.hall.roomchat.Chat_TextMsg")
function CharacterAnimator:ctor()
	self.super.ctor(self,RoomChatCfg.animatorType.Character)
end

function CharacterAnimator:init(aniData,playdata)
	self.super.init(self,aniData,playdata)
	
	self.content = aniData.content
	self.parentNode = playdata.parentNode or display.getRunningScene()--动画播放的父节点
	self.position = playdata.position or cc.p(0,0) --动画播放的位置
	self.zorder = playdata.zorder or 10 --动画的层级
	self.flippedX = playdata.flippedX or false --是否X轴反转
	self.flippedY = playdata.flippedY or false --是否X轴反转
end

function CharacterAnimator:play()
	wwlog(self.logTag,"文字动画开始播放...")
	self.super.play(self)
	if isLuaNodeValid(self.parentNode) then --这里防止节点被释放了，释放了，那么这个动画就停止播放
		wwlog(self.logTag,"文字内容 %s",self.content)
		local textHandles = Chat_TextMsg:create()
		self.parentNode:addChild(textHandles.root,self.zorder)
		
		local imgBg = textHandles.root:getChildByName("Image_bg")
		imgBg:setFlippedX(self.flippedX)
		imgBg:setFlippedY(self.flippedY)
		
		print(ToolCom:wrapString(self.content,RoomChatCfg.characterBubbleMaxLen))
		local textContent = cc.Label:createWithSystemFont(ToolCom:wrapString(self.content,RoomChatCfg.characterBubbleMaxLen),"", 36)
		--#21504a
		textContent:setColor(cc.c3b(0x21,0x50,0x4A))
		textContent:setAnchorPoint(cc.p(0.5,0.5))
		textContent:setScaleX(self.flippedX and -1 or 1)
		textContent:setScaleY(self.flippedY and -1 or 1)
		local textSize = textContent:getContentSize()
		local oldSize = imgBg:getContentSize()
		local newSize = textSize
		newSize.width = textSize.width+100
		newSize.height = textSize.height+100
		imgBg:setContentSize(newSize)
		local imgSize = imgBg:getContentSize()
		textContent:setPosition(cc.p(imgSize.width/2,(imgSize.height+20)/2))
		textContent:setVisible(false)
		imgBg:addChild(textContent)
	
		textHandles.root:setPosition(self.position)
		textHandles.root:runAction(textHandles.animation)
		textHandles.animation:play("animation0",false)
		textHandles.animation:setAnimationEndCallFunc1("animation0",function ()
			self:stop()
			textHandles.root:removeFromParent()
		end)
		textHandles.animation:setFrameEventCallFunc(function (frame)
			local eventFrame = tolua.cast(frame,"ccs.EventFrame")
			if eventFrame then
				print("frameName",eventFrame:getEvent())
				if eventFrame:getEvent()=="showText" then
					if isLuaNodeValid(textContent) then
						textContent:setVisible(true)
					end
					
				end
			end

		end)
				
	else
		self:stop()
	end
	
end

function CharacterAnimator:stop()
	self.super.stop(self)
	wwlog(self.logTag,"文字动画播放完毕...")
end
return CharacterAnimator
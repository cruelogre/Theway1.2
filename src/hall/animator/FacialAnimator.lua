-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  表情动画播放模型
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local FacialAnimator = class("FacialAnimator",import(".ChatAnimatorBase","hall.animator."))
local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")

function FacialAnimator:ctor()
	self.super.ctor(self,RoomChatCfg.animatorType.Facial)
	wwlog(self.logTag,"表情动画创建中...")
end

function FacialAnimator:init(aniData,playdata)
	self.super.init(self,aniData,playdata)
	
	self.animFile = aniData.animFile
	self.animDesc = aniData.desc
	self.parentNode = playdata.parentNode or display.getRunningScene()--动画播放的父节点
	self.position = playdata.position or cc.p(0,0) --动画播放的位置
	self.zorder = playdata.zorder or 10 --动画的层级
end

function FacialAnimator:play()
	wwlog(self.logTag,"表情动画 %s 开始播放...",self.animDesc)
	self.super.play(self)
	if isLuaNodeValid(self.parentNode) then --这里防止节点被释放了，释放了，那么这个动画就停止播放
		local tempFacialSp = cc.Sprite:create()
		self.parentNode:addChild(tempFacialSp,self.zorder)
		tempFacialSp:setPosition(self.position)
		
		tempFacialSp:runAction(cc.Sequence:create(WWAnimatePackerLua:getAnimate(self.animFile),cc.DelayTime:create(0.5),
		cc.CallFunc:create(handler(self,self.stop)),cc.RemoveSelf:create(true)))
	else
		self:stop()
	end
	
end

function FacialAnimator:stop()
	self.super.stop(self)
	wwlog(self.logTag,"表情动画 %s 播放完毕...",self.animDesc)
end
return FacialAnimator
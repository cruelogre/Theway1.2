-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  房间动画工厂
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChatAnimatorFactory = class("ChatAnimatorFactory")
local FacialAnimator  = require("hall.animator.FacialAnimator")
local CharacterAnimator = require("hall.animator.CharacterAnimator")

local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")
function ChatAnimatorFactory:ctor()
	self.logTag = self.__cname..".lua"
end
--创建动画模型
--@param aniType 动画类型
--  参数类型在 RoomChatCfg.animatorType 中定义 
--	Facial 表情  
--	Character 文字
--@param  animData 创建参数 table表
-- A.创建表情时
-- animFile 表情动画文件路径  WWAnimatePackerLua 解析，文件不带后缀 详情使用见WWAnimatePackerLua说明
-- B. 创建文字时
-- text 文字内容
--@param  playData 播放参数 table表
-- 参数需要 
--	parentNode 父节点 
-- 	position 播放的位置 
--	zorder 层级
function ChatAnimatorFactory:createAnimator(aniType,animData,playData)
	local animodule = nil
	if aniType==RoomChatCfg.animatorType.Facial then
		animodule = FacialAnimator:create()
	elseif aniType == RoomChatCfg.animatorType.Character then
		animodule = CharacterAnimator:create()
	end
	if animodule then
		animodule:init(animData,playData)
	end
	return animodule
end
cc.exports.ChatAnimatorFactory = cc.exports.ChatAnimatorFactory or ChatAnimatorFactory:create()
return ChatAnimatorFactory
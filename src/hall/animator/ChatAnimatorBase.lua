-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  聊天动画基类

-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChatAnimatorBase = class("ChatAnimatorBase")
local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")
function ChatAnimatorBase:ctor(mType)
	self.mType = mType
	self.playingState = RoomChatCfg.animatorState.Init  --是否在播放
	self.logTag = self.__cname..".lua"
	
end
--初始化
--@param aniData 动画数据
--@param playdata 播放参数
function ChatAnimatorBase:init(aniData,playdata)
	self.aniData = aniData
	self.playdata = playdata
end
--播放动画，这是只是设置播放状态
function ChatAnimatorBase:play()
	self.playingState = RoomChatCfg.animatorState.Playing
end

--停止，设置播放状态
function ChatAnimatorBase:stop()
	self.playingState = RoomChatCfg.animatorState.Stoped
end

function ChatAnimatorBase:getType()
	return self.mType
end
function ChatAnimatorBase:getState()
	return self.playingState
end
return ChatAnimatorBase
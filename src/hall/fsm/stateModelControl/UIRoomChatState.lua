-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.11.14
-- Last:    
-- Content:  房间聊天状态机对应周期函数实现
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIRoomChatState = class("UIRoomChatState",require("packages.statebase.UIState"))



function UIRoomChatState:onLoad(lastStateName,param)
	UIRoomChatState.super.onLoad(self,lastStateName,param)

	
end


function UIRoomChatState:onStateEnter()
	UIRoomChatState.super.onStateEnter(self)
end
function UIRoomChatState:onStateEnter()
	UIRoomChatState.super.onStateResume(self)
end

--重新进入 在上层状态机被弹出时，这个调用 不是走加载流程
function UIRoomChatState:onStateResume()
	UIRoomChatState.super.onStateResume(self)

end

--其他状态机覆盖在当前状态机上时 调用
function UIRoomChatState:onStatePause()
	UIRoomChatState.super.onStatePause(self)

end

return UIRoomChatState
-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.25
-- Last: 
-- Content:  房间选择配置管理
--			包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChooseRoomCfg = {}
ChooseRoomCfg.innerEventComponent = nil
ChooseRoomCfg.InnerEvents = {

	CR_EVENT_HALLNETLIST = "CR_EVENT_HALLNETLIST", --游戏房间列表
}

ChooseRoomCfg.maxCountEveryRow = 2

return ChooseRoomCfg
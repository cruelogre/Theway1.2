-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal
-- Date:    2016.09.29
-- Last: 
-- Content:  大厅配置管理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HallCfg = {}
HallCfg.innerEventComponent = nil
HallCfg.InnerEvents = {
	HALL_EVENT_EQUIPMENT_NUMBER = "HALL_EVENT_EQUIPMENT_NUMBER", --获取到道具数量
	HALL_EVENT_FIRSTCHARGE_STATE = "HALL_EVENT_FIRSTCHARGE_STATE", --获取到首充状态
	HALL_EVENT_FIRSTCHARGE_CONTENT = "HALL_EVENT_FIRSTCHARGE_CONTENT", --获取到首充内容
    HALL_EVENT_GOODS_DETAIL_INFO = "HALL_EVENT_GOODS_DETAIL_INFO",--获取物品的详细信息
    HALL_EVENT_GOODS_BOX_INFO = "HALL_EVENT_GOODS_BOX_INFO",--获取物品箱列表
}

HallCfg.KEY_NOTICECACHE = "KEY_NOTICECACHE" --公告ID缓存KEY

HallCfg.enterView = nil --进入大厅就要显示的界面
HallCfg.enterViewData = nil --显示界面的创建参数
HallCfg.enterViewOrder = 0 -- 进入大厅就要显示的界面的层级

HallCfg.bankRuptLimit = 2000 --破产金币临界值
return HallCfg
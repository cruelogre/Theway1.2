-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.12.21
-- Last: 
-- Content:  活动配置管理
--			包括常量定义
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ActivityCfg = {}
--活动界面中的跳转配置 一级界面（状态机） 二级界面（非状态机）直接打开
ActivityCfg.openType = {
	STATEUI = 1, --状态机界面
	SECONDUI = 2,--直接打开界面
	THIRDAPP = 3, --第三方app
}

ActivityCfg.jumpMap = {
	--个人信息界面
	userinfo = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x001, --跳转的ID
		eventName = "userinfo",
		stateName = "UIUserInfoState",
		
	},
	--一键注册界面
	register = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x002, --跳转的ID
		--uipath = "hall.mediator.view.widget.account.Register",
		param = { openType = "performSwitch" }, --状态机参数
		eventName = "userinfo",
		stateName = "UIUserInfoState",
	},
	--商城界面 钻石
	shop_Diamond = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x003, --跳转的ID
		param = { store_openType = 1 }, --状态机参数
		eventName = "store",
		stateName = "UIStoreState",
	},
	--商城界面 金币
	shop_Gold = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x004, --跳转的ID
		param = { store_openType = 2 },--状态机参数
		eventName = "store",
		stateName = "UIStoreState",
	},
	--商城界面 VIP
	shop_VIP = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x005, --跳转的ID
		param = { store_openType = 3 },--状态机参数
		eventName = "store",
		stateName = "UIStoreState",
	},
	--商城界面 道具
	shop_Prop = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x006, --跳转的ID
		param = { store_openType = 4 },--状态机参数
		eventName = "store",
		stateName = "UIStoreState",
	},
	--任务界面
	task = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x007, --跳转的ID
		eventName = "task",
		stateName = "UITaskState",
	},
	--兑换中心界面
	exchange = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x008, --跳转的ID
		eventName = "exchange",
		stateName = "UIExchangeState",
	},
	--排行榜界面
	rank = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x009, --跳转的ID
		eventName = "rank",
		stateName = "UIRankState",
	},
	--反馈界面
	feedback = {
		uopenType = ActivityCfg.openType.SECONDUI,
		searchId = 0x00A, --跳转的ID
		uipath = "hall.mediator.view.SettingLayer_FeedBack",
	},
	--签到界面
	sign = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x00B, --跳转的ID
		eventName = "sign",
		stateName = "UISignState",
	},
	--1 经典 2 比赛 3 私人
	--比赛界面
	match = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x00C, --跳转的ID
		param = { crType = 1 },
		eventName = "match",
		stateName = "UIMatchState",
	},
	--比赛报名界面
	match_Sign = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x012, --跳转的ID
		param = { crType = 1 },
		externalKeys = {"enterMatchId"}, --额外的参数key
		eventName = "match",
		stateName = "UIMatchState",
	},
	--私人房界面
	siren = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x00D, --跳转的ID
		param = { crType = 3 },
		eventName = "siren",
		stateName = "UISiRenRoomState",
	},
	--经典房界面
	chooseRoom = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x00E, --跳转的ID
		param = { crType = 2 ,gameid=wwConfigData.GAME_ID},
		eventName = "chooseRoom",
		stateName = "UIChooseRoomState",
	},
	--经典房快速开始
	chooseRoom_fStart = {
		uopenType = ActivityCfg.openType.STATEUI,
		searchId = 0x00F, --跳转的ID
		param = { crType = 2 ,gameid=wwConfigData.GAME_ID,fStart = "performClick",},
		eventName = "chooseRoom",
		stateName = "UIChooseRoomState",
	},
	--QQ
	qq = {
		uopenType = ActivityCfg.openType.THIRDAPP,
		searchId = 0x010, --跳转的ID
		
	},
	wexin = {
		uopenType = ActivityCfg.openType.THIRDAPP,
		searchId = 0x011, --跳转的ID
		
	},
}

--通过id查询跳转的信息
function ActivityCfg.getOpenDataById(searchId)
	local openData = nil
	for ii,v in pairs(ActivityCfg.jumpMap) do
		if v.searchId == searchId then
			openData = v
			break
		end
	end
	return openData
end


return ActivityCfg
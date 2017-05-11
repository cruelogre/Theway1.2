-------------------------------------------------------------------------
-- Desc:    活动跳转配置约定，转换成lua配置表 
-- Author:  cruelogre
-- Info:    Version1.0 模块化支持
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local UIJmperConfig = {
	[0x001] = {
		searchId = 0x001,
		desc = "跳转至个人信息界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "userinfo",
		stateName = "UIUserInfoState",
		param = {
			},
	},
	[0x002] = {
		searchId = 0x002,
		desc = "跳转至一键注册界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "userinfo",
		stateName = "UIUserInfoState",
		param = {
			openType = "performSwitch",
			},
	},
	[0x003] = {
		searchId = 0x003,
		desc = "跳转至商城钻石界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "store",
		stateName = "UIStoreState",
		param = {
			store_openType = 1,
			},
	},
	[0x004] = {
		searchId = 0x004,
		desc = "跳转至商城金币界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "store",
		stateName = "UIStoreState",
		param = {
			store_openType = 2,
			},
	},
	[0x005] = {
		searchId = 0x005,
		desc = "跳转至商城VIP界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "store",
		stateName = "UIStoreState",
		param = {
			store_openType = 3,
			},
	},
	[0x006] = {
		searchId = 0x006,
		desc = "跳转至商城道具界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "store",
		stateName = "UIStoreState",
		param = {
			store_openType = 4,
			},
	},
	[0x007] = {
		searchId = 0x007,
		desc = "跳转至任务界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "task",
		stateName = "UITaskState",
		param = {
			cancelAnim = 1,
			},
	},
	[0x008] = {
		searchId = 0x008,
		desc = "跳转至兑换中心界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "exchange",
		stateName = "UIExchangeState",
		param = {
			},
	},
	[0x009] = {
		searchId = 0x009,
		desc = "跳转至排行榜界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "rank",
		stateName = "UIRankState",
		param = {
			},
	},
	[0x00A] = {
		searchId = 0x00A,
		desc = "跳转至反馈界面",
		state = "已完成",
		uopenType = 2,
		openDesc = "直接二级界面",
		uipath = "hall.mediator.view.SettingLayer_FeedBack",
		param = {
			},
	},
	[0x00B] = {
		searchId = 0x00B,
		desc = "跳转至签到界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "sign",
		stateName = "UISignState",
		param = {
			},
	},
	[0x00C] = {
		searchId = 0x00C,
		desc = "跳转至比赛列表界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "match",
		stateName = "UIMatchState",
		param = {
			crType = 1,
			},
	},
	[0x00D] = {
		searchId = 0x00D,
		desc = "跳转至私人房界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "siren",
		stateName = "UISiRenRoomState",
		param = {
			crType = 3,
			},
	},
	[0x00E] = {
		searchId = 0x00E,
		desc = "跳转至经典房界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "chooseRoom",
		stateName = "UIChooseRoomState",
		param = {
			crType = 2,
			gameid = "%1%",
			},
	},
	[0x00F] = {
		searchId = 0x00F,
		desc = "跳转至经典房快速开始",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "chooseRoom",
		stateName = "UIChooseRoomState",
		param = {
			crType = 2,
			fStart = "performClick",
			gameid = "%1%",
			},
	},
	[0x010] = {
		searchId = 0x010,
		desc = "跳转至QQ",
		state = "调研中",
		uopenType = 3,
		openDesc = "第三方APP",
		param = {
			},
	},
	[0x011] = {
		searchId = 0x011,
		desc = "跳转至微信",
		state = "调研中",
		uopenType = 3,
		openDesc = "第三方APP",
		param = {
			},
	},
	[0x012] = {
		searchId = 0x012,
		desc = "跳转至比赛报名界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "match",
		stateName = "UIMatchState",
		param = {
			crType = 1,
			enterMatchId = "%1%",
			},
	},
	[0x013] = {
		searchId = 0x013,
		desc = "跳转至活动界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "activity",
		stateName = "UIActivityState",
		param = {
			},
	},
	[0x014] = {
		searchId = 0x014,
		desc = "跳转至首充界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "fcharge",
		stateName = "UIFirstChargeState",
		param = {
			},
	},
	[0x015] = {
		searchId = 0x015,
		desc = "跳转至牛牛界面",
		state = "已完成",
		uopenType = 1,
		openDesc = "状态机界面",
		eventName = "chooseRoom",
		stateName = "UIChooseRoomState",
		param = {
			crType = 2,
			gameid = "%1%",
			},
	},
}
return UIJmperConfig
-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.16
-- Last:
-- Content:  签到
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
    stateName = "UIChooseRoomState";-- 状态机模块名（见名知意即可）
    resData = { };-- 状态机对象所用到的所有资源
    controller = "hall.fsm.stateModelControl.UIChooseRoomState";-- 控制器 配置UISettingState.lua
    view = "hall.mediator.view.ChooseRoomLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
    entry = false; --是否是Scene的根状态机（逻辑上每个Scene有且只有一个）
    enter =  --当前状态机下的事件状态容器
    {
	    --对应的stateName（当前根状态下的所有状态）
		{eventName="store2";stateName="UIStoreState"},
       
    };
    push = --
    {
        -- { eventName = "test2"; stateName = "UITestViewState" }
		{eventName="store";stateName="UIStoreState"},
		{eventName="userinfo";stateName="UIUserInfoState"},
        { eventName = "exchange"; stateName = "UIExchangeState" },
	    { eventName = "rank"; stateName = "UIRankState" },
		{ eventName = "task"; stateName = "UITaskState" },
		{ eventName = "activity"; stateName = "UIActivityState" },
		{ eventName = "sirenInvited"; stateName = "UISiRenInvitedState" },
    };
    pop = { { eventName = "back" } };
	interceptor =  --拦截器配置
	{
		{name="hall.fsm.stateInterceptor.LoginInterceptor",id="LoginInterceptor",priority=1 },
	};
	filter =  --过滤器配置
	{
		{name="hall.fsm.stateFilter.TaskFilter",id="TaskFilter",priority=1 },
	}
}
registry.resData.Texture =
{
    "hall/choose/chooserm_bg_mak.png",
	"hall/choose/chooserm_item_bg.png",
	"hall/choose/chooserm_item_icon1.png",
	"hall/choose/chooserm_item_icon2.png",
	"hall/choose/chooserm_item_mode1.png",
	"hall/choose/chooserm_item_mode2.png",
	"hall/choose/chooserm_item_mode3.png",
	"hall/choose/chooserm_item_mode4.png",
	"hall/choose/chooserm_item_mode5.png",
	"hall/choose/chooserm_mask.png",
	
}
registry.resData.Plist = 
{
    
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { 
	
}
return registry
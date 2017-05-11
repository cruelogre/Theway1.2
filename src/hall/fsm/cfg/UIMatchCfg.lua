-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.09.10
-- Last:
-- Content:  比赛
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
    stateName = "UIMatchState";-- 状态机模块名（见名知意即可）
    resData = { };-- 状态机对象所用到的所有资源
    controller = "hall.fsm.stateModelControl.UIMatchState";-- 控制器 配置UISettingState.lua
    view = "hall.mediator.view.MatchLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
    entry = false; --是否是Scene的根状态机（逻辑上每个Scene有且只有一个）
    enter =  --当前状态机下的事件状态容器
    {
	    --对应的stateName（当前根状态下的所有状态）
        -- { eventName = "openShop"; stateName = "UIShopState" }, 
        -- { eventName = "test1"; stateName = "UITestView2State" } --
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
	
    "hall/match/hall_match_plist1.png",
	"hall/match/hall_match_plist2.png",

	"hall/match/match_desc_podium.png",

	"hall/match/match_mate_bg1.png",
	"hall/match/match_mate_bg2.png",
	
	
}
registry.resData.Plist = 
{
   
	"hall/match/hall_match_plist1.plist",
	"hall/match/hall_match_plist2.plist",
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { 
	
}
return registry
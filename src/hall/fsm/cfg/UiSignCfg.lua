-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.16
-- Last:
-- Content:  签到
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
    stateName = "UISignState";-- 状态机模块名（见名知意即可）
    resData = { };-- 状态机对象所用到的所有资源
    controller = "hall.fsm.stateModelControl.UISignState";-- 控制器 配置UISettingState.lua
    view = "hall.mediator.view.SignLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
    entry = false; --是否是Scene的根状态机（逻辑上每个Scene有且只有一个）
    enter =  --当前状态机下的事件状态容器
    {
	    --对应的stateName（当前根状态下的所有状态）
        -- { eventName = "openShop"; stateName = "UIShopState" }, 
        -- { eventName = "test1"; stateName = "UITestView2State" } --
    };
    push = --
    {
		{eventName="store";stateName="UIStoreState"},
		{ eventName = "sirenInvited"; stateName = "UISiRenInvitedState" },
        -- { eventName = "test2"; stateName = "UITestViewState" }
    };
    pop = { { eventName = "back" } };
	interceptor =  --拦截器配置
	{
		{name="hall.fsm.stateInterceptor.LoginInterceptor",id="LoginInterceptor",priority=1 },
	}
}
registry.resData.Texture =
{
    "hall/sign/sign.png",
	"hall/sign/sign_plist2.png",
	"hall/sign/animation/sign_item_anim.png"
	
}
registry.resData.Plist = 
{
    "hall/sign/sign.plist",
	"hall/sign/sign_plist2.plist",
	"hall/sign/animation/sign_item_anim.plist"
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { 
	"hall/sign/animation/sign_item_anim"
}
return registry
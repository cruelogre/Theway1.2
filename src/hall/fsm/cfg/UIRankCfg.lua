-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  Jackie Liu
-- Date:    2016.08.16
-- Last:
-- Content:  排行榜
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
    stateName = "UIRankState";-- 状态机模块名（见名知意即可）
    resData = { };-- 状态机对象所用到的所有资源
    controller = "hall.fsm.stateModelControl.UIRankState";-- 控制器 配置UISettingState.lua
    view = "hall.mediator.view.RankLayer";-- 加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
    entry = false;-- 是否是Scene的根状态机（逻辑上每个Scene有且只有一个）
    enter =-- 当前状态机下的事件状态容器
    {
        -- 对应的stateName（当前根状态下的所有状态）
        --        { eventName = "store2"; stateName = "UIStoreState" },

    };
    push =--
    {
        -- { eventName = "test2"; stateName = "UITestViewState" }
        { eventName = "userinfo"; stateName = "UIUserInfoState" },
		{ eventName = "sirenInvited"; stateName = "UISiRenInvitedState" },
    };
    pop = { { eventName = "back" } };
    interceptor =-- 拦截器配置
    {
        { name = "hall.fsm.stateInterceptor.LoginInterceptor", id = "LoginInterceptor", priority = 1 },
    }
}
registry.resData.Texture =
{
    --    "hall/siren/siren_plist.png",
}
registry.resData.Plist =
{
    "hall/rank/rank.plist",
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = {

}
return registry
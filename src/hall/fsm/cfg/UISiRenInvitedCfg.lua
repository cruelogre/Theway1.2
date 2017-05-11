-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruel ogre
-- Date:    2017.2.8
-- Last:
-- Content:  私人房被邀请
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
    stateName = "UISiRenInvitedState";-- 状态机模块名（见名知意即可）
    resData = { };-- 状态机对象所用到的所有资源
    controller = "packages.statebase.UIState";-- 控制器 配置UISettingState.lua
    view = "hall.mediator.view.widget.siren.SiRen_invite_receive";-- 加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
    entry = false;-- 是否是Scene的根状态机（逻辑上每个Scene有且只有一个）
    enter =-- 当前状态机下的事件状态容器
    {

    };
    push =
    {

    };
    pop = { { eventName = "back" } };

}
registry.resData.Texture =
{
    "hall/siren/siren_plist.png",
}
registry.resData.Plist =
{
    "hall/siren/siren_plist.plist",
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = {}
return registry
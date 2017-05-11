-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.15
-- Last:
-- Content:  大厅状态机根配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
    stateName = "UIRoot";-- 状态机模块名（见名知意即可）
    resData = { };-- 状态机对象所用到的所有资源（音频、）
    controller = "hall.fsm.stateModelControl.UIHallSceneState";-- 控制器 配置UISettingState.lua
    view = "hall.mediator.view.UIHallLayer";
    entry = true;
    enter = {
    };
    push = {
        -- 压栈状态
        { eventName = "setting"; stateName = "UISettingState" },
        { eventName = "sign"; stateName = "UISignState" },
        { eventName = "chooseRoom"; stateName = "UIChooseRoomState" },
        { eventName = "store"; stateName = "UIStoreState" },
        { eventName = "match"; stateName = "UIMatchState" },
        { eventName = "email"; stateName = "UIEmailState" },
        { eventName = "userinfo"; stateName = "UIUserInfoState" },
        { eventName = "exchange"; stateName = "UIExchangeState" },
        { eventName = "siren"; stateName = "UISiRenRoomState" },
        { eventName = "activity"; stateName = "UIActivityState" },
        { eventName = "task"; stateName = "UITaskState" },
        { eventName = "rank"; stateName = "UIRankState" },
        { eventName = "fcharge"; stateName = "UIFirstChargeState" },
        { eventName = "goodsBox"; stateName = "UIGoodsBoxState" },
		{ eventName = "cardPartner"; stateName = "UICardPartnerState" },
		{ eventName = "sirenInvited"; stateName = "UISiRenInvitedState" },
		
    };
    pop = { { eventName = "back" } };
    filter =-- 过滤器配置
    {
        { name = "hall.fsm.stateFilter.TaskFilter", id = "TaskFilter", priority = 1 },
		{ name = "hall.fsm.stateFilter.ChatMsgFilter", id = "ChatMsgFilter", priority = 2 },
    };
    resLimit = 3;
}

registry.resData.Texture =
{
    "hall/plist/halltop.png",
    "hall/plist/hallbottom.png",
    "hall/plist/hallcontent.png",
    "hall/animation/hall_plist1.png",
    "hall/animation/animation_plist.png",
    "hall/common/hall_common.png",
}
registry.resData.Plist =
{
    "hall/plist/halltop.plist",
    "hall/plist/hallbottom.plist",
    "hall/plist/hallcontent.plist",
    "hall/plist/halltop.plist",
    "hall/animation/hall_plist1.plist",
    "hall/animation/animation_plist.plist",
    "hall/common/hall_common.plist",
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { }

return registry
-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.15
-- Last:    
-- Content:  大厅状态机根配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
	stateName = "UIRoot"; -- 状态机模块名（见名知意即可）
	resData = {}; --状态机对象所用到的所有资源（音频、）
	controller = "WhippedEgg.fsm.stateModelControl.UIWhippedEggSceneState"; -- 控制器 配置UISettingState.lua
	entry = true;
	enter = {
	};
	push = { --压栈状态
		{eventName="setting";stateName="UISettingState"},
		{eventName="store";stateName="UIStoreState"},
		{eventName="chat";stateName="UIRoomChatState"},
		{eventName="banner";stateName="UIGDBannerState"},
		{eventName="win";stateName="UIGDGameoverWinState"},
		{eventName="lose";stateName="UIGDGameoverLoseState"},
		{eventName="personal";stateName="UIGDPersonalSettleState"},
		{eventName="match";stateName="UIGDMatchSettleState"},
	
	}; 
	pop = {{eventName="back"}};
	filter =  --过滤器配置
	{
		{name="WhippedEgg.fsm.stateFilter.UserInfoFilter",id="UserInfoFilter",priority=1 },
	}
}

registry.resData.Texture =
{
	
--[[	"guandan/pokerAnim/guandan_bombs.png",
	"guandan/pokerAnim/guandan_gangban.png",
	"guandan/pokerAnim/guandan_jokbb1.png",
	"guandan/pokerAnim/guandan_jokbb2.png",
	"guandan/pokerAnim/guandan_label.png",
	"guandan/pokerAnim/guandan_light.png",
	"guandan/pokerAnim/guandan_pair.png",
	
	"guandan/pokerAnim/guandan_straflush.png",--]]

	"guandan/guandan_gaming.png",
	"guandan/leavlUp.png",
	"guandan/poker.png",
	"guandan/wenzi.png",
}
registry.resData.Plist = 
{ 

--[[	"guandan/pokerAnim/guandan_bombs.plist",
	"guandan/pokerAnim/guandan_gangban.plist",
	"guandan/pokerAnim/guandan_jokbb1.plist",
	"guandan/pokerAnim/guandan_jokbb2.plist",
	"guandan/pokerAnim/guandan_label.plist",
	"guandan/pokerAnim/guandan_light.plist",
	"guandan/pokerAnim/guandan_pair.plist",
	
	"guandan/pokerAnim/guandan_straflush.plist",--]]

	"guandan/guandan_gaming.plist",
	"guandan/leavlUp.plist",
	"guandan/poker.plist",
	"guandan/wenzi.plist",
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { }

return registry
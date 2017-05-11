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
	controller = "BullFighting.fsm.stateModelControl.UIBullFightingSceneState"; -- 控制器 配置UISettingState.lua
	entry = true;
	enter = {
	};
	push = { --压栈状态
		{eventName="setting";stateName="UISettingState"},
		{eventName="store";stateName="UIStoreState"},
		{eventName="chat";stateName="UIRoomChatState"},
	
	}; 
	pop = {{eventName="back"}};
	filter =  --过滤器配置
	{
		-- {name="WhippedEgg.fsm.stateFilter.UserInfoFilter",id="UserInfoFilter",priority=1 },
	}
}

registry.resData.Texture =
{
	"bullfighting/animate.png",
	"bullfighting/niu.png",
	"bullfighting/others.png",
	"bullfighting/poker.png",
}
registry.resData.Plist = 
{ 
	"bullfighting/animate.plist",
	"bullfighting/niu.plist",
	"bullfighting/others.plist",
	"bullfighting/poker.plist",
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { }

return registry
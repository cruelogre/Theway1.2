-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2017.1.5
-- Last:    
-- Content:  游戏结算状态机根配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
	stateName = "UIGDMatchSettleState"; -- 状态机模块名（见名知意即可）
	resData = {}; --状态机对象所用到的所有资源（音频、）
	controller = "WhippedEgg.fsm.stateModelControl.UIGDMatchSettleState"; -- 控制器 配置UISettingState.lua
	view = "WhippedEgg.mediator.view.GDMatchSettleLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
	enter = {
	};
	push = { --压栈状态
	
	}; 
	pop = {{eventName="back"}};
	filter =  --过滤器配置
	{
		
	},
	clearRes = true, --是否保留资源在队列中
}

registry.resData.Texture =
{
	"guandan/match/gdmatch_title_text.png",
	"guandan/match/noFail.png",
	"guandan/match/match_img_icon.png",
	"guandan/match/gdmatch_title_bg.png",
}
registry.resData.Plist = 
{ 

}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { }

return registry
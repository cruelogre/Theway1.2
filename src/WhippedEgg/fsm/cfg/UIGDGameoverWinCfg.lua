-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2017.1.5
-- Last:    
-- Content:  游戏结算状态机根配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
	stateName = "UIGDGameoverWinState"; -- 状态机模块名（见名知意即可）
	resData = {}; --状态机对象所用到的所有资源（音频、）
	controller = "WhippedEgg.fsm.stateModelControl.UIGDGameoverWinState"; -- 控制器 配置UISettingState.lua
	view = "WhippedEgg.mediator.view.GDGameoverWinLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
	enter = {
		{eventName="banner";stateName="UIGDBannerState"},
		{eventName="personal";stateName="UIGDPersonalSettleState"},
		{eventName="match";stateName="UIGDMatchSettleState"},
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
	"guandan/gameover/common/gd_cm_label1.png",
	"guandan/gameover/common/gd_cm_label2.png",
	"guandan/gameover/common/gd_cm_content1.png",
	"guandan/gameover/common/gd_cm_content2.png",
	"guandan/gameover/common/gd_cm_gold.png",
	"guandan/gameover/common/gd_cm_rank1.png",
	"guandan/gameover/common/gd_cm_rank2.png",
	"guandan/gameover/common/gd_cm_rank3.png",
	"guandan/gameover/common/gd_cm_rank4.png",
	"guandan/gameover/common/gd_cm_tag1.png",
	"guandan/gameover/common/gd_cm_tag2.png",
	"guandan/gameover/common/gd_cm_tag3.png",
	"guandan/gameover/common/gd_cm_vs.png",
	
	"guandan/gameover/win/gd_win_light.png",
	"guandan/gameover/win/gd_win_light_03.png",
	"guandan/gameover/win/gd_win_light_02.png",
	"guandan/gameover/win/gd_win_title.png",
	"guandan/gameover/win/gd_win_light_01.png",
	"guandan/gameover/win/gd_win_img.png",
	"guandan/gameover/win/gd_win_flower_01.png",
	"guandan/gameover/win/gd_win_flower_03.png",
	"guandan/gameover/win/gd_win_flower_02.png",
	"guandan/gameover/win/gd_win_flower_04.png",
	"guandan/gameover/win/gd_win_flower_05.png",
	"guandan/gameover/win/gd_win_flower_06.png",
	"guandan/gameover/win/gd_win_flower_07.png",
	"guandan/gameover/win/gd_win_flower_08.png",

}
registry.resData.Plist = 
{ 

}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { }

return registry
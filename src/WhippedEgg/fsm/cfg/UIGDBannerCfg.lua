-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2017.1.5
-- Last:    
-- Content:  游戏结算状态机根配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
	stateName = "UIGDBannerState"; -- 状态机模块名（见名知意即可）
	resData = {}; --状态机对象所用到的所有资源（音频、）
	controller = "WhippedEgg.fsm.stateModelControl.UIGDBannerState"; -- 控制器 配置UISettingState.lua
	view = "WhippedEgg.mediator.view.GDBannerLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
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
	"guandan/gameover/banner/gd_banner_curtain.png",
	"guandan/gameover/banner/gd_banner_flag1.png",
	"guandan/gameover/banner/gd_banner_flag2.png",
	"guandan/gameover/banner/gd_banner_flagbg.png",
	"guandan/gameover/banner/gd_banner_horn.png",
	"guandan/gameover/banner/gd_banner_stick1.png",
	"guandan/gameover/banner/gd_banner_stick2.png",
	"guandan/gameover/banner/gd_banner_title.png",
	"guandan/gameover/banner/zhi_01.png",
	"guandan/gameover/banner/zhi_02.png",
	"guandan/gameover/banner/zhi_03.png",
	"guandan/gameover/banner/zhi_04.png",
	"guandan/gameover/win/gd_win_light_03.png",
	"guandan/gameover/win/gd_win_light_02.png",
	"guandan/gameover/win/gd_win_light_01.png",
	"guandan/gameover/common/gd_cm_label1.png",
	"guandan/gameover/common/gd_cm_label2.png",
}
registry.resData.Plist = 
{ 

}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { }

return registry
-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2017.1.5
-- Last:    
-- Content:  游戏结算状态机根配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
	stateName = "UIGDGameoverLoseState"; -- 状态机模块名（见名知意即可）
	resData = {}; --状态机对象所用到的所有资源（音频、）
	controller = "WhippedEgg.fsm.stateModelControl.UIGDGameoverLoseState"; -- 控制器 配置UISettingState.lua
	view = "WhippedEgg.mediator.view.GDGameoverLoseLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
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
	
	"guandan/gameover/lose/gd_lose_title.png",
	"guandan/gameover/lose/gd_lose_light_0009.png",
	"guandan/gameover/lose/gd_lose_light_0005.png",
	"guandan/gameover/lose/gd_lose_light_0008.png",
	"guandan/gameover/lose/gd_lose_img.png",
	"guandan/gameover/lose/gd_lose_light_0007.png",
	"guandan/gameover/lose/gd_lose_light_0006.png",
	"guandan/gameover/lose/gd_lose_light_0010.png",
	"guandan/gameover/lose/gd_lose_light_0004.png",
	"guandan/gameover/lose/gd_lose_light_0011.png",
	"guandan/gameover/lose/gd_lose_light_0003.png",
	"guandan/gameover/lose/gd_lose_light_0012.png",
	"guandan/gameover/lose/gd_lose_thunder_0005.png",
	"guandan/gameover/lose/gd_lose_thunder_0018.png",
	"guandan/gameover/lose/gd_lose_thunder_0004.png",
	"guandan/gameover/lose/gd_lose_thunder_0017.png",
	"guandan/gameover/lose/gd_lose_thunder_0003.png",
	"guandan/gameover/lose/gd_lose_thunder_0016.png",
	"guandan/gameover/lose/gd_lose_thunder_0002.png",
	"guandan/gameover/lose/gd_lose_thunder_0015.png",
	"guandan/gameover/lose/gd_lose_thunder_0001.png",
	"guandan/gameover/lose/gd_lose_thunder_0014.png",
	"guandan/gameover/lose/gd_lose_light_0002.png",
	"guandan/gameover/lose/gd_lose_thunder_0006.png",
	"guandan/gameover/lose/gd_lose_thunder_0019.png",
	"guandan/gameover/lose/gd_lose_thunder_0007.png",
	"guandan/gameover/lose/gd_lose_thunder_0020.png",
	"guandan/gameover/lose/gd_lose_thunder_0013.png",
	"guandan/gameover/lose/gd_lose_thunder_0026.png",
	"guandan/gameover/lose/gd_lose_thunder_0011.png",
	"guandan/gameover/lose/gd_lose_thunder_0024.png",
	"guandan/gameover/lose/gd_lose_thunder_0012.png",
	"guandan/gameover/lose/gd_lose_thunder_0025.png",
	"guandan/gameover/lose/gd_lose_thunder_0009.png",
	"guandan/gameover/lose/gd_lose_thunder_0022.png",
	"guandan/gameover/lose/gd_lose_thunder_0008.png",
	"guandan/gameover/lose/gd_lose_thunder_0021.png",
	"guandan/gameover/lose/gd_lose_thunder_0010.png",
	"guandan/gameover/lose/gd_lose_thunder_0023.png",
	"guandan/gameover/lose/gd_lose_light_0013.png",
	"guandan/gameover/lose/gd_lose_light_0001.png",
	"guandan/gameover/lose/gd_lose_light_0014.png",
	
}
registry.resData.Plist = 
{ 

}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { }

return registry
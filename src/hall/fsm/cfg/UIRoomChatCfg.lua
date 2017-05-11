-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.11.14
-- Last:    
-- Content:  房间聊天状态机配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
	stateName = "UIRoomChatState"; -- 状态机模块名（见名知意即可）
	resData = {}; --状态机对象所用到的所有资源（音频、）
	controller = "hall.fsm.stateModelControl.UIRoomChatState"; -- 控制器 配置UISettingState.lua
	view = "hall.mediator.view.UIRoomChatLayer"; --加载完后创建的界面,可不配置（如不配置请在UISettingState里面去自动调用视图构建）
	entry = false;
	enter = {
	};
	push = { --压栈状态
		
	
	}; 
	pop = {{eventName="back"}}
}

registry.resData.Texture =
{
	"hall/roomchat/roomchat_plist.png",	
	"hall/animation/facial/facial_angry.png",
	"hall/animation/facial/facial_contempt.png",	
	"hall/animation/facial/facial_crazy.png",	
	"hall/animation/facial/facial_cry.png",	
	"hall/animation/facial/facial_gratitude.png",	
	"hall/animation/facial/facial_grimace.png",	
	"hall/animation/facial/facial_laugh.png",	
	"hall/animation/facial/facial_nervous.png",	
	"hall/animation/facial/facial_proud.png",	
	"hall/animation/facial/facial_scare.png",	
	"hall/animation/facial/facial_tuhao.png",	
	"hall/animation/facial/facial_yawn.png",	
}
registry.resData.Plist = 
{ 
	"hall/roomchat/roomchat_plist.plist",	
	"hall/animation/facial/facial_angry.plist",
	"hall/animation/facial/facial_contempt.plist",	
	"hall/animation/facial/facial_crazy.plist",	
	"hall/animation/facial/facial_cry.plist",	
	"hall/animation/facial/facial_gratitude.plist",	
	"hall/animation/facial/facial_grimace.plist",	
	"hall/animation/facial/facial_laugh.plist",	
	"hall/animation/facial/facial_nervous.plist",	
	"hall/animation/facial/facial_proud.plist",	
	"hall/animation/facial/facial_scare.plist",	
	"hall/animation/facial/facial_tuhao.plist",	
	"hall/animation/facial/facial_yawn.plist",
}
registry.resData.Armature = { }
registry.resData.Sound = { }
registry.resData.FrameAnim = { 
	"hall/animation/facial/facial_angry",
	"hall/animation/facial/facial_contempt",	
	"hall/animation/facial/facial_crazy",	
	"hall/animation/facial/facial_cry",	
	"hall/animation/facial/facial_gratitude",	
	"hall/animation/facial/facial_grimace",	
	"hall/animation/facial/facial_laugh",	
	"hall/animation/facial/facial_nervous",	
	"hall/animation/facial/facial_proud",	
	"hall/animation/facial/facial_scare",	
	"hall/animation/facial/facial_tuhao",	
	"hall/animation/facial/facial_yawn",
}

return registry
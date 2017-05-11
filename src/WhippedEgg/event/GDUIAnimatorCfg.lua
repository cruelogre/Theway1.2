-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.10
-- Last: 
-- Content:  游戏中UI特效播放配置文件
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDUIAnimatorCfg = {}
GDUIAnimatorCfg.Type = {
	CURRENT_PLAY_NUM = 1, --本次打几
	NOTRIBUTE = 2, --抗贡
	CHOOSE_LAIZI = 3,--播放随机打几蛋碎动画
	MATCH_OPENING = 4, --比赛开始动画
	MATCH_UPGRADE = 5, --比赛晋级动画
}
GDUIAnimatorCfg.animInfo = {
	{
		Type = GDUIAnimatorCfg.Type.CURRENT_PLAY_NUM,
		Node = "csb.guandan.BlackTipsPoint",
		Texture = {
			"guandan/match/cup.png",
			"guandan/match/cupBg.png",
			"guandan/match/gdmatch_opening_bg.png",
		},
		Plist = {},
		Animation = {}, --播放的动画
		UIImage = {}, --需要修改纹理的ImageView以 key --> value形式传入
		UIText = {}, -- 需要修改文字的Text 以 key --> value形式传入
		Visivle = {}, --需要修改显示的控件
	},
	{
		Type = GDUIAnimatorCfg.Type.NOTRIBUTE,
		Node = "csb.guandan.animation.Node_notribute",
		Texture = {
			"guandan/pokerAnim/guandan_refusetri.png"
		},
		Plist = {
			"guandan/pokerAnim/guandan_refusetri.plist"
		},
		Animation = {}, --播放的动画
		UIImage = {}, --需要修改纹理的ImageView以 key --> value形式传入
		UIText = {}, -- 需要修改文字的Text 以 key --> value形式传入
		Visivle = {}, --需要修改显示的控件
	},
	{
		Type = GDUIAnimatorCfg.Type.CHOOSE_LAIZI,
		Node = "csb.guandan.animation.Node_laizi",
		Texture = {
			"guandan/pokerAnim/guandan_anycard_1.png",
			"guandan/pokerAnim/guandan_anycard_2.png",
		},
		Plist = {
			"guandan/pokerAnim/guandan_anycard_1.plist",
			"guandan/pokerAnim/guandan_anycard_2.plist",
		},
		Animation = {}, --播放的动画
		UIImage = {}, --需要修改纹理的ImageView以 key --> value形式传入
		UIText = {}, -- 需要修改文字的Text 以 key --> value形式传入
		Visivle = {}, --需要修改显示的控件
	},
	{
		Type = GDUIAnimatorCfg.Type.MATCH_OPENING,
		Node = "csb.guandan.GDMatchOpening1",
		Texture = {
			"guandan/match/gdmatch_opening_bg.png",
			"guandan/match/gdmatch_opening_text1.png",
			"guandan/match/match_opening_shade.png",
			"guandan/match/match_particle_light1.png",
			"guandan/match/match_particle_light2.png",
			"guandan/match/match_baoguang0001.png",
			"guandan/match/match_baoguang0002.png",
			"guandan/match/match_baoguang0003.png",
			"guandan/match/match_baoguang0004.png",
			"guandan/match/match_baoguang0005.png",
			"guandan/match/match_baoguang0006.png",
			"guandan/match/match_baoguang0007.png",
			"guandan/match/match_baoguang0008.png",
			"guandan/match/match_baoguang0009.png",
		},
		Plist = {},
		Animation = {}, --播放的动画
		UIImage = {}, --需要修改纹理的ImageView以 key --> value形式传入
		UIText = {}, -- 需要修改文字的Text 以 key --> value形式传入
		Visivle = {}, --需要修改显示的控件
	},
	{
		Type = GDUIAnimatorCfg.Type.MATCH_UPGRADE,
		Node = "csb.guandan.GDMatchOpening2",
		Texture = {
			"guandan/match/gdmatch_opening_bg.png",
			"guandan/match/gdmatch_opening_text2.png",
			"guandan/match/match_upgrade_shade.png",
			"guandan/match/match_particle_light1.png",
			"guandan/match/match_particle_light2.png",
			"guandan/match/match_baoguang0001.png",
			"guandan/match/match_baoguang0002.png",
			"guandan/match/match_baoguang0003.png",
			"guandan/match/match_baoguang0004.png",
			"guandan/match/match_baoguang0005.png",
			"guandan/match/match_baoguang0006.png",
			"guandan/match/match_baoguang0007.png",
			"guandan/match/match_baoguang0008.png",
			"guandan/match/match_baoguang0009.png",
		},
		Plist = {},
		Animation = {}, --播放的动画
		UIImage = {}, --需要修改纹理的ImageView以 key --> value形式传入
		UIText = {}, -- 需要修改文字的Text 以 key --> value形式传入
		Visivle = {}, --需要修改显示的控件
	},
}
return GDUIAnimatorCfg
-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.06
-- Last: 
-- Content:  游戏中打牌特效配置
-- cardType  属于哪个牌类型的
-- Node  二维的数组节点，一维作为一个spawn，整个sequnce播放
--  Animation  动画的二维节点 
--				name 动画名字   
--				isEnd 是否结尾（删除）
--				endTag 帧动画结束是否需要回调 
--				isFull 是否全屏 
--				delay 播放延时
--				zorder 添加到哪个层 <0 低层	>0 高层 默认 可以不配置 高层
--
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDAnimationCfg = {
	{
		--属于哪个牌类型的  三张
		cardType = {CARD_TYPE.TRIPLE,},
		--二维的数组节点，一维作为一个spawn，整个sequnce播放
		Node = {
			--[[{"csb.guandan.animation.Node_light1","csb.guandan.animation.Node_label_triple"},--]]
		
		},
		--动画的二维节点 name 动画名字 isEnd 是否结尾（删除） endTag 帧动画结束是否需要回调  isFull 是否全屏 delay 播放延时
		Animation = {
			{
				--[[{name="animation0"},{name="animation0",isEnd = true}--]]
			},
		},
	},
	{
		--三代二
		cardType = {CARD_TYPE.TRIPLE_AND_DOUBLE,},
		Node = {
			--[[{"csb.guandan.animation.Node_light1","csb.guandan.animation.Node_label_threetwo"},--]]
		},
		Animation = {
			{
				--[[{name="animation0"},{name="animation0",isEnd = true}--]]
			},
		
		},
	},
	{
		--顺子
		cardType = {CARD_TYPE.COMMON_STRAIGHT,},
		Node = {
		--[[	{"csb.guandan.animation.Node_light1","csb.guandan.animation.Node_label_flush"},--]]
		},
		Animation = {
			{
				--[[{name="animation0"},{name="animation0",isEnd = true}--]]
			},
		
		},
	},
	{
		--钢板
		cardType = {CARD_TYPE.PLATE,},
		Node = {
			{"csb.guandan.animation.Node_gangban",--[["csb.guandan.animation.Node_light2","csb.guandan.animation.Node_gangban_label"--]]},
		},
		Animation = {
			{
				{name="animation0",height = -200,isEnd = true,zorder = -1 },--[[{name="animation0",height = -400},{name="animation0",height = -400}--]]
			},
		
		},
		Textures = {"guandan/pokerAnim/guandan_gangban.png","guandan/pokerAnim/guandan_gangban_1.png",},
		Plists = {"guandan/pokerAnim/guandan_gangban.plist","guandan/pokerAnim/guandan_gangban_1.plist",},
	},
	{
		--连对
		cardType = {CARD_TYPE.LINK_DOUBLE,},
		Node = {
			{--[["csb.guandan.animation.Node_light1","csb.guandan.animation.Node_label_double",--]]"csb.guandan.animation.Node_liandui"},
		},
		Animation = {
			{
				--[[{name="animation0"},{name="animation0"},--]]{name="animation0",height = -200,isEnd = true}
			},
		
		},
		Textures = {"guandan/pokerAnim/guandan_pair.png",},
		Plists = {"guandan/pokerAnim/guandan_pair.plist",},
	},
	{
		--同花顺
		cardType = {CARD_TYPE.FLUSH_BOMB,},
		Node = {
			{--[["csb.guandan.animation.Node_light1","csb.guandan.animation.Node_label_traflush",--]]"csb.guandan.animation.Node_straflush"},
		},
		Animation = {
			{
				--[[{name="animation0",delay = 0.3},{name="animation0",delay = 0.3},--]]{name="animation0",width = -100,height = -300,isEnd = true}
			},
		
		},
		Textures = {"guandan/pokerAnim/guandan_straflush.png",},
		Plists = {"guandan/pokerAnim/guandan_straflush.plist",},
	},
	
	{
		--王炸
		cardType = {CARD_TYPE.KING_BOMB,},
		Node = {
			{--[["csb.guandan.animation.Node_light1","csb.guandan.animation.Node_label_jokerbomb",--]]"csb.guandan.animation.Node_jokerBomb1"},
			{"csb.guandan.animation.Node_jokerBomb2"},
		},
		Animation = {
			{
				--[[{name="animation0"},{name="animation0"},--]]{name="animation0",endTag = true,isfull = true },
			},
			{
				{name="animation0",isfull = true,isEnd = true },
			},
		},
		Textures = {"guandan/pokerAnim/guandan_jokbb1.png","guandan/pokerAnim/guandan_jokbb2.png",},
		Plists = {"guandan/pokerAnim/guandan_jokbb1.plist","guandan/pokerAnim/guandan_jokbb2.plist",},
	},
	{
		--炸弹
		cardType = {CARD_TYPE.FOUR_BOMB,CARD_TYPE.FIVE_BOMB,CARD_TYPE.SIX_BOMB,CARD_TYPE.SEVEN_BOMB,CARD_TYPE.EIGHT_BOMB,CARD_TYPE.NINE_BOMB,CARD_TYPE.TEN_BOMB },
		Node = {
			{"csb.guandan.animation.Node_bomb",--[["csb.guandan.animation.Node_light1","csb.guandan.animation.Node_label_bomb"--]]},
			
		},
		Animation = {
			{
				{name="animation0",delay= 0.2,isfull = true,isEnd = true },--[[{name="animation0"},{name="animation0"},--]]
			},
			
		},
		Textures = {"guandan/pokerAnim/guandan_bombs_1.png","guandan/pokerAnim/guandan_bombs_2.png",},
		Plists = {"guandan/pokerAnim/guandan_bombs_1.plist","guandan/pokerAnim/guandan_bombs_2.plist",},
	},
	
}

return GDAnimationCfg
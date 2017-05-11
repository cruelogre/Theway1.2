-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  己玩家
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MyPlayer = class("MyPlayer",cc.Layer
	,require("packages.mvc.Mediator")
	)
local Card = require("WhippedEgg.View.Card")
require("WhippedEgg.ConstType")
local CardDetection = require("WhippedEgg.CardDetection")
local CardTips = require("WhippedEgg.CardTips")
local GameModel = require("WhippedEgg.Model.GameModel")
local Toast = require("app.views.common.Toast")
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
require("hall.util.RoomChatManager")

function MyPlayer:ctor( ... )
	-- body
	self:init()
end

--初始化
function MyPlayer:init()
	-- body
	self.logTag = "MyPlayer.lua"

	local playerUi = require("csb.guandan.GamePlayBottomLayer"):create()
	if not playerUi then
		return
	end
	local rootPlay = playerUi["root"]
	self.rootPlayAni = playerUi["animation"]
	rootPlay:runAction(self.rootPlayAni)
	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame or
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		self.rootPlayAni:play("animation0",true)
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
		self.rootPlayAni:play("animation1",true)
	end
	--玩家头像一大堆信息
	self.Image_bg = rootPlay:getChildByName("Image_bg")
	rootPlay:setPosition(cc.p(self.Image_bg:getContentSize().width/2,self.Image_bg:getContentSize().height/2))
	self.Image_gold = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_gold") --昵称
	self.Text_name = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_name") --昵称
	self.Text_gold = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_gold") --金币显示label
	self.Image_headbg = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_headbg")
	local playerHeadUi = require("csb.guandan.HeadNode"):create()
	self.rootPlayerHeadUi = playerHeadUi["root"]
  	self.Image_headbg:addChild(self.rootPlayerHeadUi)
  	self.rootPlayerHeadUi:setPosition(cc.p(self.Image_headbg:getContentSize().width/2,self.Image_headbg:getContentSize().height/2))
  	self.rootPlayerHeadUiAni = playerHeadUi["animation"]
	self.rootPlayerHeadUi:runAction(self.rootPlayerHeadUiAni)

	local function checkInfo( ... )
		-- body
		if GameManageFactory:getCurGameManage().gameState ~= GameStateType.Enter and GameManageFactory:getCurGameManage().gameState ~= GameStateType.None then
	        playSoundEffect("sound/effect/anniu")
		  	GameManageFactory:getCurGameManage():requestUserInfo(DataCenter:getUserdataInstance():getValueByKey("userid"))
  		end
	end
	self.Image_headbg:addClickEventListener(checkInfo)
	self.headImgMachine = self.rootPlayerHeadUi:getChildByName("Image_head") --头像
	self.headImgMachine:setLocalZOrder(0)
	self.Image_head_mark = self.rootPlayerHeadUi:getChildByName("Image_head_mark") --名次
	self.Image_head_mark:setLocalZOrder(2)
	self.Image_head_mark:setVisible(false)
	local headTravelNode = require("csb.guandan.headTravelAni"):create()
	self.rootheadTravelNode = headTravelNode["root"]
  	self:addChild(self.rootheadTravelNode,1)
  	self.rootheadTravelNode:setPosition(self.rootPlayerHeadUi:convertToWorldSpace(cc.p(self.Image_head_mark:getPositionX(),self.Image_head_mark:getPositionY())))
  	self.rootheadTravelNodeAni = headTravelNode["animation"]
	self.rootheadTravelNode:runAction(self.rootheadTravelNodeAni)
	self.rootheadTravelNode:setVisible(false)
	self.Rank_info = ccui.Helper:seekWidgetByName(self.Image_bg,"rank_info") --名次详情
	self.Rank_info:setVisible(false)
	self.Text_Rank = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_Rank") --名次
	self.Text_Stage = ccui.Helper:seekWidgetByName(self.Rank_info,"Text_4") --阶段
	self.Text_Promotion = ccui.Helper:seekWidgetByName(self.Rank_info,"Text_4_0") --晋级
    --记牌器用到了Button_rmcard的enter和exit接口，其他地方不能再使用这两个接口，by刘龙。
	self.Button_rmcard = ccui.Helper:seekWidgetByName(self.Image_bg,"Button_rmcard") --记牌器
	self.img_rmcard = ccui.Helper:seekWidgetByName(self.Button_rmcard,"Image_rm") --记牌器
  	self.Button_recover = ccui.Helper:seekWidgetByName(self.Image_bg,"Button_recover") --恢复
  	self.Button_manage = ccui.Helper:seekWidgetByName(self.Image_bg,"Button_manage") --理牌
  	self.Button_straight = ccui.Helper:seekWidgetByName(self.Image_bg,"Button_straight") --同花顺
  	self.Button_Rank = ccui.Helper:seekWidgetByName(self.Image_bg,"Button_Rank") --排行
  	self.Button_add = ccui.Helper:seekWidgetByName(self.Image_bg,"Button_add") --加金币
  	
  	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
		self.Button_add:setVisible(true)
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime or
		GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then --比赛
		self.Button_add:setVisible(false)
	end
  	self.Button_add:addClickEventListener(handler(self,self.btnClick))
  	self.Button_rmcard:addClickEventListener(handler(self,self.btnClick))
  	self.Button_recover:addClickEventListener(handler(self,self.btnClick))
  	self.Button_manage:addClickEventListener(handler(self,self.btnClick))
  	self.Button_straight:addClickEventListener(handler(self,self.btnClick))
  	self.Button_Rank:addClickEventListener(handler(self,self.btnClick))

  	--玩牌层
	self.playcardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self:addChild(self.playcardLayer)
	self.playcardLayer:setScale(0.5)

	--供牌层
	self.tributecardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self:addChild(self.tributecardLayer)

	--团团转牌层
	self.rciclescardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self:addChild(self.rciclescardLayer)

	--我的牌
	self.cardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self.cardLayer:setPosition(cc.p(screenSize.width/2,self.Image_bg:getContentSize().height))
	self:addChild(self.cardLayer)

	self:addChild(rootPlay)

	--进/抗贡位置
	self.TributePos = false
  	self.Gender = GenderType.male

  	--打牌按钮
	local ButtonGP1 = require("csb.guandan.GamePlayButtonGP1"):create()
	if not ButtonGP1 then
		return
	end
	self.rootGP1 = ButtonGP1["root"]
	self.animGP1 = ButtonGP1["animation"]
	self.rootGP1:setVisible(false)
	self.rootGP1:runAction(self.animGP1)
	self.rootGP1:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height*33/48))
  	self:addChild(self.rootGP1)
  	self.Button_ignore = self.rootGP1:getChildByName("Button_ignore") --不出
  	self.Button_tip = self.rootGP1:getChildByName("Button_tip") --提示
  	self.Button_show = self.rootGP1:getChildByName("Button_show") --出牌
  	self.Button_ignore:addClickEventListener(handler(self,self.btnClick))
  	self.Button_tip:addClickEventListener(handler(self,self.btnClick))
  	self.Button_show:addClickEventListener(handler(self,self.btnClick))
  	self.clock = self.rootGP1:getChildByName("Image_alarm") --闹钟
  	self.clockSec = self.clock:getChildByName("Text_alarm") --闹钟数字
  	self.secCount = 0 --倒计时秒

  	self.stateImg = ccui.Helper:seekWidgetByName(self.Image_bg,"state") --金币显示label
  	self.stateImg:ignoreContentAdaptWithSize(true)
  	self.stateImg:setVisible(false)
  	--玩家状态
  	self.stateType = PlayerStateType.None

  	--提示
  	self.buttomTips = ccui.Helper:seekWidgetByName(self.Image_bg,"bottomTips") --提示
  	self.buttomTipsImg = ccui.Helper:seekWidgetByName(self.buttomTips,"Image_2") --提示
  	self.buttomTipsImg:ignoreContentAdaptWithSize(true)
  	self.buttomTips:setVisible(false)

	--所有牌(每个牌值都有一个表)
	self.allCard = {}
	self.allColorCard = {}
	
	self.cardFix = MY_FIX --牌间距
	--发牌过程到了几列
	self.curCol = 0 
	--上次发的牌
	self.lastCard = false
	self.dealCardEd = false --发完牌

	--用于牌面显示的牌
	self.allViewCard = {}
	--判断有效无效牌
	self.effectiveCards = {}
	self.dealCardIdx = 0

	--正选中的牌
	self.checkIngCard = {}
	self.cancleCard = {}
	--选中完成的牌
	self.checkEdCard = {}

	--提示
	self:clearTipsInfo()
	self.toastState = 0
	--有自动打不过对方提示
	self.notPassOther = false

	--上家牌类型 大小
	self.upperPlayerType = tonumber(CARD_TYPE.NONE)
	self.upperPlayerVal = 0

	self.myPlayerType = 1
	self.myPlayerVal = 0
	self.myPlayerColor = 0

	--是否托管
	self.Trusteeship = false
	self.firstTimePolice = true

	self.Solitaire = false --接风

	self.isGetPlayCard = true --收到回复

	--设置个人信息
	self:setHeadInfo()
	self.Text_Rank:setString("0/0") --名次

	self:setDisableButtonState(true)
	self:setBtnTankState(true)
	self:setAddGoldState(true)

	self:registerScriptHandler(handler(self,self.onNodeEvent))

	RoomChatManager:setCurGameID(wwConfigData.GAMELOGICPARA.GUANDAN.GAME_ID)
	GameManageFactory:getCurGameManage().FoldMenuLayer:addChatNode(Player_Type.SelfPlayer,DataCenter:getUserdataInstance():getValueByKey("userid"),self:getTributePos(),
		cc.p(self:getTributePos().x + 10,self:getTributePos().y + 160),false,false)
end

--onEnter onExit
function MyPlayer:onNodeEvent( event )
	-- body
	if event == "enter" then
		self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
    elseif event == "exit" then
       	if self.turnToPlayScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
			self.turnToPlayScriptFuncId = false
		end

		if self.TouchCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.TouchCardScriptFuncId)
			self.TouchCardScriptFuncId = false
	  	end

	  	if self.ToastTipsScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ToastTipsScriptFuncId)
			self.ToastTipsScriptFuncId = false
		end

		if self.NotPlayerCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.NotPlayerCardScriptFuncId)
			self.NotPlayerCardScriptFuncId = false
		end

		if self.zorerCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.zorerCardScriptFuncId)
			self.zorerCardScriptFuncId = false
		end
		self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
    end
end

--[[
handleType 为消息处理类型
--]]
function MyPlayer:refreshInfo(event)
	local handleType = unpack(event._userdata)
	if handleType == 1 then
		--刷新个人信息区域
		wwlog(self.logTag, "更新MyPlayer金币信息")
		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
			self.Text_gold:setString(ToolCom.splitNumFix(tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash")) or 0)) --金币显示label
		end
	end
end


--提示
function MyPlayer:ToastTips( state,Visible )
	-- body
	--如果有常驻提示
	if state == ToastState.None and self.allTimeVisible then
		return
	end

	self.toastState = state
	if Visible then
		self.allTimeVisible = true
	  	self.buttomTips:setVisible(true)

		if self.toastState == ToastState.FriendCard then --朋友的牌
			self.buttomTipsImg:loadTexture("guandan_wenzi_friendCards.png",UI_TEX_TYPE_PLIST)
		elseif self.toastState == ToastState.NoPass then --不能大过对方
			self.buttomTipsImg:loadTexture("guandan_wenzi_noCardPass.png",UI_TEX_TYPE_PLIST)
		elseif self.toastState == ToastState.Trusteeship then --托管
			self.buttomTipsImg:loadTexture("guandan_wenzi_trusteeShip.png",UI_TEX_TYPE_PLIST)
			GameManageFactory:getCurGameManage():addCancleTrShipLayer()
		end
	else
		if self.ToastTipsScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ToastTipsScriptFuncId)
			self.ToastTipsScriptFuncId = false
		end

	  	self.buttomTips:setVisible(true)
	  	if self.toastState == ToastState.None then
	  		self.buttomTips:setVisible(false)
	  	elseif self.toastState == ToastState.NoRule then --不符合规则
			self.buttomTipsImg:loadTexture("guandan_wenzi_cardNoRule.png",UI_TEX_TYPE_PLIST)
		elseif self.toastState == ToastState.FriendNeedHelp then --队友需要你
			self.buttomTipsImg:loadTexture("guandan_wenzi_donotLeaveme.png",UI_TEX_TYPE_PLIST)
		elseif self.toastState == ToastState.NoColorBomb then --没有同花顺
			self.buttomTipsImg:loadTexture("guandan_wenzi_haveNoFlushBob.png",UI_TEX_TYPE_PLIST)
		elseif self.toastState == ToastState.NoPass then --不能大过对方
			self.buttomTipsImg:loadTexture("guandan_wenzi_noCardPass.png",UI_TEX_TYPE_PLIST)
		elseif self.toastState == ToastState.MustChooseOneCard then
			self.buttomTipsImg:loadTexture("guandan_wenzi_mustChooseaCard.png",UI_TEX_TYPE_PLIST)
		end

	  	local function InVisibleToastTip( ... )
	  		-- body
	  		self.buttomTips:setVisible(false)
	  		if self.ToastTipsScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ToastTipsScriptFuncId)
				self.ToastTipsScriptFuncId = false
			end

			--检测是否查看对家牌
			if GameManageFactory:getCurGameManage():IsSeeFriendPlayerCard() then
				self:ToastTips(ToastState.FriendCard,true)
			elseif self.notPassOther then --自动提示打不过对方 要重新出来
				self:ToastTips(ToastState.NoPass,true)
			elseif self.Trusteeship then  --托管要重新出来
				self:ToastTips(ToastState.Trusteeship,true)
			end
	  	end
	  	if not self.ToastTipsScriptFuncId then
			self.ToastTipsScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(InVisibleToastTip,1.5, false)
		end
	end
end

function MyPlayer:ToastTipsPlayerLeave( leave )
	-- body
	if leave then
		if self.ToastTipsScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ToastTipsScriptFuncId)
			self.ToastTipsScriptFuncId = false
		end

		self.allTimeVisible = true
		self.buttomTips:setVisible(true)
		self.buttomTipsImg:loadTexture("guandan_wenzi_plyerLeave.png",UI_TEX_TYPE_PLIST)
		GameManageFactory:getCurGameManage():addCancleTrShipLayer()
		GameManageFactory:getCurGameManage():setCancleTrShipLayerEffective(false)
	else
		self.buttomTips:setVisible(false)
		GameManageFactory:getCurGameManage():delCancleTrShipLayer()
		GameManageFactory:getCurGameManage():setCancleTrShipLayerEffective(true)

		--检测是否查看对家牌
		if GameManageFactory:getCurGameManage():IsSeeFriendPlayerCard() then
			self:ToastTips(ToastState.FriendCard,true)
		elseif self.notPassOther then --自动提示打不过对方 要重新出来
			self:ToastTips(ToastState.NoPass,true)
		elseif self.Trusteeship then  --托管要重新出来
			self:ToastTips(ToastState.Trusteeship,true)
		end
	end
end

function MyPlayer:setDisableButtonState( disEnabled )
	-- body
	--查看队友牌 一定置灰
	if GameManageFactory:getCurGameManage():IsSeeFriendPlayerCard() then
		disEnabled = true
	end

	if GameManageFactory:getCurGameManage().TipsAniLayer then
		GameManageFactory:getCurGameManage().FoldMenuLayer:setDisableButtonState(disEnabled)
	end

	if disEnabled then
		self.Button_rmcard:setBright(false)
  		self.Button_rmcard:setTouchEnabled(false)
  		ToolCom:setNodeGray(self.img_rmcard,true)

  		self.Button_recover:setBright(false)
  		self.Button_recover:setTouchEnabled(false)

  		self.Button_manage:setBright(false)
  		self.Button_manage:setTouchEnabled(false)

  		self.Button_straight:setBright(false)
  		self.Button_straight:setTouchEnabled(false)
	else
		self.Button_rmcard:setBright(true)
  		self.Button_rmcard:setTouchEnabled(true)
  		ToolCom:sprRemoveGray(self.img_rmcard,true)

  		self.Button_recover:setBright(true)
  		self.Button_recover:setTouchEnabled(true)

  		self.Button_manage:setBright(true)
  		self.Button_manage:setTouchEnabled(true)

  		self.Button_straight:setBright(true)
  		self.Button_straight:setTouchEnabled(true)

  		self.Button_Rank:setBright(true)
  		self.Button_Rank:setTouchEnabled(true)
	end
end

function MyPlayer:setBtnTankState( disEnabled )
	-- body
	if disEnabled then
		self.Button_Rank:setBright(false)
  		self.Button_Rank:setTouchEnabled(false)
	else
		self.Button_Rank:setBright(true)
  		self.Button_Rank:setTouchEnabled(true)
	end
end

function MyPlayer:setAddGoldState( disEnabled )
	-- body
	if disEnabled then
		self.Button_add:setBright(false)
		self.Button_add:setTouchEnabled(false)
	else
		self.Button_add:setBright(true)
		self.Button_add:setTouchEnabled(true)
	end
end

--按钮事件
function MyPlayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")
	if ref:getName() == "Button_rmcard" then --记牌器
        MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic:getCardRecorder():click_btnCardRecorder_callback()
  	elseif ref:getName() == "Button_recover" then --恢复

		if self.dealCardEd and self:getCardCount() > 0 then
			self:Arrangement()
		end	
  	elseif ref:getName() == "Button_manage" then --理牌
  		if self.dealCardEd and self:getCardCount() > 0 then
  			self:changeToSingleCol()
  			--如果还在进贡退贡中要还原状态
			if self.stateType == PlayerStateType.PayTribute then
				self:PayTribute()
			elseif self.stateType == PlayerStateType.RetTribute then
				self:RetTribute()
			end

			self:clearTipsInfo()
  		end
  	elseif ref:getName() == "Button_straight" then --同花顺
  		if self.dealCardEd and self:getCardCount() > 0 then
  			self:cardTipsFlushBomb()
  		end
  	elseif ref:getName() == "Button_ignore" then --不出
  		self:donotPlayCard()
  	elseif ref:getName() == "Button_tip" then --提示
  		--如果已经没牌打过对方 提示就不出
  		if self.notPassOther then
  			self:donotPlayCard()
			self.notPassOther = false
			if self.NotPlayerCardScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.NotPlayerCardScriptFuncId)
				self.NotPlayerCardScriptFuncId = false
			end
  		else
  			self:cardTips(self.upperPlayerType,self.upperPlayerVal,true)
  		end
  	elseif ref:getName() == "Button_show" then --出牌
  		--打牌动画
  		if self.stateType == PlayerStateType.PayTribute  or 
  			self.stateType == PlayerStateType.RetTribute then --进贡--退贡
  			self:chooseTributeCard()
  		else
			if self.Trusteeship then
				return --现在是托管 别动
			end
  			local Success = self:detectionPlayCard()
	  		if Success then
	  			self:playCardBtn()
	  			
		  		--隐藏打牌按钮及闹钟倒计时
		  		self.rootGP1:setVisible(false)
		  		if self.turnToPlayScriptFuncId then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
					self.turnToPlayScriptFuncId = false
				end
	  		end
  		end
  	elseif ref:getName() == "Button_Rank" then
  		if self.dealCardEd then
	  		if self.Rank_info:isVisible() then
				self.Rank_info:setVisible(false)
			else
				self.Rank_info:setVisible(true)
			end
		end
	elseif ref:getName() == "Button_add" then
		local sceneIDKeyTmp
		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
			sceneIDKeyTmp = "GameCustom"
		elseif GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
			sceneIDKeyTmp = "GameSiren"
		elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
			GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
			GameManageFactory.gameType == Game_Type.MatchRcircleCount or
			GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛
			sceneIDKeyTmp = "GameMatch"
		end
		FSRegistryManager:currentFSM():trigger("store", 
		{parentNode=display.getRunningScene(), zorder=zorderLayer.CustomLayer, store_openType=2, sceneIDKey = sceneIDKeyTmp})
	end
end

--不出牌
function MyPlayer:donotPlayCard( ... )
	-- body
	--向服务器发消息
	for k,v in pairs(self.checkEdCard) do -- 将正在选中的放在已选表内
		v.faceImg:setColor(cc.c3b(255,255,255))
		v.mState = Card_State.State_None
		v.allLight = false
	end
	self.checkEdCard = {}
	self:chooseCardMoveUp()

	if self.callBcak then -- 打完回调
		self.callBcak(PlayCardType.NO_CARD)
	end
	wwlog(self.logTag,"我没有出牌")
	self:setStateType(PlayerStateType.NotPlay)
	self.rootGP1:setVisible(false)
	if self.turnToPlayScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
		self.turnToPlayScriptFuncId = false
	end
	--提示清空
	self:clearTipsInfo()

	--自动检测打不过对方
	if self.toastState == ToastState.NoPass and 
		self.NotPlayerCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.NotPlayerCardScriptFuncId)
		self.NotPlayerCardScriptFuncId = false
		self.allTimeVisible = false
		self:ToastTips(ToastState.None)
		self.notPassOther = false
	end
end

--设置头像信息
function MyPlayer:setHeadInfo(playerDatas)
  	self.Gender = DataCenter:getUserdataInstance():getValueByKey("gender")
	self:addHead(DataCenter:getUserdataInstance():getHeadIcon())

	self.Text_name:setString(DataCenter:getUserdataInstance():getValueByKey("nickname") or "") --昵称
	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
		self.Text_gold:setString(ToolCom.splitNumFix(tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash")) or 0)) --金币显示label
		self.Image_gold:loadTexture("guandan/guandan_bottom_gold_bg.png")
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime  then --比赛
		if playerDatas then
			if  playerDatas.TScore ~= nil then
				self.Text_gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.TScore) or 0)) --积分显示label
			else
				self.Text_gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.Score) or 0)) --积分显示label
			end
		else
			self.Text_gold:setString(ToolCom.splitNumFix(0)) --积分显示label
		end
		self.Image_gold:loadTexture("guandan/guandan_bottom_fen_bg.png")
	elseif	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		if playerDatas then
			if playerDatas.TFortune then
				self.Text_gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.TFortune))) 
			elseif playerDatas.Fortune then
				self.Text_gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.Fortune))) 
			end
		end
		self.Image_gold:loadTexture("guandan/guandan_bottom_fen_bg.png")
	end
end

function MyPlayer:addHead( fileName )
	-- body
	if self.headImgMachine:getChildByName("headNodeFrame") then
		self.headImgMachine:removeChildByName("headNodeFrame")
	end
	
	local param = {
		headFile=fileName,
		maskFile="",
		frameFile = "common/common_userheader_frame_userinfo.png",
		headType=2,
		radius=60,
		width = self.headImgMachine:getContentSize().width,
		height = self.headImgMachine:getContentSize().height,
		headIconType = DataCenter:getUserdataInstance():getValueByKey("IconID"),
		userID = DataCenter:getUserdataInstance():getValueByKey("userid")
	}
	local WWHeadSprite = WWHeadSprite:create(param)

	self.headNodeFrame = ccui.ImageView:create("guandan_bottom_head_bg1.png",UI_TEX_TYPE_PLIST)
	local headClippingNode = createClippingNode("guandan_head_robot.png",WWHeadSprite,
		cc.p(self.headNodeFrame:getContentSize().width/2,self.headNodeFrame:getContentSize().height/2))
	self.headNodeFrame:addChild(headClippingNode)
	self.headNodeFrame:setName("headNodeFrame")
	self.headNodeFrame:setScale(0.99)
	self.headNodeFrame:setPosition(cc.p(self.headImgMachine:getContentSize().width/2,self.headImgMachine:getContentSize().height/2))
	self.headImgMachine:addChild(self.headNodeFrame,1)

	self:addMoveHead(fileName)
end

function MyPlayer:addMoveHead( fileName )
	-- body
	if self:getChildByName("moveClippingNode") then
		self:removeChildByName("moveClippingNode")
	end

	local param = {headFile=fileName,maskFile="",headType=2,radius=60,
		frameFile = "common/common_userheader_frame_userinfo.png",
		width = self.headImgMachine:getContentSize().width,
		height = self.headImgMachine:getContentSize().height,
		headIconType = DataCenter:getUserdataInstance():getValueByKey("IconID"),
		userID = DataCenter:getUserdataInstance():getValueByKey("userid")}

	local moveHeadSprite = WWHeadSprite:create(param)
	local ClippingNode = createClippingNode("guandan_head_robot.png",moveHeadSprite,
		cc.p(self.headImgMachine:getContentSize().width/2,self.headImgMachine:getContentSize().height/2))

	self.moveClippingNode = ccui.ImageView:create("guandan_bottom_head_bg1.png",UI_TEX_TYPE_PLIST)
	ClippingNode:setPosition(cc.p(ClippingNode:getContentSize().width/2,ClippingNode:getContentSize().height/2))
	self.moveClippingNode:addChild(ClippingNode)
	self.moveClippingNode:setName("moveClippingNode")
	self:addChild(self.moveClippingNode,1)
	local pos = self.headImgMachine:convertToWorldSpace(cc.p(self.headNodeFrame:getPositionX(),self.headNodeFrame:getPositionY()))
	self.moveClippingNode:setPosition(cc.p(pos.x,pos.y))
	self.moveClippingNode:setVisible(false)
end

function MyPlayer:runMoveAction( callBack )
	-- body
	local posSrc = self.headImgMachine:convertToWorldSpace(cc.p(self.headNodeFrame:getPositionX(),self.headNodeFrame:getPositionY()))
	local posDest = cc.p(self:getContentSize().width/2,	self:getContentSize().height/3)
	local midPos = cc.p(posDest.x,posDest.y-self.moveClippingNode:getContentSize().height)
	
	self.Image_bg:runAction(cc.Sequence:create(cc.FadeOut:create(0.1),cc.CallFunc:create(function ( ... )
		-- body
		self.moveClippingNode:setVisible(true)
		self.moveClippingNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,posDest),
		cc.DelayTime:create(0.25),
		cc.MoveTo:create(0.1,midPos),
		cc.DelayTime:create(0.25),
		cc.MoveTo:create(0.2,posSrc),
		cc.CallFunc:create(function ( ... )
			-- body
			self.Image_bg:setOpacity(255)
			self.moveClippingNode:setVisible(false)
			self.rootPlayerHeadUiAni:play("animation0",false)
			self.rootPlayerHeadUiAni:setAnimationEndCallFunc1("animation0",function ()
				if callBack then
					callBack()
				end
			end)
		end)))
	end)))
end

--设置名次
function MyPlayer:setRank( rank,gameOver )
	-- body
	if rank and rank > 0  and rank < 5 then
		if not self.Image_head_mark:isVisible() then
			if rank >= 4 or gameOver then
				self.Image_head_mark:setVisible(true)
				self.Image_head_mark:loadTexture(string.format("guandan_mark_index%d.png",rank),UI_TEX_TYPE_PLIST)
			else
				playSoundEffect("sound/effect/wanpai")
				--名次图片
				local nodeMark = self:getChildByName("nodeMarkIcon")
				local nodeMarkPos = cc.p(self.playcardLayer:getPositionX()+self.playcardLayer:getContentSize().width/2,
					self.playcardLayer:getPositionY()+self.playcardLayer:getContentSize().height/2)
				if not nodeMark then
					nodeMark = ccui.ImageView:create(string.format("guandan_mark_index%d.png",rank),UI_TEX_TYPE_PLIST)
					nodeMark:setName("nodeMarkIcon")
					nodeMark:setPosition(nodeMarkPos)
					self:addChild(nodeMark)
				else
					nodeMark:loadTexture(string.format("guandan_mark_index%d.png",rank),UI_TEX_TYPE_PLIST)
					nodeMark:setPosition(nodeMarkPos)
				end
				nodeMark:setVisible(true)

				local posDest = self.rootPlayerHeadUi:convertToWorldSpace(cc.p(self.Image_head_mark:getPositionX(),self.Image_head_mark:getPositionY()))
				local bezier = {
						        cc.p(nodeMarkPos.x - 200, nodeMarkPos.y + 100),
						        cc.p(posDest.x + 200, posDest.y + 100),
						        posDest
						    }
			    local bezierTo = cc.BezierTo:create(0.6, bezier)
				nodeMark:runAction(cc.Sequence:create(
					cc.Spawn:create(bezierTo,cc.Sequence:create(cc.DelayTime:create(0.35),
												cc.ScaleTo:create(0.2,8),
												cc.ScaleTo:create(0.1,1))),
					cc.CallFunc:create(function ( ... )
					-- body
					nodeMark:setVisible(false)
					self.Image_head_mark:setVisible(true)
					self.Image_head_mark:loadTexture(string.format("guandan_mark_index%d.png",rank),UI_TEX_TYPE_PLIST)
					self.rootheadTravelNode:setVisible(true)
					self.rootheadTravelNodeAni:play("animation0",false)
					self.rootPlayerHeadUiAni:play("animation0",false)
					self.rootPlayerHeadUiAni:setAnimationEndCallFunc1("animation0",function ()
						--注销回调
					end)
				end)))
			end
		end
	else
		self.Image_head_mark:setVisible(false)
	end
end

--设置出牌状态文字
function MyPlayer:setStateType( state )
	-- body
	self.stateType = state
	self.stateImg:setVisible(true)
	if self.stateType == PlayerStateType.None then
  		self.stateImg:setVisible(false)
	elseif self.stateType == PlayerStateType.Wait then
		self.stateImg:loadTexture("guandan_wenzi_wait.png",UI_TEX_TYPE_PLIST)
	elseif self.stateType == PlayerStateType.Ready then
		self.stateImg:loadTexture("guandan_wenzi_ready.png",UI_TEX_TYPE_PLIST)
	elseif self.stateType == PlayerStateType.PayTribute then
		self.stateImg:loadTexture("guandan_wenzi_paytribut.png",UI_TEX_TYPE_PLIST)
	elseif self.stateType == PlayerStateType.RetTribute then
		self.stateImg:loadTexture("guandan_wenzi_retTribute.png",UI_TEX_TYPE_PLIST)
	elseif self.stateType == PlayerStateType.UnPayTribute then
		self.stateImg:setVisible(false)
	elseif self.stateType == PlayerStateType.NotPlay then
		self.stateImg:loadTexture("guandan_wenzi_buchu.png",UI_TEX_TYPE_PLIST)
		if self.Trusteeship then
			self.rootGP1:setVisible(false)
			if self.turnToPlayScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
				self.turnToPlayScriptFuncId = false
			end
		end
	elseif self.stateType == PlayerStateType.Solitaire then
  		self.stateImg:setVisible(false)
		self.Solitaire = true
	end	
end

--轮到我打牌 开始倒计时
function MyPlayer:turnToPlay( upperPlayerType,upperPlayerVal,callBcak,time )
	-- body
	self:setDisableButtonState(false)
	self:setBtnTankState(false)
	self:setAddGoldState(false)

	self:hideCard()
	self:clearTipsInfo()

	if upperPlayerType and upperPlayerVal and callBcak then --正常打牌
		wwlog(self.logTag,"显示我的倒计时闹钟")
		self.upperPlayerType = tonumber(upperPlayerType)
		self.upperPlayerVal = tonumber(upperPlayerVal)
		self.callBcak = callBcak --我打完要回调

		

	  	if 	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
			self.rootGP1:setVisible(true)
			self.animGP1:play("animation3",false)
		else
			self.secCount = time
			self.rootGP1:setVisible(true)
			self.animGP1:play("animation0",false)
		  	self.clockSec:setString(tostring(self.secCount)) --闹钟数字
		  	if not self.turnToPlayScriptFuncId then
		  		self.turnToPlayScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)
		  	end
		end

	  	if self.upperPlayerType == tonumber(CARD_TYPE.NONE) and self.upperPlayerVal == 0 then
	  		self.Button_ignore:setBright(false)
	  		-- self.Button_ignore:getChildByName("sp_ignore"):getVirtualRenderer():setState(1)
	  		self.Button_ignore:setTouchEnabled(false)
	  	else 
	  		self.Button_ignore:setBright(true)
	  		-- self.Button_ignore:getChildByName("sp_ignore"):getVirtualRenderer():setState(0)
	  		self.Button_ignore:setTouchEnabled(true)
	  	end

	  	--没有托管 提示是否有牌可以出
	  	if not self.Trusteeship then
		  	if self.upperPlayerType ~= tonumber(CARD_TYPE.NONE) then
	  			self:preDetectionPassOther()
	  		end
	  	end
	end
end

--预先判断是否打过上家
function MyPlayer:preDetectionPassOther( ... )
	-- body
	wwlog("预先判断是否打过上家")
	local havePro = self:cardTips(self.upperPlayerType,self.upperPlayerVal,false)
		--没有大于对方 自动不出
		if not havePro then
			if not self.NotPlayerCardScriptFuncId then
				local function donotPlayCard( ... ) --不出
					-- body
					self:donotPlayCard()
					self.notPassOther = false
					if self.NotPlayerCardScriptFuncId then
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.NotPlayerCardScriptFuncId)
						self.NotPlayerCardScriptFuncId = false
					end
				end
	  		self.NotPlayerCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(donotPlayCard, math.random(3,5), false)
	  	end
	end
end

--倒计时递减
function MyPlayer:countDown( ... )
	-- body
	self.secCount = self.secCount - 1
	if self.secCount >= 0 then
  		self.clockSec:setString(tostring(self.secCount)) --闹钟数字
  	else
  		--超时托管一定要等服务器发了牌才能取消 不然有bug
  		if GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
			--私人房不能托管
		else
			wwlog(self.logTag,"超时请求托管")
			GameManageFactory:getCurGameManage():substitute(0) --托管
			GameManageFactory:getCurGameManage():setCancleTrShipLayerEffective(false)
			self.rootGP1:setVisible(false)
		end

  		if self.turnToPlayScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
			self.turnToPlayScriptFuncId = false
		end
  	end
end

--设置托管
function MyPlayer:setTrusteeShip( trusteeShip )
	-- body
	wwlog(self.logTag,"设置我的托管状态 %s",trusteeShip)
	if trusteeShip then
		self.Trusteeship = true
		self:ToastTips(ToastState.Trusteeship,true)
	else
		self.Trusteeship = false
		GameManageFactory:getCurGameManage():delCancleTrShipLayer()
		if GameManageFactory:getCurGameManage():IsSeeFriendPlayerCard() then
			self:ToastTips(ToastState.FriendCard,true)
		else
			self.allTimeVisible = false
			self:ToastTips(ToastState.None)
		end

		--轮到我打牌
		if self.rootGP1:isVisible() and self.turnToPlayScriptFuncId then
			self:preDetectionPassOther()
		end
	end
end
--检测可否打牌
function MyPlayer:detectionPlayCard()
	-- body
	if next(self.checkEdCard) == nil then
		self:ToastTips(ToastState.NoRule)
	end

	local function compareCard( myPlayerVal,upperPlayerVal)
		-- body
		if myPlayerVal == GameModel.nowCardVal and upperPlayerVal ~= GameModel.nowCardVal then
			if upperPlayerVal >= tonumber(CARD_VALUE.R_WA) then
  				self:ToastTips(ToastState.NoRule)
				return false
			else
				return true
			end
		elseif myPlayerVal ~= GameModel.nowCardVal and upperPlayerVal == GameModel.nowCardVal then
			if myPlayerVal >= tonumber(CARD_VALUE.R_WA) then
				return true
			else
				self:ToastTips(ToastState.NoRule)
				return false
			end

		elseif myPlayerVal ~= GameModel.nowCardVal and upperPlayerVal ~= GameModel.nowCardVal then
			if myPlayerVal > upperPlayerVal then --比上家牌大
				return true
			else
				self:ToastTips(ToastState.NoRule)
				return false
			end
		else
			self:ToastTips(ToastState.NoRule)
			return false
		end
	end

	--如果玩家出钢板 我则优先选钢板 （遇到 2233 + 癞子 可能组成钢板 和 连对）
	if self.upperPlayerType == tonumber(CARD_TYPE.PLATE) then
		self.myPlayerType,self.myPlayerVal,self.myPlayerColor = CardDetection.detectionType(self.checkEdCard,true,true)
	else
		self.myPlayerType,self.myPlayerVal,self.myPlayerColor = CardDetection.detectionType(self.checkEdCard,true)
	end
	self.myPlayerType = tonumber(self.myPlayerType)
	self.myPlayerVal = tonumber(self.myPlayerVal)
	self.myPlayerColor = tonumber(self.myPlayerColor)
	if self.upperPlayerType == tonumber(CARD_TYPE.NONE) and self.upperPlayerVal == 0 then --我先出
		if self.myPlayerType > tonumber(CARD_TYPE.NONE) then
			return true
		else
			self:ToastTips(ToastState.NoRule)
			return false
		end
	else
		if self.myPlayerType <= tonumber(CARD_TYPE.NONE) then --我先出
			self:ToastTips(ToastState.NoRule)
			return false
		else
			if self.upperPlayerType < tonumber(CARD_TYPE.FOUR_BOMB) and
		 		self.myPlayerType < tonumber(CARD_TYPE.FOUR_BOMB) then --一级牌
				if self.myPlayerType == self.upperPlayerType then --一级牌
					if self.myPlayerType == tonumber(CARD_TYPE.SINGLE)  then --单个
						return compareCard(self.myPlayerVal,self.upperPlayerVal)
					elseif self.myPlayerType == tonumber(CARD_TYPE.DOUBLE) then --对
						return compareCard(self.myPlayerVal,self.upperPlayerVal)
					elseif self.myPlayerType == tonumber(CARD_TYPE.TRIPLE) then --三个
						return compareCard(self.myPlayerVal,self.upperPlayerVal)
					elseif self.myPlayerType == tonumber(CARD_TYPE.TRIPLE_AND_DOUBLE) then --三带二
						return compareCard(self.myPlayerVal,self.upperPlayerVal)
					else
						if self.myPlayerVal > self.upperPlayerVal then --比上家牌大
							return true
						else
							self:ToastTips(ToastState.NoRule)
							return false
						end
					end
				else
					self:ToastTips(ToastState.NoRule)
					return false
				end
			elseif self.upperPlayerType < tonumber(CARD_TYPE.FOUR_BOMB) and
						self.myPlayerType >= tonumber(CARD_TYPE.FOUR_BOMB) then
					return true
			elseif self.upperPlayerType >= tonumber(CARD_TYPE.FOUR_BOMB) and
						self.myPlayerType < tonumber(CARD_TYPE.FOUR_BOMB) then
						self:ToastTips(ToastState.NoRule)
					return false
			elseif self.upperPlayerType >= tonumber(CARD_TYPE.FOUR_BOMB) and
						self.myPlayerType >= tonumber(CARD_TYPE.FOUR_BOMB) then
				--同花顺 第一个牌是当前打的牌其实并不大
				if self.myPlayerType == tonumber(CARD_TYPE.FLUSH_BOMB) and 
					self.upperPlayerType == tonumber(CARD_TYPE.FLUSH_BOMB) then
					if self.myPlayerVal > self.upperPlayerVal then --比上家牌大
						return true
					else
						self:ToastTips(ToastState.NoRule)
						return false
					end
				else
					if self.myPlayerType == self.upperPlayerType then --同级牌
						return compareCard(self.myPlayerVal,self.upperPlayerVal)
					elseif self.myPlayerType > self.upperPlayerType then
						return true
					else
						self:ToastTips(ToastState.NoRule)
						return false
					end
				end
			end
		end
	end
end

function MyPlayer:playCardBtn()
	-- body
	--传给服务器牌值
	local callBcakValTrue = {}
	local callBcakValReplace = {}
	for k,v in pairs(self.checkEdCard) do -- 遍历已选表
		--传给服务器
		local xNodeTrue = {}
		xNodeTrue.color = v.color
		xNodeTrue.val = v.val
		table.insert(callBcakValTrue,xNodeTrue)

		local xNodeReplace = {}
		xNodeReplace.color = v.color
		if v.isLaizi then
			xNodeReplace.val = v.isLaizi 
		else
			xNodeReplace.val = v.val 
		end

		--同花顺要变花色
		if self.myPlayerType == tonumber(CARD_TYPE.FLUSH_BOMB) then
			if v.isLaizi then
				xNodeReplace.color = self.myPlayerColor
			end
		end
		
		table.insert(callBcakValReplace,xNodeReplace)
	end
	--向服务器发消息
	if self.callBcak then -- 打完回调
		self.callBcak(PlayCardType.NORMAL,callBcakValTrue,callBcakValReplace,self.myPlayerType,self.myPlayerVal)
	end
	self.isGetPlayCard = false --正在打牌

	printCardLogType(tonumber(self.myPlayerType),callBcakValReplace,"我主动出牌")
end

function MyPlayer:playCard( trueCards,replaceCards )
	-- body
	--关闭打牌按钮
	wwlog(self.logTag,"服务器反馈(我)打牌数据过来")
	self.isGetPlayCard = true --收到回复

	self:setStateType(PlayerStateType.None)
	self.rootGP1:setVisible(false)
	if self.turnToPlayScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
		self.turnToPlayScriptFuncId = false
	end

	if next(trueCards) then
		--对比两种牌 查癞子
		if #trueCards ~= #replaceCards then --两个牌数值必须相同
			return
		end

		for i=1,#trueCards do
			local trueNode = trueCards[i]
			local replaceNode = replaceCards[i]
			if trueNode.val ~= replaceNode.val then --前后数值不一样 出现癞子
				trueNode.isLaizi = replaceNode.val
			end
		end

		--人家三带二 三个要在前面
		self.myPlayerType,self.myPlayerVal = CardDetection.detectionType(trueCards)
		printCardLogType(tonumber(self.myPlayerType),replaceCards,"我选择出")

		self.playcardLayer:removeAllChildren()
		for k,v in pairs(trueCards) do
			local cardNode = Card:create(v)
	  		if cardNode then
				cardNode.isLaizi = v.isLaizi
				cardNode:setPlayState()
				cardNode:setLocalZOrder(k)
				self.playcardLayer:addChild(cardNode)
				local pos = cc.p(MY_FIX_WEIDTH/2 + (k-1)*MY_FIX,MY_FIX_HEIGHT/2)
				cardNode:setPosition(pos)
			end  

			--删除两个库保存的节点
			local deleteIdx = -1
			for m,n in pairs(self.allCard[v.val]) do
				if v.color == n.color then
					if next(self.checkEdCard) then --自选
						if findItemByColorAndValue(self.checkEdCard,n.color,n.val) then
							if findItem(self.checkEdCard,n) then
								deleteIdx = n.createIdx
								table.remove(self.allCard[v.val],m)
								break
							end
						else
							deleteIdx = n.createIdx
							table.remove(self.allCard[v.val],m)
							break
						end
					else
						deleteIdx = n.createIdx
						table.remove(self.allCard[v.val],m)
						break
					end
				end
			end

			if v.val < tonumber(CARD_VALUE.R_WA) then --大小王不分花色 
				for m,n in pairs(self.allColorCard[v.val][v.color]) do
					if deleteIdx == n.createIdx then
						table.remove(self.allColorCard[v.val][v.color],m)
						break
					end
				end
			end

			--从剩余牌移除选中牌
			for i=#self.allViewCard,1,-1 do
				local find = false
				local nodeTable = self.allViewCard[i]
				for m,n in pairs(nodeTable) do
					if v.val == n.val and v.color == n.color and deleteIdx == n.createIdx then --找到有被选中
						--把选中的数据移除移表
						table.remove(nodeTable,m)
						self.cardLayer:removeChild(n,true)
						find = true
						break
					end
				end

				if next(nodeTable) == nil then
					table.remove(self.allViewCard,i)
				end

				if find then
					break
				end
			end
		end

		self.playcardLayer:setContentSize(cc.size(MY_FIX_WEIDTH + (#trueCards-1)*MY_FIX,MY_FIX_HEIGHT))
		self.playcardLayer:setPosition(cc.p((screenSize.width - self.playcardLayer:getContentSize().width)/2,
				self:getContentSize().height/3))

		local flashPos = cc.p(self.playcardLayer:getPositionX()+self.playcardLayer:getContentSize().width/2,
			self.playcardLayer:getPositionY()+self.playcardLayer:getContentSize().height/2)
		GameManageFactory:getCurGameManage():playCardFlash( tonumber(self.myPlayerType),flashPos,true )
	end
	
	if GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		GameManageFactory:getCurGameManage():addDouble(self.myPlayerType)
	end

	self.checkEdCard = {}
	self:clearTipsInfo()
	self:fixCardMove()

	--先把打的牌盖住手上的牌 一秒钟后手上的牌盖住打的牌
	self.playcardLayer:setLocalZOrder(self.cardLayer:getLocalZOrder()+1)

	if not self.zorerCardScriptFuncId then 
		self.zorerCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
			-- body
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.zorerCardScriptFuncId)
			self.zorerCardScriptFuncId = false
			self.playcardLayer:setLocalZOrder(self.cardLayer:getLocalZOrder()-1)
		end,2, false)
	end
end

function MyPlayer:PlayCardSound( isFirst )
	-- body
	if self:getCardCount() <= CHANGECOLOR_CARD_PLAYER_NUM and self.firstTimePolice then
		self.firstTimePolice = false
		callThePoliceSound(self.Gender)
	else
		if self.Solitaire then
			self.Solitaire = false
			passPlayCardSound(self,self.Gender,true,self.myPlayerType,self.myPlayerVal)
		else
			passPlayCardSound(self,self.Gender,isFirst,self.myPlayerType,self.myPlayerVal)
		end
	end 
end

--获取牌数
function MyPlayer:getCardCount( ... )
	-- body
	local count = 0
	for k,v in pairs(self.allViewCard) do
		count = count + #v
	end

	return count
end

--隐藏牌面
function MyPlayer:hideCard( ... )
	-- body
	self.playcardLayer:removeAllChildren()
	self:setStateType(PlayerStateType.None)
	self.rootGP1:setVisible(false)
	
	if self.turnToPlayScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
		self.turnToPlayScriptFuncId = false
	end
end

function MyPlayer:hideClock( decection )
	-- body
	if decection and self.secCount > 0 and self.rootGP1:isVisible() then
		wwlog(self.logTag,"双闹钟出现了 我玩家 还剩余%d 秒倒计时",self.secCount)
	end

	self.rootGP1:setVisible(false)
	
	if self.turnToPlayScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.turnToPlayScriptFuncId)
		self.turnToPlayScriptFuncId = false
	end
end

--进贡开始
function MyPlayer:PayTribute( callBcak )
	-- body
	self:setDisableButtonState(true)
	self.PayTributeCallBcak = callBcak --进贡完成回调
	self:setStateType(PlayerStateType.PayTribute)
	self.rootGP1:setVisible(true)
	self.animGP1:play("animation1",false)

	local cloneTable = clone(self.allViewCard)
	cardTributeSort(cloneTable)
	local findVal = false
	for k,v in pairs(cloneTable) do
		for m,n in pairs(v) do
			if not findVal then
				if n.val == GameModel.nowCardVal then --主牌
					if n.color == tonumber(FOLLOW_TYPE.TYPE_H) then
						n:setGray()
						n.mState = Card_State.State_Discard
					else
						findVal = n.val
					end
				else
					findVal = n.val
				end
			else
				if n.val ~= findVal then
					n:setGray()
					n.mState = Card_State.State_Discard
				else
					if n.val == GameModel.nowCardVal and n.color == tonumber(FOLLOW_TYPE.TYPE_H) then
						n:setGray()
						n.mState = Card_State.State_Discard
					end 
				end
			end
		end
	end
end

--选好进退贡牌
function MyPlayer:chooseTributeCard( ... )
	-- body
	if #self.checkEdCard <= 0 then
		self:ToastTips(ToastState.MustChooseOneCard)
	elseif #self.checkEdCard > 1 then
		self:ToastTips(ToastState.MustChooseOneCard)
	else
		--删除两个库保存的节点
		local TributeCardNode = self.checkEdCard[1]
		for k,v in pairs(self.allCard[TributeCardNode.val]) do
			if TributeCardNode == v then 
				removeItem(self.allCard[TributeCardNode.val],v)
				break
			end
		end

		if TributeCardNode.val < tonumber(CARD_VALUE.R_WA) then --大小王不分花色 
			for k,v in pairs(self.allColorCard[TributeCardNode.val][TributeCardNode.color]) do
				if TributeCardNode == v then 
					removeItem(self.allColorCard[TributeCardNode.val][TributeCardNode.color],v)
					break
				end
			end
		end

		wwlog(self.logTag,"--把牌进/退贡出去")
		self:TributeCard(TributeCardNode)
		--从剩余牌移除选中牌
		for i=#self.allViewCard,1,-1 do
			local find = false
			local nodeTable = self.allViewCard[i]
			for k,v in pairs(nodeTable) do
				if v == TributeCardNode then --找到有被选中
					--把选中的数据移除移表
					table.remove(nodeTable,k)
					find = true
					break
				end
			end

			if next(self.allViewCard[i]) == nil then
				table.remove(self.allViewCard,i)
			end

			if find then
				break
			end
		end
		
		--进贡完回调
		if self.PayTributeCallBcak then
			self.PayTributeCallBcak({color = TributeCardNode.color,val = TributeCardNode.val})
			TributeSound(self,self.Gender,true,TributeCardNode.val)
		end

		--退贡完回调
		if self.RetTributeCallBcak then
			self.RetTributeCallBcak({color = TributeCardNode.color,val = TributeCardNode.val})
			TributeSound(self,self.Gender,false,TributeCardNode.val)
		end

		self.cardLayer:removeChild(TributeCardNode,true)
		self.checkEdCard = {}
		self:fixCardMove()
		self:PayTributeEnd()
		self.rootGP1:setVisible(false)
		self:setStateType(PlayerStateType.None)
		GameManageFactory:getCurGameManage():setTributeEnd()
	end
end

function MyPlayer:TributeCard(TributeCardNode)
	-- body
	self.tributecardLayer:removeAllChildren()
	local cardNode
	if type(TributeCardNode) == "table" then
	 	cardNode = Card:create(TributeCardNode)
	else
	 	cardNode = TributeCardNode:clone()
	end
	cardNode:setName("TributeCardNode")
	self.tributecardLayer:addChild(cardNode,1)
	local pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2)
	cardNode:setPosition(pos)

	self.tributecardLayer:setScale(0.5)
	self.tributecardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT))
	self.tributecardLayer:setPosition(cc.p((screenSize.width - self.tributecardLayer:getContentSize().width)/2,
				self:getContentSize().height/3))

	self.TributePos = self.tributecardLayer:convertToWorldSpace(cc.p(cardNode:getPositionX(),cardNode:getPositionY()))
end

--获取进/退贡牌的位置
function MyPlayer:getTributePos( ... )
	-- body
	local pos = self.rootPlayerHeadUi:convertToWorldSpace(cc.p(self.headImgMachine:getPositionX(),self.headImgMachine:getPositionY()))
	return pos
end
--获得头像位置
function MyPlayer:getHeadPos( ... )
	-- body
	return self.Image_bg:convertToWorldSpace(cc.p(self.Image_headbg:getPositionX(),self.Image_headbg:getPositionY()))
end
--交换进/退贡的牌
function MyPlayer:ExchangTributeCard( player )
	-- body
	local TributeCardNode = self.tributecardLayer:getChildByName("TributeCardNode")
	if TributeCardNode then
		TributeCardNode:setVisible(false)
		local cardNode = TributeCardNode:clone()
		cardNode:setScale(0.5)
		cardNode:setPosition(self.TributePos)
		GameManageFactory:getCurGameManage().FoldMenuLayer:addChild(cardNode)
		cardNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,player:getTributePos()),cc.CallFunc:create(function ( ... )
			-- body
			self.tributecardLayer:removeAllChildren()
			player:setCardsCount(DISTRIBUTE_CARD_MIN_NUM)
		end),cc.DelayTime:create(3),cc.CallFunc:create(function ( ... )
			-- body
            --记牌器记录自己给出的贡牌
            MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic:getCardRecorder():onGiveTributeCard(cardNode)
			cardNode:removeFromParent()
		end)))
	end
end

--退贡开始
function MyPlayer:RetTribute( callBcak )
	-- body
	self:setDisableButtonState(true)
	self.RetTributeCallBcak = callBcak --退贡完成回调
	self:setStateType(PlayerStateType.RetTribute)
	self.rootGP1:setVisible(true)
	self.animGP1:play("animation2",false)

	local cloneTable = clone(self.allViewCard)
	cardTributeSort(cloneTable)
	for k,v in pairs(cloneTable) do
		for m,n in pairs(v) do
			if n.val >= tonumber(CARD_VALUE.R_WA) or  
				n.val == GameModel.nowCardVal then --大于等于主牌的牌置灰点击无效果
				n:setGray()
				n.mState = Card_State.State_Discard
			end
		end
	end
end

--进/退工超时
function MyPlayer:TributeOverTime( ... )
	-- body
	self.rootGP1:setVisible(false)
	if #self.checkEdCard ~= 1 then
		for k,v in pairs(self.checkEdCard) do
			v.mState = Card_State.State_None
			v.faceImg:setColor(cc.c3b(255,255,255))
		end
		self.checkEdCard = {}

		local cloneTable = clone(self.allViewCard)
		cardTributeSort(cloneTable)

		if self.stateType == PlayerStateType.PayTribute then
			for k,v in pairs(cloneTable) do
				for m,n in pairs(v) do
					if n.mState ~= Card_State.State_Discard then
						wwlog(self.logTag,"自动找到一个进贡牌")
						table.insert(self.checkEdCard,n)
						break
					end
				end

				if #self.checkEdCard >= 1 then
					break
				end
			end
		elseif self.stateType == PlayerStateType.RetTribute then
			for i=#cloneTable,1,-1 do
				for m,n in pairs(cloneTable[i]) do
					if n.mState ~= Card_State.State_Discard then
						wwlog(self.logTag,"自动找到一个退贡牌")
						table.insert(self.checkEdCard,n)
						break
					end
				end

				if #self.checkEdCard >= 1 then
					break
				end
			end
		end
	end

	--超时自动进/退贡
	self:chooseTributeCard()
end

--收到的牌
function MyPlayer:getTributeCard( card )
	-- body
	wwlog(self.logTag,"收到一张牌 插到现有牌中%d  %d",card.color,card.val)
	local cardNode = Card:create(card)
	if cardNode then
		cardNode:setVisible(false)
		self.dealCardIdx = self.dealCardIdx + 1
  		cardNode.createIdx = self.dealCardIdx -- 创建索引 用于区别同花色同大小牌
		self.cardLayer:addChild(cardNode)

		table.insert(self.allCard[cardNode.val],cardNode)
		if cardNode.val < tonumber(CARD_VALUE.R_WA) then --大小王不分花色 
			table.insert(self.allColorCard[cardNode.val][cardNode.color],cardNode)
		end

		local idx = false
		for k,v in pairs(self.allViewCard) do
			if self.effectiveCards[k] == tonumber(CARD_TYPE.SINGLE) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.DOUBLE) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.TRIPLE) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.FOUR_BOMB) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.FIVE_BOMB) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.SIX_BOMB) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.SEVEN_BOMB) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.EIGHT_BOMB) or
			 	self.effectiveCards[k] == tonumber(CARD_TYPE.NINE_BOMB) then --有序
				if v[1].val == cardNode.val then
					idx = k
					break
				end
			end
		end

		--在有序 同值牌中找到一列
		if idx then
			wwlog(self.logTag,"收到一张牌 插入第%d列",idx)
			table.insert(self.allViewCard[idx],1,cardNode)
		else
			for k,v in pairs(self.allViewCard) do
				if cardNode.val == GameModel.nowCardVal then
					if v[1].val < tonumber(CARD_VALUE.R_WA) and 
						v[1].val ~= GameModel.nowCardVal then
						idx = k
						break
					end 
				else
					if v[1].val == GameModel.nowCardVal then
						if cardNode.val >= tonumber(CARD_VALUE.R_WA) then
							idx = k
							break
						end
					else
						if cardNode.val > v[1].val then
							idx = k
							break
						end
					end
				end
			end

			if idx then
				wwlog(self.logTag,"收到一张牌 插入第%d列",idx)
				table.insert(self.allViewCard,idx,{cardNode})
			else
				wwlog(self.logTag,"找不到合适位置 直接插到最后面")
				table.insert(self.allViewCard,{cardNode})
			end
		end
		self:fixCardMove()
	end
    --获得贡牌
    MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic:getCardRecorder():onGetTributeCard(card)
end

--进贡结束
function MyPlayer:PayTributeEnd( ... )
	-- body
	self:setDisableButtonState(false)
	self:setStateType(PlayerStateType.TributeEnd)

	for k,v in pairs(self.allViewCard) do
		for m,n in pairs(v) do
			n:reSetGray()
			n.mState = Card_State.State_None
		end
	end

	self.checkEdCard = {}
end

--更换玩家
function MyPlayer:changePlayer( ... )
	self:setDisableButtonState(true)
	self:setBtnTankState(true)
	self:setAddGoldState(true)
	self.cardLayer:removeAllChildren()
	self.buttomTips:setVisible(false)
	self.allViewCard = {}
	self.dealCardEd = false
	self:hideCard()
	self:setRank(0)
end

--继续游戏
function MyPlayer:continueGame( ... )
	-- body
	self:setDisableButtonState(true)
	self:setBtnTankState(true)
	self:setAddGoldState(true)
	self.cardLayer:removeAllChildren()
	self.buttomTips:setVisible(false)
	self.allViewCard = {}
	self.dealCardEd = false
	self:hideCard()
end

--整理
function MyPlayer:Arrangement( ... )
	-- body
	local cards = {}
	for k,v in pairs(self.allViewCard) do
		for m,n in pairs(v) do
			local xNode = {}
			xNode.color = n.color
			xNode.val = n.val
			table.insert(cards,xNode)
		end
	end
	for k,v in pairs(self.checkEdCard) do
		v.faceImg:setColor(cc.c3b(255,255,255))
	end
	self.checkEdCard = {}
	self:clearTipsInfo()

	self:createCards(cards)
	self:fixCardMove()

	--如果还在进贡退贡中要还原状态
	if self.stateType == PlayerStateType.PayTribute then
		self:PayTribute()
	elseif self.stateType == PlayerStateType.RetTribute then
		self:RetTribute()
	end
end

--恢复对局
function MyPlayer:recoveryOn( cards )
	-- body
	self:releaseCards()
	self:createCards(cards)
	self:fixCardMove()
end

--创建牌
function MyPlayer:createCards( cardTable )
	-- body
	--准备要发的牌
	cardDetectionBigToSmallSort(cardTable)
	self.allCard = {}
	self.allColorCard = {}
	--显示表清空
	self.allViewCard = {}
	for i = tonumber(CARD_VALUE.R2),tonumber(CARD_VALUE.R_WB) do
		--------分值的表---------------------------------------------------------
		if not self.allCard[i] then --每个牌值要一个表
			self.allCard[i] = {}
		end

		------分花色的表--------------------------------------------------------
		if i < tonumber(CARD_VALUE.R_WA) then --大小王不分花色
			if not self.allColorCard[i] then --每个牌值花色要一个表
				self.allColorCard[i] = {}

				for k = tonumber(FOLLOW_TYPE.TYPE_B),tonumber(FOLLOW_TYPE.TYPE_H) do
					if not self.allColorCard[i][k] then
						self.allColorCard[i][k] = {}
					end
				end
			end
		end
	end

	local lastCard = false
	self.dealCardIdx = 0
	self.cardLayer:removeAllChildren()
  	for i = 1,#cardTable do --DISTRIBUTE_CARD_MIN_NUM do
  		local cardNode = Card:create(cardTable[i])
  		if cardNode then
  			cardNode:setVisible(false)
  			self.dealCardIdx = self.dealCardIdx + 1
  			cardNode.createIdx = self.dealCardIdx -- 创建索引 用于区别同花色同大小牌
  			self.cardLayer:addChild(cardNode,i)

  			table.insert(self.allCard[cardNode.val],cardNode)
  			if cardNode.val < tonumber(CARD_VALUE.R_WA) then --大小王不分花色 
  				table.insert(self.allColorCard[cardNode.val][cardNode.color],cardNode)
  			end

  			if not lastCard or lastCard.val ~= cardNode.val then 
  				self.allViewCard[#self.allViewCard + 1] = {}
  			end
  			lastCard = cardNode
  			table.insert(self.allViewCard[#self.allViewCard],cardNode)
  		end
  	end
end

function MyPlayer:findRcicleCardIdx( ... )
	-- body
	local count = 0
	for k,v in pairs(self.allViewCard) do
		local find = false
		for m,n in pairs(v) do
			if n.val == GameModel.nowCardVal and n.color == GameModel.nowCardColor and not n.findByRcicle then
				n.findByRcicle = true
				count = count + m
				find = true
				break
			end
		end

		if find then
			break
		else
			count = count + #v
		end
	end

	return count
end

--删除牌节省内存
function MyPlayer:releaseCards( ... )
	-- body
	self.checkIngCard = {}
	for k,v in pairs(self.checkEdCard) do
		if v.faceImg then
			v.faceImg:setColor(cc.c3b(255,255,255))
		end
	end
	self.checkEdCard = {}
	self.cancleCard = {}
	--删除所有牌
	self.cardLayer:setContentSize(cc.size(0,0))
	self.cardLayer:removeAllChildren()
	self.playcardLayer:removeAllChildren()
	self.tributecardLayer:removeAllChildren()
	self.rciclescardLayer:removeAllChildren()
	-- self.buttomTips:setVisible(false)
	self.rootGP1:setVisible(false)
	GameManageFactory:getCurGameManage():delCancleTrShipLayer()
	--查找表清空
	self.allCard = {}
	self.allColorCard = {}
	self.dealCardEd = false

	--显示表清空
	self.allViewCard = {}
	self.effectiveCards = {}
	self.cardFix = MY_FIX
	self.curCol = 0
	self.lastCard = false
	self.Trusteeship = false

	self:clearTipsInfo()
  	self.stateType = PlayerStateType.None
end

function MyPlayer:findCardNode( playerCardIndex )
	-- body
	local count = 0
	for k,v in pairs(self.allViewCard) do
		if playerCardIndex <= count + #v then --在本表中可以找到
    		return v[playerCardIndex - count],k
    	else
    		count = count + #v
    	end
	end
end

function MyPlayer:showRcircleCard( ... )
	-- body
	self.rciclescardLayer:setScale(0.5)

	local cardNode = Card:create({val = GameModel.nowCardVal,color = GameModel.nowCardColor})
	cardNode:setPlayState()
	local pos = false
	if self.rciclescardLayer:getChildrenCount() <= 0 then
		pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2)
		cardNode:setPosition(pos)
		self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT))
	else
		pos = cc.p(MY_FIX_WEIDTH/2 + 2*MY_FIX_WEIDTH,MY_FIX_HEIGHT/2)
		cardNode:setPosition(pos)
		self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH*3,MY_FIX_HEIGHT))
	end
	self.rciclescardLayer:addChild(cardNode,1)
	self.rciclescardLayer:setPosition(cc.p((screenSize.width - self.rciclescardLayer:getContentSize().width)/2,
				self:getContentSize().height/3))
end

function MyPlayer:deleteRcircleCard( ... )
	-- body
	self.rciclescardLayer:removeAllChildren()
end

--发牌
function MyPlayer:dealCard(node,playerCardIndex)
	-- body
	local cardNode = self:findCardNode(playerCardIndex)
	if cardNode then
		local scale = cardNode:getScale()
		cardNode:setScale(0.5)
		cardNode:beginDeal()
		cardNode.mState = Card_State.State_None --设置没被选中
		cardNode.allLight = false
		cardNode:setPosition(self.cardLayer:convertToNodeSpace(cc.p(node:getPositionX(),node:getPositionY())))
		cardNode:setVisible(true)

		local pos = false
		if self.curCol > 0 then
			if self.lastCard.val == cardNode.val then --同一列
				pos = cc.p(MY_FIX_WEIDTH/2 + (self.curCol - 1)*self.cardFix,MY_FIX_HEIGHT/2 + MY_FIX_UP*self.lastCard.row)
		 		cardNode.col = self.curCol
		 		cardNode.row = self.lastCard.row+1
		 		cardNode:setLocalZOrder(self.lastCard:getLocalZOrder() - 1)
		 		self.lastCard = cardNode
			else
		 		self.curCol = self.curCol + 1
				self.cardLayer:setContentSize(cc.size((self.curCol - 1)*self.cardFix+MY_FIX_WEIDTH,MY_FIX_HEIGHT))
				pos = cc.p(MY_FIX_WEIDTH/2 + (self.curCol - 1)*self.cardFix,MY_FIX_HEIGHT/2)
				cardNode.col = self.curCol
				cardNode.row = 1
				self.lastCard = cardNode
				self.lastCard:setLocalZOrder(self.curCol*100)
			end
		else
			self.curCol = 1
			self.cardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT))
			pos = cc.p(MY_FIX_WEIDTH/2 + (self.curCol - 1)*self.cardFix,MY_FIX_HEIGHT/2)
			cardNode.col = self.curCol
			cardNode.row = 1
			self.lastCard = cardNode
			self.lastCard:setLocalZOrder(self.curCol*100)
		end

		cardNode:runAction(cc.Spawn:create(cc.Sequence:create(cc.DelayTime:create(0.03),cc.ScaleTo:create(0.03,scale)),
			cc.Sequence:create(cc.MoveTo:create(0.05,pos),cc.CallFunc:create(function ( ... )
				-- body
				--超过一定宽度就要缩小间距
				if self.curCol > MY_MAX_CARD_COUNT then
					self.cardFix = MY_MAX_CARD_COUNT*MY_FIX/self.curCol
					self:fixCardMove(playerCardIndex)
					self.cardLayer:setContentSize(cc.size((self.curCol-1)*self.cardFix+MY_FIX_WEIDTH,MY_FIX_HEIGHT))
				end

				--让牌居中对齐
				self.cardLayer:setPosition(cc.p((screenSize.width - self.cardLayer:getContentSize().width)/2,
					self.Image_bg:getContentSize().height))
			end)),
			cc.Sequence:create(cc.DelayTime:create(0.02),cc.RotateBy:create(0.01,360)),
			cc.Sequence:create(cc.DelayTime:create(0.015),cc.CallFunc:create(function ( ... )
				-- body
				cardNode:dalayDeal()
			end))))
	end

	--发完牌就可以触摸了
	--重写触摸 截断下层消息
	if playerCardIndex >= DISTRIBUTE_CARD_MAX_NUM/DISTRIBUTE_CARD_PLAYER_NUM then
	    --触摸绑定
	    self.dealCardEd = true
        ----记牌器埋点：发牌完成回调，现在记牌器暂时不需要了，注释by刘龙。
        --MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic:getCardRecorder():onDealCardEnded()
	    if self.stateType == PlayerStateType.PayTribute or 
	    	self.stateType == PlayerStateType.RetTribute then
	   	 	self:setDisableButtonState(true)
			self:setBtnTankState(true)
			self:setAddGoldState(true)
	   	else
	   	 	self:setDisableButtonState(false)
			self:setBtnTankState(false)
			self:setAddGoldState(false)
	   	end

	    self.effectiveCards = {} 
		for k,v in pairs(self.allViewCard) do
			--重新计算每列是否有效无效组成可发送的牌
			local typeCard = CardDetection.detectionType(v)
			table.insert(self.effectiveCards,tonumber(typeCard))
		end

		if not self.listener then
			self.listener = cc.EventListenerTouchOneByOne:create()
		    self.listener:setSwallowTouches(false)
		    self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_BEGAN)
		    self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_MOVED)
		    self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_ENDED)

		    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
		end
	end
end

--发牌移动
function MyPlayer:fixCardMove( idx )
	-- body
	if idx then --一张一张发(用于发牌阶段)
		for i=1,idx do
			local cardNode = self:findCardNode(i)
			if cardNode then
				local x = MY_FIX_WEIDTH/2 + (cardNode.col-1)*self.cardFix
				cardNode:setPositionX(x)
			end
		end
	else -- 整体一起发
		--计算应该排多少列
		local colCount = #self.allViewCard
		if colCount > MY_MAX_CARD_COUNT then
			self.cardFix = MY_MAX_CARD_COUNT*MY_FIX/colCount
		else
			self.cardFix = MY_FIX
		end
		--让牌居中对齐
		self.cardLayer:setContentSize(cc.size((colCount-1)*self.cardFix+MY_FIX_WEIDTH,MY_FIX_HEIGHT))
		self.cardLayer:setPosition(cc.p((screenSize.width - self.cardLayer:getContentSize().width)/2,
					self.Image_bg:getContentSize().height))

		--先计算剩余的牌
		self.effectiveCards = {} 
		self.curCol = 0
		for k,v in pairs(self.allViewCard) do
			--重新计算每列是否有效无效组成可发送的牌
			local typeCard,val = CardDetection.detectionType(v)
			table.insert(self.effectiveCards,tonumber(typeCard))
			self:sortColCard( typeCard,v)
			for m,node in pairs(v) do
				node:setVisible(true)
				node.mState = Card_State.State_None --设置没被选中
				node.faceImg:setColor(cc.c3b(255,255,255))
				node.allLight = false
				node.moveUp = false
				local pos = false
				if self.curCol > 0 then
					if self.lastCard.col == k then --同一列
						pos = cc.p(self.lastCard:getPositionX(),MY_FIX_HEIGHT/2 + MY_FIX_UP*self.lastCard.row)
						node:setPosition(pos)
						node.col = self.curCol
						node.row = self.lastCard.row + 1
				 		node:setLocalZOrder(self.lastCard:getLocalZOrder() - 1)
				 		self.lastCard = node
					else
						pos = cc.p(MY_FIX_WEIDTH/2 + self.curCol*self.cardFix,MY_FIX_HEIGHT/2)
						node:setPosition(pos)
				 		self.curCol = self.curCol + 1
						node.col = self.curCol
						node.row = 1
						self.lastCard = node
						self.lastCard:setLocalZOrder(self.curCol*100)
					end
				else
					pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2)
					node:setPosition(pos)
					self.curCol = 1
					node.col = 1
					node.row = 1
					self.lastCard = node
					self.lastCard:setLocalZOrder(self.curCol*100)
				end
			end
		end

		--触摸绑定
		self.dealCardEd = true
	    self:setDisableButtonState(false)
		self:setBtnTankState(false)
		self:setAddGoldState(false)
		if not self.listener then
			self.listener = cc.EventListenerTouchOneByOne:create()
		    self.listener:setSwallowTouches(false)
		    self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_BEGAN)
		    self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_MOVED)
		    self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_ENDED)

		    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
		end
	end
end

--提示出牌
function MyPlayer:cardTips( tipsType,val,isEnterButton )
	-- body
	if self.upperPlayerType == tonumber(CARD_TYPE.NONE) and self.upperPlayerVal == 0 then
		if not self.haveTips and next(self.tipsProject) == nil then
			self.haveTips = true
			self.tipsProject = CardTips.tipBigCard( self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard )
		end
  	else
		if tipsType == CARD_TYPE.SINGLE then      --单个
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipSignle(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.DOUBLE then  --对
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipDouble(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.TRIPLE then  --三个
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipTriple(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.TRIPLE_AND_DOUBLE then  --三带二
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipThreeAndTwo(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.COMMON_STRAIGHT then  --普通顺子
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipCommonStraight(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.PLATE then  --钢板
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipPlate(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.LINK_DOUBLE then  --连对
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipLinkDouble(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.FOUR_BOMB then    --四炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tip4Bomb(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.FIVE_BOMB then    --五炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tip5Bomb(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.FLUSH_BOMB then   --同花顺
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipColorBomb( self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val )
			end
		elseif tipsType == CARD_TYPE.SIX_BOMB then     --六炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tip6Bomb(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.SEVEN_BOMB then     --七炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tip7Bomb(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.EIGHT_BOMB then     --八炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tip8Bomb(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.NINE_BOMB then     --九炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tip9Bomb(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.TEN_BOMB then     --十炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tip10Bomb(self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,val)
			end
		elseif tipsType == CARD_TYPE.KING_BOMB then     --王炸
			if not self.haveTips and next(self.tipsProject) == nil then
				self.haveTips = true
				self.tipsProject = CardTips.tipKingBomb(self.allCard)
			end
		end
	end

	if isEnterButton then
		if next(self.tipsProject) then
			--清空已选
			for k,v in pairs(self.checkEdCard) do
				v.mState = Card_State.State_None
				v.faceImg:setColor(cc.c3b(255,255,255))
			end
			self.checkEdCard = {}
				
			--找下一个
			if self.tipsIdx < #self.tipsProject then
				self.tipsIdx = self.tipsIdx + 1
			else
				self.tipsIdx = 1
			end

			for k,v in pairs(self.tipsProject[self.tipsIdx]) do
				table.insert(self.checkEdCard,v)
			end

			for k,v in pairs(self.checkEdCard) do
				v.mState = Card_State.State_Checked
				v.faceImg:setColor(CardChooseBlenColor)
			end

    		self:chooseCardMoveUp()

			return true
		else
			self:ToastTips(ToastState.NoPass)
			return false
		end
	else
		if next(self.tipsProject) == nil then
			self:ToastTips(ToastState.NoPass,true)
			self.notPassOther = true
			return false
		end
	end

	return true
end

--提示同花顺
function MyPlayer:cardTipsFlushBomb( ... )
	-- body
	if next(self.tipsFlushBomb) == nil then
		self.tipsFlushBomb = CardTips.tipColorBomb( self.effectiveCards,self.allViewCard,self.allCard,self.allColorCard,0,true )
	end

	if next(self.tipsFlushBomb) then
		for k,v in pairs(self.checkEdCard) do
			v.mState = Card_State.State_None
			v.faceImg:setColor(cc.c3b(255,255,255))
		end
		self.checkEdCard = {}
		
		if self.tipsIdx < #self.tipsFlushBomb then
			self.tipsIdx = self.tipsIdx + 1
		else
			self.tipsIdx = 1
		end
		for k,v in pairs(self.tipsFlushBomb[self.tipsIdx]) do
			table.insert(self.checkEdCard,v)
		end

		for k,v in pairs(self.checkEdCard) do
			v.mState = Card_State.State_Checked
			v.faceImg:setColor(CardChooseBlenColor)
		end
	else
		self:ToastTips(ToastState.NoColorBomb)
	end
end
--理成列
function MyPlayer:changeToSingleCol( ... )
	-- body
	--选中完成的牌
	--排序
	if next(self.checkEdCard) == nil then
		return
	end
	for k,v in pairs(self.checkEdCard) do -- 遍历已选表
		--从剩余牌移除选中牌
		for i=#self.allViewCard,1,-1 do
			local find = false
			local nodeTable = self.allViewCard[i]
			for m,n in pairs(nodeTable) do
				if v == n then --找到有被选中
					--把选中的数据移除移表
					table.remove(nodeTable,m)
					find = true
					break
				end
			end

			if next(nodeTable) == nil then
				table.remove(self.allViewCard,i)
			end

			if find then
				break
			end
		end
	end

	--牌型检测后排序
	local typeCard,val = CardDetection.detectionType(self.checkEdCard)

	if next(self.allViewCard) == nil then
		table.insert(self.allViewCard,self.checkEdCard)
	else
		if tonumber(typeCard) < CARD_TYPE.FOUR_BOMB then --不是炸弹 同花顺直接排右边
			table.insert(self.allViewCard,self.checkEdCard)
		else
			table.insert(self.allViewCard,1,self.checkEdCard)
		end
	end

	--清空提示
	for k,v in pairs(self.checkEdCard) do
		v.mState = Card_State.State_None
		v.faceImg:setColor(cc.c3b(255,255,255))
	end
	self.checkEdCard = {}
	self.tipsProject = {}
	self.tipsIdx = 0

	self:fixCardMove()
end

----------------------------------------------------
--触摸事件
----------------------------------------------------
function MyPlayer:onTouchEvent(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
    	self.checkIngCard = {}
    	self.cancleCard = {}

    	if self.TouchCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.TouchCardScriptFuncId)
			self.TouchCardScriptFuncId = false
	  	end
	  	--发牌完成，不是托管才能触摸
	  	if self.dealCardEd and not self.Trusteeship and not self:chooseCard(touch) and not self.TouchCardScriptFuncId then
	  		self.TouchCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.seeDesktop),1, false)
		end
        return true
    elseif event:getEventCode() == cc.EventCode.MOVED then
    	--发牌完成才能触摸
    	if self.dealCardEd and not self.Trusteeship then
    		self:chooseCard(touch)
    	end
    elseif event:getEventCode() == cc.EventCode.ENDED then
    	--查看桌面
		self.Rank_info:setVisible(false)
	    GameManageFactory:getCurGameManage():closePlayerInfo()

    	if self.TouchCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.TouchCardScriptFuncId)
			self.TouchCardScriptFuncId = false
	  	end

	  	for m,n in pairs(self.allViewCard) do
			for k,v in pairs(n) do
				v:setOpacity(255)
			end
		end

		--瞎点瞬间又牌被托管打出去 
		self:deteleNullCard(self.checkIngCard)
		self:deteleNullCard(self.cancleCard)

    	if next(self.checkIngCard) == nil and next(self.cancleCard) == nil then --本次没有选到一个
    		if self.isGetPlayCard then
	    		for k,v in pairs(self.checkEdCard) do -- 将正在选中的放在已选表内
	    			if isLuaNodeValid(v) then
			    		v.faceImg:setColor(cc.c3b(255,255,255))
			    		v.mState = Card_State.State_None
						v.allLight = false
					end
		    	end
		    	self.checkEdCard = {}
		    end

	    	--右上角菜单还原
	    	GameManageFactory:getCurGameManage():resetMenuMain()
	    	--清空牌提示信息
	    	self:clearTipsInfo()

	    	--检测到打不过上家牌 就不出
	    	if self.notPassOther then
	  			self:donotPlayCard()
				self.notPassOther = false
				if self.NotPlayerCardScriptFuncId then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.NotPlayerCardScriptFuncId)
					self.NotPlayerCardScriptFuncId = false
				end
	  		end
    	else
			playSoundEffect("sound/effect/xuanpai")
    		if GameModel.mChooseSignle or 
    			self.stateType == PlayerStateType.PayTribute or
    			self.stateType == PlayerStateType.RetTribute then --单选
    			for k,v in pairs(self.checkIngCard) do -- 将正在选中的放在已选表内
		    		v.mState = Card_State.State_Checked
		    		v.faceImg:setColor(CardChooseBlenColor)
		    		table.insert(self.checkEdCard,v)
			    end
		    	self.checkIngCard = {}

	    		--取消选中恢复
		    	for k,v in pairs(self.cancleCard) do
		    		for m,n in pairs(self.checkEdCard) do -- 将正在选中的放在已选表内
		    			if v == n then
				    		n.faceImg:setColor(cc.c3b(255,255,255))
				    		n.mState = Card_State.State_None
				    		n.allLight = false
				    		removeItem(self.checkEdCard,n)
				    	end
			    	end
		    	end
		    	self.cancleCard = {}
		    else
		    	if #self.checkIngCard == 1 and #self.cancleCard == 1 then 
		    		--直接添加checkIngCard
		    		local  node  = self.checkIngCard[1]
		    		node.mState = Card_State.State_Checked
		    		node.faceImg:setColor(CardChooseBlenColor)
		    		table.insert(self.checkEdCard,node)
		    		local allChoose = true
		    		for m,n in pairs(self.allViewCard[node.col]) do
		    			if n.mState ~= Card_State.State_Checked then --找到没有被选中
		    				allChoose = false
		    				break
		    			end
		    		end
	    			--如果全选 并且多于1个 又要设置亮标志
		    		if allChoose and #self.allViewCard[node.col] > 1 then
		    			for m,n in pairs(self.allViewCard[node.col]) do
			    			n.allLight = true
			    		end
			    	end
			    	self.checkIngCard = {}

			    	--直接删除cancleCard
			    	local  node = self.cancleCard[1]
			    	node.faceImg:setColor(cc.c3b(255,255,255))
				    node.mState = Card_State.State_None
				    removeItem(self.checkEdCard,node)
				    for m,n in pairs(self.allViewCard[node.col]) do
		    			n.allLight = false
		    		end
			    	self.cancleCard = {}
		    	else
		    		if #self.cancleCard == 1 then
			    		--找到是否有没被选中
			    		local idx = tonumber(self.cancleCard[1].col)
						local allChoose = true
			    		for m,n in pairs(self.allViewCard[idx]) do
			    			if n.mState ~= Card_State.State_Checked then 
			    				allChoose = false
			    				break
			    			end
			    		end

						--全选中 就只选中当前的 其他全设置未选
			    		if allChoose and #self.allViewCard[idx] > 1 then
			    			-- print("全选中 就只选中当前的 其他全设置未选")
			    			for m,n in pairs(self.allViewCard[idx]) do
								n.allLight = false
				    			if n ~= self.cancleCard[1] then --找到是否有被选中
				    				n.faceImg:setColor(cc.c3b(255,255,255))
				    				n.mState = Card_State.State_None
				    				removeItem(self.checkEdCard,n)
				    			end
				    		end
				    	else
				    		self.cancleCard[1].faceImg:setColor(cc.c3b(255,255,255))
				    		self.cancleCard[1].mState = Card_State.State_None
				    		removeItem(self.checkEdCard,self.cancleCard[1])
				    	end
			    	else
				    	--取消选中恢复
				    	for k,v in pairs(self.cancleCard) do
				    		for m,n in pairs(self.checkEdCard) do -- 将正在选中的放在已选表内
				    			if v == n then
						    		n.faceImg:setColor(cc.c3b(255,255,255))
						    		n.mState = Card_State.State_None
						    		n.allLight = false
						    		removeItem(self.checkEdCard,n)
						    	end
					    	end
				    	end
				    end
			    	self.cancleCard = {}

			    	if #self.checkIngCard == 1 then --单选就特殊处理(如果这一列没有一个选中 当选中一个 整列都选中)
		    			local find = false
		    			local idx = tonumber(self.checkIngCard[1].col)
			    		for m,n in pairs(self.allViewCard[idx]) do
			    			if n.mState == Card_State.State_Checked then --找到是否有被选中
			    				find = true
			    				break
			    			end
			    		end
		    			
			    		if not find then --没有一个选中 就全选
			    			-- print("--没有一个选中 就全选")
			    			local  node = self.checkIngCard[1]

			    			local addAllCol = function ( ... )
			    				-- body
			    				for m,n in pairs(self.allViewCard[idx]) do
					    			n.mState = Card_State.State_Checked
				    				if #self.allViewCard[idx] > 1 then
					    				n.allLight = true
					    			end
						    		n.faceImg:setColor(CardChooseBlenColor)
						    		table.insert(self.checkEdCard,n)
					    		end
			    			end


			    			local addTipsCol = function ( ... )
			    				-- body
			    				local  node  = self.checkIngCard[1]
					    		node.mState = Card_State.State_Checked
					    		node.faceImg:setColor(CardChooseBlenColor)
					    		table.insert(self.checkEdCard,node)

					    		local count = tonumber(self.upperPlayerType)-2
			    				for m,n in pairs(self.allViewCard[idx]) do
			    					if count > 0  and n ~= node then
			    						count = count - 1
						    			n.mState = Card_State.State_Checked
							    		n.faceImg:setColor(CardChooseBlenColor)
							    		table.insert(self.checkEdCard,n)
							    	end
					    		end
			    			end

			    			if self.rootGP1:isVisible() then
			    				if self.upperPlayerType == CARD_TYPE.SINGLE then
			    					if self.effectiveCards[idx] == tonumber(CARD_TYPE.DOUBLE) or
								 		self.effectiveCards[idx] == tonumber(CARD_TYPE.TRIPLE)  then 
								 		if self.upperPlayerVal == tonumber(CARD_VALUE.R_WB) then--大王 没得选
					    					addAllCol()
										elseif self.upperPlayerVal == GameModel.nowCardVal then --本次打的牌 只有大小王要的起
											if node.val >= tonumber(CARD_VALUE.R_WA) then
												addTipsCol()
											else
					    						addAllCol()
											end
										else
											if node.val > self.upperPlayerVal then
												addTipsCol()
											elseif node.val == GameModel.nowCardVal and
												self.upperPlayerVal < tonumber(CARD_VALUE.R_WA) then
												addTipsCol()
											else
					    						addAllCol()
											end
										end
									else
			    						addAllCol()
									end
		    					elseif self.upperPlayerType == CARD_TYPE.DOUBLE then
		    						if 	self.effectiveCards[idx] == tonumber(CARD_TYPE.TRIPLE)  then 
										if self.upperPlayerVal == GameModel.nowCardVal or 
											self.upperPlayerVal > tonumber(CARD_VALUE.R_WA) then --本次打的牌 只有大小王要的起
					    					addAllCol()
										else
											if node.val > self.upperPlayerVal then
												addTipsCol()
											elseif node.val == GameModel.nowCardVal and
												self.upperPlayerVal < tonumber(CARD_VALUE.R_WA) then
												addTipsCol()
											else
					    						addAllCol()
											end
										end 
									else
			    						addAllCol()
									end
		    					else
			    					addAllCol()
								end
			    			else
			    				addAllCol()
			    			end
				    	else
				    		--直接添加
				    		local  node  = self.checkIngCard[1]
				    		node.mState = Card_State.State_Checked
				    		node.faceImg:setColor(CardChooseBlenColor)
				    		table.insert(self.checkEdCard,node)

				    		local allChoose = true
				    		for m,n in pairs(self.allViewCard[idx]) do
				    			if n.mState ~= Card_State.State_Checked then --找到没有被选中
				    				allChoose = false
				    				break
				    			end
				    		end
			    			--如果全选 并且多于1个 又要设置亮标志
				    		if allChoose and #self.allViewCard[idx] > 1 then
				    			for m,n in pairs(self.allViewCard[idx]) do
					    			n.allLight = true
					    		end
					    	end
				    	end
		    		else
			    		for k,v in pairs(self.checkIngCard) do -- 将正在选中的放在已选表内
				    		v.mState = Card_State.State_Checked
				    		v.faceImg:setColor(CardChooseBlenColor)
				    		table.insert(self.checkEdCard,v)

				    		--如果全选中
					    	local allChoose = true
				    		for m,n in pairs(self.allViewCard[v.col]) do
				    			if n.mState ~= Card_State.State_Checked then --找到是否有被选中
				    				allChoose = false
				    				break
				    			end
				    		end
				    		if allChoose and #self.allViewCard[v.col] > 1 then
				    			for m,n in pairs(self.allViewCard[v.col]) do
				    				n.allLight = true
					    		end
					    	end
				    	end
				    end
			    	self.checkIngCard = {}
		    	end
		    end
    	end

    	self:chooseCardMoveUp()
    end
end

function MyPlayer:chooseCardMoveUp( ... )
	-- body
	--牌间隔
	for k,v in pairs(self.allViewCard) do
		local find = false
		for m,n in pairs(v) do
			if findItem(self.checkEdCard,n) then
				find = true
				break
			end
		end

		if find then
			if not v[1].moveUp then
				local typeCard,val = CardDetection.detectionType(v)
				self:sortColCard( typeCard,v)
				for m,n in pairs(v) do
					n:setLocalZOrder(k*100 -m)
	    			n:setPosition(cc.p(n:getPositionX(),MY_FIX_HEIGHT/2 + (m-1)*(MY_FIX_UP_EXPAND)))
	    			n.moveUp = true
	    		end
	    	end
    	else
    		if v[1].moveUp then
    			local typeCard,val = CardDetection.detectionType(v)
				self:sortColCard( typeCard,v)
	    		for m,n in pairs(v) do
					n:setLocalZOrder(k*100 -m)
	    			n:setPosition(cc.p(n:getPositionX(),MY_FIX_HEIGHT/2 + (m-1)*(MY_FIX_UP)))
	    			n.moveUp = false
	    		end
	    	end
		end
	end
end

function MyPlayer:sortColCard( typeCard,cards )
	-- body
	local function sortByCreateIdx( cardList )
		-- body
		table.sort( cardList, function ( a,b )
			-- body
			if a.color < b.color then --黑梅方红
				return true
			elseif a.color > b.color then
				return false
			else
				return a.createIdx < b.createIdx
			end 
		end )
	end

	if typeCard == CARD_TYPE.NONE or
		typeCard == CARD_TYPE.DOUBLE or  
		typeCard == CARD_TYPE.TRIPLE or  
		typeCard == CARD_TYPE.FOUR_BOMB or  
		typeCard == CARD_TYPE.FIVE_BOMB or  
		typeCard == CARD_TYPE.SIX_BOMB or  
		typeCard == CARD_TYPE.SEVEN_BOMB or  
		typeCard == CARD_TYPE.EIGHT_BOMB or  
		typeCard == CARD_TYPE.NINE_BOMB or  
		typeCard == CARD_TYPE.TEN_BOMB then --不是炸弹 同花顺直接排右边
		cardDetectionSmallToBigSort(cards)
	elseif typeCard == CARD_TYPE.COMMON_STRAIGHT or
			typeCard == CARD_TYPE.FLUSH_BOMB then
		local cardTable = {} 
		for i=#cards,1,-1 do
			table.insert(cardTable,cards[i])
		end
		CloneTable(cardTable,cards)
	elseif	typeCard == CARD_TYPE.PLATE or
			typeCard == CARD_TYPE.KING_BOMB then
		local cardTable1 = {} 
		local count = #cards
		for i=count/2+1,count do
			table.insert(cardTable1,cards[i])
		end
		sortByCreateIdx(cardTable1)

		local cardTable2 = {} 
		for i=1,count/2 do
			table.insert(cardTable2,cards[i])
		end
		sortByCreateIdx(cardTable2)

		local allCardTable = {}
		for k,v in pairs(cardTable1) do
			table.insert(allCardTable,v)
		end

		for k,v in pairs(cardTable2) do
			table.insert(allCardTable,v)
		end
		CloneTable(allCardTable,cards)
	elseif typeCard == CARD_TYPE.LINK_DOUBLE then
		local cardTable1 = {} 
		for i=5,6 do
			table.insert(cardTable1,cards[i])
		end
		sortByCreateIdx(cardTable1)

		local cardTable2 = {}
		for i=3,4 do
			table.insert(cardTable2,cards[i])
		end
		sortByCreateIdx(cardTable2)

		local cardTable3 = {}
		for i=1,2 do
			table.insert(cardTable3,cards[i])
		end
		sortByCreateIdx(cardTable3)

		local allCardTable = {}
		for k,v in pairs(cardTable1) do
			table.insert(allCardTable,v)
		end

		for k,v in pairs(cardTable2) do
			table.insert(allCardTable,v)
		end

		for k,v in pairs(cardTable3) do
			table.insert(allCardTable,v)
		end
		CloneTable(allCardTable,cards)
	elseif typeCard == CARD_TYPE.TRIPLE_AND_DOUBLE then
		local cardTable1 = {} 
		for i=1,3 do
			table.insert(cardTable1,cards[i])
		end
		sortByCreateIdx(cardTable1)

		local cardTable2 = {}
		for i=4,5 do
			table.insert(cardTable2,cards[i])
		end
		sortByCreateIdx(cardTable2)

		local allCardTable = {}
		for k,v in pairs(cardTable1) do
			table.insert(allCardTable,v)
		end

		for k,v in pairs(cardTable2) do
			table.insert(allCardTable,v)
		end

		CloneTable(allCardTable,cards)
	end
end
--查看牌桌
function MyPlayer:seeDesktop( ... )
	-- body
	for m,n in pairs(self.allViewCard) do
		for k,v in pairs(n) do
			v:setOpacity(50)
		end
	end

	if self.TouchCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.TouchCardScriptFuncId)
		self.TouchCardScriptFuncId = false
  	end
end

--点击选中
function MyPlayer:chooseCard( touch )
	-- body
	for m,n in pairs(self.allViewCard) do
		for k,v in pairs(n) do
			local cardState = false
			if v.row == 1 then --第一排
				if v.col == self.curCol then --最后一列
					cardState = Card_Check_Size.all
				else
					cardState = Card_Check_Size.half
				end
			else
				--下列存在
				if self.allViewCard[v.col+1] and #self.allViewCard[v.col+1] >= v.row then
					cardState = Card_Check_Size.halpUp
				else
					cardState = Card_Check_Size.up
				end
			end

    		local check = v:isContainsTouch(touch,cardState,self.cardFix)
    		if check then
    			if v.mState == Card_State.State_None then
    				insertItem(self.checkIngCard,v)
    				v.faceImg:setColor(CardChooseBlenColor)
    			elseif v.mState == Card_State.State_Checked then
    				if GameModel.mChooseSignle or 
    					self.stateType == PlayerStateType.PayTribute or
    					self.stateType == PlayerStateType.RetTribute then --单选
	    				for k,v in pairs(self.checkIngCard) do -- 将正在选中的放在已选表内
				    		v.mState = Card_State.State_Checked
				    		v.faceImg:setColor(CardChooseBlenColor)
				    		table.insert(self.checkEdCard,v)
					    end
			    		self.checkIngCard = {}

			    		--取消选中恢复
				    	for k,v in pairs(self.cancleCard) do
				    		for m,n in pairs(self.checkEdCard) do -- 将正在选中的放在已选表内
				    			if v == n then
						    		n.faceImg:setColor(cc.c3b(255,255,255))
						    		n.mState = Card_State.State_None
						    		n.allLight = false
						    		removeItem(self.checkEdCard,n)
						    	end
					    	end
				    	end
				    	self.cancleCard = {}
		    			insertItem(self.cancleCard,v)
			    		v.faceImg:setColor(cc.c3b(255,255,255))
		    		else
		    			insertItem(self.cancleCard,v)
		    			if #self.cancleCard > 1 then
    						for m,n in pairs(self.cancleCard) do
    							if n.allLight then
		    						for x,y in pairs(self.allViewCard[n.col]) do
				    					if n == y then
					    					n.faceImg:setColor(cc.c3b(255,255,255))
						    			end
						    			y.allLight = false
						    		end
						    	else
						    		n.faceImg:setColor(cc.c3b(255,255,255))
					    		end
    						end
	    				end

		    			if v.allLight  then 
	    					if #self.cancleCard > 1 then
			    				for m,n in pairs(self.allViewCard[v.col]) do
			    					if n == v then
				    					n.faceImg:setColor(cc.c3b(255,255,255))
					    			end
					    			n.allLight = false
					    		end
					    	end
		    			end
		    		end 
    			end

    			return true
    		end
		end
	end

	return false
end

function MyPlayer:setMatchInfo( info )
	-- body
	--暂时缓存下信息 下次设置
	self.matchInfo = info
	self:setMatchRank(info)
	self.Text_Stage:setString("")
	self.Text_Stage:removeAllChildren()
	self.Text_Stage:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_myplayer_set'),
		info.SetNo,info.TotalSet,info.PlayNo,info.TotalPlay),
			self.Text_Stage:getFontSize(),self.Text_Stage:getTextColor()))

	self.Text_Promotion:setString("")
	self.Text_Promotion:removeAllChildren()

	if info.SetNo < info.TotalSet then
		if GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_SINGLE then
			self.Text_Promotion:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_myplayer_rank'),info.upgradeInfo),
				self.Text_Promotion:getFontSize(),self.Text_Promotion:getTextColor()))
		elseif GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_MUTIPLE then
			self.Text_Promotion:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_myplayer_rank_deque'),info.upgradeInfo/2),
				self.Text_Promotion:getFontSize(),self.Text_Promotion:getTextColor()))
		end
	else
		self.Text_Promotion:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_myplayer_endSet')),
			self.Text_Promotion:getFontSize(),self.Text_Promotion:getTextColor()))
	end
end

function MyPlayer:setMatchRank( info )
	-- body
	if self.matchInfo then
		self.matchInfo.MRanking = info.MRanking
		self.matchInfo.TotalNumber = info.TotalNumber
	end

	if GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_SINGLE then
		self.Text_Rank:setString(info.MRanking.."/"..info.TotalNumber) --名次
	elseif GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_MUTIPLE then
		self.Text_Rank:setString(info.MRanking.."/"..info.TotalNumber/2) --名次
	end
end

function MyPlayer:teamTypeChange( ... )
	-- body
	if self.matchInfo then
		self:setMatchInfo(self.matchInfo)
	end
end

--清空提示信息
function MyPlayer:clearTipsInfo()
	self.tipsProject = {}
	self.tipsFlushBomb = {}
	self.haveTips = false
	self.tipsIdx = 0
end

function MyPlayer:deteleNullCard( list )
	-- body
	--边选择边有牌已经打出去
	for i=#list,1,-1 do
		if tolua.isnull(list[i]) then
			table.remove(list,i)
		end
	end
end

return MyPlayer
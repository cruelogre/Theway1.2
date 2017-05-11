-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  己玩家
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullMyPlayer = class("BullMyPlayer",cc.Layer,require("packages.mvc.Mediator"))

local BullCard = require("BullFighting.mediator.view.BullCard")
local BullProgressTimer = require("BullFighting.mediator.view.BullProgressTimer")
local Toast = require("app.views.common.Toast")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local BullfightPokerUtil = require("BullFighting.util.BullfightPokerUtil")
require("hall.util.RoomChatManager")

function BullMyPlayer:ctor()
	-- body
	self:init()
end

--初始化
function BullMyPlayer:init()
	-- body
	self.logTag = "BullMyPlayer.lua"

	local playerUi = require("csb.bullfighting.PlayBottomLayer"):create()
	local rootPlay = playerUi["root"]
	self.rootPlayAni = playerUi["animation"]
	rootPlay:runAction(self.rootPlayAni)
	self:addChild(rootPlay)
	--玩家头像一大堆信息
	self.Image_bg = rootPlay:getChildByName("Image_bg")
	rootPlay:setPosition(cc.p(self.Image_bg:getContentSize().width/2,self.Image_bg:getContentSize().height/2))
	self.Image_gold = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_gold") 
	self.Text_name = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_name") --昵称
	self.Image_kuang = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_kuang") --庄家框框
	self.Image_kuang:setVisible(false)
	self.Text_gold = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_gold") --金币显示label
	self.Image_headbg = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_headbg")
	local playerHeadUi = require("csb.bullfighting.HeadNode"):create()
	self.rootPlayerHeadUi = playerHeadUi["root"]
  	self.Image_headbg:addChild(self.rootPlayerHeadUi)
  	self.rootPlayerHeadUi:setPosition(cc.p(self.Image_headbg:getContentSize().width/2,self.Image_headbg:getContentSize().height/2))
  	self.rootPlayerHeadUiAni = playerHeadUi["animation"]
	self.rootPlayerHeadUi:runAction(self.rootPlayerHeadUiAni)

	self.ShopBtn = rootPlay:getChildByName("shop")
	self.changeCardBtn = rootPlay:getChildByName("changeCard")
	self.chatBtn = rootPlay:getChildByName("chat")
	self.ShopBtn:addClickEventListener(handler(self,self.btnClick))
	self.changeCardBtn:addClickEventListener(handler(self,self.btnClick))
	self.chatBtn:addClickEventListener(handler(self,self.btnClick))
	self:setChatButtonState(true)
	self.beiandget = rootPlay:getChildByName("beiandget")
	if cc.Director:getInstance():getContentScaleFactor() == 1 then
		self.beiandget:setProperty([[90]],"bullfighting/wenzishu2.png",56,55,"0")
	else
		self.beiandget:setProperty([[90]],"bullfighting/wenzishu2.png",38,37,"0")
	end
	self.beiandget:setVisible(false)
	local function checkInfo( ... )
		-- body
		playSoundEffect("sound/effect/anniu")
		if self.BullInfo then
			BullFightingManage:requestUserInfo(self.BullInfo.UserId)
  		end
	end
	self.Image_headbg:addClickEventListener(checkInfo)
	self.headImgMachine = self.rootPlayerHeadUi:getChildByName("Image_head") --头像
	self.headImgMachine:setLocalZOrder(0)
	self.Image_head_mark = self.rootPlayerHeadUi:getChildByName("Image_head_mark") --名次
	self.Image_head_mark:setLocalZOrder(2)
	self.Image_head_mark:setVisible(false)
	self.sidelines = self.rootPlayerHeadUi:getChildByName("sidelines") --旁观
	self.sidelines:setLocalZOrder(2)
	self.sidelines:setVisible(false)
  	self.Button_add = ccui.Helper:seekWidgetByName(self.Image_bg,"Button_add") --加金币
  	self.Button_add:addClickEventListener(handler(self,self.btnClick))

  	--加倍按钮
	local addDouble = require("csb.bullfighting.addDouble"):create()
	self.rootAddDouble = addDouble["root"]
	self.rootAddDouble:setVisible(false)
	self.rootAddDouble:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height*24/48))
  	self:addChild(self.rootAddDouble)
  	self.Button_1 = self.rootAddDouble:getChildByName("Button_1") --不出
  	self.Button_2 = self.rootAddDouble:getChildByName("Button_2") --不出
  	self.Button_3 = self.rootAddDouble:getChildByName("Button_3") --不出
  	self.Button_4 = self.rootAddDouble:getChildByName("Button_4") --不出
  	self.ButtonRate_1 = self.rootAddDouble:getChildByName("Button_1"):getChildByName("count") --倍数
  	self.ButtonRate_2 = self.rootAddDouble:getChildByName("Button_2"):getChildByName("count") --倍数
  	self.ButtonRate_3 = self.rootAddDouble:getChildByName("Button_3"):getChildByName("count") --倍数
  	self.ButtonRate_4 = self.rootAddDouble:getChildByName("Button_4"):getChildByName("count") --倍数
	
	if cc.Director:getInstance():getContentScaleFactor() == 1 then
		self.ButtonRate_1:setProperty([[]],"bullfighting/wenzishu1.png",38,54,"0")
		self.ButtonRate_2:setProperty([[]],"bullfighting/wenzishu1.png",38,54,"0")
		self.ButtonRate_3:setProperty([[]],"bullfighting/wenzishu1.png",38,54,"0")
		self.ButtonRate_4:setProperty([[]],"bullfighting/wenzishu1.png",38,54,"0")
	else
		self.ButtonRate_1:setProperty([[]],"bullfighting/wenzishu1.png",25,36,"0")
		self.ButtonRate_2:setProperty([[]],"bullfighting/wenzishu1.png",25,36,"0")
		self.ButtonRate_3:setProperty([[]],"bullfighting/wenzishu1.png",25,36,"0")
		self.ButtonRate_4:setProperty([[]],"bullfighting/wenzishu1.png",25,36,"0")
	end

  	local function chooseClick( ref )
  		-- body
		playSoundEffect("sound/effect/bullfight/multiplechoose")

  		if ref == self.Button_1 then
			self:requestMultiple(self.BetScore[1])
		elseif ref == self.Button_2 then
			self:requestMultiple(self.BetScore[2])
		elseif ref == self.Button_3 then
			self:requestMultiple(self.BetScore[3])
		elseif ref == self.Button_4 then --下注
			self:requestMultiple(self.BetScore[4])
		end
  	end
  	self.Button_1:addClickEventListener(chooseClick)
  	self.Button_2:addClickEventListener(chooseClick)
  	self.Button_3:addClickEventListener(chooseClick)
  	self.Button_4:addClickEventListener(chooseClick)

  	--算牛按钮
	local Calculation = require("csb.bullfighting.Calculation"):create()
	self.rootCalculation = Calculation["root"]
	self.rootCalculation:setVisible(false)
	self.rootCalculation:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height*24/48))
  	self:addChild(self.rootCalculation)
  	self.CalculationKuan = {}
  	for i=1,4 do
  		local node = self.rootCalculation:getChildByName("CalculationKuan_"..i):getChildByName("shu") --数字1
		if cc.Director:getInstance():getContentScaleFactor() == 1 then
			node:setProperty([[]],"bullfighting/wenzishu4.png",40,53,"0")
		else
			node:setProperty([[]],"bullfighting/wenzishu4.png",27,36,"0")
		end

  		table.insert(self.CalculationKuan,node)
  	end
  	self.CalculationKuan_Buttontip = self.rootCalculation:getChildByName("Buttontip") --提示
  	self.CalculationKuan_Buttontip:addClickEventListener(handler(self,self.btnClick))
  	self.CalculationKuan_ButtontipCount = self.CalculationKuan_Buttontip:getChildByName("Text_1")
  	self.CalculationKuan_Buttontip:addClickEventListener(handler(self,self.btnClick))
  	self.tipsPao = self.rootCalculation:getChildByName("tipsPao") --提示

  	--算牛按钮
	local sendNiu = require("csb.bullfighting.sendNiu"):create()
	self.rootSendNiu = sendNiu["root"]
	self.rootSendNiu:setVisible(false)
	self.rootSendNiu:setPosition(cc.p(self:getContentSize().width*0.9,self.Image_bg:getContentSize().height*2.5))
  	self:addChild(self.rootSendNiu)
  	self.Button_SendNiuhave = self.rootSendNiu:getChildByName("Button_have")--有牛
  	self.Button_SendNiuno = self.rootSendNiu:getChildByName("Button_no") --没牛
  	self.Button_SendNiuhave:addClickEventListener(handler(self,self.btnClick))
  	self.Button_SendNiuno:addClickEventListener(handler(self,self.btnClick))

  	--进度条
  	self.bullProgressTimer = BullProgressTimer:create(BullCaculateCardTime)
	self:addChild(self.bullProgressTimer)
	self.bullProgressTimer:setVisible(false)
	self.bullProgressTimer:setplaySoundEffect(false)

	--状态
	self.stateImg = ccui.ImageView:create("choosebei.png",UI_TEX_TYPE_PLIST)
  	self.stateImg:ignoreContentAdaptWithSize(true)
  	self.stateImg:setVisible(false)
  	self:addChild(self.stateImg)

  	--玩家状态
  	self.Gender = GenderType.male

  	--用于牌面显示的牌
	self.allViewCard = {}
  	--我的牌
	self.cardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self.cardLayer:setPosition(cc.p(screenSize.width/2,self.Image_bg:getContentSize().height))
	self:addChild(self.cardLayer)
	--上次发的牌
	self.dealCardEd = false --发完牌
	self.dealCardIndx = 0
	self.overTurnCardIndx = 0

	--正选中的牌
	self.checkIngCard = {}
	self.cancleCard = {}
	--选中完成的牌
	self.checkEdCard = {}

	self.calculationVal = 0

	self.haveSetCurState = false

	self:registerScriptHandler(handler(self,self.onNodeEvent))
	
	if not self.listener then
		self.listener = cc.EventListenerTouchOneByOne:create()
		self.listener:setSwallowTouches(false)
		self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_BEGAN)
		self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_MOVED)
		self.listener:registerScriptHandler(handler(self,self.onTouchEvent),cc.Handler.EVENT_TOUCH_ENDED)

		self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
	end

	--最开始渲染出头像
	self.Gender = DataCenter:getUserdataInstance():getValueByKey("gender")
	self:addHead(DataCenter:getUserdataInstance():getHeadIcon())
	self.Text_name:setString(DataCenter:getUserdataInstance():getValueByKey("nickname") or "") --昵称

	RoomChatManager:setCurGameID(wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID)
	BullFightingManage.BullFoldMenuLayer:addChatNode(BullSeverPlayerType.SelfPlayerSeat,DataCenter:getUserdataInstance():getValueByKey("userid"),
		cc.p(self:getHeadPos().x,self:getHeadPos().y+self.Image_headbg:getContentSize().height/2),
		cc.p(self:getHeadPos().x,self:getHeadPos().y+self.Image_headbg:getContentSize().height*1.2),false,false)
end

function BullMyPlayer:EnterBullGame( info )
	-- body
	self.BullInfo = clone(info)
	self.UserId = self.BullInfo.UserId --用户id
	--设置个人信息
	self:setHeadInfo()
	--设置当前状态
	self:setCurState()
end

--开局
function BullMyPlayer:resetGame( )
	-- body
	wwlog(self.logTag,"重新开始 清理所有")
	self.haveSetCurState = false
  	self:releaseCards()

	self.rootSendNiu:setVisible(false)
	self.rootCalculation:setVisible(false)
	self.rootAddDouble:setVisible(false)
	self.bullProgressTimer:setVisible(false)
	self.bullProgressTimer:setplaySoundEffect(false)

	self.Image_kuang:setVisible(false)
	self.Image_head_mark:setVisible(false)
	self.beiandget:setVisible(false)
	self.stateImg:setVisible(false)

	if self.paoScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.paoScriptFuncId)
		self.paoScriptFuncId = false
	end

	if self.visibleCardScriptHander then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.visibleCardScriptHander)
		self.visibleCardScriptHander = false
	end
end

--继续游戏
function BullMyPlayer:continueGame( ... )
	-- body
	wwlog(self.logTag,"继续游戏")
	if not self.visibleCardScriptHander then
		self.visibleCardScriptHander = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
			-- body
			self:resetGame()
			BullFightingManage.gameState = BullGameStateType.waitBegin

			--从新开始
			if #BullFightingManage.playersData <= 1 then
				self:setWaitState(BullWaitState.BullSettlment,0)
				BullFightingManage.BullDealCardLayer:setMatchingVisible(true)
			else
				self:setWaitState( BullWaitState.BullWaitBegin, self.CreateGameTimeOut)
			end 

			--可以删除待删除玩家了
			BullFightingManage:delAllAddedPlayer()
			wwlog(self.logTag,"结算 结束",os.date("[%Y-%m-%d %H:%M:%S] ", os.time())) 
			if self.visibleCardScriptHander then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.visibleCardScriptHander)
				self.visibleCardScriptHander = false
			end
		end, 3, false)
	end

	self:sendEnterGame()
end

--请求进入随机、看牌场房间
function BullMyPlayer:sendEnterGame( ... )
	-- body
	local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
    local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)
    BullFightingSceneProxy:requestLobbyActionHandle(BullFightingSceneController.GameZoneID, 15)  --请求进入随机、看牌场房间
end

--onEnter onExit
function BullMyPlayer:onNodeEvent( event )
	-- body
	if event == "enter" then
		self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
    elseif event == "exit" then
    	if self.paoScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.paoScriptFuncId)
			self.paoScriptFuncId = false
		end

		if self.visibleCardScriptHander then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.visibleCardScriptHander)
			self.visibleCardScriptHander = false
		end

		self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
		self:getEventDispatcher():removeEventListener(self.listener)
    end
end

--[[
handleType 为消息处理类型
--]]
function BullMyPlayer:refreshInfo(event)
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

--按钮事件
function BullMyPlayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")
	if ref == self.Button_add or  ref == self.ShopBtn then
		local sceneIDKeyTmp = "BuillFighting"  --斗牛
		FSRegistryManager:currentFSM():trigger("store", 
		{parentNode=display.getRunningScene(), zorder=zorderLayer.CustomLayer, store_openType=2, sceneIDKey = sceneIDKeyTmp})
	elseif ref == self.chatBtn then
		local gamedata = DataCenter:getData(COMMON_EVENTS.C_EVENT_GAMEDATA) or {GamePlayID = 1}
		FSRegistryManager:currentFSM():trigger("chat", 
        {parentNode=display.getRunningScene(), zorder = zorderLayer.CustomLayer,MatchID = 0,GamePlayID = gamedata.GamePlayID,InviteRoomID = 0})
	elseif ref == self.Button_SendNiuhave then
		if #self.checkEdCard < BULL_CARD_NUM then
			Toast:makeToast(i18n:get("str_bullfighting", "bull_haveNiu_Tips"), 2.0):show()
		else
		 	if self.calculationVal%10 == 0  then
				self:sendNiuToSever(0)

				self:setWaitState(BullWaitState.BullWaitCaculate,self.bullProgressTimer:getNowTime())
				self.rootCalculation:setVisible(false)
			else
				if detectionBullBomb(self.allViewCard) or detectionBullFiveLit(self.allViewCard) then
					self:sendNiuToSever(0)

					self:setWaitState(BullWaitState.BullWaitCaculate,self.bullProgressTimer:getNowTime())
					self.rootCalculation:setVisible(false)
				else
					Toast:makeToast(i18n:get("str_bullfighting", "bull_haveNiu_Tips"), 2.0):show()
				end
			end
		end
	elseif ref == self.Button_SendNiuno then
		if self.BullInfo.BullNum <= BullType.None then
			self:sendNiuToSever(0,self.allViewCard)

			self:setWaitState(BullWaitState.BullWaitCaculate,self.bullProgressTimer:getNowTime())
			self.rootCalculation:setVisible(false)
		else
			Toast:makeToast(i18n:get("str_bullfighting", "bull_haveNiu_havelook"), 2.0):show()
		end
	elseif ref == self.CalculationKuan_Buttontip then
		self:sendNiuToSever(1,self.allViewCard)

		self:setWaitState(BullWaitState.BullWaitCaculate,self.bullProgressTimer:getNowTime())
		self.rootCalculation:setVisible(false)
	end
end

function BullMyPlayer:sendNiuToSever(Type,cards)
	-- body
	for k,v in pairs(self.checkEdCard) do
		if isLuaNodeValid(v) then
			v.faceImg:setColor(cc.c3b(255,255,255))
		end
	end
		
	local pokerData = false
	if cards then
		pokerData = self:parseLocalNoNiuPoker(cards)
	else
		pokerData = self:parseLocalNiuPoker()
	end
	local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
    local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)
	BullFightingSceneProxy:requestDNShowPokerReq(BullFightingSceneController.GamePlayID,BullFightingSceneController.PlayType,
		pokerData,Type)
end

--设置头像信息
function BullMyPlayer:setHeadInfo()	
  	self.Gender = DataCenter:getUserdataInstance():getValueByKey("gender")
	self:addHead(DataCenter:getUserdataInstance():getHeadIcon())
	self.Text_name:setString(DataCenter:getUserdataInstance():getValueByKey("nickname") or "") --昵称
	if self.BullInfo and self.BullInfo.Chip then
		self.Text_gold:setString(ToolCom.splitNumFix(tonumber(self.BullInfo.Chip))) 
	end
end

function BullMyPlayer:addHead( fileName )
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

	self.headNodeFrame = ccui.ImageView:create("ourkuang.png",UI_TEX_TYPE_PLIST)
	local headClippingNode = createClippingNode("rabot.png",WWHeadSprite,
		cc.p(self.headNodeFrame:getContentSize().width/2,self.headNodeFrame:getContentSize().height/2))
	self.headNodeFrame:addChild(headClippingNode)
	self.headNodeFrame:setName("headNodeFrame")
	self.headNodeFrame:setScale(0.99)
	self.headNodeFrame:setPosition(cc.p(self.headImgMachine:getContentSize().width/2,self.headImgMachine:getContentSize().height/2))
	self.headImgMachine:addChild(self.headNodeFrame,1)
end

--还原刚刚进去状态
function BullMyPlayer:setCurState()
	-- body
	wwlog(self.logTag,"设置我的状态")

	--是否参与
	self:setPlayStatus(self.BullInfo.Status)

	--设置庄家
	local isBanker = false
	if self.BullInfo.GameStatus == 2 or self.BullInfo.GameStatus == 3 or self.BullInfo.GameStatus == 4 then --下注
		if BullFightingManage.initRoomData.BankerId == self.UserId then
			isBanker = true
			self:setIsBanker(true)
		end
	end

	if not self.haveSetCurState then
		self.haveSetCurState = true

		if self.BullInfo.GameStatus == 2 then --下注
			if self.BullInfo.Status == 2 and self.BullInfo.BetRate == -1 then --对局者
				if isBanker then --我是庄家就等待别人下注
					self:setWaitState(BullWaitState.BullWaitOtherChoose,BullFightingManage.initRoomData.RemainTime)
				else
					if self.BullInfo.BetRate == -1 then --没下注
						self:setCanMultiple(BullFightingManage.initRoomData.MyBetScore,BullFightingManage.initRoomData.RemainTime)
					else
						self:setMultiple(self.BullInfo.BetRate)
						self:setWaitState(BullWaitState.BullWaitOtherChoose,BullFightingManage.initRoomData.RemainTime)
					end
				end
			elseif self.BullInfo.Status == 1 then
				self:setWaitState(BullWaitState.BullWaitOtherChoose,BullFightingManage.initRoomData.RemainTime)
			end
		elseif self.BullInfo.GameStatus == 3 then --亮牌
			if self.BullInfo.Status == 2 then
				self:reductionCard(self.BullInfo.Card,self.BullInfo.CardStatus)
				self:CalculaCardOpen(BullFightingManage.initRoomData.RemainTime)
				self:setMultiple(self.BullInfo.BetRate)
			elseif self.BullInfo.Status == 1 then
				self:setWaitState(BullWaitState.BullWaitCaculate,BullFightingManage.initRoomData.RemainTime)
			end
		elseif self.BullInfo.GameStatus == 4 then --结算
			self:sendEnterGame()
		end
	end
end

--设置是否参与
function BullMyPlayer:setPlayStatus( status )
	-- body
	if status == 2 then --参与
		self.sidelines:setVisible(false)
	elseif status == 1 then --旁观
		self.sidelines:setVisible(true)
	end
end

function BullMyPlayer:setComplete( ... )
	-- body
	if not self.cardLayer:getChildByName("CompleteImgNode") then
		local CompleteImgNode = ccui.ImageView:create("over.png",UI_TEX_TYPE_PLIST)
		self.cardLayer:addChild(CompleteImgNode,BULL_DISTRIBUTE_CARD_MIN_NUM + 1)
		CompleteImgNode:setName("CompleteImgNode")
	  	CompleteImgNode:setPosition(cc.p(self.cardLayer:getContentSize().width/2,self.cardLayer:getContentSize().height/2))
	end

	for k,v in pairs(self.allViewCard) do
		v.mState = Card_State.State_Discard
	end
	
	self.checkEdCard = {}
	self.cancleCard = {}
end

--还原牌
function BullMyPlayer:reductionCard( cardTable,CardStatus )
	-- body
	self:createCards(cardTable)
	for k,v in pairs(self.allViewCard) do
  		v:setVisible(true)
  		if CardStatus == 3 then --暗牌
  			v:beginDeal()
  		elseif CardStatus == 4 then --明牌
  			v:dalayDeal()
  			self.dealCardEd = true
  		end
	end
end

function BullMyPlayer:setWaitState( state,time )
	-- body
	if time and time >= 0 then
		if state == BullWaitState.BullWaitBegin then --等待开局倒计时
	  		self.stateImg:loadTexture("newgame.png",UI_TEX_TYPE_PLIST)
		elseif state == BullWaitState.BullWaitChoose then --等待我选择下注倍数
	  		self.stateImg:setPosition(cc.p(screenSize.width/2 - self.stateImg:getContentSize().width/4,
				screenSize.height/2+ self.stateImg:getContentSize().height*1.5))
	  		self.stateImg:loadTexture("choosebei.png",UI_TEX_TYPE_PLIST)
		elseif state == BullWaitState.BullWaitOtherChoose then --等待等待其他玩家下注
	  		self.stateImg:loadTexture("waitothers.png",UI_TEX_TYPE_PLIST)
	  		self.stateImg:setPosition(cc.p(screenSize.width/2 - self.stateImg:getContentSize().width/4,
				screenSize.height/2))
		elseif state == BullWaitState.BullWaitCaculate then --等待等待其他玩家思考
	  		self.stateImg:loadTexture("waitotherthink.png",UI_TEX_TYPE_PLIST)
	  		self.stateImg:setPosition(cc.p(screenSize.width/2 - self.stateImg:getContentSize().width/4,
				screenSize.height/2))
	  	elseif state == BullWaitState.BullSettlment then
	  		self.CreateGameTimeOut = time
	  		self.stateImg:setVisible(false)
	  		self.bullProgressTimer:setVisible(false)
			self.bullProgressTimer:setplaySoundEffect(false)
	  		return
		end
		self.stateImg:setVisible(true)
		self.bullProgressTimer:setVisible(true)

		if  state == BullWaitState.BullWaitBegin then --等待开局倒计时 在左边显示
			self.stateImg:setPosition(cc.p(screenSize.width/2 + self.bullProgressTimer.back:getContentSize().width/2,
				screenSize.height/2))
			self.bullProgressTimer:setPosition(cc.p(self.stateImg:getPositionX()-self.stateImg:getContentSize().width/2 - self.bullProgressTimer.back:getContentSize().width/2,
				self.stateImg:getPositionY()))
		else
			self.bullProgressTimer:setPosition(cc.p(self.stateImg:getPositionX()+self.stateImg:getContentSize().width/2 + self.bullProgressTimer.back:getContentSize().width/2,
				self.stateImg:getPositionY()))
		end
		
		self.bullProgressTimer:reSet(time,function ( ... )
			-- body
			self:CalculaCardClose()
		end)
	else
		wwlog(self.logTag,"时间哪里去了")
	end
end

--可选倍数
function BullMyPlayer:setCanMultiple(BetScore,time)
	-- body
	self.BetScore = BetScore
	self.rootAddDouble:setVisible(true)

	if self.BetScore[1] < 0 then
		self.Button_1:setTouchEnabled(false)
		self.Button_1:setBright(false)
	else
		self.Button_1:setTouchEnabled(true)
		self.Button_1:setBright(true)
	end

	if self.BetScore[2] < 0 then
		self.Button_2:setTouchEnabled(false)
		self.Button_2:setBright(false)
	else
		self.Button_2:setTouchEnabled(true)
		self.Button_2:setBright(true)
	end

	if self.BetScore[3] < 0 then
		self.Button_3:setTouchEnabled(false)
		self.Button_3:setBright(false)
	else
		self.Button_3:setTouchEnabled(true)
		self.Button_3:setBright(true)
	end

	if self.BetScore[4] < 0 then
		self.Button_4:setTouchEnabled(false)
		self.Button_4:setBright(false)
	else
		self.Button_4:setTouchEnabled(true)
		self.Button_4:setBright(true)
	end

	self.ButtonRate_1:setString(self.BetScore[1])
	self.ButtonRate_2:setString(self.BetScore[2])
	self.ButtonRate_3:setString(self.BetScore[3])
	self.ButtonRate_4:setString(self.BetScore[4])

	self:setWaitState(BullWaitState.BullWaitChoose,time)
end

--设置倍数
function BullMyPlayer:setMultiple( multi )
	-- body
	if multi > 0 then
		self.beiandget:setVisible(true)
		self.beiandget:setString(":"..multi)
	end
end

--下注几倍
function BullMyPlayer:requestMultiple(Score)
	-- body
	self:setWaitState(BullWaitState.BullWaitOtherChoose,self.bullProgressTimer:getNowTime())
	self.rootAddDouble:setVisible(false)
	local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
    local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)

	BullFightingSceneProxy:requestDNBetReq(BullFightingSceneController.GamePlayID,BullFightingSceneController.PlayType,
		self.BullInfo.SeatId,Score,0)  --下注倍数
end

--设置庄家
function BullMyPlayer:setIsBanker( isBanker,blink,callBack )
	-- body
  	self.Image_kuang:setVisible(isBanker)
  	if blink then
  		self.Image_kuang:runAction(cc.Sequence:create(cc.Blink:create(0.5,3),cc.CallFunc:create(function ( ... )
  			-- body
			self.Image_head_mark:setVisible(isBanker)
  			if callBack then
  				callBack()
  			end
  		end)))

  		self.Image_kuang:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function ( ... )
  			-- body
			playSoundEffect("sound/effect/bullfight/bankchoose")

  		end)),3))
  	else
		self.Image_head_mark:setVisible(isBanker)
  	end
end

--设置随机庄家
function BullMyPlayer:setRadomBanker(isBanker)
	-- body
  	self.Image_kuang:setVisible(isBanker)
end

--创建牌
function BullMyPlayer:createCards( cardTable,delNodeFunc,k )
	-- body
	--准备要发的牌
	self.delNodeFunc = delNodeFunc
	self:releaseCards()
  	for i = 1,#cardTable do --BULL_DISTRIBUTE_CARD_MIN_NUM do
  		local cardNode = BullCard:create(cardTable[i])
  		if cardNode then
  			if k then
  				cardNode.createIdx = k - i + 1
  			end
  			cardNode:beginDeal()
  			cardNode:setVisible(false)
  			self.cardLayer:addChild(cardNode,i)
  			local pos = cc.p((i - 1 + 0.5)*cardNode.faceImg:getContentSize().width,
					cardNode.faceImg:getContentSize().height/2)
  			cardNode:setPosition(pos)

			self.cardLayer:setContentSize(cc.size(cardNode.faceImg:getContentSize().width*BULL_DISTRIBUTE_CARD_MIN_NUM,cardNode.faceImg:getContentSize().height))
			self.cardLayer:setPosition(cc.p((screenSize.width - self.cardLayer:getContentSize().width)/2,
					self.Image_bg:getContentSize().height))

  			table.insert(self.allViewCard,cardNode)
  		end
  	end
end

--删除牌节省内存
function BullMyPlayer:releaseCards( ... )
	-- body
	self.checkIngCard = {}
	for k,v in pairs(self.checkEdCard) do
		if isLuaNodeValid(v) then
			v.faceImg:setColor(cc.c3b(255,255,255))
		end
	end
	self.checkEdCard = {}
	self.cancleCard = {}
	--删除所有牌
	self.cardLayer:removeAllChildren()
	--查找表清空
	self.dealCardEd = false

	--显示表清空
	self.allViewCard = {}
	self.dealCardIndx = 0
	self.overTurnCardIndx = 0

end

--发牌
function BullMyPlayer:dealCard(userdata)
	-- body
	if self.dealCardIndx <= 0 then
		playSoundEffect("sound/effect/bullfight/deal")
	end

	local dealFunc = function ( ... )
		-- body
		self.dealCardIndx = self.dealCardIndx + 1
		local cardNode = self.allViewCard[self.dealCardIndx]
		if cardNode then
			local scale = cardNode:getScale()
			cardNode:setScale(BullCardScale)
			cardNode.mState = Card_State.State_None --设置没被选中
			local delNode = BullFightingManage.BullDealCardLayer:getCardByIdx(cardNode.createIdx)
			if delNode then
				cardNode:setPosition(self.cardLayer:convertToNodeSpace(cc.p(delNode:getPosition())))
			else
				cardNode:setPosition(self.cardLayer:convertToNodeSpace(cc.p(screenSize.width/2,screenSize.height/2)))
			end
			cardNode:setVisible(true)

			--删除牌回调
			if self.delNodeFunc then
				self.delNodeFunc(cardNode.createIdx)
			end

			local pos = cc.p((self.dealCardIndx - 1 + 0.5)*cardNode.faceImg:getContentSize().width,
						cardNode.faceImg:getContentSize().height/2)

			cardNode:runAction(cc.Spawn:create(cc.ScaleTo:create(0.3,scale),
				cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function ( ... )
				-- body
				self:dealCard(userdata)
			end)),cc.Sequence:create(cc.EaseSineIn:create(cc.MoveTo:create(0.3,pos)),cc.CallFunc:create(function ( ... )
					-- body
					--最后一张牌翻转完
					cardNode:overTurn(function ( ... )
						-- body
						if self.dealCardIndx >= BULL_DISTRIBUTE_CARD_MIN_NUM then
							--计算牛的框框打开
							self:CalculaCardOpen(userdata.BetTime)
						end
					end)
				end))))
		else
			--重写触摸 截断下层消息
		    self.dealCardEd = true
		end
	end

	dealFunc()
end

--发完牌倒计时开始自己选牌
function BullMyPlayer:CalculaCardOpen( time )
	-- body
	self.stateImg:setVisible(false)
	self.rootAddDouble:setVisible(false)
	self.rootCalculation:setVisible(true)
	self.tipsPao:setVisible(true)
	if not self.paoScriptFuncId then
		self.paoScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
			-- body
			self.tipsPao:setVisible(false)
			if self.paoScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.paoScriptFuncId)
				self.paoScriptFuncId = false
			end
		end, 3, false)
	end

	for k,v in pairs(self.CalculationKuan) do
		v:setString('')
	end
	self.rootSendNiu:setVisible(true)

	self.bullProgressTimer:setVisible(true)
	self.bullProgressTimer:setPosition(cc.p(screenSize.width/2,screenSize.height/2 + self.bullProgressTimer.back:getContentSize().height*9/10))
	self.bullProgressTimer:reSet(time or BullCaculateCardTime)
end

--关闭计算牛
function BullMyPlayer:CalculaCardClose( ... )
	-- body
	self.stateImg:setVisible(false)
	self.rootCalculation:setVisible(false)
	self.rootSendNiu:setVisible(false)
	self.bullProgressTimer:setVisible(false)
	self.bullProgressTimer:setplaySoundEffect(false)
	self.rootAddDouble:setVisible(false)
end

--完成
function BullMyPlayer:CalculaCardResult(data,callback)
	-- body
	self:CalculaCardClose()
	if self.cardLayer:getChildByName("CompleteImgNode") then
		self.cardLayer:removeChildByName("CompleteImgNode")
	end

	-- --隐藏投注数
	-- self.beiandget:setVisible(false)

	for k,v in pairs(self.allViewCard) do
		v:setCard(data.Card[k].val,data.Card[k].color)
		v.mState = Card_State.State_Discard
	end

	-- body
    self:showNiuCard()
    for k,v in pairs(self.checkEdCard) do
		if isLuaNodeValid(v) then
			v.faceImg:setColor(cc.c3b(255,255,255))
		end
	end
	
	--音效牛几
	playNiuValSoundFileName(self.Gender,data.BullNum)
	if data.BullNum > BullType.None then
		for k,v in pairs(self.allViewCard) do
			if k > 3 then
				v:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(v.faceImg:getContentSize().width/4,0)),
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function ( ... )
						-- body
						if callback and k == #self.allViewCard then
							callback()
						end
				end)))
			end
		end
	else
		if callback then
			callback()
		end
	end

	--牛几
	local Calculateniu = require("csb.bullfighting.Calculateniu"):create()
	local rootCalculateniu = Calculateniu["root"]
	local rootCalculateniuAni = Calculateniu["animation"]
	rootCalculateniu:runAction(rootCalculateniuAni)
	rootCalculateniuAni:play("animation0",false)
	
	self.cardLayer:addChild(rootCalculateniu,BULL_DISTRIBUTE_CARD_MIN_NUM + 2)
	rootCalculateniu:setPosition(cc.p(rootCalculateniu:getChildByName("niudi"):getContentSize().width/2,
		self.cardLayer:getContentSize().height/2))
	local niu = rootCalculateniu:getChildByName("niu")
	niu:loadTexture("niu_"..data.BullNum..".png",UI_TEX_TYPE_PLIST)
end

function BullMyPlayer:setGoldAnimate( golds )
	-- body
	local gold = tonumber(golds)
	local goldsget = false
	if gold > 0 then
		playSoundEffect("sound/effect/bullfight/niuwin")

		goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu2.png",56,55,"0")
		if cc.Director:getInstance():getContentScaleFactor() == 1 then
			goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu2.png",56,55,"0")
		else
			goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu2.png",38,37,"0")
		end

		goldsget:setString(";"..gold)
	elseif gold < 0 then
		playSoundEffect("sound/effect/bullfight/niufail")

		goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu3.png",56,55,"0")
		if cc.Director:getInstance():getContentScaleFactor() == 1 then
			goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu3.png",56,55,"0")
		else
			goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu3.png",38,37,"0")
		end

		goldsget:setString(":"..math.abs(gold))
	else
		return
	end
	goldsget:setScale(1.2)
	self.cardLayer:addChild(goldsget,BULL_DISTRIBUTE_CARD_MIN_NUM + 2)
	goldsget:setName("goldsget")
  	goldsget:setPosition(cc.p(self.cardLayer:getContentSize().width,self.cardLayer:getContentSize().height/2))

  	goldsget:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(1,cc.p(0,200))),
  			cc.FadeOut:create(0.5),cc.CallFunc:create(function ( ... )
  				-- body
  				goldsget:removeFromParent()
  			end)))
end

--获得金币位置
function BullMyPlayer:getGoldPos( ... )
	-- body
	return self.Image_bg:convertToWorldSpace(cc.p(self.Image_gold:getPositionX() - self.Image_gold:getContentSize().width*0.48,self.Image_gold:getPositionY()))
end

--获得头像位置
function BullMyPlayer:getHeadPos( ... )
	-- body
	return self.Image_bg:convertToWorldSpace(cc.p(self.Image_headbg:getPositionX(),self.Image_headbg:getPositionY()))
end

----------------------------------------------------
--触摸事件
----------------------------------------------------
function BullMyPlayer:onTouchEvent(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
    	self.checkIngCard = {}
    	self.cancleCard = {}

    	if self.dealCardEd then
    		self:chooseCard(touch)
    	end
        return true
    elseif event:getEventCode() == cc.EventCode.MOVED then
    	--发牌完成才能触摸
    	if self.dealCardEd then
    		self:chooseCard(touch)
    	end
    elseif event:getEventCode() == cc.EventCode.ENDED then
    	--查看桌面
    	BullFightingManage:closePlayerInfo()

    	if next(self.checkIngCard) == nil and next(self.cancleCard) == nil then --本次没有选到一个
    		for k,v in pairs(self.checkEdCard) do -- 将正在选中的放在已选表内
	    		v.faceImg:setColor(cc.c3b(255,255,255))
	    		v.mState = BullCardState.State_None
	    	end
	    	self.checkEdCard = {}

	    	--右上角菜单还原
	    	BullFightingManage.BullFoldMenuLayer:resetMenuMain()
    	else
			playSoundEffect("sound/effect/xuanpai")
	    	
	    	--取消选中恢复
	    	for k,v in pairs(self.cancleCard) do
	    		v.mState = BullCardState.State_None
	    		removeItem(self.checkEdCard,v)
	    	end
	    	self.cancleCard = {}

	    	--选中
	    	if #self.checkIngCard == 1 then
	    		local insertCardNode = self.checkIngCard[1]
	    		if #self.checkEdCard < BULL_CARD_NUM then
		    		insertCardNode.mState = BullCardState.State_Checked
			    	insertItem(self.checkEdCard,insertCardNode)
				else
					local delCardNode = self.checkEdCard[#self.checkEdCard]
		    		delCardNode.mState = BullCardState.State_None
				    delCardNode.faceImg:setColor(cc.c3b(255,255,255))
		    		removeItem(self.checkEdCard,delCardNode)

				    insertCardNode.mState = BullCardState.State_Checked
				    insertItem(self.checkEdCard,insertCardNode)
				end
	    	else
	    		for k,v in pairs(self.checkIngCard) do -- 将正在选中的放在已选表内
	    			if #self.checkEdCard < BULL_CARD_NUM then
			    		v.mState = BullCardState.State_Checked
			    		insertItem(self.checkEdCard,v)
			    	else
			    		v.mState = BullCardState.State_None
			    		v.faceImg:setColor(cc.c3b(255,255,255))
			    	end
		    	end
		    end

	    	self.checkIngCard = {}
    	end
    	self:Calculation()
    end
end

--点击选中
function BullMyPlayer:chooseCard( touch )
	-- body
	for m,n in pairs(self.allViewCard) do
		local check = n:isContainsTouch(touch)
		if check then
			if n.mState == BullCardState.State_None then
				n.mState = BullCardState.State_CheckIng
				n.faceImg:setColor(BullCardChooseBlenColor)
				insertItem(self.checkIngCard,n)
			elseif n.mState == BullCardState.State_Checked then
	    		n.mState = BullCardState.State_CheckIng
	    		n.faceImg:setColor(cc.c3b(255,255,255))
    			insertItem(self.cancleCard,n)
			end
		end
	end
end

--显示牛几
function BullMyPlayer:showNiuCard()
	-- body
	for k,v in pairs(self.allViewCard) do
		local pos = cc.p((k-1)*v.faceImg:getContentSize().width/2 + v.faceImg:getContentSize().width/2,
					v.faceImg:getContentSize().height/2)
		v:setPosition(pos)
	end

	if self.cardLayer then
		if isLuaNodeValid(self.allViewCard[1]) then 
			self.cardLayer:setContentSize(cc.size(self.allViewCard[1].faceImg:getContentSize().width*(BULL_DISTRIBUTE_CARD_MIN_NUM + 1)/2,
				self.allViewCard[1].faceImg:getContentSize().height))
		end
		self.cardLayer:setPosition(cc.p((screenSize.width - self.cardLayer:getContentSize().width)/2,
					self.Image_bg:getContentSize().height))
	end
end

function BullMyPlayer:Calculation( ... )
	-- body
	self.calculationVal = 0
	for i=1,BULL_CARD_NUM do
		local cardNode = self.checkEdCard[i]
		if cardNode then
			self.calculationVal = self.calculationVal + cardNode.bullVal
			local value = ""
			if cardNode.val == BullCardValue.R1 then --A
				value = ":"
			elseif cardNode.val <= BullCardValue.R10 then
				value = tostring(cardNode.val)
			elseif cardNode.val <= BullCardValue.RJ then
				value = ";"
			elseif cardNode.val <= BullCardValue.RQ then
				value = "<"
			elseif cardNode.val <= BullCardValue.RK then
				value = "="
			end

			self.CalculationKuan[i]:setString(value)
		else
			self.CalculationKuan[i]:setString("")
		end
	end

	if self.calculationVal > 0 then
		self.CalculationKuan[#self.CalculationKuan]:setString(self.calculationVal.."")
	else
		self.CalculationKuan[#self.CalculationKuan]:setString("")
	end
end

function BullMyPlayer:parseLocalNoNiuPoker(cards)
	-- body
	local pokerCard = {}
	for k,v in pairs(cards) do
		local node = {}
		node.color = v.color
		node.val = v.val
		table.insert(pokerCard,node)
	end
	return BullfightPokerUtil.parseLocalData(pokerCard)
end

function BullMyPlayer:parseLocalNiuPoker()
	-- body
	local pokerCard = {}
	for k,v in pairs(self.checkEdCard) do
		local node = {}
		node.color = v.color
		node.val = v.val
		table.insert(pokerCard,node)
	end

	for k,v in pairs(self.allViewCard) do
		local find = false
		for m,n in pairs(self.checkEdCard) do
			if v == n then
				find = true
				break
			end
		end

		if not find then
			local node = {}
			node.color = v.color
			node.val = v.val
			table.insert(pokerCard,node)
		end
	end

	return BullfightPokerUtil.parseLocalData(pokerCard)
end

function BullMyPlayer:setChatButtonState( grey )
	-- body
	if grey then
		self.chatBtn:setTouchEnabled(false)
		self.chatBtn:setBright(false)
	else
		self.chatBtn:setTouchEnabled(true)
		self.chatBtn:setBright(true)
	end
end


return BullMyPlayer
-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  设置层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local FoldMenuLayer = class("FoldMenuLayer",cc.Layer)
local Toast = require("app.views.common.Toast")
local GDAnimator = require("WhippedEgg.util.GDAnimator")
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

function FoldMenuLayer:ctor( ... )
	-- body
	self:init()
end

function FoldMenuLayer:init( ... )
	-- body
	self.logTag = "FoldMenuLayer.lua"
	--右上角菜单
	local FoldMenu = require("csb.guandan.FoldMenu"):create()
	if not FoldMenu then
		return
	end
	self.rootFoldMenu = FoldMenu["root"]
	self.foldedmenu_bg = self.rootFoldMenu:getChildByName("foldedmenu_bg")
	self.foldedmenu_main = self.rootFoldMenu:getChildByName("foldedmenu_main")
	self.rootFoldMenu:setPosition(cc.p(self:getContentSize().width - self.foldedmenu_bg:getContentSize().width/2,
		self:getContentSize().height))
  	self:addChild(self.rootFoldMenu)
  	self.rootFoldMenu:setLocalZOrder(100)

  	self.foldedmenu_main = self.rootFoldMenu:getChildByName("foldedmenu_main") --按钮
  	self.foldedmenu_bg = self.rootFoldMenu:getChildByName("foldedmenu_bg") --底层
  	self.foldedmenu_bg:setPosition(cc.p(0,self.foldedmenu_bg:getContentSize().height))
  	self.foldedmenu_set = self.foldedmenu_bg:getChildByName("foldedmenu_set") --设置按钮
  	self.foldedmenu_trusteeship = self.foldedmenu_bg:getChildByName("foldedmenu_trusteeship") --托管按钮
  	self.foldedmenu_exit = self.foldedmenu_bg:getChildByName("foldedmenu_exit") --退出按钮

  	self.foldedmenu_main:addClickEventListener(handler(self,self.btnClick))
  	self.foldedmenu_set:addClickEventListener(handler(self,self.btnClick))
  	self.foldedmenu_trusteeship:addClickEventListener(handler(self,self.btnClick))
  	self.foldedmenu_exit:addClickEventListener(handler(self,self.btnClick))
  	self.foldedmenuRunActioonEnd = true

  	--底分 
	local TopLeftLayer = require("csb.guandan.GamePlayTopLeftLayer"):create()
	if not TopLeftLayer then
		return
	end
	self.rootTopLeftLayer = TopLeftLayer["root"]
	self.Image_bg = self.rootTopLeftLayer:getChildByName("Image_bg")
	self.rootTopLeftLayer:setPosition(cc.p(self.Image_bg:getContentSize().width/2,
		(self:getContentSize().height-self.Image_bg:getContentSize().height/2)))
  	self:addChild(self.rootTopLeftLayer)
  	self.Text_number = self.Image_bg:getChildByName("Text_number") --底分
  	self.selfTextNumberParent =  self.Image_bg:getChildByName("Image_self")
  	self.otherTextNumberParent =  self.Image_bg:getChildByName("Image_opposite")
  	self.Text_self_number = self.selfTextNumberParent:getChildByName("Text_self_number") --自己打几
  	self.Text_opppsite_number = self.otherTextNumberParent:getChildByName("Text_opppsite_number") --对方打几
  	self.selfLight = self.selfTextNumberParent:getChildByName("self")
  	self.oppsiteLight = self.otherTextNumberParent:getChildByName("opposite")
  	self.selfLight:loadTexture("self_on.png",UI_TEX_TYPE_PLIST)
  	self.oppsiteLight:loadTexture("opposite_on.png",UI_TEX_TYPE_PLIST)

	self:setDisableButtonState(true)

	--接风动画
  	local solitaireNode = require("csb.guandan.solitaire"):create()
	self.rootSolitaireNodeNode = solitaireNode["root"]
  	self:addChild(self.rootSolitaireNodeNode,1)
  	self.rootSolitaireNodeAni = solitaireNode["animation"]
	self.rootSolitaireNodeNode:runAction(self.rootSolitaireNodeAni)
	self.rootSolitaireNodeNode:setVisible(false)

	local nodeSolitaireDot = require("csb.guandan.nodeSolitaireDot"):create()
	self.rootNodeSolitaireDot = nodeSolitaireDot["root"]
  	self:addChild(self.rootNodeSolitaireDot,1)
  	self.rootNodeSolitaireDot:setVisible(false)
end

function FoldMenuLayer:addChatBtn( ... )
  -- body
  	if not self:getChildByName("ChatNode") then
		local ChatNode = require("csb.guandan.ChatNode"):create()
		if not ChatNode then
			return
		end
		self.rootChatNode = ChatNode["root"]
		local ChatNodeBtn = self.rootChatNode:getChildByName("Button_1")
		ChatNodeBtn:addClickEventListener(handler(self,self.btnClick))
		self.rootChatNode:setName("ChatNode")
		self.rootChatNode:setPosition(cc.p(100,screenSize.height*0.45))
		if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
			GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
			GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
			self:addChild(self.rootChatNode)
		elseif  GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or
			GameManageFactory.gameType == Game_Type.PersonalRcircle then --私人房
			self:addChild(self.rootChatNode)
	  	end
	else
		self.rootChatNode:setVisible(true)
	end
end

function FoldMenuLayer:inVisibleChatBtn( ... )
	-- body
	if isLuaNodeValid(self.rootChatNode) then
		self.rootChatNode:setVisible(false)
	end
end

function FoldMenuLayer:setFoldMenuVisible( visible )
	-- body
	if isLuaNodeValid(self.rootFoldMenu) and isLuaNodeValid(self.rootTopLeftLayer) then
		self.rootFoldMenu:setVisible(visible)
		self.rootTopLeftLayer:setVisible(visible)
	end
end

--按钮事件
function FoldMenuLayer:btnClick( ref )
  -- body
    playSoundEffect("sound/effect/anniu")
	if ref:getName() == "Button_1" then --聊天   
	    local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
		
	    if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
	        GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
	        GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
			local gamedata = DataCenter:getData(COMMON_EVENTS.C_EVENT_GAMEDATA)
			FSRegistryManager:runWithFSM(FSMConfig.FSM_WHIPPEDEGG):trigger("chat", 
	        {parentNode=display.getRunningScene(), zorder = zorderLayer.CustomLayer,MatchID = 0,GamePlayID = gamedata.GamePlayID,InviteRoomID = 0})
	    elseif  GameManageFactory.gameType == Game_Type.PersonalPromotion or 
	        GameManageFactory.gameType == Game_Type.PersonalRandom or
	        GameManageFactory.gameType == Game_Type.PersonalRcircle then --私人房
	         FSRegistryManager:runWithFSM(FSMConfig.FSM_WHIPPEDEGG):trigger("chat", 
	      {parentNode=display.getRunningScene(), zorder = zorderLayer.CustomLayer,MatchID = 0,GamePlayID = 0,InviteRoomID = WhippedEggSceneController.gameZoneId})
	    end
  	end
end

--设置底分
function FoldMenuLayer:setRoomPoint( point )
	-- body
	GameModel.roomPoints = point

	local contentText = SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_setlayer_roompoint'),GameModel.roomPoints),
		32,cc.c3b(255,255,255))
	self.Text_number:removeAllChildren()
	self.Text_number:addChild(contentText)
end


--右边按钮还原回去
function FoldMenuLayer:resetMenuMain( ... )
	-- body
	if self.foldedmenuRunActioonEnd then
		self.foldedmenuRunActioonEnd = false
		self.foldedmenu_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(0,self.foldedmenu_bg:getContentSize().height)),cc.CallFunc:create(function ( ... )
			-- body
			self.foldedmenuRunActioonEnd = true
		end)))
	end

	GameManageFactory:getCurGameManage():closePlayerInfo()
end

function FoldMenuLayer:resetMenuMainPos( ... )
	-- body
	self.foldedmenuRunActioonEnd = true
	self.foldedmenu_bg:setPosition(cc.p(0,self.foldedmenu_bg:getContentSize().height))
end

--按钮事件
function FoldMenuLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")

	if ref:getName() == "foldedmenu_main" then --显示隐藏
		GameManageFactory:getCurGameManage():closePlayerInfo()
		if self.foldedmenuRunActioonEnd then
			self.foldedmenuRunActioonEnd = false
			if self.foldedmenu_bg:getPositionY() == 0 then
				self.foldedmenu_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(0,self.foldedmenu_bg:getContentSize().height)),cc.CallFunc:create(function ( ... )
					-- body
					self.foldedmenuRunActioonEnd = true
				end)))
			elseif self.foldedmenu_bg:getPositionY() == self.foldedmenu_bg:getContentSize().height then
				self.foldedmenu_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(0,0)),cc.CallFunc:create(function ( ... )
					-- body
					self.foldedmenuRunActioonEnd = true
				end)))
			end
		end
	elseif ref:getName() == "foldedmenu_set" then --设置
	
		FSRegistryManager:runWithFSM(FSMConfig.FSM_WHIPPEDEGG):trigger("setting", 
			{parentNode=display.getRunningScene(), zorder = zorderLayer.CustomLayer})
		self:resetMenuMain() --点击了托管，应该要隐藏
  	elseif ref:getName() == "foldedmenu_trusteeship" then --托管
  			if GameManageFactory:getCurGameManage().MyPlayer.dealCardEd and GameManageFactory:getCurGameManage():getPlayCardsCount(Player_Type.SelfPlayer) > 0 then
  				GameManageFactory:getCurGameManage():substitute(0)
  			end
			self:resetMenuMain() --点击了托管，应该要隐藏
  	elseif ref:getName() == "foldedmenu_exit" then --退出
  		self:resetMenuMain() --点击了托管，应该要隐藏
  		self:exitGame()
  	elseif ref:getName() == "Button_1" then --聊天   
	    local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
	    if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
	        GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
	        GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
			local gamedata = DataCenter:getData(COMMON_EVENTS.C_EVENT_GAMEDATA)
			FSRegistryManager:runWithFSM(FSMConfig.FSM_WHIPPEDEGG):trigger("chat", 
	        {parentNode=display.getRunningScene(), zorder = zorderLayer.CustomLayer,MatchID = 0,GamePlayID = gamedata.GamePlayID,InviteRoomID = 0})
	    elseif  GameManageFactory.gameType == Game_Type.PersonalPromotion or 
	        GameManageFactory.gameType == Game_Type.PersonalRandom or
	        GameManageFactory.gameType == Game_Type.PersonalRcircle then --私人房
	        FSRegistryManager:runWithFSM(FSMConfig.FSM_WHIPPEDEGG):trigger("chat", 
	      	{parentNode=display.getRunningScene(), zorder = zorderLayer.CustomLayer,MatchID = 0,GamePlayID = 0,InviteRoomID = WhippedEggSceneController.gameZoneId})
	    end
	end
end

function FoldMenuLayer:exitGame( ... )
	-- body
	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then
  		if GameManageFactory:getCurGameManage().gameState == GameStateType.Enter or
  			GameManageFactory:getCurGameManage().gameState == GameStateType.None then
  			GameManageFactory:getCurGameManage():exitGame()
  		else
  			GameManageFactory:getCurGameManage().MyPlayer:ToastTips(ToastState.FriendNeedHelp)
  		end
  	elseif GameManageFactory.gameType == Game_Type.MatchRamdomTime or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --定时比赛
  		if GameManageFactory:getCurGameManage().gameState == GameStateType.Enter or GameManageFactory:getCurGameManage().gameState == GameStateType.None then
  			local  exitTime = tonumber(DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_WILL_START).Param1)
  			if exitTime <= 60 then
  				Toast:makeToast(i18n:get('str_guandan','guandan_setlayer_cannotexit_time'), 1.0):show()
  			else
				self:matchExitDialog(GameManageFactory.gameType)
  			end
  		elseif GameManageFactory:getCurGameManage().gameState == GameStateType.WaitSettlement then
  			GameManageFactory:getCurGameManage():exitGame()
  		else
  			Toast:makeToast(i18n:get('str_guandan','guandan_setlayer_cannotexit'), 1.0):show()
  		end
  	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount then --定人比赛
  		if GameManageFactory:getCurGameManage().gameState == GameStateType.Enter or GameManageFactory:getCurGameManage().gameState == GameStateType.None then
			self:matchExitDialog(GameManageFactory.gameType)
  		elseif GameManageFactory:getCurGameManage().gameState == GameStateType.WaitSettlement then
  			GameManageFactory:getCurGameManage():exitGame()
  		else
  			Toast:makeToast(i18n:get('str_guandan','guandan_setlayer_cannotexit'), 1.0):show()
  		end
  	elseif GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
		self:personalExitDialog(GameManageFactory.gameType)
  	end
end

--退出私人房
function FoldMenuLayer:personalExitDialog(gameType)
	local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
	local backToHallFun = function ()
  		-- Toast:makeToast(i18n:get('str_guandan','guandan_SirenJieSan'), 1.0):show()
		GameManageFactory:getCurGameManage():exitGame()
	end
	local para = {}
    para.leftBtnlabel = i18n:get('str_common','comm_no')
    para.rightBtnlabel = i18n:get('str_common','comm_yes')
	para.rightBtnCallback = backToHallFun
	para.showclose = false  --是否显示关闭按钮
	if WhippedEggSceneController.MasterID == DataCenter:getUserdataInstance():getValueByKey("userid") then --房主
    	para.content = i18n:get('str_guandan','guandan_Master')
	else
    	para.content = i18n:get('str_guandan','guandan_NoMaster')
	end

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
end

function FoldMenuLayer:matchExitDialog(gameType)
	local backToHallFun = function ()
		if FSRegistryManager.curFSMName == FSMConfig.FSM_WHIPPEDEGG then
			--WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
			--比赛被取消  没有玩经典的时候 退出去
			if GameManageFactory:getCurGameManage().gameState == GameStateType.Enter or GameManageFactory:getCurGameManage().gameState == GameStateType.None then
  				GameManageFactory:getCurGameManage():exitGame()
  			else
				Toast:makeToast(i18n:get('str_guandan','guandan_setlayer_cannotexit'), 1.0):show()
			end
		end
	end
	local para = {}
    para.leftBtnlabel = (GameManageFactory.gameType == Game_Type.MatchRamdomTime or GameManageFactory.gameType == Game_Type.MatchRcircleTime)
		and i18n:get('str_match','match_exit_cancel1') or i18n:get('str_match','match_exit_cancel2')
		
    para.rightBtnlabel = (GameManageFactory.gameType == Game_Type.MatchRamdomTime or GameManageFactory.gameType == Game_Type.MatchRcircleTime)
		and i18n:get('str_match','match_exit_sure1') or i18n:get('str_match','match_exit_sure2')
		
	--para.singleName = tostring(eventTable.MatchID)
	if GameManageFactory.gameType == Game_Type.MatchRamdomTime or GameManageFactory.gameType == Game_Type.MatchRcircleTime then
		para.leftBtnCallback = backToHallFun
	else
		para.rightBtnCallback = backToHallFun
	end
   
	para.showclose = false  --是否显示关闭按钮
	--eventTable.MatchName
    para.content = (GameManageFactory.gameType == Game_Type.MatchRamdomTime or GameManageFactory.gameType == Game_Type.MatchRcircleTime)
		and i18n:get('str_match','match_exit_msg1') or i18n:get('str_match','match_exit_msg2')

    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
end

function FoldMenuLayer:setDisableButtonState( Enabled )
	-- body
	if Enabled then
		self.foldedmenu_trusteeship:setBright(false)
  		self.foldedmenu_trusteeship:setTouchEnabled(false)
	else
		if GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
			--私人房不能托管
		else
			self.foldedmenu_trusteeship:setBright(true)
  			self.foldedmenu_trusteeship:setTouchEnabled(true)
  		end
	end
end

--恢复对局
function FoldMenuLayer:setCurGamePlayNum()
	--设置己方对方
	self.Text_self_number:setVisible(false)
  	self.Text_opppsite_number:setVisible(false)

	if GameModel.isPlayerBankerType == lightWiner.winerLeft then --己方
		self.selfLight:loadTexture("self_on.png",UI_TEX_TYPE_PLIST)
		self.oppsiteLight:loadTexture("opposite_off.png",UI_TEX_TYPE_PLIST)
	elseif GameModel.isPlayerBankerType == lightWiner.winerRight then --对方
		self.selfLight:loadTexture("self_off.png",UI_TEX_TYPE_PLIST)
		self.oppsiteLight:loadTexture("opposite_on.png",UI_TEX_TYPE_PLIST)
	elseif GameModel.isPlayerBankerType == lightWiner.winerAll then --双方
  		self.selfLight:loadTexture("self_on.png",UI_TEX_TYPE_PLIST)
		self.oppsiteLight:loadTexture("opposite_on.png",UI_TEX_TYPE_PLIST)
	end
end

function FoldMenuLayer:recoveryOn( ... )
	-- body
	local function playNum( num )
		-- body
		if num <= 10 then
			return tostring(num)
		elseif num == 11 then
			return	"J"
		elseif num == 12 then
			return	"Q"
		elseif num == 13 then
			return	"K"
		elseif num == 14 then
			return	"A"
		end
	end
	self.Text_self_number:setVisible(true)
  	self.Text_opppsite_number:setVisible(true)
  	self.Text_self_number:setString(playNum(GameModel.myNumber)) --自己打几
  	self.Text_opppsite_number:setString(playNum(GameModel.opppsiteNumber)) --对方打几

 
	if GameModel.isPlayerBankerType == lightWiner.winerLeft then --己方
		self.selfLight:loadTexture("self_on.png",UI_TEX_TYPE_PLIST)
		self.oppsiteLight:loadTexture("opposite_off.png",UI_TEX_TYPE_PLIST)
	elseif GameModel.isPlayerBankerType == lightWiner.winerRight then --对方
		self.selfLight:loadTexture("self_off.png",UI_TEX_TYPE_PLIST)
		self.oppsiteLight:loadTexture("opposite_on.png",UI_TEX_TYPE_PLIST)
	elseif GameModel.isPlayerBankerType == lightWiner.winerAll then --双方
  		self.selfLight:loadTexture("self_on.png",UI_TEX_TYPE_PLIST)
		self.oppsiteLight:loadTexture("opposite_on.png",UI_TEX_TYPE_PLIST)
	end
end

function FoldMenuLayer:changePlayer( ... )
	-- body
	self.Text_self_number:setVisible(true)
  	self.Text_opppsite_number:setVisible(true)
  	self.Text_self_number:setString("?") --自己打几
  	self.Text_opppsite_number:setString("?") --对方打几

  	self.selfLight:loadTexture("self_on.png",UI_TEX_TYPE_PLIST)
  	self.oppsiteLight:loadTexture("opposite_on.png",UI_TEX_TYPE_PLIST)
  	GameModel.myNumber = 0
  	GameModel.opppsiteNumber = 0
end

function FoldMenuLayer:solitaireAni( playerType )
	-- body
	playSoundEffect("sound/effect/jiefeng")

	local nodeSolitaireDotPos = false
	local posDest = false

	if playerType == Player_Type.SelfPlayer then --我
		nodeSolitaireDotPos = cc.p(GameManageFactory:getCurGameManage():getUpPlayer().playcardLayer:getPositionX() + GameManageFactory:getCurGameManage():getUpPlayer().playcardLayer:getContentSize().width/2,
		GameManageFactory:getCurGameManage():getUpPlayer().playcardLayer:getPositionY() + GameManageFactory:getCurGameManage():getUpPlayer().playcardLayer:getContentSize().height/2)

		posDest = GameManageFactory:getCurGameManage().MyPlayer.rootPlayerHeadUi:convertToWorldSpace(cc.p(GameManageFactory:getCurGameManage().MyPlayer.headImgMachine:getPositionX(),
			GameManageFactory:getCurGameManage().MyPlayer.headImgMachine:getPositionY()))
	elseif playerType == Player_Type.UpPlayer then --上
		nodeSolitaireDotPos = cc.p(GameManageFactory:getCurGameManage().MyPlayer.playcardLayer:getPositionX() + GameManageFactory:getCurGameManage().MyPlayer.playcardLayer:getContentSize().width/2,
		GameManageFactory:getCurGameManage().MyPlayer.playcardLayer:getPositionY() + GameManageFactory:getCurGameManage().MyPlayer.playcardLayer:getContentSize().height/2)

		posDest = GameManageFactory:getCurGameManage():getUpPlayer().rootPlayerHeadUi:convertToWorldSpace(cc.p(GameManageFactory:getCurGameManage():getUpPlayer().headImgMachine:getPositionX(),GameManageFactory:getCurGameManage():getUpPlayer().headImgMachine:getPositionY()))
	elseif playerType == Player_Type.LeftPlayer then --左
		nodeSolitaireDotPos = cc.p(GameManageFactory:getCurGameManage():getRightPlayer().playcardLayer:getPositionX()+GameManageFactory:getCurGameManage():getRightPlayer().playcardLayer:getContentSize().width/2,
		GameManageFactory:getCurGameManage():getRightPlayer().playcardLayer:getPositionY()+GameManageFactory:getCurGameManage():getRightPlayer().playcardLayer:getContentSize().height/2)

		posDest = GameManageFactory:getCurGameManage():getLeftPlayer().rootPlayerHeadUi:convertToWorldSpace(cc.p(GameManageFactory:getCurGameManage():getLeftPlayer().headImgMachine:getPositionX(),GameManageFactory:getCurGameManage():getLeftPlayer().headImgMachine:getPositionY()))
	elseif playerType == Player_Type.RightPlayer then --右
		nodeSolitaireDotPos = cc.p(GameManageFactory:getCurGameManage():getLeftPlayer().playcardLayer:getPositionX()+GameManageFactory:getCurGameManage():getLeftPlayer().playcardLayer:getContentSize().width/2,
		GameManageFactory:getCurGameManage():getLeftPlayer().playcardLayer:getPositionY()+GameManageFactory:getCurGameManage():getLeftPlayer().playcardLayer:getContentSize().height/2)

		posDest = GameManageFactory:getCurGameManage():getRightPlayer().rootPlayerHeadUi:convertToWorldSpace(cc.p(GameManageFactory:getCurGameManage():getRightPlayer().headImgMachine:getPositionX(),GameManageFactory:getCurGameManage():getRightPlayer().headImgMachine:getPositionY()))
	end

	self.rootNodeSolitaireDot:setPosition(nodeSolitaireDotPos)
	self.rootNodeSolitaireDot:setScale(1.5)
	self.rootSolitaireNodeNode:setPosition(nodeSolitaireDotPos)
	self.rootSolitaireNodeNode:setVisible(true)
	self.rootSolitaireNodeAni:play("animation0",false)
	self.rootSolitaireNodeAni:setAnimationEndCallFunc1("animation0",function ( ... )
		-- body
		self.rootSolitaireNodeNode:setVisible(false)
		self.rootNodeSolitaireDot:setVisible(true)
		self.rootNodeSolitaireDot:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.6,posDest),cc.ScaleTo:create(0.5,2.5)),cc.CallFunc:create(function ( ... )
			-- body
			self.rootNodeSolitaireDot:setVisible(false)
			self.rootSolitaireNodeNode:setVisible(true)
			self.rootSolitaireNodeNode:setPosition(posDest)
			self.rootSolitaireNodeAni:play("animation1",false)
		end)))
	end)
end

function FoldMenuLayer:addChatNode( playid,userid,position1,position2,flippedX,flippedY )
	-- body
	require("hall.util.RoomChatManager")
    --  playid 播放ID 可以放置座位号
    --  userid 用户ID
    --  parentNode 父节点 
    --  position 播放的位置 
    --  zorder 层级
    local charplaydata1 = {
      playid = playid,
      userid= userid,
      parentNode = self,
      position = position1,
      zorder = 15,
      flippedX = flippedX,
      flippedY = flippedY
    }
    RoomChatManager:addCharPlayData(charplaydata1)

    local charplaydata2 = {}
    copyTable(charplaydata1,charplaydata2)
    charplaydata2.position = position2
    RoomChatManager:addFacialPlayData(charplaydata2)
end

return FoldMenuLayer
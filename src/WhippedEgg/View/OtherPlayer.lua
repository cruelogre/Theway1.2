-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  玩家基类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local OtherPlayer = class("OtherPlayer",cc.Layer)
local Card = import(".Card","WhippedEgg.View.")
local CardDetection = require("WhippedEgg.CardDetection")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local HeadNode = require("csb.guandan.HeadNode")
local Toast = require("app.views.common.Toast")

function OtherPlayer:ctor( playerType )
	-- body
	self:init(playerType)
end


--初始化
function OtherPlayer:init( playerType )
	-- body
	self.logTag = "OtherPlayer"
	--玩家头像一大堆信息
	local playerUi = false
	self.playerType = playerType
	if self.playerType == Player_Type.UpPlayer then --上
		playerUi = require("csb.guandan.HeadItem1"):create()
	elseif self.playerType == Player_Type.LeftPlayer then --左
		playerUi = require("csb.guandan.HeadItem2"):create()
	elseif self.playerType == Player_Type.RightPlayer then --右
		playerUi = require("csb.guandan.HeadItem2"):create()
	end
	if not playerUi then
		return
	end
	self.rootplayerUi = playerUi["root"]
  	self:addChild(self.rootplayerUi)
  	self.rootplayerUiAni = playerUi["animation"]
	self.rootplayerUi:runAction(self.rootplayerUiAni)
  	self.Image_bg = self.rootplayerUi:getChildByName("Image_bg")
  	self.Image_kuang = self.rootplayerUi:getChildByName("Image_kuang")
  	self.Image_kuang:setVisible(false)
  	self.clock = self.Image_bg:getChildByName("Image_alarm")
  	self.stateImg = self.Image_bg:getChildByName("state")
  	self.stateImg:setVisible(false)
  	self.stateImg:ignoreContentAdaptWithSize(true)
	self.Image_bg:setVisible(false) -- 匹配到玩家之前隐藏
	self.Image_remain = self.Image_bg:getChildByName("Image_remain")
  	if self.playerType == Player_Type.UpPlayer then --上
  		self.rootplayerUi:setPosition(cc.p(self:getContentSize().width/2,
  			self:getContentSize().height-self.Image_bg:getContentSize().height))
	elseif self.playerType == Player_Type.LeftPlayer then --左
		self.rootplayerUi:setPosition(cc.p(self.Image_bg:getContentSize().width/2 + 20,self:getContentSize().height*2/3))
		self.Image_remain:setPosition(cc.p(math.abs(self.Image_remain:getPositionX()) + self.Image_bg:getContentSize().width,
			self.Image_remain:getPositionY()))
		self.clock:setPosition(cc.p(math.abs(self.clock:getPositionX()) + self.Image_bg:getContentSize().width,
			self.clock:getPositionY()))
		self.stateImg:setPosition(cc.p(self.clock:getPositionX(),self.clock:getPositionY()))
	elseif self.playerType == Player_Type.RightPlayer then --右
		self.rootplayerUi:setPosition(cc.p(self:getContentSize().width - self.Image_bg:getContentSize().width/2 - 20,
			self:getContentSize().height*2/3))
	end
  	self.clockSec = self.clock:getChildByName("Text_alarm") --闹钟数字
  	self.clock:setVisible(false)
  	self.secCount = 0 --倒计时秒

  	--玩家状态
  	self.stateType = PlayerStateType.None

	--头像信息
	self.Image_headbg = self.Image_bg:getChildByName("Image_headbg")
	local playerHeadUi = HeadNode:create()
	self.rootPlayerHeadUi = playerHeadUi["root"]
  	self.Image_headbg:addChild(self.rootPlayerHeadUi)
  	self.rootPlayerHeadUi:setPosition(cc.p(self.Image_headbg:getContentSize().width/2,self.Image_headbg:getContentSize().height/2))
  	self.rootPlayerHeadUiAni = playerHeadUi["animation"]
	self.rootPlayerHeadUi:runAction(self.rootPlayerHeadUiAni)

	local function checkInfo( ... )
		-- body
		if GameManageFactory:getCurGameManage().gameState ~= GameStateType.Enter and GameManageFactory:getCurGameManage().gameState ~= GameStateType.None then
	        playSoundEffect("sound/effect/anniu")
			if self.playerDatas then
				GameManageFactory:getCurGameManage():requestUserInfo(self.playerDatas.UserID)
			end
		end
	end
	self.Image_headbg:addClickEventListener(checkInfo)
	self.headImgMachine = self.rootPlayerHeadUi:getChildByName("Image_head") --头像
	self.headImgMachine:setLocalZOrder(0)
	self.Image_head_mark = self.rootPlayerHeadUi:getChildByName("Image_head_mark") --头像标志
	self.Image_head_mark:setLocalZOrder(2)
	self.Image_head_mark:setVisible(false)
	local headTravelNode = require("csb.guandan.headTravelAni"):create()
	self.rootheadTravelNode = headTravelNode["root"]
  	self:addChild(self.rootheadTravelNode)
  	self.rootheadTravelNode:setPosition(self.rootPlayerHeadUi:convertToWorldSpace(cc.p(self.Image_head_mark:getPositionX(),self.Image_head_mark:getPositionY())))
  	self.rootheadTravelNodeAni = headTravelNode["animation"]
	self.rootheadTravelNode:runAction(self.rootheadTravelNodeAni)
	self.rootheadTravelNode:setVisible(false)
	self.Image_gold = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_gold")
	self.name = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_name") --名字
	self.gold = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_gold") --金币数
	self.ImgRemain = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_remain") --牌
	self.remain = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_remain") --剩余张数
	self:setCardsCount(0)
	--发牌动画
	self.cardNodeAni = {}
	for i=1,DISTRIBUTE_CARD_MAX_NUM do
		local cardNode = cc.Sprite:create("guandan/guandan_remain_card_bg1.png")
		self:addChild(cardNode)
		cardNode:setVisible(false)
		table.insert(self.cardNodeAni,cardNode)
	end

	--打的牌
	self.playcardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self:addChild(self.playcardLayer)
	self.playcardLayer:setScale(0.5)

	--进贡牌
	self.tributeCardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self:addChild(self.tributeCardLayer)

	--团团转牌层
	self.rciclescardLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self:addChild(self.rciclescardLayer)

	--jin/抗贡位置
	self.TributePos = false

	--剩下队友查看牌
	self.leftLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),0,0)
	self:addChild(self.leftLayer)
	self.allViewCard = {}
	self.cardFix = MY_FIX

	--第一次你报警
	self.firstTimePolice = true

	--接风
	self.Solitaire = false

	--onEnter onExit
	self:registerScriptHandler(handler(self,self.onNodeEvent))
end

--onEnter onExit
function OtherPlayer:onNodeEvent( event )
	-- body
	if event == "enter" then
    elseif event == "exit" then
        if self.ScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
		end
    end
end

--设置头像信息
function OtherPlayer:setHeadInfo( playerDatas )
	-- body
	wwlog(self.logTag,"设置头像信息")
	self.Image_bg:setVisible(true)
	self.playerDatas = playerDatas
  	self.Gender = playerDatas.Gender
	self:addHead(DataCenter:getUserdataInstance():getHeadIconByGender(self.Gender))

	----各种设置信息
	if GameManageFactory.gameType == Game_Type.ClassicalPromotion or 
		GameManageFactory.gameType == Game_Type.ClassicalRandomGame or 
		GameManageFactory.gameType == Game_Type.ClassicalRcircleGame then --经典
		if playerDatas.Fortune then
			self.gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.Fortune)))
		end
		self.Image_gold:loadTexture("guandan/guandan_bottom_gold_bg.png")
	elseif GameManageFactory.gameType == Game_Type.MatchRamdomCount or 
		GameManageFactory.gameType == Game_Type.MatchRamdomTime or 
		GameManageFactory.gameType == Game_Type.MatchRcircleCount or
		GameManageFactory.gameType == Game_Type.MatchRcircleTime then --比赛then --比赛
		if playerDatas then
			if playerDatas.TScore ~= nil then
				self.gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.TScore)))
			else
				self.gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.Score)))
			end
		else
			self.gold:setString(ToolCom.splitNumFix(0))
		end
		self.Image_gold:loadTexture("guandan/guandan_bottom_fen_bg.png")
	elseif 	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		if playerDatas then
			if playerDatas.TFortune then
				self.gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.TFortune))) 
			elseif playerDatas.Fortune then
				self.gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.Fortune)))
			elseif playerDatas.Score then
				self.gold:setString(ToolCom.splitNumFix(tonumber(playerDatas.Score))) 
			end
		end
		self.Image_gold:loadTexture("guandan/guandan_bottom_fen_bg.png")
	end

	if playerDatas then
		if playerDatas.UserName then
			self.name:setString(subNickName(playerDatas.UserName))
		elseif playerDatas.Nickname then
			self.name:setString(subNickName(playerDatas.Nickname))
		end
	end

	if self.playerType == Player_Type.UpPlayer then --上
    	GameManageFactory:getCurGameManage().FoldMenuLayer:addChatNode(self.playerType,playerDatas.UserID,self:getTributePos(),
    		cc.p(self:getTributePos().x,self:getTributePos().y - 170),false,true)
	elseif self.playerType == Player_Type.LeftPlayer then --左
		GameManageFactory:getCurGameManage().FoldMenuLayer:addChatNode(self.playerType,playerDatas.UserID,self:getTributePos(),
			cc.p(self:getTributePos().x + 190,self:getTributePos().y),false,false)
	elseif self.playerType == Player_Type.RightPlayer then --右
		GameManageFactory:getCurGameManage().FoldMenuLayer:addChatNode(self.playerType,playerDatas.UserID,self:getTributePos(),
			cc.p(self:getTributePos().x - 180,self:getTributePos().y),true,false)
	end
end

--设置名次
function OtherPlayer:setRank( rank,gameOver )
	-- body
	if rank and rank > 0 and rank < 5 then
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
				local bezier = false
				if self.playerType == Player_Type.UpPlayer then --上
					bezier = {
						        cc.p(nodeMarkPos.x + 200, nodeMarkPos.y + 100),
						        cc.p(posDest.x + 200, posDest.y - 100),
						        posDest
						    }
				elseif self.playerType == Player_Type.LeftPlayer then --左
					bezier = {
						        cc.p(nodeMarkPos.x + 50, nodeMarkPos.y + 100),
						        cc.p(posDest.x + 50, posDest.y + 100),
						        posDest
						    }
				elseif self.playerType == Player_Type.RightPlayer then --右
					bezier = {
						       	cc.p(nodeMarkPos.x - 50, nodeMarkPos.y + 100),
						        cc.p(posDest.x - 50, posDest.y + 100),
						        posDest
						    }
				end
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
					self.rootplayerUiAni:play("animation0",false)
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

--更换玩家
function OtherPlayer:changePlayer( ... )
	-- body
	self.Image_bg:setVisible(false)
	self.playcardLayer:removeAllChildren()
	self.tributeCardLayer:removeAllChildren()
	self.rciclescardLayer:removeAllChildren()
	self.leftLayer:removeAllChildren()
	self.allViewCard = {}
	self:hideCard()
	self.cardCount = 0
end

--继续游戏
function OtherPlayer:continueGame( ... )
	-- body
	self.Image_remain:setVisible(false)
	self.playcardLayer:removeAllChildren()
	self.tributeCardLayer:removeAllChildren()
	self.rciclescardLayer:removeAllChildren()
	self.leftLayer:removeAllChildren()
	self:setStateType(PlayerStateType.Wait)
	self:hideClock()
	self.allViewCard = {}
	self.cardCount = 0
	self:setCardsCount(self.cardCount)
end

--继续游戏
function OtherPlayer:clearDesk( ... )
	-- body
	self.Image_remain:setVisible(false)
	self.playcardLayer:removeAllChildren()
	self.tributeCardLayer:removeAllChildren()
	self.leftLayer:removeAllChildren()
	self:setStateType(PlayerStateType.None)
	self:hideClock()
	self.allViewCard = {}
	self.cardCount = 0
	self:setCardsCount(self.cardCount)
end

--隐藏牌
function OtherPlayer:hideCard( ... )
	-- body
	self.playcardLayer:removeAllChildren()
	self.tributeCardLayer:removeAllChildren()
	self.rciclescardLayer:removeAllChildren()
	self:setStateType(PlayerStateType.None)
	self:hideClock()
end

--隐藏闹钟
--decection检测是否双闹钟了
function OtherPlayer:hideClock( decection )
	-- body
	if decection and self.secCount > 0 and self.clock:isVisible() then
		wwlog(self.logTag,"双闹钟出现了 其他玩家%d 还剩余%d 秒倒计时",self.playerType,self.secCount)
	end

	self.clock:setVisible(false)
	self.Image_kuang:setVisible(false)
	if self.ScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
	end
end

--设置出牌状态文字
function OtherPlayer:setStateType( state )
	-- body
	--隐藏闹钟
	self:hideClock()

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
		donotPlayCardSound(self.Gender)
		self.stateImg:loadTexture("guandan_wenzi_buchu.png",UI_TEX_TYPE_PLIST)
	elseif self.stateType == PlayerStateType.Solitaire then
  		self.stateImg:setVisible(false)
		self.Solitaire = true
	end	
end

--轮到我打牌 开始倒计时
function OtherPlayer:turnToPlay( typeCard,time ) --特殊处理 存在typeCard 代表打完了 隐藏牌面
	-- body
	if typeCard then
		self:hideCard()
	else
		self:hideCard()

		if 	GameManageFactory.gameType == Game_Type.PersonalPromotion or 
			GameManageFactory.gameType == Game_Type.PersonalRandom or 
			GameManageFactory.gameType == Game_Type.PersonalRcircle then
			self.Image_kuang:setVisible(true)
			self.rootplayerUiAni:play("animation1",true)
		else
			self.clock:setVisible(true)
			self.secCount = time
		  	self.clockSec:setString(tostring(self.secCount)) --闹钟数字
		  	self.ScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countDown), 1, false)
		end
	end
end

--倒计时递减
function OtherPlayer:countDown( ... )
	-- body
	--self.clock:runAction(cc.Repeat:create(cc.Sequence:create(cc.RotateBy:create(0.5,10),cc.RotateBy:create(0.5,-20),cc.RotateBy:create(0.5,10)),3))
	self.secCount = self.secCount - 1
	if self.secCount >= 0 then
  		self.clockSec:setString(tostring(self.secCount)) --闹钟数字
  	else --超时
  		if self.ScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
		end
  	end
end

function OtherPlayer:showRcircleCard( ... )
	-- body
	local cardNode = Card:create({val = GameModel.nowCardVal,color = GameModel.nowCardColor})
	cardNode:setPlayState()
	local scale = 0.5
	self.rciclescardLayer:setScale(scale)
	if self.playerType == Player_Type.UpPlayer then --上
		local pos = false
		if self.rciclescardLayer:getChildrenCount() <= 0 then
			pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2)
			cardNode:setPosition(pos)
			self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT))
		else
			pos = cc.p(MY_FIX_WEIDTH/2 + MY_FIX_WEIDTH*2,MY_FIX_HEIGHT/2)
			cardNode:setPosition(pos)
			self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH*3,MY_FIX_HEIGHT))
		end
		self.rciclescardLayer:addChild(cardNode,1)
  		self.rciclescardLayer:setPosition(cc.p((screenSize.width - self.rciclescardLayer:getContentSize().width)/2,
					self:getContentSize().height*0.58))
	elseif self.playerType == Player_Type.LeftPlayer then --左
		local pos = false
		if self.rciclescardLayer:getChildrenCount() <= 0 then
			pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2)
			cardNode:setPosition(pos)
			self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT))
		else
			pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2 + MY_FIX_HEIGHT*1.5)
			cardNode:setPosition(pos)
			self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT*2))
		end
		self.rciclescardLayer:addChild(cardNode,1)
		self.rciclescardLayer:setPosition(cc.p(300-(1-scale)*0.5*self.rciclescardLayer:getContentSize().width,(self:getContentSize().height - self.rciclescardLayer:getContentSize().height)/2 ))
	elseif self.playerType == Player_Type.RightPlayer then --右
		local pos = false
		if self.rciclescardLayer:getChildrenCount() <= 0 then
			pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2)
			cardNode:setPosition(pos)
			self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT))
		else
			pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2 + MY_FIX_HEIGHT*1.5)
			cardNode:setPosition(pos)
			self.rciclescardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT*2))
		end
		self.rciclescardLayer:addChild(cardNode,1)
		self.rciclescardLayer:setPosition(cc.p((screenSize.width - self.rciclescardLayer:getContentSize().width + (1-scale)*0.5*self.rciclescardLayer:getContentSize().width- 300)
			,(self:getContentSize().height - self.rciclescardLayer:getContentSize().height)/2))
	end
end

function OtherPlayer:deleteRcircleCard( ... )
	-- body
	self.rciclescardLayer:removeAllChildren()
end

--发牌
function OtherPlayer:dealCard(node,playerCardIndex)
	-- body
	self.Image_remain:setVisible(true)
	self:setCardsCount(playerCardIndex)
	-- 发牌
	local cardNode = self.cardNodeAni[playerCardIndex]
	cardNode:setPosition(self:convertToNodeSpace(cc.p(node:getPositionX(),node:getPositionY())))
	cardNode:setVisible(true)
	local pos = self.Image_bg:convertToWorldSpace(cc.p(self.ImgRemain:getPositionX(),self.ImgRemain:getPositionY()))
	cardNode:runAction(cc.Spawn:create(
		cc.Sequence:create(cc.MoveTo:create(0.05,pos),cc.CallFunc:create(function ( ... )
			-- body
			cardNode:setVisible(false)
		end))))
end

function OtherPlayer:releaseCards( ... )
	-- body
	self:setCardsCount(0)
	if self.ScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ScriptFuncId)
	end
end

--删除牌节省内存
function OtherPlayer:setCardsCount( count )
	-- body
	self.cardCount = count
	self.remain:setString(tostring(self.cardCount))
	if GameManageFactory:getCurGameManage().gameState == GameStateType.Playing or GameManageFactory:getCurGameManage().gameState == GameStateType.Settlement then
		if self.cardCount <= CHANGECOLOR_CARD_PLAYER_NUM then
			self.ImgRemain:loadTexture("guandan/guandan_remain_card_bg2.png")
		else
			self.ImgRemain:loadTexture("guandan/guandan_remain_card_bg1.png")
		end
	else
		self.ImgRemain:loadTexture("guandan/guandan_remain_card_bg1.png")
	end
end


--打牌
function OtherPlayer:playCard( trueCards,replaceCards,view,isFirst )
	-- body
	wwlog(self.logTag,"服务器反馈(其他玩家)打牌数据过来")

	--如果我对家 要实时看牌
	if view then
		self:deletePlayCard(trueCards)
	end

	--出了牌就隐藏闹钟
	self:hideClock()

	local count = self.cardCount - #trueCards
	self:setCardsCount(count)

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
	local typeCard,val = CardDetection.detectionType(trueCards)
	
	if self.playerType == Player_Type.UpPlayer then --上
		printCardLogType(tonumber(typeCard),replaceCards,"上玩家   选择出")
	elseif self.playerType == Player_Type.LeftPlayer then --左
		printCardLogType(tonumber(typeCard),replaceCards,"左玩家    选择出")
	elseif self.playerType == Player_Type.RightPlayer then --右
		printCardLogType(tonumber(typeCard),replaceCards,"右玩家     选择出")
	end

	if self:getCardCount() <= CHANGECOLOR_CARD_PLAYER_NUM and self.firstTimePolice then
		self.firstTimePolice = false
		callThePoliceSound(self.Gender)
	else
		if self.Solitaire then
			self.Solitaire = false
			passPlayCardSound(self,self.Gender,true,typeCard,val)
		else
			passPlayCardSound(self,self.Gender,isFirst,typeCard,val)
		end
	end 

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
	end

	local scale = 0.5
	self.playcardLayer:setContentSize(cc.size(MY_FIX_WEIDTH + (#trueCards-1)*MY_FIX,MY_FIX_HEIGHT))
	if self.playerType == Player_Type.UpPlayer then --上
  		self.playcardLayer:setPosition(cc.p((screenSize.width - self.playcardLayer:getContentSize().width)/2,
					self:getContentSize().height/2))
	elseif self.playerType == Player_Type.LeftPlayer then --左
		self.playcardLayer:setPosition(cc.p(250-(1-scale)*0.5*self.playcardLayer:getContentSize().width,self:getContentSize().height*6/13))
	elseif self.playerType == Player_Type.RightPlayer then --右
		self.playcardLayer:setPosition(cc.p((screenSize.width - self.playcardLayer:getContentSize().width + (1-scale)*0.5*self.playcardLayer:getContentSize().width- 250),
					self:getContentSize().height*6/13))
	end

	local flashPos = cc.p(self.playcardLayer:getPositionX()+self.playcardLayer:getContentSize().width/2,
			self.playcardLayer:getPositionY()+self.playcardLayer:getContentSize().height/2)
	GameManageFactory:getCurGameManage():playCardFlash( tonumber(typeCard),flashPos,false )
	if GameManageFactory.gameType == Game_Type.PersonalPromotion or 
		GameManageFactory.gameType == Game_Type.PersonalRandom or 
		GameManageFactory.gameType == Game_Type.PersonalRcircle then
		GameManageFactory:getCurGameManage():addDouble(typeCard)
	end
end

--进贡退贡的牌
function OtherPlayer:TributeCard(card)
	-- body
	local count = self.cardCount - 1
	self:setCardsCount(count)

	if self.stateType == PlayerStateType.PayTribute then
		TributeSound(self,self.Gender,true,card.val)
	elseif self.stateType == PlayerStateType.RetTribute then
		TributeSound(self,self.Gender,false,card.val)
	end

	self:setStateType(PlayerStateType.None)

	self.tributeCardLayer:removeAllChildren()
	local cardNode = Card:create(card)
	cardNode:setName("TributeCardNode")
	self.tributeCardLayer:addChild(cardNode,1)
	local pos = cc.p(MY_FIX_WEIDTH/2,MY_FIX_HEIGHT/2)
	cardNode:setPosition(pos)
	
	local scale = 0.5
	self.tributeCardLayer:setScale(scale)
	self.tributeCardLayer:setContentSize(cc.size(MY_FIX_WEIDTH,MY_FIX_HEIGHT))
	if self.playerType == Player_Type.UpPlayer then --上
  		self.tributeCardLayer:setPosition(cc.p((screenSize.width - self.tributeCardLayer:getContentSize().width)/2,
					self:getContentSize().height/2))
	elseif self.playerType == Player_Type.LeftPlayer then --左
		self.tributeCardLayer:setPosition(cc.p(250-(1-scale)*0.5*self.tributeCardLayer:getContentSize().width,self:getContentSize().height*6/13))
	elseif self.playerType == Player_Type.RightPlayer then --右
		self.tributeCardLayer:setPosition(cc.p((screenSize.width - self.tributeCardLayer:getContentSize().width + (1-scale)*0.5*self.tributeCardLayer:getContentSize().width- 250),
					self:getContentSize().height*6/13))
	end

	self.TributePos = self.tributeCardLayer:convertToWorldSpace(cc.p(cardNode:getPositionX(),cardNode:getPositionY()))
end

--获取进/退贡牌的位置
function OtherPlayer:getTributePos( ... )
	-- body
	local pos = self.rootPlayerHeadUi:convertToWorldSpace(cc.p(self.headImgMachine:getPositionX(),self.headImgMachine:getPositionY()))
	return pos
end
--获得头像位置
function OtherPlayer:getHeadPos( ... )
	-- body
	return self.Image_bg:convertToWorldSpace(cc.p(self.Image_headbg:getPositionX(),self.Image_headbg:getPositionY()))
end
--交换进/退贡的牌
function OtherPlayer:ExchangTributeCard( player,callBack,card )
	-- body
	local TributeCardNode = self.tributeCardLayer:getChildByName("TributeCardNode")
	if TributeCardNode then
		TributeCardNode:setVisible(false)
		local cardNode = TributeCardNode:clone()
		cardNode:setScale(0.5)
		cardNode:setPosition(self.TributePos)
		GameManageFactory:getCurGameManage().FoldMenuLayer:addChild(cardNode)
		cardNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,player:getTributePos()),cc.CallFunc:create(function ( ... )
			-- body
			self.tributeCardLayer:removeAllChildren()
			if card then
				player:getTributeCard(card)
			else
				player:setCardsCount(DISTRIBUTE_CARD_MIN_NUM)
			end
			if callBack then
				callBack()
			end
		end),cc.DelayTime:create(3),cc.CallFunc:create(function ( ... )
			-- body
			cardNode:removeFromParent()
		end)))
	end
end

--让队友看牌
function OtherPlayer:seeFriendPlayerCard( Cards )
	-- body
	if next(Cards) == nil then
		return
	end
	cardDetectionBigToSmallSort(Cards)
	self.allViewCard = {}
	self.leftLayer:removeAllChildren()
	local lastCard = false
  	for i = 1,#Cards do --DISTRIBUTE_CARD_MIN_NUM do
  		local cardNode = Card:create(Cards[i])
  		if cardNode then
  			cardNode:setVisible(false)
  			cardNode.val = tonumber(Cards[i].val)
  			cardNode.color = tonumber(Cards[i].color)
  			self.leftLayer:addChild(cardNode,i)

  			if not lastCard or lastCard.val ~= cardNode.val then 
  				self.allViewCard[#self.allViewCard + 1] = {}
  			end

  			lastCard = cardNode
  			table.insert(self.allViewCard[#self.allViewCard],cardNode)
  		end
  	end

  	self:fixCardMove()
end

function OtherPlayer:deletePlayCard(cards)
	--显示表
	if next(self.allViewCard) == nil then
		return
	end

	for k,v in pairs(cards) do
		--从剩余牌移除选中牌
		for m,n in pairs(self.allViewCard) do
			for x,y in pairs(n) do
				if y.color == v.color and y.val == v.val then
					--把选中的数据移除移表
					removeItem(n,y)
					self.leftLayer:removeChild(y,true)
					if next(n) == nil then
						removeItem(self.allViewCard,n)
					end 
					break
				end
			end
		end
	end

	self:fixCardMove()
end

--发牌移动
function OtherPlayer:fixCardMove()
	-- 整体一起发
	--计算应该排多少列
	local colCount = #self.allViewCard
	if colCount > MY_MAX_CARD_COUNT then
		self.cardFix = MY_MAX_CARD_COUNT*MY_FIX/colCount
	else
		self.cardFix = MY_FIX
	end
	--让牌居中对齐
	self.leftLayer:setContentSize(cc.size((colCount-1)*self.cardFix+MY_FIX_WEIDTH,MY_FIX_HEIGHT))
	self.leftLayer:setPosition(cc.p((screenSize.width - self.leftLayer:getContentSize().width)/2,
				GameManageFactory:getCurGameManage().MyPlayer.Image_bg:getContentSize().height))

	--先计算剩余的牌
	self.curCol = 0
	for k,v in pairs(self.allViewCard) do
		table.sort( v, function ( a,b )
			-- body
			if a.val < b.val then
				return true
			elseif a.val > b.val then
				return false
			else
				return a.color < b.color --黑梅方红
			end
		end )

		for m,node in pairs(v) do
			node:setVisible(true)
			local pos = false
			if self.curCol > 0 then
				if self.lastCard.col == k then --同一列
					pos = cc.p(self.lastCard:getPositionX(),self.lastCard:getPositionY() + MY_FIX_UP)
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
end

--获取牌数
function OtherPlayer:getCardCount( ... )
	-- body
	return self.cardCount
end

--设置托管状态
function OtherPlayer:setTrShipState( trShipState )
	-- body
	if self.headNodeFrame then
		if trShipState then
			--搞个机器人
			self.headNodeFrame:setVisible(false)
		else
			self.headNodeFrame:setVisible(true)
		end
	end
end

function OtherPlayer:setLeave( ... )
	-- body
	if not self.headNodeFrame:getChildByName("LeaveImg") then
		local LeaveImg = ccui.ImageView:create("leave.png",UI_TEX_TYPE_PLIST)
		self.headNodeFrame:addChild(LeaveImg)
		LeaveImg:setName("LeaveImg")
		LeaveImg:setScale(1.02)
		LeaveImg:setPosition(cc.p(self.headNodeFrame:getContentSize().width/2,self.headNodeFrame:getContentSize().height/2))
	end
	self.headNodeFrame:setVisible(true)
	self.headNodeFrame:getChildByName("LeaveImg"):setVisible(true)
end

function OtherPlayer:comeBack( ... )
	-- body
	if self.headNodeFrame and self.headNodeFrame:getChildByName("LeaveImg") then
		self.headNodeFrame:setVisible(true)
		self.headNodeFrame:getChildByName("LeaveImg"):setVisible(false)
	end
end

function OtherPlayer:addHead( fileName )
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
		headIconType = self.playerDatas.IconID,
		userID = self.playerDatas.UserID
	}
	local WWHeadSprite = WWHeadSprite:create(param)

	if self.playerType == Player_Type.UpPlayer then --上
		self.headNodeFrame = ccui.ImageView:create("guandan_bottom_head_bg1.png",UI_TEX_TYPE_PLIST)
	elseif self.playerType == Player_Type.LeftPlayer then --左
		self.headNodeFrame = ccui.ImageView:create("guandan_bottom_head_bg2.png",UI_TEX_TYPE_PLIST)
	elseif self.playerType == Player_Type.RightPlayer then --右
		self.headNodeFrame = ccui.ImageView:create("guandan_bottom_head_bg2.png",UI_TEX_TYPE_PLIST)
	end

	local headClippingNode = createClippingNode("guandan_head_robot.png",WWHeadSprite,
		cc.p(self.headNodeFrame:getContentSize().width/2,self.headNodeFrame:getContentSize().height/2+1))
	self.headNodeFrame:addChild(headClippingNode)
	self.headNodeFrame:setName("headNodeFrame")
	self.headNodeFrame:setScale(0.99)
	self.headNodeFrame:setPosition(cc.p(self.headImgMachine:getContentSize().width/2,self.headImgMachine:getContentSize().height/2))
	self.headImgMachine:addChild(self.headNodeFrame,1)

	self:addMoveHead(fileName)
end

function OtherPlayer:addMoveHead( fileName )
	-- body
	if self:getChildByName("moveClippingNode") then
		self:removeChildByName("moveClippingNode")
	end

	local param = {headFile=fileName,maskFile="",headType=2,radius=60,
	frameFile = "common/common_userheader_frame_userinfo.png",
		width = self.headImgMachine:getContentSize().width,
		height = self.headImgMachine:getContentSize().height,
		headIconType = self.playerDatas.IconID,
		userID = self.playerDatas.UserID}

	local moveHeadSprite = WWHeadSprite:create(param)
	local ClippingNode = createClippingNode("guandan_head_robot.png",moveHeadSprite,
		cc.p(self.headImgMachine:getContentSize().width/2,self.headImgMachine:getContentSize().height/2))

	if self.playerType == Player_Type.UpPlayer then --上
		self.moveClippingNode = ccui.ImageView:create("guandan_bottom_head_bg1.png",UI_TEX_TYPE_PLIST)
	elseif self.playerType == Player_Type.LeftPlayer then --左
		self.moveClippingNode = ccui.ImageView:create("guandan_bottom_head_bg2.png",UI_TEX_TYPE_PLIST)
	elseif self.playerType == Player_Type.RightPlayer then --右
		self.moveClippingNode = ccui.ImageView:create("guandan_bottom_head_bg2.png",UI_TEX_TYPE_PLIST)
	end
	ClippingNode:setPosition(cc.p(self.moveClippingNode:getContentSize().width/2,self.moveClippingNode:getContentSize().height/2))
	self.moveClippingNode:addChild(ClippingNode)
	self.moveClippingNode:setName("moveClippingNode")
	self:addChild(self.moveClippingNode,1)
	local pos = self.headImgMachine:convertToWorldSpace(cc.p(self.headNodeFrame:getPositionX(),self.headNodeFrame:getPositionY()))
	self.moveClippingNode:setPosition(cc.p(pos.x,pos.y))
	self.moveClippingNode:setVisible(false)
end

function OtherPlayer:runMoveAction( callBack )
	-- body
	local posSrc = self.headImgMachine:convertToWorldSpace(cc.p(self.headNodeFrame:getPositionX(),self.headNodeFrame:getPositionY()))
	local posDest = cc.p(self:getContentSize().width/2,	self:getContentSize().height/3)
	local midPos = false
	if self.playerType == Player_Type.UpPlayer then --上
		midPos = cc.p(posDest.x,posDest.y+self.moveClippingNode:getContentSize().height)
	elseif self.playerType == Player_Type.LeftPlayer then --左
		midPos = cc.p(posDest.x - self.moveClippingNode:getContentSize().width ,posDest.y)
	elseif self.playerType == Player_Type.RightPlayer then --右
		midPos = cc.p(posDest.x + self.moveClippingNode:getContentSize().width ,posDest.y)
		playSoundEffect("sound/effect/huanwei")
	end
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
			self.rootplayerUiAni:play("animation0",false)
			self.rootPlayerHeadUiAni:play("animation0",false)
			self.rootPlayerHeadUiAni:setAnimationEndCallFunc1("animation0",function ()
				if callBack then
					callBack()
				end
			end)
		end)))
	end)))
end

return OtherPlayer
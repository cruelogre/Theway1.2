-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  玩家基类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullOtherPlayer = class("BullOtherPlayer",cc.Layer)
local BullCard = require("BullFighting.mediator.view.BullCard")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local HeadNode = require("csb.bullfighting.HeadNode")
local Toast = require("app.views.common.Toast")

function BullOtherPlayer:ctor( playerType )
	-- body
	self:init(playerType)
end


--初始化
function BullOtherPlayer:init( playerType )
	-- body
	self.logTag = "BullOtherPlayer"
	--玩家头像一大堆信息
	local playerUi = false
	self.playerType = playerType

	if self.playerType == BullSeverPlayerType.LeftPlayerSeat then --左
		playerUi = require("csb.bullfighting.HeadItem2"):create()
	elseif self.playerType == BullSeverPlayerType.LeftUpPlayerSeat then --左上
		playerUi = require("csb.bullfighting.HeadItem1"):create()
	elseif self.playerType == BullSeverPlayerType.RightUpPlayerSeat then --右上
		playerUi = require("csb.bullfighting.HeadItem1"):create()
	elseif self.playerType == BullSeverPlayerType.RightPlayerSeat then --右
		playerUi = require("csb.bullfighting.HeadItem2"):create()
	end

	self.rootplayerUi = playerUi["root"]
	self.rootplayerUi:setVisible(false)
  	self:addChild(self.rootplayerUi)
  	self.Image_bg = self.rootplayerUi:getChildByName("Image_bg")
  	self.Image_kuang = self.rootplayerUi:getChildByName("Image_kuang")
  	self.beiandget = self.rootplayerUi:getChildByName("beiandget")
  	if cc.Director:getInstance():getContentScaleFactor() == 1 then
		self.beiandget:setProperty([[90]],"bullfighting/wenzishu2.png",56,55,"0")
	else
		self.beiandget:setProperty([[90]],"bullfighting/wenzishu2.png",38,37,"0")
	end

	self.beiandget:setVisible(false)
  	self.Image_kuang:setVisible(false)
	-- self.Image_bg:setVisible(false) -- 匹配到玩家之前隐藏
	if self.playerType == BullSeverPlayerType.LeftPlayerSeat then --左
		self.rootplayerUi:setPosition(cc.p(self.Image_bg:getContentSize().width/2 + 20,self:getContentSize().height*7/12))
	elseif self.playerType == BullSeverPlayerType.LeftUpPlayerSeat then --左上
		self.rootplayerUi:setPosition(cc.p(self:getContentSize().width/2 - self.Image_bg:getContentSize().width,
  			self:getContentSize().height-self.Image_bg:getContentSize().height))
	elseif self.playerType == BullSeverPlayerType.RightUpPlayerSeat then --右上
		self.rootplayerUi:setPosition(cc.p(self:getContentSize().width/2 + self.Image_bg:getContentSize().width,
  			self:getContentSize().height-self.Image_bg:getContentSize().height))
	elseif self.playerType == BullSeverPlayerType.RightPlayerSeat then --右
		self.rootplayerUi:setPosition(cc.p(self:getContentSize().width - self.Image_bg:getContentSize().width/2 - 20,
			self:getContentSize().height*7/12))
	end

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
        playSoundEffect("sound/effect/anniu")
		if self.BullInfo then
			BullFightingManage:requestUserInfo(self.BullInfo.UserId)
		end
	end
	self.Image_headbg:addClickEventListener(checkInfo)
	self.headImgMachine = self.rootPlayerHeadUi:getChildByName("Image_head") --头像
	self.headImgMachine:setLocalZOrder(0)
	self.Image_head_mark = self.rootPlayerHeadUi:getChildByName("Image_head_mark") --头像标志
	self.Image_head_mark:setLocalZOrder(2)
	self.Image_head_mark:setVisible(false)
	self.sidelines = self.rootPlayerHeadUi:getChildByName("sidelines") --旁观
	self.sidelines:setLocalZOrder(2)
	self.sidelines:setVisible(false)
	self.Image_gold = ccui.Helper:seekWidgetByName(self.Image_bg,"Image_gold")
	self.name = ccui.Helper:seekWidgetByName(self.Image_bg,"Text_name") --名字
	self.gold = ccui.Helper:seekWidgetByName(self.Image_gold,"Text_gold") --金币数

	--打的牌
	self.cardLayer = cc.LayerColor:create(cc.c4b(0,0,255,0),0,0)
	self:addChild(self.cardLayer)	
	self.cardLayer:setScale(BullCardScale)
	self.allViewCard = {}
	self.dealCardIndx = 0
	self.overTurnCardIndx = 0
		
	self.haveSetCurState = false
	--onEnter onExit
	self:registerScriptHandler(handler(self,self.onNodeEvent))
end

--onEnter onExit
function BullOtherPlayer:onNodeEvent( event )
	-- body
	if event == "enter" then
    elseif event == "exit" then
      	if self.visibleCardScriptHander then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.visibleCardScriptHander)
			self.visibleCardScriptHander = false
		end
    end
end

function BullOtherPlayer:EnterBullGame( info )
	-- body
	self.BullInfo = clone(info)
	self.rootplayerUi:setVisible(true)
	self.UserId = self.BullInfo.UserId --用户id
	self:setHeadInfo()
	--设置当前状态
	self:setCurState()
end

function BullOtherPlayer:resetGame()
	-- body
	self:releaseCards()
	self.haveSetCurState = false
	
	self.dealCardIndx = 0
	self.overTurnCardIndx = 0
	self.Image_kuang:setVisible(false)
	self.Image_head_mark:setVisible(false)
	self.beiandget:setVisible(false)

	if self.visibleCardScriptHander then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.visibleCardScriptHander)
		self.visibleCardScriptHander = false
	end
end

--继续游戏
function BullOtherPlayer:continueGame( ... )
	-- body
	if not visibleCardScriptHander then
		self.visibleCardScriptHander = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
			-- body
			self:resetGame()

			if self.visibleCardScriptHander then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.visibleCardScriptHander)
				self.visibleCardScriptHander = false
			end
		end, 3, false)
	end
end

--玩家离开
function BullOtherPlayer:exitBullGame( ... )
	-- body
	self.rootplayerUi:setVisible(false)

	self:resetGame()
end

--设置头像信息
function BullOtherPlayer:setHeadInfo()
	-- body
	self.Gender = self.BullInfo.Gender
	self:addHead(DataCenter:getUserdataInstance():getHeadIconByGender(self.BullInfo.Gender))
	----各种设置信息
	self.gold:setString(ToolCom.splitNumFix(tonumber(self.BullInfo.Chip)))
	self.name:setString(subNickName(self.BullInfo.UserName))

	if self.playerType == BullSeverPlayerType.LeftPlayerSeat then --左
    	BullFightingManage.BullFoldMenuLayer:addChatNode(self.playerType,self.BullInfo.UserId,self:getHeadPos(),
    		self:getHeadPos(),false,false)
	elseif self.playerType == BullSeverPlayerType.LeftUpPlayerSeat then --左上
		BullFightingManage.BullFoldMenuLayer:addChatNode(self.playerType,self.BullInfo.UserId,self:getHeadPos(),
			self:getHeadPos(),false,true)
	elseif self.playerType == BullSeverPlayerType.RightUpPlayerSeat then --右上
		BullFightingManage.BullFoldMenuLayer:addChatNode(self.playerType,self.BullInfo.UserId,self:getHeadPos(),
			self:getHeadPos(),false,true)
	elseif self.playerType == BullSeverPlayerType.RightPlayerSeat then --右
		BullFightingManage.BullFoldMenuLayer:addChatNode(self.playerType,self.BullInfo.UserId,self:getHeadPos(),
			self:getHeadPos(),true,false)
	end
end

--还原刚刚进去状态
function BullOtherPlayer:setCurState()
	-- body
	--设置是否参与
	wwlog(self.logTag,"设置其他玩家状态")
	self:setPlayStatus(self.BullInfo.Status)
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
			if self.BullInfo.Status == 2 then --对局者
				self:setMultiple(self.BullInfo.BetRate)
			end
		elseif self.BullInfo.GameStatus == 3 then --亮牌
			if self.BullInfo.Status == 2 then --对局者
				self:setMultiple(self.BullInfo.BetRate)
				self:reductionCard(BullCards,self.BullInfo.CardStatus)
			end
		elseif self.BullInfo.GameStatus == 4 then --结算
		end
	end
end

--还原牌
function BullOtherPlayer:reductionCard( cardTable,CardStatus )
	-- body
	self:createCards(cardTable)
	for k,v in pairs(self.allViewCard) do
  		v:setVisible(true)
  		local pos = cc.p((k-1)*v.faceImg:getContentSize().width/2 + v.faceImg:getContentSize().width/2,
					v.faceImg:getContentSize().height/2)
  		v:setPosition(pos)

  		if CardStatus == 3 then --暗牌
  			v:beginDeal()
  		elseif CardStatus == 4 then --明牌
  			v:dalayDeal()
  		end
	end
end

--设置倍数
function BullOtherPlayer:setMultiple( multi )
	-- body
	if multi > 0 then
		self.beiandget:setVisible(true)
		self.beiandget:setString(":"..multi)
	end
end

--设置庄家
function BullOtherPlayer:setIsBanker( isBanker,blink,callBack )
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
function BullOtherPlayer:setRadomBanker(isBanker)
	-- body
  	self.Image_kuang:setVisible(isBanker)
end

--设置是否参与
function BullOtherPlayer:setPlayStatus( status )
	-- body
	if status == 2 then --参与
		self.sidelines:setVisible(false)
	elseif status == 1 then --旁观
		self.sidelines:setVisible(true)
	end
end

function BullOtherPlayer:setComplete( ... )
	-- body
	if not self.cardLayer:getChildByName("CompleteImgNode") then
		local CompleteImgNode = ccui.ImageView:create("over.png",UI_TEX_TYPE_PLIST)
		self.cardLayer:addChild(CompleteImgNode,BULL_DISTRIBUTE_CARD_MIN_NUM + 1)
		CompleteImgNode:setName("CompleteImgNode")
	  	CompleteImgNode:setPosition(cc.p(self.cardLayer:getContentSize().width/2,self.cardLayer:getContentSize().height/2))
	end
end

--创建牌
function BullOtherPlayer:createCards( cardTable,delNodeFunc,k )
	-- body
	--准备要发的牌
	self.delNodeFunc = delNodeFunc
	self:releaseCards()
  	for i = 1,#cardTable do --BULL_DISTRIBUTE_CARD_MIN_NUM do
  		local cardNode = BullCard:create(cardTable[i])
  		if cardNode then
  			if k then
  				cardNode.createIdx = k-i+1
  			end
  			cardNode:setVisible(false)
  			cardNode:beginDeal()
  			self.cardLayer:addChild(cardNode,i)
  			table.insert(self.allViewCard,cardNode)
  		end
  	end

  	self.cardLayer:setContentSize(cc.size(self.allViewCard[1].faceImg:getContentSize().width*(BULL_DISTRIBUTE_CARD_MIN_NUM + 1)/2,
		self.allViewCard[1].faceImg:getContentSize().height))

	local conPos = self.rootplayerUi:convertToWorldSpace(cc.p(self.Image_bg:getPositionX(),self.Image_bg:getPositionY()))
	local scale = self.cardLayer:getScale()
	if self.playerType == BullSeverPlayerType.LeftPlayerSeat then --左
		self.cardLayer:setPosition(cc.p(conPos.x-(1-scale)*self.cardLayer:getContentSize().width/2+self.Image_bg:getContentSize().width*0.75,
			conPos.y-(1-scale)*self.cardLayer:getContentSize().height/2 - self.cardLayer:getContentSize().height*scale/2))
	elseif self.playerType == BullSeverPlayerType.LeftUpPlayerSeat then --左上
		self.cardLayer:setPosition(cc.p(conPos.x-(1-scale)*self.cardLayer:getContentSize().width/2-self.cardLayer:getContentSize().width*scale/2,
			conPos.y-(1-scale)*self.cardLayer:getContentSize().height/2-self.Image_bg:getContentSize().height/2-self.cardLayer:getContentSize().height*scale))
	elseif self.playerType == BullSeverPlayerType.RightUpPlayerSeat then --右上
		self.cardLayer:setPosition(cc.p(conPos.x-(1-scale)*self.cardLayer:getContentSize().width/2-self.cardLayer:getContentSize().width*scale/2,
			conPos.y-(1-scale)*self.cardLayer:getContentSize().height/2-self.Image_bg:getContentSize().height/2-self.cardLayer:getContentSize().height*scale))
	elseif self.playerType == BullSeverPlayerType.RightPlayerSeat then --右
		self.cardLayer:setPosition(cc.p(conPos.x-(1-scale)*self.cardLayer:getContentSize().width/2-self.Image_bg:getContentSize().width*0.75-self.cardLayer:getContentSize().width*scale,
			conPos.y-(1-scale)*self.cardLayer:getContentSize().height/2 - self.cardLayer:getContentSize().height*scale/2))
	end
end

function BullOtherPlayer:releaseCards( ... )
	-- body
	self.allViewCard = {}
	self.cardLayer:removeAllChildren()
end

function BullOtherPlayer:dealCard(otherDealCardCallBack)
	-- body
	if self.dealCardIndx <= 0 then
		playSoundEffect("sound/effect/bullfight/deal")
	end

	local dealFunc = function ( otherDealCardCallBack )
		-- body
		self.dealCardIndx = self.dealCardIndx + 1
		local cardNode = self.allViewCard[self.dealCardIndx]
		if cardNode then

			local scale = cardNode:getScale()
			cardNode:beginDeal()

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

			local pos = cc.p((self.dealCardIndx-1)*cardNode.faceImg:getContentSize().width/2 + cardNode.faceImg:getContentSize().width/2,
					cardNode.faceImg:getContentSize().height/2)

			cardNode:runAction(cc.Spawn:create(cc.ScaleTo:create(0.3,scale),
				cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function ( ... )
				-- body
				self:dealCard(otherDealCardCallBack)
			end)),cc.EaseSineIn:create(cc.MoveTo:create(0.3,pos)),cc.DelayTime:create(1),cc.CallFunc:create(function ( ... )
				-- body
				if self.dealCardIndx >= BULL_DISTRIBUTE_CARD_MIN_NUM and otherDealCardCallBack then
					otherDealCardCallBack()
				end
			end)))
		end
	end

	dealFunc(otherDealCardCallBack)
end

--翻转牌
function BullOtherPlayer:overTurn(callBack)
	-- body
	local dealFunc = function ( callBack )
		-- body
		self.overTurnCardIndx = self.overTurnCardIndx + 1
		local cardNode = self.allViewCard[self.overTurnCardIndx]
		if cardNode then
			cardNode:runAction(cc.Spawn:create(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function ( ... )
				-- body
				self:overTurn(callBack)
			end)),cc.CallFunc:create(function ( ... )
					-- body
					if self.overTurnCardIndx >= BULL_DISTRIBUTE_CARD_MIN_NUM then
						cardNode:overTurn(function ( ... )
							-- body
							if callBack then
								callBack()
							end
						end)
					else
						cardNode:overTurn()
					end
				end)))
		end
	end

	dealFunc(callBack)
end

--结算
function BullOtherPlayer:CalculaCardResult( data,callBack )
	-- body
	for k,v in pairs(self.allViewCard) do
		v:setCard(data.Card[k].val,data.Card[k].color)
	end

	--隐藏完成
	if self.cardLayer:getChildByName("CompleteImgNode") then
		self.cardLayer:removeChildByName("CompleteImgNode")
	end

	-- --隐藏投注数
	-- self.beiandget:setVisible(false)
	--音效牛几
	-- playNiuValSoundFileName(self.Gender,data.BullNum)

	self:overTurn(function ( ... )
		-- body
		if data.BullNum > BullType.None then
			for k,v in pairs(self.allViewCard) do
				if k > 3 then
					v:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(v.faceImg:getContentSize().width/4,0)),
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function ( ... )
						-- body
						if callBack and k == #self.allViewCard then
							callBack()
						end
					end)))
				end
			end
		else
			if callBack then
				callBack()
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
	end)
end

function BullOtherPlayer:setGoldAnimate( golds )
	-- body
	local gold = tonumber(golds)
	local goldsget = false
	if gold > 0 then
		goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu2.png",56,55,"0")
		if cc.Director:getInstance():getContentScaleFactor() == 1 then
			goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu2.png",56,55,"0")
		else
			goldsget = ccui.TextAtlas:create([[90]],"bullfighting/wenzishu2.png",38,37,"0")
		end

		goldsget:setString(";"..gold)
	elseif gold < 0 then
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
	goldsget:setScale(2.5)
	self.cardLayer:addChild(goldsget,BULL_DISTRIBUTE_CARD_MIN_NUM + 2)
	goldsget:setName("goldsget")
  	goldsget:setPosition(cc.p(self.cardLayer:getContentSize().width,self.cardLayer:getContentSize().height/2))

  	goldsget:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(1,cc.p(0,300))),
  			cc.FadeOut:create(0.5),cc.CallFunc:create(function ( ... )
  				-- body
  				goldsget:removeFromParent()
  			end)))
end

--获得金币位置
function BullOtherPlayer:getGoldPos( ... )
	-- body
	return self.Image_bg:convertToWorldSpace(cc.p(self.Image_gold:getPositionX() - self.Image_gold:getContentSize().width*0.38,self.Image_gold:getPositionY()))
end

--获得头像位置
function BullOtherPlayer:getHeadPos( ... )
	-- body
	return self.Image_bg:convertToWorldSpace(cc.p(self.Image_headbg:getPositionX(),self.Image_headbg:getPositionY()))
end

function BullOtherPlayer:addHead( fileName )
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
		headIconType = self.BullInfo.Icon,
		userID = self.BullInfo.UserId
	}
	local WWHeadSprite = WWHeadSprite:create(param)
	self.headNodeFrame = ccui.ImageView:create("otherkuang.png",UI_TEX_TYPE_PLIST)
	local headClippingNode = createClippingNode("rabot.png",WWHeadSprite,
		cc.p(self.headNodeFrame:getContentSize().width/2,self.headNodeFrame:getContentSize().height/2+1))
	self.headNodeFrame:addChild(headClippingNode)
	self.headNodeFrame:setName("headNodeFrame")
	self.headNodeFrame:setScale(0.99)
	self.headNodeFrame:setPosition(cc.p(self.headImgMachine:getContentSize().width/2,self.headImgMachine:getContentSize().height/2))
	self.headImgMachine:addChild(self.headNodeFrame,1)
end

return BullOtherPlayer
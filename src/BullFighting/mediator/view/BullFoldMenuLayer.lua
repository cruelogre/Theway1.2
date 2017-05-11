-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  设置层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullFoldMenuLayer = class("BullFoldMenuLayer",cc.Layer)
local Toast = require("app.views.common.Toast")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local SimpleRichText = require("app.views.uibase.SimpleRichText")

function BullFoldMenuLayer:ctor( ... )
	-- body
	self:init()
end

function BullFoldMenuLayer:init( ... )
	-- body
	self.logTag = "BullFoldMenuLayer.lua"
	--右上角菜单
	local FoldMenu = require("csb.bullfighting.bullFoldMenu"):create()
	if not FoldMenu then
		return
	end
	self.rootFoldMenu = FoldMenu["root"]
	self.foldedmenu_bg = self.rootFoldMenu:getChildByName("Image_1")
	self.foldedmenu_main = self.rootFoldMenu:getChildByName("pull")
	self.rootFoldMenu:setPosition(cc.p(self:getContentSize().width - self.foldedmenu_bg:getContentSize().width/2,
		self:getContentSize().height))
  	self:addChild(self.rootFoldMenu)

  	self.foldedmenu_bg:setPosition(cc.p(0,self.foldedmenu_bg:getContentSize().height))
  	self.foldedmenu_set = self.foldedmenu_bg:getChildByName("set") --设置按钮
  	self.foldedmenu_exit = self.foldedmenu_bg:getChildByName("exit") --退出按钮

  	self.foldedmenu_main:addClickEventListener(handler(self,self.btnClick))
  	self.foldedmenu_set:addClickEventListener(handler(self,self.btnClick))
  	self.foldedmenu_exit:addClickEventListener(handler(self,self.btnClick))
  	self.foldedmenuRunActioonEnd = true

  	--查看玩家信息
	local checkInfo = require("csb.guandan.GameDataCard"):create()
	if not checkInfo then
		return
	end
	self.rootCheckInfo = checkInfo["root"]
	self:addChild(self.rootCheckInfo)
	self.rootCheckInfo:setVisible(false)
	self.ImageInfoBg = self.rootCheckInfo:getChildByName("Image_info_bg")
	self.Image_headbg = self.ImageInfoBg:getChildByName("Image_headbg")
end

function BullFoldMenuLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")
	if ref == self.foldedmenu_main then
		self:closePlayerInfo()
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
	elseif ref == self.foldedmenu_set then
		FSRegistryManager:runWithFSM(FSMConfig.FSM_BULLFIGHTING):trigger("setting", 
			{parentNode=display.getRunningScene(), zorder = zorderLayer.CustomLayer})
		self:resetMenuMain() --点击了托管，应该要隐藏
	elseif ref == self.foldedmenu_exit then
		self:resetMenuMain() --点击了托管，应该要隐藏
  		self:exitGame()
	end
end

function BullFoldMenuLayer:resetMenuMain( ... )
	-- body
	if self.foldedmenuRunActioonEnd then
		self.foldedmenuRunActioonEnd = false
		self.foldedmenu_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(0,self.foldedmenu_bg:getContentSize().height)),cc.CallFunc:create(function ( ... )
			-- body
			self.foldedmenuRunActioonEnd = true
		end)))
	end

	self:closePlayerInfo()
end

function BullFoldMenuLayer:exitGame( ... )
	-- body
	if BullFightingManage.gameState == BullGameStateType.waitBegin or BullFightingManage.SelfPlayer.BullInfo.Status == 1 then
		BullFightingManage:exitGame()
	else
		Toast:makeToast(i18n:get('str_bullfighting','bull_cannotexit'), 1.0):show()
	end
end

function BullFoldMenuLayer:addChatNode( playid,userid,position1,position2,flippedX,flippedY )
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

--查看玩家信息
function BullFoldMenuLayer:checkPlayerInfo( playerType,info )
	-- body
	self.rootCheckInfo:setScale(0)
	self.rootCheckInfo:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 1.0)))
	self.rootCheckInfo:setVisible(true)

	local Image_head = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"player_head") --头像
	local Text_username = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"Text_username") --名字
	local Text_winrate_2 = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"Text_winrate_2") --胜率
	local Button_add = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"Button_add") --加好友
	local Text_Id = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"Text_Id") --ID
	local jingyanBar = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"LoadingBar_jinyan") --经验
	local Text_jinyan = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"Text_jinyan")
	local meiliBar = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"LoadingBar_meili") --魅力
	local Text_meili = ccui.Helper:seekWidgetByName(self.ImageInfoBg,"Text_meili") --魅力

	local function addHead( fileName )
	-- body
		if Image_head:getChildByName("WWHeadSprite") then
			Image_head:removeChildByName("WWHeadSprite")
		end

		local param = {
			headFile=fileName,maskFile="",
			headType=2,
			radius=60,
			width = Image_head:getContentSize().width,
			height = Image_head:getContentSize().height,
			headIconType = info.IconID,
			userID = info.UserID
	    }
		local HeadSprite = WWHeadSprite:create(param)
		local clippingNode = createClippingNode("guandan_head_robot.png",HeadSprite,
			cc.p(Image_head:getContentSize().width/2,Image_head:getContentSize().height/2))
		clippingNode:setName("WWHeadSprite")
		Image_head:addChild(clippingNode,1)
	end
	addHead(DataCenter:getUserdataInstance():getHeadIconByGender(info.Gender))
	Text_username:setString("")
	Text_username:removeAllChildren()
	if info.Gender == GenderType.male then
	  	local RichText = SimpleRichText:create(string.format("%s|%s;;",info.Nickname,"guandan/datacard/datacard_sex_male.png"),
			Text_username:getFontSize(),Text_username:getTextColor(),Text_username:getFontName())
	  	RichText:setAnchorPoint(Text_username:getAnchorPoint())
		Text_username:addChild(RichText)
	elseif info.Gender == GenderType.female then
	  	local RichText = SimpleRichText:create(string.format("%s|%s;;",info.Nickname,"guandan/datacard/datacard_sex_female.png"),
			Text_username:getFontSize(),Text_username:getTextColor(),Text_username:getFontName())
	  	RichText:setAnchorPoint(Text_username:getAnchorPoint())
		Text_username:addChild(RichText)
	end

	if info.Victories == "" then
		Text_winrate_2:setString("0.0%")
	else
		Text_winrate_2:setString(info.Victories.."%")
	end

	local function addFriend( ... )
		-- body
		self.rootCheckInfo:setVisible(false)
		local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)
		local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)
		SocialContactProxy:requestAddBuddy(info.UserID,wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID,
			BullFightingSceneController.GamePlayID)
	end
	Button_add:addClickEventListener(addFriend)
    
	Text_Id:setString("ID"..info.UserID)

	jingyanBar:setPercent(info.GamePoint*100/info.NextLevelPoint)
	Text_jinyan:setString(info.GamePoint.."/"..info.NextLevelPoint)

	meiliBar:setPercent(0)
	Text_meili:setString("0/0")


	local pos = false
	Button_add:setVisible(true)
	if playerType == BullPlayerType.SelfPlayerSeat then
		Button_add:setVisible(false)

		local node = BullFightingManage.SelfPlayer.Image_headbg
		pos = cc.p(node:getPositionX()-node:getContentSize().width/2+self.ImageInfoBg:getContentSize().width/2,
			node:getPositionY()+node:getContentSize().height/2+self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("ourkuang.png",UI_TEX_TYPE_PLIST)
	elseif playerType == BullPlayerType.RightPlayerSeat then

		local node = BullFightingManage.RightPlayer.rootplayerUi
		local Image_bg = BullFightingManage.RightPlayer.Image_bg

		pos = cc.p(node:getPositionX()-Image_bg:getContentSize().width/2-self.ImageInfoBg:getContentSize().width/2,	node:getPositionY() + Image_bg:getContentSize().height/2 - self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("otherkuang.png",UI_TEX_TYPE_PLIST)

	elseif playerType == BullPlayerType.RightUpPlayerSeat then

		local node = BullFightingManage.RightUpPlayer.rootplayerUi
		local Image_bg = BullFightingManage.RightUpPlayer.Image_bg

		pos = cc.p(node:getPositionX(),	node:getPositionY()-Image_bg:getContentSize().height/2-self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("otherkuang.png",UI_TEX_TYPE_PLIST)

	elseif playerType == BullPlayerType.LeftUpPlayerSeat then
		
		local node = BullFightingManage.LeftUpPlayer.rootplayerUi
		local Image_bg = BullFightingManage.LeftUpPlayer.Image_bg
		
		pos = cc.p(node:getPositionX(),node:getPositionY() - Image_bg:getContentSize().height/2 - self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("otherkuang.png",UI_TEX_TYPE_PLIST)
	elseif playerType == BullPlayerType.LeftPlayerSeat then

		local node = BullFightingManage.LeftPlayer.rootplayerUi
		local Image_bg = BullFightingManage.LeftPlayer.Image_bg
		
		pos = cc.p(node:getPositionX() + Image_bg:getContentSize().width/2 + self.ImageInfoBg:getContentSize().width/2,	node:getPositionY() + Image_bg:getContentSize().height/2 - self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("otherkuang.png",UI_TEX_TYPE_PLIST)
	end

	local HallChatService = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)
    if  playerType == BullPlayerType.SelfPlayerSeat or HallChatService:checkFriend({userid=info.UserID,owerid = DataCenter:getUserdataInstance():getValueByKey("userid") }) then
		Button_add:setTouchEnabled(false)
		Button_add:setBright(false)
	else
		Button_add:setTouchEnabled(true)
		Button_add:setBright(true)
	end
end

--关闭玩家信息
function BullFoldMenuLayer:closePlayerInfo( ... )
	-- body
	self.rootCheckInfo:setVisible(false)
end

return BullFoldMenuLayer
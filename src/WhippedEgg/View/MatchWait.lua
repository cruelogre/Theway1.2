-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  等待层
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchWait = class("MatchWait",cc.LayerColor)
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local LuaWxShareNativeBridge = require("app.utilities.LuaWxShareNativeBridge")
local WWItemSprite = require("app.views.customwidget.WWItemSprite")
local WWNetSprite = require("app.views.customwidget.WWNetSprite")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)

function MatchWait:ctor( ... )
	-- body
	self:init()
end

function MatchWait:init( ... )
	-- body
	self.logTag = "MatchWait"
	
	--比赛等待
	local matchWait = require("csb.guandan.MatchWait"):create()
	if not matchWait then
		return
	end
	self.rootMatchWait = matchWait["root"]
	self.rootMatchWaitAni = matchWait["animation"]
	self.rootMatchWait:runAction(self.rootMatchWaitAni)
	local backGrand = self.rootMatchWait:getChildByName("backGrand")
	FixUIUtils.stretchUI(backGrand)
	FixUIUtils.setRootNodewithFIXED(self.rootMatchWait)
  	self:addChild(self.rootMatchWait)
  	self.rootMatchWait:setVisible(false)
  	self.Image_head = ccui.Helper:seekWidgetByName(backGrand,"Image_head")
  	self.Image_bg = ccui.Helper:seekWidgetByName(backGrand,"Image_bg")
  	self.Image_bgLengh = self.Image_bg:getContentSize().width*2/3
  	self.title = ccui.Helper:seekWidgetByName(backGrand,"title")
  	self.ImageBar = ccui.Helper:seekWidgetByName(backGrand,"ImageBar")
  	self.progress = ccui.Helper:seekWidgetByName(backGrand,"progress")
  	self.beginNode = ccui.Helper:seekWidgetByName(backGrand,"beginNode")
  	self.endNode = ccui.Helper:seekWidgetByName(backGrand,"endNode")
  	self.middleNode = ccui.Helper:seekWidgetByName(backGrand,"middleNode")
  	self.middleNode:setVisible(false)
  	self.mineNode = ccui.Helper:seekWidgetByName(backGrand,"mineNode")


--[[  	--比赛结算
	local matchSettment = require("csb.guandan.MatchSettlement"):create()
	if not matchSettment then
		return
	end
	self.rootMatchSettment = matchSettment["root"]
	self.rootMatchSettmentAni = matchSettment["animation"]
	FixUIUtils.setRootNodewithFIXED(self.rootMatchSettment)
	FixUIUtils.stretchUI(self.rootMatchSettment:getChildByName("Image_15"))
	self:addChild(self.rootMatchSettment)
	self.rootMatchSettment:setVisible(false)
	self.rootMatchSettment:runAction(self.rootMatchSettmentAni)
	local ImageDi = self.rootMatchSettment:getChildByName("Image")
	self.SettmentTitle = ccui.Helper:seekWidgetByName(ImageDi,"titile")
	self.SettmentRank = ccui.Helper:seekWidgetByName(ImageDi,"rank")
	self.SettmentBack = ccui.Helper:seekWidgetByName(ImageDi,"back")
	self.SettmentShowoff = ccui.Helper:seekWidgetByName(ImageDi,"showoff")
	self.SettmentAward = ccui.Helper:seekWidgetByName(ImageDi,"Panel_award")
	self.SettmentChenghao = ccui.Helper:seekWidgetByName(ImageDi,"Panel_chenghao")
	self.SettmentAward:setVisible(false)
	self.SettmentChenghao:setVisible(false)
	self.SettmentBack:addClickEventListener(handler(self,self.btnClick))
	self.SettmentShowoff:addClickEventListener(handler(self,self.btnClick))--]]

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

	self:registerScriptHandler(handler(self,self.onNodeEvent))

	self.LastMatchRankInfo = false
	self.CurMatchRankInfo = false
end

--onEnter onExit
function MatchWait:onNodeEvent( event )
	-- body
	if event == "enter" then
    elseif event == "exit" then
    end
end

--按钮事件
function MatchWait:btnClick( ref )
    playSoundEffect("sound/effect/anniu")

	if ref:getName() == "back" then
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref:getName() == "showoff" then
		self.SettmentBack:setVisible(false)
		self.SettmentShowoff:setVisible(false)

		--截屏回调方法  
		 local function afterCaptured(succeed, outputFile)  
		    if succeed then  
		     	wwlog(self.logTag,"截屏分享成功%s",outputFile)
		     	LuaWxShareNativeBridge:create():callNativeShareByPhotos(outputFile,1)
		     	self.SettmentBack:setVisible(true)
				self.SettmentShowoff:setVisible(true)
				-- GameManageFactory:getCurGameManage():exitGame()
		    else  
		        wwlog(self.logTag,"截屏分享失败")  
		    end  
		 end  
	  
	    local fileName = "CaptureScreenTest.png"  
		fileName = ww.IPhoneTool:getInstance():getExternalFilesDir()..fileName
	    -- 截屏  
	    cc.utils:captureScreen(afterCaptured, fileName)  
	end
end

--剩余几桌
function MatchWait:setDeskCount( count )
	-- body
	self.title:setString("")
  	self.title:removeAllChildren()
  	local RichText = SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_desk'),count),
		self.title:getFontSize(),self.title:getTextColor())
  	RichText:setAnchorPoint(self.title:getAnchorPoint())
	self.title:addChild(RichText)
end

function MatchWait:setMatchRank( info )
	-- body
	self.LastMatchRankInfo = self.CurMatchRankInfo
	self.CurMatchRankInfo = info
	local curRank = self.CurMatchRankInfo.MRanking
	local maxRank = self.CurMatchRankInfo.TotalNumber

	local mineNodeText1 = ccui.Helper:seekWidgetByName(self.mineNode,"Text_1")
  	mineNodeText1:setString("")
  	mineNodeText1:removeAllChildren()
  	if GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_SINGLE then
		mineNodeText1:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_currank'),curRank,maxRank),
			mineNodeText1:getFontSize(),mineNodeText1:getTextColor()))
	elseif GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_MUTIPLE then
		mineNodeText1:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_currank'),curRank,maxRank/2),
			mineNodeText1:getFontSize(),mineNodeText1:getTextColor()))
	end
end

function MatchWait:setMatcheliminateCount( count )
	-- body
	wwlog(self.logTag,string.format("共%d人被我淘汰",count))

	self.eliminateCount = count

  	local mineNodeText2 = ccui.Helper:seekWidgetByName(self.mineNode,"Text_2")
	mineNodeText2:setString("")
  	mineNodeText2:removeAllChildren()
  	if GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_SINGLE then
		mineNodeText2:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_eliminate'),self.eliminateCount),
			mineNodeText2:getFontSize(),mineNodeText2:getTextColor()))
	elseif GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_MUTIPLE then
		mineNodeText2:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_eliminate_deque'),self.eliminateCount/2),
			mineNodeText2:getFontSize(),mineNodeText2:getTextColor()))
	end
end

--等待其他玩家
function MatchWait:waitOther( deskInfo,matchInfo )
	-- body
	if isLuaNodeValid(GameManageFactory:getCurGameManage().FoldMenuLayer) then
		GameManageFactory:getCurGameManage().FoldMenuLayer:setFoldMenuVisible(false)
	end
	wwlog(self.logTag,"比赛等待其他玩家")
	self.deskInfo = deskInfo
	self.matchInfo = matchInfo
	self.setCount = #self.deskInfo --一共几轮
	self.curSet = self.matchInfo.SetNo --现在第几轮
	self.Image_head:getChildByName("Text_3"):setString(GameManageFactory:getCurGameManage():getRoomName())
	self.rootMatchWait:setVisible(true)
	self.rootMatchWaitAni:play("animation0",true)
	local ContentSize1 = self.Image_bg:getContentSize()
	self.Image_bg:setContentSize(cc.size(math.min(self.Image_bgLengh*self.setCount,self.Image_bgLengh*1.5),self.Image_bg:getContentSize().height))
	local ContentSize2 = self.Image_bg:getContentSize()
	local layout = self.ImageBar:getComponent("__ui_layout")
	if layout then
		local size = layout:getSize()
		size.width = size.width*ContentSize2.width/ContentSize1.width
		size.height = size.height*ContentSize2.height/ContentSize1.height
		layout:setSize(size)
		layout:refreshLayout()
		self.ImageBar:setContentSize(size)
	end
	self.ImageBar:setPosition(cc.p(self.Image_bg:getContentSize().width/2,self.Image_bg:getContentSize().height/2))

	--起始
	local beginNodeText = ccui.Helper:seekWidgetByName(self.beginNode,"Text")
	local beginNodeImg = ccui.Helper:seekWidgetByName(self.beginNode,"Image_6")
	beginNodeText:setString("")
  	beginNodeText:removeAllChildren()
  	if GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_SINGLE then
		beginNodeText:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_begin'),self.deskInfo[1]),
			beginNodeText:getFontSize(),beginNodeText:getTextColor()))
	elseif GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_MUTIPLE then
		beginNodeText:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_begin_deque'),self.deskInfo[1]/2),
			beginNodeText:getFontSize(),beginNodeText:getTextColor()))
	end
	local text = ccui.Text:create(string.format("%d人开赛",self.deskInfo[1]),"FZZhengHeiS-B-GB.ttf",beginNodeText:getFontSize())
	beginNodeImg:setContentSize(cc.size(math.max(beginNodeImg:getContentSize().width,text:getContentSize().width + 20 ),beginNodeImg:getContentSize().height))

	-- --我
	self.mineNode:setPosition(cc.p(self.ImageBar:getContentSize().width*(2*self.curSet - 1)/(self.setCount*2),self.mineNode:getPositionY()))
	self.progress:setContentSize(cc.size(self.mineNode:getPositionX(),self.progress:getContentSize().height))
	if self.mineNode:getChildByName("WWHeadSprite") then
		self.mineNode:removeChildByName("WWHeadSprite")
	end

	local param = {headFile="guandan/head_girl.png",frameFile = "common/common_userheader_frame_userinfo.png",maskFile="",headType=1,radius=self.mineNode:getContentSize().width/2+2,
		width = 100,
		height = 100}
	self.WWHeadSprite = WWHeadSprite:create(param)
	self.WWHeadSprite:setPosition(cc.p(self.mineNode:getContentSize().width/2,self.mineNode:getContentSize().height/2))
	self.WWHeadSprite:setName("WWHeadSprite")
	self.mineNode:addChild(self.WWHeadSprite,1)

  	--中间
	for i=1,self.setCount-1 do
		local middleNode = self.middleNode:clone()
		middleNode:setPosition(cc.p(i*self.ImageBar:getContentSize().width/self.setCount,self.middleNode:getPositionY()))
		middleNode:setVisible(true)
		self.ImageBar:addChild(middleNode)

	  	local middleNodeText = ccui.Helper:seekWidgetByName(middleNode,"Text")
		local midNodeImg = ccui.Helper:seekWidgetByName(middleNode,"Image_6")
	  	middleNodeText:setString("")
	    middleNodeText:removeAllChildren()
	   	if GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_SINGLE then
	  		middleNodeText:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_promotion'),self.deskInfo[i+1]),
				middleNodeText:getFontSize(),middleNodeText:getTextColor()))
	  	elseif GameManageFactory:getCurGameManage().teamType == Team_Type.TEAM_MUTIPLE then
	  		middleNodeText:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_promotion_deque'),self.deskInfo[i+1]/2),
				middleNodeText:getFontSize(),middleNodeText:getTextColor()))
	  	end
	  	local text = ccui.Text:create(string.format("%d人晋级",self.deskInfo[1]),"FZZhengHeiS-B-GB.ttf",middleNodeText:getFontSize())
		midNodeImg:setContentSize(cc.size(math.max(midNodeImg:getContentSize().width,text:getContentSize().width + 20 ),midNodeImg:getContentSize().height))
	end
end


function MatchWait:teamTypeChange( ... )
	-- body
	if self.CurMatchRankInfo then
		self:setMatchRank(self.CurMatchRankInfo)
	end

	if self.eliminateCount then
		self:setMatcheliminateCount(self.eliminateCount)
	end

	if self.deskInfo and self.matchInfo then
		self:waitOther(self.deskInfo,self.matchInfo)
	end
end

function MatchWait:matchContinue( ... )
	-- body
  	self.rootMatchWait:setVisible(false)
  	if isLuaNodeValid(GameManageFactory:getCurGameManage().FoldMenuLayer) then
		GameManageFactory:getCurGameManage().FoldMenuLayer:setFoldMenuVisible(true)
	end
end

--结算
function MatchWait:settment( info )
	-- body
	wwlog(self.logTag,"比赛结算")
	playSoundEffect("sound/effect/jiangzhuang")
  	self.rootMatchSettment:setVisible(true)
	self.rootMatchSettmentAni:play("animation0",false)
	self.rootMatchSettmentAni:setFrameEventCallFunc(function (frame)
		if info.awardlist and #info.awardlist > 0 then
	  		self.SettmentAward:setVisible(true)
			self.SettmentChenghao:setVisible(false)
			local Text_1_1 = self.SettmentAward:getChildByName("Text_1_1")
			local Panel_prize = self.SettmentAward:getChildByName("Panel_prize")
			Panel_prize:removeAllChildren()

			for k,v in pairs(info.awardlist) do
				local mRank = info.MRanking
				local matchid = WhippedEggSceneProxy.gamezoneid
				local fileName = false
				if mRank <= 3 then
					--fileName = string.format("hall/match/match_desc_prize%d.png",mRank)
					
				else
					--fileName = "common/common_prize_default.png"
				end
				fileName = "common/common_prize_default.png"
				local prize = WWItemSprite:createItem({
					id = v.FID,
					count = v.MagicCount,
					defaultSrc = fileName,
					remoteSrc = MatchCfg:getMatchImageURL(2,matchid,mRank),
					fontColor = cc.c3b(0x00,0x00,0x00),
				})
				--更新金币钻石
				updataGoods(v.FID,v.MagicCount)

				prize:setPosition(cc.p(prize:getContentSize().width*0.8 + (k-1)*prize:getContentSize().width,Text_1_1:getPositionY()+prize:getContentSize().height))
	  			Panel_prize:addChild(prize)
			end
	  	else
	  		self.SettmentAward:setVisible(false)
			self.SettmentChenghao:setVisible(true)
		end
	end)

	self.SettmentTitle:setString("")
 	self.SettmentTitle:removeAllChildren()
  	self.SettmentTitle:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_settment'),
    DataCenter:getUserdataInstance():getValueByKey("nickname"),(info and info.name) or "蛙蛙游戏"),
  			self.SettmentTitle:getFontSize(),self.SettmentTitle:getTextColor()))

  	self.SettmentRank:setString(string.format(i18n:get('str_guandan','guandan_wait_settment_rank'),(info and info.MRanking) or 0))
end

--查看玩家信息
function MatchWait:checkPlayerInfo( playerType,info )
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
	-- addHead(info.fileName)
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
		local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
		local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)

		if WhippedEggSceneController.gameType == Game_Type.PersonalPromotion or 
			WhippedEggSceneController.gameType == Game_Type.PersonalRandom or 
			WhippedEggSceneController.gameType == Game_Type.PersonalRcircle then    --私人房
			SocialContactProxy:requestAddBuddy(info.UserID,wwConfigData.GAMELOGICPARA.GUANDAN.GAME_ID,
			WhippedEggSceneProxy.GamePlayID,WhippedEggSceneController.gameZoneId)
		else
			SocialContactProxy:requestAddBuddy(info.UserID,wwConfigData.GAMELOGICPARA.GUANDAN.GAME_ID,
			WhippedEggSceneProxy.GamePlayID)
		end
	end
	Button_add:addClickEventListener(addFriend)

	Text_Id:setString("ID"..info.UserID)
	jingyanBar:setPercent(info.GamePoint*100/info.NextLevelPoint)
	Text_jinyan:setString(info.GamePoint.."/"..info.NextLevelPoint)
	meiliBar:setPercent(0)
	Text_meili:setString("0/0")

	local pos = false
	Button_add:setVisible(true)
	if playerType == Player_Type.UpPlayer then
		
		local node = GameManageFactory:getCurGameManage().UpPlayer.rootplayerUi
		local Image_bg = GameManageFactory:getCurGameManage().UpPlayer.Image_bg

		pos = cc.p(node:getPositionX(),node:getPositionY()-Image_bg:getContentSize().height/2-self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("guandan_bottom_head_bg1.png",UI_TEX_TYPE_PLIST)
	elseif playerType == Player_Type.LeftPlayer then

		local node = GameManageFactory:getCurGameManage().LeftPlayer.rootplayerUi
		local Image_bg = GameManageFactory:getCurGameManage().LeftPlayer.Image_bg

		pos = cc.p(node:getPositionX()+Image_bg:getContentSize().width/2+self.ImageInfoBg:getContentSize().width/2,
			node:getPositionY()+Image_bg:getContentSize().height/2-self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("guandan_bottom_head_bg2.png",UI_TEX_TYPE_PLIST)

	elseif playerType == Player_Type.RightPlayer then

		local node = GameManageFactory:getCurGameManage().RightPlayer.rootplayerUi
		local Image_bg = GameManageFactory:getCurGameManage().RightPlayer.Image_bg

		pos = cc.p(node:getPositionX()-Image_bg:getContentSize().width/2-self.ImageInfoBg:getContentSize().width/2,
			node:getPositionY()+Image_bg:getContentSize().height/2-self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("guandan_bottom_head_bg2.png",UI_TEX_TYPE_PLIST)

	elseif playerType == Player_Type.SelfPlayer then
		Button_add:setVisible(false)

		local node = GameManageFactory:getCurGameManage().MyPlayer.Image_headbg
		pos = cc.p(node:getPositionX()-node:getContentSize().width/2+self.ImageInfoBg:getContentSize().width/2,
			node:getPositionY()+node:getContentSize().height/2+self.ImageInfoBg:getContentSize().height/2)
		self.rootCheckInfo:setPosition(pos)
		self.Image_headbg:loadTexture("guandan_bottom_head_bg1.png",UI_TEX_TYPE_PLIST)
	end
	local HallChatService = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)
    if playerType == Player_Type.SelfPlayer or HallChatService:checkFriend({userid=info.UserID,owerid = DataCenter:getUserdataInstance():getValueByKey("userid") }) then
		Button_add:setTouchEnabled(false)
		Button_add:setBright(false)
	else
		Button_add:setTouchEnabled(true)
		Button_add:setBright(true)
	end
end

--关闭玩家信息
function MatchWait:closePlayerInfo( ... )
	-- body
	self.rootCheckInfo:setVisible(false)
end

function MatchWait:getPlayerInfoVisible( ... )
	-- body
	return self.rootCheckInfo:isVisible()
end

return MatchWait
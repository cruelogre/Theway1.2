-------------------------------------------------------------------------
-- Title:        个人详情面板
-- Author:    Jackie Liu
-- Date:       2016/10/18 16:33:18
-- Desc:
--        一键注册：就是绑定手机号。
--        切换至游客账号：当前账号肯定已经绑定手机，再注册一个新号并登录。以后只要当前账号切换至游客账号就是这个新号。
--        登录到已有账号：注销当前账号，注销成功后手机账号登录。
--        问题：
--            1、如果这些过程中发生了断网情况，很有可能是后台的通讯层机制主动断网了，请和后台沟通确认这些过程会不会导致断开连接。
--            2、登录到已有账号会触发断网，所以在注销之后手动断开重连了一次。
-- Modify: 2016/12/23  by cruelogre 添加进入后打开界面
--  	   2016/12/26  by cruelogre 修改进入后需要查询的用户ID数据，如果ID是空则标识自己 否则其他人的UI显示不一样：一键注册，编辑
--         2016/12/27  by cruelogre  修改UI为斗牛 惯蛋可滑动显示的游戏数据
-- 		   2017/1/22 by cruelogre  修改UI添加好友按钮  如果是别人 不是好友就显示+好友 是好友就显示已是好友
--		   2017/2/7  by cruelogre  修改显示头像bug
--		   2017/2/21 by cruelogre 修改地区显示bug  
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local UserInfoLayer = class("UserInfoLayer"
, require("app.views.uibase.PopWindowBase")
, require("packages.mvc.Mediator"))
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local HallProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)

local Toast = require("app.views.common.Toast")
local userData = DataCenter:getUserdataInstance()

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

local csbMainPath = "csb.hall.userinfo.UserinfoLayer"
local Node_UserInfoContent = require("csb.hall.userinfo.Node_UserInfoContent")

local ViewChildConf =
{
    changeHead = "hall.mediator.view.widget.userinfo.UserInfo_widget_cghead",
    changeNick = "hall.mediator.view.widget.userinfo.UserInfo_widget_cgnick",
    changeSex = "hall.mediator.view.widget.userinfo.UserInfo_widget_cgsex",
    edit = "hall.mediator.view.widget.userinfo.UserInfo_widget_Edit",
    login = "hall.mediator.view.widget.account.Login",
    register = "hall.mediator.view.widget.account.Register",
    resetPsw = "hall.mediator.view.widget.account.ResetPsw",
    setPsw = "hall.mediator.view.widget.account.SetPsw",
    verifyCode = "hall.mediator.view.widget.account.VerifyCode",
}

local getChild = function(node, name) return ccui.Helper:seekWidgetByName(node, name) end

local getStr = function(flag)
    return i18n:get("str_userInfo", flag)
end
local getComStr = function(flag)
    return i18n:get("str_common", flag)
end

function UserInfoLayer:ctor(param)
    UserInfoLayer.super.ctor(self)
    self._childViews = { }
    self.logTag = "UserInfoLayer.lua"
	self.userid = param.userid
	self.enterActions = {}--进入时的动作
	self.hasEnter = false
	self.handlers = {}
	self.isFriend = param.isFriend --是否是我的好友
    self:init()
end

function UserInfoLayer:onEnter()
    self.super.onEnter(self)
    self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
    self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED, handler(self, self.agreeFriend))
    self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_FRIEND_DELETED, handler(self, self.deleteFriend))
	
    self._listener = WWFacade:addCustomEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, function(event)
        local handleType = unpack(event._userdata)
        if handleType == 1 then
            -- 个人数据刷新
			if not self.userid or tostring(self.userid)==tostring(userData:getValueByKey("userid")) then
				self._txtCrystal:setString(ToolCom.splitNumFix(userData:getGoodsAttrByName("shuij", "count") or 0))
				self._txtDiamond:setString(ToolCom.splitNumFix(tonumber(userData:getValueByKey("Diamond")) or 0))
				self._txtGold:setString(ToolCom.splitNumFix(tonumber(userData:getValueByKey("GameCash")) or 0))
			end
        end
    end )
	
	--UserProxy:requestGameInfo(nil,"1,2,3",wwConfigData.GAME_ID)
	self.hasEnter = true
		--依次执行
	if self.enterActions then
		for i,v in ipairs(self.enterActions) do
			if self[v.action] then
				self[v.action](self,v.arg)
			end
		end
	end
end


function UserInfoLayer:onExit()
    self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
    self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED)
    self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_FRIEND_DELETED)
    if self._listener then
        WWFacade:removeEventListener(self._listener)
    end
    self.super.onExit(self)
	self.hasEnter = false
end

function UserInfoLayer:unregisterUserListener()
	if UserInfoCfg.innerEventComponent and self._handles then
		for _,v in pairs(self.handlers) do
			UserInfoCfg.innerEventComponent:removeEventListener(v)
		end
		removeAll(self.handlers)
	end
end
-- 当前账号是否绑定手机号？
local isBindPhone = function()
    return DataCenter:getUserdataInstance():getValueByKey("BindPhone") ~= ""
end

function UserInfoLayer:init()
    self.node = require(csbMainPath):create().root:addTo(self)
    --    FixUIUtils.stretchUI(self.node)
    FixUIUtils.setRootNodewithFIXED(self.node)

    self.imgId = self.node:getChildByName("Image_bg")
    FixUIUtils.stretchUI(self.imgId)
	--ScrollView_content
	local scollview = ccui.Helper:seekWidgetByName(self.imgId,"ScrollView_content")
	local userContent = Node_UserInfoContent:create().root
	scollview:addChild(userContent,1)
	self.panelContent = userContent:getChildByName("Panel_content")
	
	scollview:setInnerContainerSize(self.panelContent:getContentSize())
	scollview:setScrollBarEnabled(false)
    self.imgTop = getChild(self.panelContent, "Image_top")
    --    Text_id:setString([[ID：100170219]])
    self._txtID = getChild(self.panelContent, "Text_id")
    self._txtName = getChild(self.panelContent, "Text_name"):setVisible(false)
    self._txtName = cc.LabelTTF:create("NULL", "FZZhengHeiS-B-GB.ttf", 48):setAnchorPoint(cc.p(0.0, 0.5)):setColor(cc.c3b(0xFF, 0xF1, 0x0A)):pos(self._txtName:pos()):addTo(self._txtName:getParent())
    --    "性别：男"
    self._txtSex = getChild(self.panelContent, "Text_sex")
    self._imgSex = getChild(self.panelContent, "Image_sex")
    --    "地区：广东 深圳"
    self._txtLocation = getChild(self.panelContent, "Text_location")
    self._txtDiamond = getChild(self.panelContent, "Text_diamond")
    self._txtGold = getChild(self.panelContent, "Text_gold")
    self._txtCrystal = getChild(self.panelContent, "Text_crystal"):setString(ToolCom.splitNumFix(userData:getGoodsAttrByName("shuij", "count") or 0))
	


	--惯蛋
	self[wwConfigData.GAME_ID] = getChild(self.panelContent, "Image_guandan")
	--斗牛
	self[wwConfigData.CHARGE_BANKID_GOLD_BULLFIGHT] = getChild(self.panelContent, "Image_bullfight")
--[[-- 局数
    self._txtAllPlay = getChild(self.panelContent, "Text_number")
    -- 胜率
    self._txtWinRate = getChild(self.panelContent, "Text_number_0")--]]
	
    local centerImg = getChild(self.panelContent, "Image_center")

    self:manualFix(centerImg, centerImg:getContentSize())
    self:popIn(self.imgId, Pop_Dir.Right)
    -- testing
    self:setDisCallback( function(...)
        -- 注销监听广播的句柄
        self:unregisterUserListener()
        -- body
        FSRegistryManager:currentFSM():trigger("back")
    end )

    getChild(self.panelContent, "Image_edit_0"):setTouchEnabled(false)
    getChild(self.panelContent, "Image_edit"):addClickEventListener(handler(self, self._btnCallback))
	
    -- 切换账号
    self._btnSwitch = getChild(self.imgId, "Button_switch")
    self._btnSwitch:setTitleText(isBindPhone() and getStr("switch_account") or getStr("register"))
    self._btnSwitch:addClickEventListener(handler(self, self._btnCallback))
    -- 提示绑定手机奖励
    self._txtHintReward = getChild(self.imgId, "hint_bind_reward"):setVisible(not isBindPhone())

    self:registerListener()

    UserProxy:requestUserInfo(self.userid)
    HallProxy:requestGoodsCount(getGoodsByFlag("shuij").fid)
	--查询游戏数据
	UserProxy:requestGameInfo(self.userid,"1,2,3",wwConfigData.GAME_ID)
	UserProxy:requestGameInfo(self.userid,"1,2,3",wwConfigData.CHARGE_BANKID_GOLD_BULLFIGHT)
    --self:reflashHead()

    -- -- 屏蔽地区设置，一律设为地区：南京。删除代码就取消屏蔽-------start
    -- local old = self._txtLocation.setString
    -- self._txtLocation.setString = function(self)
    --     old(self, getStr("region_prefix") .. "南京")
    -- end
    -- 屏蔽地区设置，一律设为地区：南京。删除代码就取消屏蔽-------end

    -- 第三方登录时，屏蔽注册登录绑定手机模块。
    if ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK):isThirdPartyLogin() then
        self._btnSwitch:setVisible(false)
        self._txtHintReward:setVisible(false)
    end
	self:dealNotSelfUI(self.userid and tostring(self.userid)~=tostring(userData:getValueByKey("userid")))
end
--处理是否为自己的UI变化
--@param  isOther 是否是其他人
function UserInfoLayer:dealNotSelfUI(isOther)
	if isOther then
		getChild(self.imgId, "Button_switch"):setVisible(false)
		getChild(self.imgId, "hint_bind_reward"):setVisible(false)
		getChild(self.panelContent, "Image_edit"):setVisible(false)
		
		if self.isFriend then
			--#7F7F7F
			getChild(self.panelContent, "Button_add"):setTitleColor({r = 0x7F, g = 0x7F, b = 0x7F})
			getChild(self.panelContent, "Button_add"):setTitleText(i18n:get('str_userInfo','is_friend'))
			getChild(self.panelContent, "Button_add"):setBright(false)
			getChild(self.panelContent, "Button_add"):setTouchEnabled(false)
		else
			--#383857
			getChild(self.panelContent, "Button_add"):setTitleColor({r = 0x38, g = 0x38, b = 0x57})
			getChild(self.panelContent, "Button_add"):setTitleText(i18n:get('str_userInfo','add_friend'))
			getChild(self.panelContent, "Button_add"):setBright(true)
			getChild(self.panelContent, "Button_add"):setTouchEnabled(true)
			getChild(self.panelContent, "Button_add"):addClickEventListener(handler(self, self._btnCallback))
		end
	else
		--这里是自己的
		local region = DataCenter:getUserdataInstance():getValueByKey("Region")
		if region == "" then
			self._txtLocation:setString("")
			-- 请求地区信息
			wwlog(self.logTag, "地区信息为空")
			UserProxy:getAndUpdateCity()
		else
			wwlog(self.logTag, region)
			self._txtLocation:setString(region)
		end
	end
	getChild(self.panelContent, "Image_edit"):setVisible(not isOther) --自己的就是编辑
	getChild(self.panelContent, "Button_add"):setVisible(isOther) --别人的就是添加好友

end
function UserInfoLayer:deleteFriend(event)
	local data = unpack(event._userdata)
	if data and data.kResult == 0 then --删除成功
		--删除了好友
		self.isFriend = false --不是我的好友了
		self:dealNotSelfUI(self.userid and tostring(self.userid)~=tostring(userData:getValueByKey("userid")))
	end

end
function UserInfoLayer:agreeFriend(event)
	--同意了添加好友
	self.isFriend = true --是我的好友了
	self:dealNotSelfUI(self.userid and tostring(self.userid)~=tostring(userData:getValueByKey("userid")))
end
function UserInfoLayer:reflashHead(iconId,userid,gender)
	--userData:getHeadIcon()
	if not iconId or not userid or not gender then
		return
	end
    wwlog(self.logTag, "reflashHead")
    local param = {
        headFile =  userData:getHeadIconByGender(gender),
        maskFile = "guandan/head_mask.png",
        frameFile = "common/common_userheader_frame_userinfo.png",
        headType = 1,
        radius = 87.5,
        headIconType = iconId or DataCenter:getUserdataInstance():getValueByKey("IconID"),
        userID = userid or DataCenter:getUserdataInstance():getValueByKey("userid")
    }

	self.imgTop:removeChildByName("headIcon")
    self.headIcon = WWHeadSprite:create(param):setScale(1.3):addTo(self.imgTop)
    :setPosition(self.imgTop:getContentSize().width * 0.15, self.imgTop:getContentSize().height * 0.5)
	self.headIcon:setName("headIcon")
end

function UserInfoLayer:registerListener()
    self._handles = { } or self._handles
    local _ = nil
	if UserInfoCfg.innerEventComponent then
		_, self._handles[#self._handles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, handler(self, self._handleProxy))
		_, self._handles[#self._handles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_SEX, handler(self, self._handleProxy))
		_, self._handles[#self._handles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_NICKNAME, handler(self, self._handleProxy))
		_, self._handles[#self._handles + 1] = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_GAMEPLAYINFO, handler(self, self._handleProxy))
	end

end
--[[
handleType 为消息处理类型
--]]
function UserInfoLayer:refreshInfo(event)
    local handleType = unpack(event._userdata)
    if handleType == 1 then
        -- 刷新地区
		--地区刷新不在这里处理
--[[        local region = DataCenter:getUserdataInstance():getValueByKey("Region")
        wwlog(self.logTag, "更新地区信息%s", region)
        self._txtLocation:setString(region)--]]

        if self._txtCrystal then
            self._txtCrystal:setString(ToolCom.splitNumFix(userData:getGoodsAttrByName("shuij", "count") or 0))
        end
    elseif handleType == 2 then
        -- 红点通知
    end
end

function UserInfoLayer:_handleProxy(event)
    if event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO then
        -- 收到个人详情数据
        local datas = DataCenter:getData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO)
        self._userInfo = datas
        self:_updateView(datas)
    elseif event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_SEX then
        -- 修改性别
        local datas = DataCenter:getData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_SEX)
        if datas.isSucc then
            self:_updateView( { Gender = datas.sex })
        else
            self:_updateView( { Gender = datas.sex })
            Toast:makeToast(getStr("modify_fail"), 2.0):show()
        end
        self._userInfo.Gender = datas.sex
    elseif event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_NICKNAME then
        -- 修改昵称
        local datas = DataCenter:getData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_NICKNAME)
        if datas.isSucc then
            self:_updateView( { Nickname = datas.nickname })
            self._userInfo.Nickname = datas.nickname
        else
            --            Toast:makeToast(getStr("modify_fail"), 2.0):show()
            Toast:makeToast(getStr("invalid_nick"), 2.0):show()
        end
	elseif event.name == UserInfoCfg.InnerEvents.MESSAGE_EVENT_GAMEPLAYINFO then
		--游戏数据
		wwlog(self.logTag,"收到游戏数据，刷新战绩")
		local gamescores = DataCenter:getData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_GAMEPLAYINFO)
		dump(gamescores,"haha",6)
		if gamescores then
			local myData = gamescores[tonumber(self.userid or userData:getValueByKey("userid"))]
			local updateTable = {}
			for gameid,gamedata in pairs(myData) do
				--AllPlay
				--Victories
				local AllPlay = 0 --总局数
				local Victories = 0 --胜率
				if gamedata and gamedata.scoreList then
					for _,v in pairs(gamedata.scoreList) do
						AllPlay = AllPlay +tonumber(v.AllPlay)
						Victories = Victories +tonumber(v.AllWin)
					end
				end
				if AllPlay>0 then
					Victories = string.format("%0.1f", 100*Victories/AllPlay) 
				end
				updateTable[gameid] = {AllPlay = AllPlay,Victories = Victories}
			end
			wwdump(updateTable,"刷新战绩UI")
			self:_updateView(updateTable)
		end

    end
end

function UserInfoLayer:_updateView(data)
    for k, v in pairs(self._childViews) do
        if v.updateView then
            v:updateView(data)
        end
    end
    if data.UserID then
        self._txtID:setString(getStr("id_prefix") .. data.UserID)
    end
    if data.Nickname then
        self._txtName:setString(data.Nickname)
    end
    if data.IconID then
    end
    if data.VIP then
    end
    if data.Gender then
        if self._txtSex:getString() ~= tostring(data.Gender) then
            local strGender = nil
            if tonumber(data.Gender) == 1 then
                strGender = getComStr("male")
                self._txtSex:setString(getStr("sex_prefix") .. strGender)
                self._imgSex:loadTexture("userinfo_img_male.png", 1)
            else
                strGender = getComStr("female")
                self._txtSex:setString(getStr("sex_prefix") .. strGender)
                self._imgSex:loadTexture("userinfo_img_female.png", 1)
            end
            self:reflashHead(data.IconID,data.UserID,data.Gender)
        end
    end
    if data.Region then
		
		local regionStr = getStr("region_prefix") ..((data.Region and data.Region ~= "") and data.Region or getStr("unkown_region"))
		print("更新地区信息.....")
		print(regionStr)
        self._txtLocation:setString(regionStr)
    end
    if data.GameCash then
        self._txtGold:setString(ToolCom.splitNumFix(tonumber(data.GameCash)))
    end
    if data.Diamond then
        self._txtDiamond:setString(ToolCom.splitNumFix(tonumber(data.Diamond)))
    end
    if data.Crystal then
        self._txtCrystal:setString(ToolCom.splitNumFix(tonumber(data.Crystal)))
    else
        if not self._txtCrystal.flag then
            self._txtCrystal.flag = true
            self._txtCrystal:setString(ToolCom.splitNumFix(userData:getGoodsAttrByName("shuij", "count") or 0))
        end
    end
	if data[wwConfigData.GAME_ID] then --惯蛋数据
		
		getChild(self[wwConfigData.GAME_ID],"Text_number")
		:setString(tostring(data[wwConfigData.GAME_ID].AllPlay)) --局数
		getChild(self[wwConfigData.GAME_ID],"Text_number_0")
		:setString(string.format("%s",tostring(data[wwConfigData.GAME_ID].Victories)).."%") --胜率
	end
	if data[wwConfigData.CHARGE_BANKID_GOLD_BULLFIGHT] then --斗牛数据
		getChild(self[wwConfigData.CHARGE_BANKID_GOLD_BULLFIGHT],"Text_number") 
		:setString(ToolCom.splitNumFix(data[wwConfigData.CHARGE_BANKID_GOLD_BULLFIGHT].AllPlay))  --局数
		getChild(self[wwConfigData.CHARGE_BANKID_GOLD_BULLFIGHT],"Text_number_0")
		:setString(tostring(data[wwConfigData.CHARGE_BANKID_GOLD_BULLFIGHT].Victories).."%") --胜率
	end
--[[    if data.AllPlay then
        self._txtAllPlay:setString(data.AllPlay)
    end
    if data.Victories then
        self._txtWinRate:setString(data.Victories == "" and "0.0%" or data.Victories .. "%")
    end--]]
end

-- 手动适配UI
function UserInfoLayer:manualFix(centerImg, oldSize)
    -- Image_link11
    local size = centerImg:getContentSize()
    dump(oldSize, "oldSize")
    dump(size, "newSize")
    if size.height / oldSize.height <= 1.3 then
        return
    end
    print(size.height / oldSize.height)
    centerImg:setContentSize(cc.size(size.width, size.height * 0.84))
    local y = centerImg:getPositionY()
    centerImg:setPositionY(y + 0.04 * size.height)
    local link1 = getChild(self.panelContent, "Image_link11")
    local link2 = getChild(self.panelContent, "Image_link12")
    for _, v in pairs(centerImg:getChildren()) do
        y = v:getPositionY()
        if v == link1 or v == link2 then
            v:setPositionY(y - 0.07 * size.height)
        else
            v:setPositionY(y - 0.1 * size.height)
        end
    end
end

-- 个人信息编辑界面
function UserInfoLayer:showChildLayer(name)
    print(ViewChildConf[name])
    local child = require(ViewChildConf[name]):create(self):addTo(self)
    self._childViews[#self._childViews + 1] = child
    child:onNodeEvent("cleanup", function()
        table.remove(self._childViews)
    end )
end

function UserInfoLayer:_btnCallback(node)
    if not self._userInfo then return end
    local name = node:getName()
    playSoundEffect("sound/effect/anniu")
    if name == "Image_top" then
        wwlog(self.logTag, "修改头像")
        self:showChildLayer("changeHead")
    elseif name == "Image_edit" then
        wwlog(self.logTag, "编辑个人信息")
        self:showChildLayer("edit")
    elseif name == "Button_switch" then
        -- local src = { "login", , "resetPsw", "setPsw", "verifyCode" }
		self:performSwitch()
	elseif name == "Button_add" then
		--是否在好友列表里边
		SocialContactProxy:requestAddBuddy(self.userid)
		Toast:makeToast(i18n:get('str_cardpartner','partner_request_send'), 1.0):show()
    end
end

function UserInfoLayer:performSwitch()
	if isBindPhone() then
		-- 切换到登录界面
		wwlog(self.logTag, "切换帐号")
		self:showChildLayer("login")

		UmengManager:eventCount("MyInfoRelogin")
	else
		wwlog(self.logTag, "一键注册登录")
		self:showChildLayer("register")

		UmengManager:eventCount("MyInfoRegister")
	end
end


--设置进入的动作
--@param 进入后需要调用的方法
function UserInfoLayer:setEnterAction(action,...)
	if self.hasEnter and self[action] then
		self[action](self,...)
	elseif self[action] then
		table.insert(self.enterActions,{action = action,arg = ...})
	end
end

-- 绑定手机
function UserInfoLayer:bindphone()
    self._btnSwitch:setTitleText(isBindPhone() and getStr("switch_account") or getStr("register"))
    self._txtHintReward:setVisible(not isBindPhone())
end

return UserInfoLayer
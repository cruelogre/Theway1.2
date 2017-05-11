-------------------------------------------------------------------------
-- Title:        私人订制-------收到邀请
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SiRen_invite_receive = class("SiRen_invite_receive", 
	require("app.views.uibase.PopWindowBase"),
	require("packages.mvc.Mediator"))
local TAG = "SiRen_invite_receive.lua"
local csbMainPath = "csb.hall.siren.receive_invite"
local csbCommonPath = "csb.hall.siren.common"
local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
local SiRenRoomCfg = require("hall.mediator.cfg.SiRenRoomCfg")

local UserInfoProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local JumpFilter = require("packages.statebase.filter.JumpFilter")

local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time):show() end
local getStr = function(flag) return i18n:get("str_sirenrm", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local getWidget = function(node, flag) return ccui.Helper:seekWidgetByName(node, flag) end
local getNode = function(node, ...)
    local ret = nil
    for k, v in ipairs( { ...}) do
        if ret then
            ret = ret:getChildByName(v)
        else
            ret = node:getChildByName(v)
        end
    end
    return ret
end
local userData = DataCenter:getUserdataInstance()
local function traverseNode(node, callback, table)
    local name = node:getName()
    table[name] = node
    callback(name, node)
    for idx, child in pairs(node:getChildren()) do
        traverseNode(child, callback, table)
    end
end

--创建的参数
function SiRen_invite_receive:ctor(param)
    self.uis = { }

	self.fromUserId = param.userid --请求的用户ID
	self.gameid = param.gameid --请求的游戏ID
	self.roomid = param.roomid --私人房的房间ID
	
    SiRen_invite_receive.super.ctor(self)
	
	
    self._broadcastHandles = { }
    self:init()
end

function SiRen_invite_receive:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = getNode(root, "bg_com")
    local container = getNode(bg, "container")
    local receinvite = require(csbMainPath):create().root:addTo(container)

    traverseNode(root, handler(self, self._initView), self.uis)

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    self:_registerBroascast()
	getNode(receinvite, "btn_no"):addClickEventListener(handler(self, self._btnCallback))
	getNode(receinvite, "btn_yes"):addClickEventListener(handler(self, self._btnCallback))
	
	self:setDisCallback(handler(self,self.closeCallBack))
	self:registListener()
	UserInfoProxy:requestUserInfo(self.fromUserId)
end

function SiRen_invite_receive:closeCallBack()
	self:removeCurInvited()--操作了后关闭
	local data = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITEED)
	self:unregistListener()

	if data and table.nums(data)>0 then
		local jumpFilter = JumpFilter:create(100,FSConst.FilterType.Filter_Resume,2)
		jumpFilter:setJumpData("sirenInvited",
			{ zorder=ww.centerOrder,
			gameid=wwConfigData.GAME_ID,
			roomid = data.Param1,
			userid = data.StrParam1
			} )
		--下边的状态
		local curStack = FSRegistryManager:currentFSM().fsm.mStateStack
		if curStack and curStack:at(curStack:size() - 1) then
			local stateName = curStack:at(curStack:size() - 1).mStateName
			--
			FSRegistryManager:currentFSM():addFilter(stateName,jumpFilter)
		end
	end
	FSRegistryManager:currentFSM():trigger("back")
end

function SiRen_invite_receive:registListener()
    self._handles = { } or self._handles
    local _ = nil
	if UserInfoCfg.innerEventComponent then
		_, self._handles[#self._handles + 1] = UserInfoCfg.innerEventComponent:addEventListener(
			UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, handler(self, self.refreshInfo))
	else
		self:registerEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, handler(self, self.refreshInfo))
	end
	 self._sirenhandles = { } or self._sirenhandles
	if SiRenRoomCfg.innerEventComponent then
		_, self._sirenhandles[#self._sirenhandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(
			SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO, handler(self, self.agreeInvited))
	else
		self:registerEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO, handler(self, self.agreeInvited))
	end
	
end
function SiRen_invite_receive:unregistListener()
	if UserInfoCfg.innerEventComponent and self._handles then
		for _,v in pairs(self._handles) do
			UserInfoCfg.innerEventComponent:removeEventListener(v)
		end
	end
	if SiRenRoomCfg.innerEventComponent and self._sirenhandles then
		for _,v in pairs(self._sirenhandles) do
			SiRenRoomCfg.innerEventComponent:removeEventListener(v)
		end
	end
	self:unregisterEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO)
	self:unregisterEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO)
end
--同意私人房邀请后，会收到房间信息
function SiRen_invite_receive:agreeInvited(event)
	local data = unpack(event._userdata)
	if not data then
		data = event._userdata
	end
	if not data then
		return
	end
	if data.Type == 2 then --这里应该是进入房间
		local data = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITEED)
		--接受邀请后，其他请求删除掉？
		removeAll(data)
		local UIJmperConfig = require("config.UIJmperConfig")
		if UIJmperConfig then
			local opendata = UIJmperConfig[0x00D] --跳转到私人房
			local jumpParam = { zorder = 3,}
			opendata.param = opendata.param or {}
			if opendata.param then
				table.merge(opendata.param,jumpParam)
			end
			UIStateJumper:JumpUI(opendata)
		end
		
		--self:close()
	end
end

function SiRen_invite_receive:refreshInfo(event)
	local data = unpack(event._userdata)
	if not data then
		data = event._userdata 
	end
	if not data or not next(data) then
		return --没有数据
	end
	wwdump(data,"邀请界面收到个人信息")

	if self.uis and self.uis["Image_header"] then
		local node = self.uis["Image_header"]
		node:removeAllChildren()
		local param = {
			headFile=DataCenter:getUserdataInstance():getHeadIconByGender(tonumber(data.Gender)),
			maskFile = "guandan/head_mask.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
			headType=1,
			radius=node:getContentSize().width/2,
	        headIconType = data.IconID,
	        userID = data.UserID
	    }
		--
		local HeadSprite = WWHeadSprite:create(param)
		HeadSprite:setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2))
		node:addChild(HeadSprite,1)
	end
	if self.uis and self.uis["Text_name"] then
		local node = self.uis["Text_name"]
		node:setString(tostring(data.Nickname))
	end
end

function SiRen_invite_receive:_initView(name, node)
    if name == "title_com" then
        node:setString(string.format(getStr("title_receive_invite"), tonumber(self.roomid)))
    end
end

function SiRen_invite_receive:_btnCallback(node)
    local name = node:getName()
    if name == "btn_no" then
		print("no")
		SocialContactProxy:refuseSiren(tonumber(self.roomid),self.fromUserId)
		--允许和拒绝都要删除当前邀请
		self:removeCurInvited()
		self:close() --操作了后关闭
	elseif name == "btn_yes" then
		print("btn_yes")
		SocialContactProxy:agreeSiren(tonumber(self.roomid),self.gameid)
		self:removeCurInvited()--操作了后关闭
		--self:close()
    end
end
--删除当前的邀请
function SiRen_invite_receive:removeCurInvited()
	local data = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITEED)
	if data and next(data) then
		local removeIndex = -1
		for index,v in ipairs(data) do
			if tonumber(v.StrParam1)== tonumber(self.fromUserId) then
				removeIndex = index
				break
			end
		end
		if removeIndex>0 then
			table.remove(data,removeIndex)
		end
		
	end
end

function SiRen_invite_receive:_inputCallback(event)
    local targetName = event.target:getName()
    if targetName == "input_phone_reg" then
        if event.name == "ATTACH_WITH_IME" then
        elseif event.name == "DETACH_WITH_IME" then
        elseif event.name == "INSERT_TEXT" then
        elseif event.name == "DELETE_BACKWARD" then
        end
    end
end

function SiRen_invite_receive:_registerBroascast()
    local _ = nil
    --    -- 验证码发送成功或失败
    --    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK, handler(self, self._handleProxy))
    --    -- 登录失败
    --    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINERROR, handler(self, self._handleProxy))
    --    -- 注销成功
    --    _, self._broadcastHandles[#self._broadcastHandles + 1] = NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGOUTOK, handler(self, self._handleProxy))
end

function SiRen_invite_receive:_handleProxy(event)
    if event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK then
    end
end

function SiRen_invite_receive:onEnter()
    SiRen_invite_receive.super.onEnter(self)
end

function SiRen_invite_receive:onExit()
    SiRen_invite_receive.super.onExit(self)
end

return SiRen_invite_receive
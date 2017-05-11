-------------------------------------------------------------------------
-- Title:        私人订制-------等待游戏开始
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SiRen_invite = class("SiRen_invite", require("app.views.uibase.PopWindowBase"))
local TAG = "SiRen_invite.lua"
local csbMainPath = "csb.hall.siren.invite"
local csbCommonPath = "csb.hall.siren.common"
local SiRenRoomCfg = import("....cfg.SiRenRoomCfg")
local Toast = require("app.views.common.Toast")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
local request = require("hall.request.SiRenRoomRequest")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local Cardpartner_Invite_Friend = require("hall.mediator.view.widget.partner.Cardpartner_Invite_Friend")

local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
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

function SiRen_invite:ctor(layer, info)
    self._SiRenRoomLayer = layer
    self._roomInfo = info
    --    -- 改成以为userid为键值
    --    table.map(self._roomInfo.userInfo, function(info, k)
    --        self._roomInfo.userInfo[info.UserID] = info
    --    end )
    --    value保存该位置上的userID
    self._slotInfo = { btn_invite1 = - 1, btn_invite2 = - 1, btn_invite3 = - 1, btn_invite4 = - 1 }
    self.uis = { }

    SiRen_invite.super.ctor(self)
    self._broadcastHandles = { }
    self:init()
end

function SiRen_invite:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = getNode(root, "bg_com")
    local container = getNode(bg, "container")
    local invite = require(csbMainPath):create().root:addTo(container)

    traverseNode(root, handler(self, self._initView), self.uis)

    -- 更新当前人员情况，房主在第一位
    table.sort(self._roomInfo.userInfo, function(a, b) return a.UserID == self._roomInfo.MasterID end)

    self:join(unpack(self._roomInfo.userInfo))

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)
end

-- 有人加入房间
function SiRen_invite:join(...)
    local slotIdx = { "btn_invite1", "btn_invite2", "btn_invite3", "btn_invite4", }
    for k, info in pairs( { ...}) do
        -- 先检查一遍是不是已经进来了，因为被邀请玩家可能杀进程退出，这时无法收到退出房间通知
        for k1, v1 in ipairs(slotIdx) do
            if self._slotInfo[v1] == info.UserID then
                -- 已经进来了就不用管了
                return
            end
        end

        for k1, v1 in ipairs(slotIdx) do
            if self._slotInfo[v1] < 0 then
                self._slotInfo[v1] = info.UserID
                local param = {
                    --                    headFile = DataCenter:getUserdataInstance():getHeadIconByGender(),
                    headFile = info.Gender == 1 and "guandan/head_boy.png" or "guandan/head_girl.png",
                    --                    maskFile = "#match_mate_bg_header2.png",
                    maskFile = "",
                    frameFile = "common/common_userheader_frame_userinfo.png",
                    headType = 1,
                    radius = 60,
                    width = 120,
                    height = 120,
                    headIconType = info.IconID,
                    -- (如果是11 则是默认头像，101，是自己审核头像（网络获取）， 102是待审核头像)
                    userID = info.UserID,
                }
                -- 头像
                local headSp = WWHeadSprite:create(param):addTo(self.uis[v1]):center(self.uis[v1])
                cc.Label:createWithSystemFont(info.Nickname, "", 30):setColor(cc.c3b(0xdc, 0xdc, 0xdc)):addTo(self.uis[v1]):bottom(self.uis[v1]):centerX(self.uis[v1]):offsetY(-10)
                break
            end
        end
    end

    local flagIsFull = true
    for k, v in pairs(self._slotInfo) do if v < 0 then flagIsFull = false break end end
    if flagIsFull then
        -- 人数满了，
        if self._roomInfo.MasterID == userData:getValueByKey("userid") then
            -- 房主显示开始游戏按钮
            self.uis.btn_invite_wx._flag_invite_listener = nil
            self.uis.btn_invite_wx:setTitleText(getStr("start_game"))
            :setTitleFontSize(46):setTitleColor(display.COLOR_WHITE)
            :getChildByName("txt"):setVisible(false)
            self.uis.btn_invite_wx:addClickEventListener( function()
                playSoundEffect("sound/effect/anniu")
                request.startGame(proxy, self._roomInfo.RoomID)
            end )
			local parentSize = self.uis.btn_invite_wx:getParent():getContentSize()
			self.uis.btn_invite_wx:setPosition(cc.p(parentSize.width/2,self.originPos.y))
        else
            -- 非房主，邀请按钮关闭
            self.uis.btn_invite_wx:setVisible(false)
        end
		
		self:setInviteState(false)
    else
        -- 人没有满，都显示邀请好友按钮
        if not self.uis.btn_invite_wx._flag_invite_listener then
            self.uis.btn_invite_wx._flag_invite_listener = true
            self.uis.btn_invite_wx:addClickEventListener( function(sender)
                playSoundEffect("sound/effect/anniu")
                -- 邀请好友
                require("app.utilities.LuaWxShareNativeBridge"):create():callNativeShareByUrl(
                2,
                getStr("share_title"),
                string.format(getStr("share_content"), wwConst.CLIENTNAME, self._roomInfo.RoomID),
                wwURLConfig.SHARE_SIREN_DOWNLOAD_URL,
                "aa")
            end )
        end
		--邀请好友
		self:setInviteState(true)
		if self.originPos then
			self.uis.btn_invite_wx:setPosition(self.originPos)
		end
        if self._roomInfo.MasterID ~= userData:getValueByKey("userid") then self.uis.btn_invite_wx:setVisible(true) end
    end
end

-- 有人离开
function SiRen_invite:left(userId)
    if userData:getValueByKey("userid") == userId then
        -- 自己离开
        self:removeFromParent()
        do return end
    else
        -- 别人离开
        for k, userID in pairs(self._slotInfo) do
            if userID == userId and userId and userId ~= -1 then
                self.uis[k]:removeAllChildren()
                self._slotInfo[k] = -1
            end
        end
    end
    if self._roomInfo.MasterID == userData:getValueByKey("userid") then
        -- 别人离开。当前是房主，开始按钮变回邀请按钮。
        if not self.uis.btn_invite_wx._flag_invite_listener then
            self.uis.btn_invite_wx._flag_invite_listener = true
            -- 人没满，邀请好友
            self.uis.btn_invite_wx:setTitleText(""):addClickEventListener( function(sender)
                playSoundEffect("sound/effect/anniu")
                -- 邀请好友
                require("app.utilities.LuaWxShareNativeBridge"):create():callNativeShareByUrl(
                2,
                getStr("share_title"),
                string.format(getStr("share_content"), wwConst.CLIENTNAME, self._roomInfo.RoomID),
                wwURLConfig.SHARE_SIREN_DOWNLOAD_URL,
                "aa")
            end )
            self.uis.btn_invite_wx:getChildByName("txt"):setVisible(true)
			self.uis.btn_invite_wx:setPosition(self.originPos)
        end
    else
        -- 别人离开，当前是非房主，显示邀请按钮。
        self.uis.btn_invite_wx:setVisible(true)
		self.uis.btn_invite_wx:setPosition(self.originPos)
    end
	self:setInviteState(true)
end
function SiRen_invite:setInviteState(enable)
	self.uis.btn_invite_friend:setVisible(enable)
	if enable then
		self.uis.btn_invite_friend:setTouchEnabled(true)
		self.uis.btn_invite_friend:setBright(true)
		if not self.uis.btn_invite_friend._flag_invite_listener then
			self.uis.btn_invite_friend._flag_invite_listener = true
            self.uis.btn_invite_friend:addClickEventListener( function(sender)
                playSoundEffect("sound/effect/anniu")
                -- 邀请在线好友
                print("邀请在线好友")
				--self:getLocalZOrder()
				
				display.getRunningScene():addChild(Cardpartner_Invite_Friend:create(4,self._roomInfo.RoomID,self:getLocalZOrder()+1),self:getLocalZOrder()+1)
            end )
		end
	else
		self.uis.btn_invite_friend._flag_invite_listener = nil
		self.uis.btn_invite_friend:setTouchEnabled(false)
		self.uis.btn_invite_friend:setBright(false)
	end
end

function SiRen_invite:_initView(name, node)
    if name == "title_com" then
        node:setString(getStr("title_invite"))
    elseif name == "title_right_node" then
        -- 标题右边
        if self._roomInfo.MasterID == userData:getValueByKey("userid") then
            -- 创建房间的才有解散权限
            ccui.Button:create("common/common_btn_yellow.png")
            :addTo(node):setTitleColor(cc.c3b(0x3e, 0x32, 0x1c)):setTitleFontSize(36):setTitleText(getStr("release_room")):offsetX(-15)
            :addClickEventListener( function(sender)
                playSoundEffect("sound/effect/anniu")
                -- 解散房间
                local roomID = self._roomInfo.RoomID
                local para = { }
                para.leftBtnlabel = i18n:get("str_common", "comm_cancel")
                para.rightBtnlabel = i18n:get("str_common", "comm_sure")
                para.leftBtnCallback = nil
                para.rightBtnCallback = function() request.releaseRoom(proxy, roomID) end
                para.showclose = false
                -- 是否显示关闭按钮
                para.content = getStr("warn_jiesan")
                import(".CommonDialog", "app.views.customwidget."):create(para):show()
            end )
        else
            -- 非创建者，显示退出房间按钮
            ccui.Button:create("common/common_btn_yellow.png")
            :addTo(node):setTitleColor(cc.c3b(0x3e, 0x32, 0x1c)):setTitleFontSize(36):setTitleText(getStr("quit_room")):offsetX(-15)
            :addClickEventListener( function(sender)
                 playSoundEffect("sound/effect/anniu")
                -- 退出房间
                request.quitRoom(proxy, self._roomInfo.RoomID)
                SiRenRoomCfg.innerEventComponent:dispatchEvent( { name = SiRenRoomCfg.InnerEvents.SIREN_ROOM_LEFT_SELF })
                -- 跟晓峰交流过，自己收不到退房通知，所以自己就直接退房。
                self:close()
                LoadingManager:endLoading()
            end )
        end
    elseif name == "txt_room_no" then
        -- 房间号
        node:setString(self._roomInfo.RoomID)
    elseif name == "rule1" then
        if self._roomInfo.Playtype == 1 then
            -- 经典
            node:getChildByName("txt1"):setString(self:getGuoJi(self._roomInfo.PlayData))
        else
            -- 其他显示局数
            local txt1, txt = node:getChildByName("txt1"), node:getChildByName("txt")
            txt1:setString(self._roomInfo.PlayData):right(node):offsetX(7)
            txt:setString(getStr("ju")):right(txt1):offsetX(-3)
        end
    elseif name == "rule2" then
        node:getChildByName("txt1"):setString(self._roomInfo.DWinPoint)
    elseif name == "rule3" then
        --        dump(self._roomInfo)
        local flag1, flag2 = string.match(self._roomInfo.MultipleData, "(%d),(%d)")
        flag1, flag2 = tonumber(flag1), tonumber(flag2)
        local str = nil
        local offsetX = nil
        if flag1 == 1 and flag2 == 1 then
            str = "title_fanbei3"
        elseif flag1 == 1 then
            offsetX = 70
            str = "title_fanbei1"
        elseif flag2 == 1 then
            offsetX = 70
            str = "title_fanbei2"
        else
            str = nil
            offsetX = 240
        end
        if offsetX then
            self.uis.rule1:offsetX(offsetX)
            self.uis.rule2:offsetX(offsetX)
            self.uis.rule3:offsetX(offsetX)
        end
        if str then
            node:getChildByName("txt"):setString(getStr(str))
        else
            node:setVisible(false)
        end
    elseif name == "btn_invite_wx" then
		self.originPos = cc.p(node:getPositionX(),node:getPositionY())
    end
end

-- 2~14对应2~A。13 对应 K
local jiConf = { [2] = "2", [3] = "3", [4] = "4", [5] = "5", [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "10", [11] = "J", [12] = "Q", [13] = "K", [14] = "A", }
function SiRen_invite:getGuoJi(ji)
    if type(ji) == "string" then
        for k, v in pairs(jiConf) do
            if v == ji then
                return k
            end
        end
    else
        for k, v in pairs(jiConf) do
            if k == ji then
                return v
            end
        end
    end
end

function SiRen_invite:_handleProxy(event)
    wwlog("收到私人房消息")
    if event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT then
        -- 解散房间异常
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY then
        local data = event._userdata
        if data.Type == 2 then
            -- 解散房间成功
            -- Toast:makeToast(i18n:get('str_guandan','guandan_SirenJieSan'), 1.0):show()
            self:close()
        elseif data.Type == 7 then
            -- 玩家离开
            self:left(data.Param1)
        elseif data.Type == 6 then
            -- 玩家进入
            local parts = string.split(data.Desc, ",")
            self:join( {
                UserID = data.Param1,
                IconID = tonumber(parts[1]),
                Gender = tonumber(parts[2]),
                Nickname = parts[3],
            } )
        end
    end
end

function SiRen_invite:onEnter()
    SiRen_invite.super.onEnter(self)
    local _ = nil
    -- 创建房间
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT, handler(self, self._handleProxy))
    -- 通知
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY, handler(self, self._handleProxy))
end

function SiRen_invite:onExit()
    -- 退出界面就是退出房间
    -- 注销监听广播的句柄
    if SiRenRoomCfg.innerEventComponent then
        for k, v in pairs(self._broadcastHandles) do
            SiRenRoomCfg.innerEventComponent:removeEventListener(v)
        end
    end
    SiRen_invite.super.onExit(self)
end

return SiRen_invite
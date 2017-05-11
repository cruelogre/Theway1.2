-------------------------------------------------------------------------
-- Title:        私人订制-------创建房间
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SiRen_create_room = class("SiRen_create_room", require("app.views.uibase.PopWindowBase"), require("packages.mvc.Mediator"))
local TAG = "SiRen_create_room.lua"
local csbMainPath = "csb.hall.siren.create_room"
local csbCommonPath = "csb.hall.siren.common"
local SiRenRoomCfg = import("....cfg.SiRenRoomCfg")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
local HallProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local request = require("hall.request.SiRenRoomRequest")
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
    if table then
        table[name] = node
    end
    callback(name, node)
    for idx, child in pairs(node:getChildren()) do
        traverseNode(child, callback, table)
    end
end
local table = table
function SiRen_create_room:ctor(SiRenRoomLayer, roomConfData)
    SiRen_create_room.super.ctor(self)
    self._SiRenRoomLayer = SiRenRoomLayer
    self._root = nil
    self.uis = { }
    -- 私人房配置，后台返回的数据
    self._roomConfData = roomConfData
    self._broadcastHandles = { }
    
    -- 初始化UI
    self:init()
    local btnPlayTypeName = { "btn11", "btn13", "btn12" }
    local btnPlayTypeShouldShow = { }
    local defaultFlag = true
    table.walk(btnPlayTypeName, function(v, k)
        if not self._roomConfData[k] then
            self.uis[v]:setVisible(false)
        else
            if defaultFlag then
                defaultFlag = false
                self.uis[v]:setEnabled(false):getChildByName("flag"):setVisible(true)
                self:_updateRoomConfView(k)
            end
            btnPlayTypeShouldShow[#btnPlayTypeShouldShow + 1] = v
        end
    end )

    if table.nums(btnPlayTypeShouldShow) == 1 then
        self.uis[btnPlayTypeShouldShow[1]]:posX(401.70)
    elseif table.nums(btnPlayTypeShouldShow) == 2 then
        self.uis[btnPlayTypeShouldShow[1]]:posX(210)
        self.uis[btnPlayTypeShouldShow[2]]:posX(560)
    end
end

function SiRen_create_room:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    self._root = root
    local bg = getNode(root, "bg_com")
    local container = getNode(bg, "container")
    local createroom = require(csbMainPath):create().root:addTo(container)

    traverseNode(root, handler(self, self._initView), self.uis)

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

--    -- 刷新水晶数量
--    HallProxy:requestGoodsCount(getGoodsByFlag("fangk").fid)
end

function SiRen_create_room:_initView(name, node)
    local btns1 = { btn11 = 1, btn12 = 3, btn13 = 2 }
    local btns2 = { btn21 = 1, btn22 = 2, btn23 = 3, btn24 = 4 }
    local btns3 = { btn31 = 3, btn32 = 4 }
    if name == "title_com" then
        -- 标题
        node:setString(getStr("create_room"))
    elseif name == "bg" then
        -- 背景
        node:setLocalZOrder(-1)
    elseif name == "title_right_node" then
        -- 标题右边
        local roomcard = display.newSprite("#siren_room_card.png"):addTo(node):setAnchorPoint(cc.p(1.0, 0.5))
        self.uis.fangk = cc.Label:createWithTTF("x" ..(userData:getGoodsAttrByName("fangk", "count") or 0), "FZZhengHeiS-B-GB.ttf", 36):addTo(node):setAnchorPoint(cc.p(0.0, 0.5)):offsetX(5)
    elseif name == "btn_create" then
        node:addClickEventListener( function(sender)
            -- 创建房间
            -- 玩法
            local PlayType, PlayData, RoomCardCount, DWinPoint, MultipleData
            -- 选了第几个房卡配置
            local selectPlayDataIdx, selectMultiBomb, selectMultiFlush = nil
            traverseNode(self._root, function(name, node)
                if btns1[name] and not node:isEnabled() then
                    PlayType = btns1[name]
                elseif btns2[name] and not node:isEnabled() then
                    selectPlayDataIdx = btns2[name]
                elseif btns3[name] and not node:isEnabled() then
                    DWinPoint = btns3[name]
                end
            end )
            -- 翻倍
            MultipleData = string.format("%d,%d", self.uis.check1:isSelected() and 1 or 0, self.uis.check2:isSelected() and 1 or 0)
            local roomConf = self._roomConfData[PlayType][selectPlayDataIdx]
            PlayData, RoomCardCount = roomConf.PlayData, roomConf.RoomCardCount
            print("**********************PlayType::", PlayType)
            print("**********************PlayData::", PlayData)
            print("**********************RoomCardCount::", RoomCardCount)
            print("**********************DWinPoint::", DWinPoint)
            print("**********************MultipleData::", MultipleData)
            request.createRoom(proxy, PlayType, PlayData, RoomCardCount, DWinPoint, MultipleData)
        end )
    elseif btns1[name] then
        -- 玩法
        local click = function(sender)
            sender:setEnabled(false):getChildByName("flag"):setVisible(true)
            for name1, v in pairs(btns1) do
                if name1 ~= name and(not self.uis[name1]:isEnabled()) then
                    self.uis[name1]:setEnabled(true):getChildByName("flag"):setVisible(false)
                end
            end
            -- 更新房间配置
            self:_updateRoomConfView(btns1[sender:getName()])
        end
        node:addClickEventListener(click)
        node:getChildByName("txt"):addClickEventListener(handler(node, click))
    elseif btns2[name] then
        -- 过几
        if name == "btn21" then
            -- 默认左边起第一个
            node:setEnabled(false):getChildByName("flag"):setVisible(true)
        end
        local click = function(sender)
            -- 当前房间配置
            sender:setEnabled(false):getChildByName("flag"):setVisible(true)
            for name1, v in pairs(btns2) do
                if name1 ~= name and(not self.uis[name1]:isEnabled()) then
                    self.uis[name1]:setEnabled(true):getChildByName("flag"):setVisible(false)
                end
            end
            self:_updateRoomConfView()
        end
        node:addClickEventListener(click)
        node:getChildByName("bg"):addClickEventListener(handler(node, click))
    elseif btns3[name] then
        -- 双下升级
        self.uis[name] = node
        if name == "btn31" then
            -- 默认左边起第一个
            node:setEnabled(false):getChildByName("flag"):setVisible(true)
        end
        local click = function(sender)
            sender:setEnabled(false):getChildByName("flag"):setVisible(true)
            for name1, v in pairs(btns3) do
                if name1 ~= name and(not self.uis[name1]:isEnabled()) then
                    self.uis[name1]:setEnabled(true):getChildByName("flag"):setVisible(false)
                end
            end
        end
        node:addClickEventListener(click)
        node:getChildByName("txt"):addClickEventListener(handler(node, click))
    elseif name == "check1" or name == "check2" then
        node:getChildByName("txt"):addClickEventListener( function()
            node:setSelected(not node:isSelected())
        end )
    end
end

function SiRen_create_room:_handleProxy(event)
    if event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE then
        -- 创建房间异常
        self:close()
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO then
        -- 创建房间成功
        self:removeFromParent()
    end
end

function SiRen_create_room:_updateRoomConfView(playType)
    local conf = self._roomConfData[playType or 1]
    local btns = { btn21 = 1, btn22 = 2, btn23 = 3, btn24 = 4 }
    traverseNode(self._root, function(name, node)
        if btns[name] and playType then
            if playType == 1 then
                -- dump(conf)
                local roomCardNum, playData = conf[btns[name]].RoomCard, conf[btns[name]].PlayData
                local txtNum = getNode(node, "txt_num"):setString(self:getGuoJi(playData))
                local txt = getNode(node, "txt"):setString(getStr("guo"))
                getNode(node, "bg", "card", "txt_card_num"):setString(string.format("x%d", roomCardNum))
                if not txtNum._siren_pos then
                    txtNum._siren_pos = txtNum:pos()
                end
                if not txt._siren_pos then
                    txt._siren_pos = txt:pos()
                end
                txt:pos(txt._siren_pos)
                txtNum:pos(txtNum._siren_pos):right(txt)
            else
                -- 局数
                -- dump(conf)
                local roomCardNum, playData = conf[btns[name]].RoomCard, conf[btns[name]].PlayData
                local txtNum = getNode(node, "txt_num"):setString(playData)
                local txt = getNode(node, "txt"):setString(getStr("ju"))
                getNode(node, "bg", "card", "txt_card_num"):setString(string.format("x%d", roomCardNum))
                if not txtNum._siren_pos then
                    txtNum._siren_pos = txtNum:pos()
                end
                if not txt._siren_pos then
                    txt._siren_pos = txt:pos()
                end
                txtNum:pos(txt._siren_pos)
                txt:pos(txtNum._siren_pos):right(txt):offsetX(-5)
            end

        elseif name == "btn_create" then
            local btns1 = { btn11 = 1, btn12 = 3, btn13 = 2 }
            local btns2 = { btn21 = 1, btn22 = 2, btn23 = 3, btn24 = 4 }
            local PlayType, selectPlayDataIdx
            for k, v in pairs(btns1) do
                if not self.uis[k]:isEnabled() then
                    PlayType = v
                end
            end
            for k, v in pairs(btns2) do
                if not self.uis[k]:isEnabled() then
                    selectPlayDataIdx = v
                end
            end
            if (userData:getGoodsAttrByName("fangk", "count") or 0) >= self._roomConfData[PlayType][selectPlayDataIdx].RoomCard then
                -- 房卡够
                node:setTitleText(getStr("create_room")):addClickEventListener( function()
                    -- 创建房间
                    local btns1 = { btn11 = 1, btn12 = 3, btn13 = 2 }
                    local btns2 = { btn21 = 1, btn22 = 2, btn23 = 3, btn24 = 4 }
                    local btns3 = { btn31 = 3, btn32 = 4 }
                    -- 玩法
                    local PlayType, PlayData, RoomCardCount, DWinPoint, MultipleData
                    -- 选了第几个房卡配置
                    local selectPlayDataIdx, selectMultiBomb, selectMultiFlush = nil
                    traverseNode(self._root, function(name, node)
                        if btns1[name] and not node:isEnabled() then
                            PlayType = btns1[name]
                        elseif btns2[name] and not node:isEnabled() then
                            selectPlayDataIdx = btns2[name]
                        elseif btns3[name] and not node:isEnabled() then
                            DWinPoint = btns3[name]
                        end
                    end )
                    -- 翻倍
                    MultipleData = string.format("%d,%d", self.uis.check1:isSelected() and 1 or 0, self.uis.check2:isSelected() and 1 or 0)
                    local roomConf = self._roomConfData[PlayType][selectPlayDataIdx]
                    PlayData, RoomCardCount = roomConf.PlayData, tonumber(roomConf.RoomCard)
                    -- dump(roomConf)
                    print("*****************************************")
                    print("**********************PlayType::", PlayType)
                    print("**********************PlayData::", PlayData)
                    print("**********************RoomCardCount::", RoomCardCount)
                    print("**********************DWinPoint::", DWinPoint)
                    print("**********************MultipleData::", MultipleData)
                    request.createRoom(proxy, PlayType, PlayData, RoomCardCount, DWinPoint, MultipleData)
                end )
            else
                -- 房卡不够
                node:setTitleText(getStr("buy_card")):addClickEventListener( function()
                    FSRegistryManager:currentFSM():trigger("store",
                    { parentNode = display.getRunningScene(), zorder = 4, store_openType = 4 })
                end )
            end
        end
    end )
end

-- 2~14对应2~A。13 对应 K
local jiConf = { [2] = "2", [3] = "3", [4] = "4", [5] = "5", [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "10", [11] = "J", [12] = "Q", [13] = "K", [14] = "A", }
function SiRen_create_room:getGuoJi(ji)
    if type(ji) == "string" then
        for k, v in pairs(jiConf) do
            if v == ji then
                return k
            end
        end
        return 2
    else
        for k, v in pairs(jiConf) do
            if k == ji then
                return v
            end
        end
        return "2"
    end
end

function SiRen_create_room:onEnter()
    SiRen_create_room.super.onEnter(self)
    local _ = nil
    -- 创建房间
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE, handler(self, self._handleProxy))
    -- 房间信息
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO, handler(self, self._handleProxy))
    self:registerEventListener(COMMON_EVENTS.C_GOODS_COUNT_UPDATE, function(event)
        local fid, count = unpack(event._userdata)
        if fid == getGoodsByFlag("fangk").fid then
            self.uis.fangk:setString("x" ..(userData:getGoodsAttrByName("fangk", "count") or 0))
        end
        self:_updateRoomConfView()
    end )
    self._listener = WWFacade:addCustomEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, function(event)
        local handleType = unpack(event._userdata)
        if handleType == 1 then
            -- 个人数据刷新
            self.uis.fangk:setString("x" ..(userData:getGoodsAttrByName("fangk", "count") or 0))
            self:_updateRoomConfView()
        end
    end )
end

function SiRen_create_room:onExit()
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            SiRenRoomCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    self:unregisterEventListener(COMMON_EVENTS.C_GOODS_COUNT_UPDATE)
    WWFacade:removeEventListener(self._listener)
    SiRen_create_room.super.onExit(self)
end

return SiRen_create_room
-------------------------------------------------------------------------
-- Title:        私人订制-------空历史记录
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SiRen_no_history = class("SiRen_no_history", require("app.views.uibase.PopWindowBase"))
local TAG = "SiRen_no_history.lua"
local csbMainPath = "csb.hall.siren.no_history"
local csbCommonPath = "csb.hall.siren.common"
local SiRenRoomCfg = import("....cfg.SiRenRoomCfg")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
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
    table[name] = node
    callback(name, node)
    for idx, child in pairs(node:getChildren()) do
        traverseNode(child, callback, table)
    end
end

function SiRen_no_history:ctor(rootNode)
    self.uis = { }
    self._rootNode = rootNode
    SiRen_no_history.super.ctor(self)
    self._broadcastHandles = { }
    self:init()
end

function SiRen_no_history:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = getNode(root, "bg_com")
    local container = getNode(bg, "container")
    local noHistory = require(csbMainPath):create().root:addTo(container)

    traverseNode(root, handler(self, self._initView), self.uis)

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)
end

function SiRen_no_history:_initView(name, node)
    if name == "title_com" then
        node:setString(getStr("history"))
    elseif name == "btn_create_room" then
        local tmp_room_info = self._rootNode:getChildByName("SiRenRoomLayer")._tmp_room_info

        if tmp_room_info then
            if tmp_room_info.isself then
                -- 当前已经创建了自己的房间
            else
                -- 当前在别人创建的房间里
            end
            node:setTitleText(getStr("back_room")):addClickEventListener( function()
                request.returnRoom(proxy, tmp_room_info.roomid)
            end )
        else
            -- 当前没有在房间里
            -- 创建房间
            node:addClickEventListener( function()
                request.roomConf(proxy)
            end )
        end
    end
end

function SiRen_no_history:_handleProxy(event)
    if event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE then
        -- 创建房间异常
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT then
        -- 返回房间异常
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_PLAY_TYPE_CONF then
        -- 获取玩法配置成功也就是进入创建房间界面
        self:removeFromParent()
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO then
        -- 返回房间成功
        self:removeFromParent()
    end
end

function SiRen_no_history:onEnter()
    SiRen_no_history.super.onEnter(self)
    local _ = nil
    -- 创建房间
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE, handler(self, self._handleProxy))
    -- 玩法局数配置
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_PLAY_TYPE_CONF, handler(self, self._handleProxy))
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO, handler(self, self._handleProxy))
end

function SiRen_no_history:onExit()
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            SiRenRoomCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    SiRen_no_history.super.onExit(self)
end

return SiRen_no_history
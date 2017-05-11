-------------------------------------------------------------------------
-- Title:        私人订制-------加入房间
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SiRen_join_room = class("SiRen_join_room", require("app.views.uibase.PopWindowBase"))
local TAG = "SiRen_join_room.lua"
local csbMainPath = "csb.hall.siren.join_room"
local csbCommonPath = "csb.hall.siren.common"
local SiRenRoomCfg = import("....cfg.SiRenRoomCfg")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
local request = require("hall.request.SiRenRoomRequest")
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
    return table
end

function SiRen_join_room:ctor(layer)
    self._SiRenRoomLayer = layer
    self.uis = { }

    SiRen_join_room.super.ctor(self)
    self._broadcastHandles = { }
    self:init()
end

function SiRen_join_room:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = getNode(root, "bg_com")
    local container = getNode(bg, "container")
    local createroom = require(csbMainPath):create().root:addTo(container)

    traverseNode(root, handler(self, self._initView), self.uis)

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)
end

function SiRen_join_room:_initView(name, node)
    local btnNum = { btn0 = 0, btn1 = 1, btn2 = 2, btn3 = 3, btn4 = 4, btn5 = 5, btn6 = 6, btn7 = 7, btn8 = 8, btn9 = 9, }
    if name == "title_com" then
        node:setString(getStr("join_room"))
    elseif name == "txt_input_num" then
        -- 输入房号
    elseif name == "btn_clear" then
        -- 清除
        node:addClickEventListener( function()
            self.uis.txt_input_num:setString(getStr("hint_input_room"))
        end )
    elseif name == "btn_del" then
        node:addClickEventListener( function()
            local now = self.uis.txt_input_num:getString()
            if now ~= getStr("hint_input_room") then
                -- 删除
                local str = tostring(now) or ""
                if #str > 0 then
                    str = string.sub(str, 1, -2)
                    self.uis.txt_input_num:setString(str)
                end
                if #str == 0 then
                    self.uis.txt_input_num:setString(getStr("hint_input_room"))
                end
            end
        end )
    elseif btnNum[name] then
        local roomNumMax = 6
        node:addClickEventListener( function()
            local now = self.uis.txt_input_num:getString()
            local str = ""
            if getStr("hint_input_room") ~= now then
                str = now
            end
            local flag = false
            if #str <= roomNumMax - 1 then
                str = str .. btnNum[name]
                -- 数字
                self.uis.txt_input_num:setString(str)
                flag = true
            end
            if flag and #str == roomNumMax then
                -- 进入房间
                wwlog("SiRen_join_room", "进入房间")
                request.joinRoom(proxy, tonumber(str))
            end
        end )
    end
end

function SiRen_join_room:_handleProxy(event)
    if event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT then
        -- 操作房间异常
    elseif event.name == SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO then
        -- 成功加入房间
        self:removeFromParent()
    end
end

function SiRen_join_room:onEnter()
    SiRen_join_room.super.onEnter(self)
    local _ = nil
    -- 创建房间
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT, handler(self, self._handleProxy))
    -- 玩法局数配置
    _, self._broadcastHandles[#self._broadcastHandles + 1] = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO, handler(self, self._handleProxy))
end

function SiRen_join_room:onExit()
    -- 注销监听广播的句柄
    if self._broadcastHandles and #self._broadcastHandles > 0 then
        table.map(self._broadcastHandles, function(v, k)
            SiRenRoomCfg.innerEventComponent:removeEventListener(v)
        end )
    end
    SiRen_join_room.super.onExit(self)
end

return SiRen_join_room
-------------------------------------------------------------------------
-- Title:        物品兑换界面
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local Exchange_item = class("Exchange_item", require("app.views.uibase.PopWindowBase"), require("packages.mvc.Mediator"))
local ExchangeCfg = require("hall.mediator.cfg.ExchangeCfg")
local ExchangeProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().ExchangeProxy)
local userData = DataCenter:getUserdataInstance()
local csbMainPath = "csb.hall.exchange.common"
local exchange_item_view = { "csb.hall.exchange.exchange_item_1", "csb.hall.exchange.exchange_item_2", "csb.hall.exchange.exchange_item_3" }
local getStr = function(flag) return i18n:get("str_exchange", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local decodeAddr = function(svrAddr) return unpack(string.split(svrAddr, "@#$%")) end
local encodeAddr = function(province, area, location) return province .. "@#$%" .. area .. "@#$%" .. location end
local device = device 
function Exchange_item:ctor(info, flagHistory)
    self.logTag = "Exchange.lua"
    self.uis = { }
    self._info = info
    --    dump(self._info)
    -- true则是兑换记录
    self._flagHistory = flagHistory
    -- 收货信息
    self._broadcastHandles = { }
    self._tmpRequestParam = nil
    -- 收货人信息
    self._receiverInfo = nil

    self.super.ctor(self)
    self:init()
    self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )
    if not self._flagHistory then
        ExchangeProxy:requestReceiverInfo()
    end
    --    ExchangeProxy:delReceiverInfo({RecordID = 13187})
end

function Exchange_item:onEnter()
    self.super.onEnter(self)
    local _
    for k, v in pairs(ExchangeCfg.InnerEvents) do
        _, self._broadcastHandles[#self._broadcastHandles + 1] = ExchangeCfg.innerEventComponent:addEventListener(v, handler(self, self._handleProxy))
    end
end

function Exchange_item:onExit()
    -- 注销监听广播的句柄
    for k, v in ipairs(self._broadcastHandles) do
        ExchangeCfg.innerEventComponent:removeEventListener(v)
    end
    self._broadcastHandles = { }
    self.super.onExit(self)
end

function Exchange_item:init()
    local bgCommon = require(csbMainPath):create().root:addTo(self)
    local imgBg = bgCommon:getChildByName("bg_com")
    local titleBg = imgBg:getChildByName("img_top_com")
    local container = imgBg:getChildByName("container")

    local Type, viewPath = self._info.ObjectType
    if Type == 1 then
        -- 话费
        viewPath = exchange_item_view[2]
    elseif Type == 2 then
        -- 其它实物
        viewPath = exchange_item_view[3]
    elseif Type == 3 then
        -- 道具
        viewPath = exchange_item_view[1]
    end

    require(viewPath):create().root:addTo(container)

    ToolCom.traverseNode(bgCommon, handler(self, self._initView), self.uis)

    FixUIUtils.setRootNodewithFIXED(bgCommon)
    FixUIUtils.stretchUI(imgBg)

    self:popIn(imgBg, Pop_Dir.Right)
end

function Exchange_item:_initView(name, node)
    if name == "item_name" then
        -- 物品名称
        node:setString(self._info.Name or self._info.EquipName)
    elseif name == "title_com" then
        if self._flagHistory then
            node:setString(getStr("title_3"))
        else
            node:setString(getStr("title_2"))
        end
    elseif name == "item_figure" then
        -- 物品图片
        ToolCom:createGoodsSprite(self._info.EquipID):addTo(node)
    elseif name == "item_desc" then
        -- 详细描述
        node:setVisible(false)
        cc.Label:createWithSystemFont(self._info.Desc, "", 26):setColor(cc.c3b(0x7d, 0x7d, 0x7d)):setDimensions(590, 100):addTo(node:getParent())
        :setAnchorPoint(0.0, 0.0):setPosition(cc.p(285, 24))
        --        :setString("阿萨德积分拉伸的法律是打飞机拉伸的法律上的看法拉萨的快捷傅案例是打飞机拉速度快发上来的咖啡机拉伸的开发就啊阿萨德拉萨的快捷傅拉伸的开发阿斯兰的开发家拉伸的开发就爱上了大口径发爱上了大口径发拉速度快及发放拉伸的开发就")
    elseif name == "crystal_count" then
        --        node:setString(userData:getGoodsAttrByName("shuij", "count") or 0)
        node:setString(self._info.NeedCoupon or self._info.Price)
        -- 根据数字长度调整位置
        self.uis.crystal:posX(node:posX() - node:width() - self.uis.crystal:width() + 5)
    elseif name == "btn_create" then
        if self._flagHistory then node:setVisible(false) return end
        -- 兑换
        node:addClickEventListener( function()
            playSoundEffect("sound/effect/anniu")
            -- 兑换按钮
            local valid = true
            local params = {
                Type = self._info.ObjectType,
                ExchID = self._info.ExchID,
                EquipID = self._info.EquipID,
                Coupon = 1,
            }
            assert(params.Type == 1 or params.Type == 2 or params.Type == 3 or params.Type == 4)
            if params.Type == 1 then
                -- 1话费
                local phoneNo = self.uis.input_phone:getString()
                if (not phoneNo) or phoneNo == "" or #phoneNo ~= 11 or(not tonumber(phoneNo)) then
                    valid = false
                    self.uis.flag_error_phone:setVisible(true)
                else
                    self.uis.flag_error_phone:setVisible(false)
                end
                params.Phone = phoneNo
            elseif params.Type == 2 then
                -- 2.其它实物
                local phoneNo = self.uis.input_phone:getString()
                local name = self.uis.input_name:getString()
                local location = self.uis.input_loc:getString()
                local province = self.uis.input_province:getString()
                local area = self.uis.input_area:getString()
                local addr = encodeAddr(province, area, location)
                if (not phoneNo) or phoneNo == "" or #phoneNo ~= 11 or(not tonumber(phoneNo)) then
                    -- 手机号有误
                    valid = false
                    self.uis.flag_error_phone:setVisible(true)
                else
                    self.uis.flag_error_phone:setVisible(false)
                end
                if (not name) or name == "" then
                    valid = false
                    self.uis.flag_error_name:setVisible(true)
                else
                    self.uis.flag_error_name:setVisible(false)
                end
                if (not location) or location == "" then
                    valid = false
                    self.uis.flag_error_addr:setVisible(true)
                else
                    self.uis.flag_error_addr:setVisible(false)
                end
                if (not province) or province == "" then
                    valid = false
                    self.uis.flag_error_prov:setVisible(true)
                else
                    self.uis.flag_error_prov:setVisible(false)
                end
                if (not area) or area == "" then
                    valid = false
                    self.uis.flag_error_area:setVisible(true)
                else
                    self.uis.flag_error_area:setVisible(false)
                end
                params.RealName = name
                params.Phone = phoneNo
                params.Address = addr
            elseif params.Type == 3 then
                -- 道具
                params.Coupon = 1
            elseif params.Type == 4 then
                -- 4.现金
                params.RealName = name
                params.Address = addr
            end
            if not valid then
                -- 信息有误
                toast(getStr("invalid_receiverInfo"))
            else
                if params.Type == 2 then
                    -- 实物需要记录收件地址
                    if not self._receiverInfo then
                        -- 新增收货人信息
                        ExchangeProxy:addReceiverInfo( {
                            RealName = params.RealName,
                            Phone = params.Phone,
                            Address = params.Address,
                        } )
                        self._tmpRequestParam = params
                    else
                        -- 收货人信息是否有更新
                        local newReceiverInfo = nil
                        if self._receiverInfo.RealName == params.RealName and
                            self._receiverInfo.Phone == params.Phone and
                            self._receiverInfo.Address == params.Address then
                        else
                            newReceiverInfo = { RealName = params.RealName, Phone = params.Phone, Address = params.Address }
                        end
                        if newReceiverInfo then
                            -- 收货人信息有变，先更新地址
                            newReceiverInfo.RecordID = self._receiverInfo.RecordID
                            ExchangeProxy:modifyReceiverInfo(newReceiverInfo)
                            self._tmpRequestParam = params
                        else
                            -- 收货人信息没有改变，直接兑换
                            -- 其他直接兑换
                            ExchangeProxy:requestExchange(params)
                        end
                    end
                else
                    -- 其他直接兑换
                    ExchangeProxy:requestExchange(params)
                end
            end
        end )
    elseif name == "btn11" then
        -- 道具兑换的数量选择按钮
    elseif name == "btn12" then
        -- 道具兑换的数量选择按钮
    elseif name == "btn13" then
        -- 道具兑换的数量选择按钮
    elseif name == "input_name_bg" then
        -- 输入姓名
        if self._flagHistory then node:getChildByName("flag_history"):setVisible(true) end
        node = node:getChildByName("input_name")
        if self._flagHistory then node:setEnabled(false); end
        if self._info.Recipient then
            node:setString(self._info.Recipient)
        end
        node:onEvent(handler(self, self._textFieldCallback))
        node:setPlaceHolderColor(cc.c3b(0x99, 0x9a, 0x9a))
        node:setTextColor(display.COLOR_BLACK)
    elseif name == "input_phone_bg" or name == "input_bg" then
        -- 兑换实物和兑换话费券的手机号输入框
        if self._flagHistory then node:getChildByName("flag_history"):setVisible(true) end
        node = node:getChildByName("input_phone")
        if self._flagHistory then node:setEnabled(false); end
        node:onEvent(handler(self, self._textFieldCallback))
        if self._info.Phone and self._info.Phone ~= "" then
            node:setString(self._info.Phone)
        end
        node:setPlaceHolderColor(cc.c3b(0x99, 0x9a, 0x9a))
        node:setTextColor(display.COLOR_BLACK)
    elseif name == "input_province_bg" then
        -- 输入省市县
        if self._flagHistory then node:getChildByName("flag_history"):setVisible(true) end
        node = node:getChildByName("input_province")
        if self._flagHistory then node:setEnabled(false); end
        node:onEvent(handler(self, self._textFieldCallback))
        if self._info.Address then
            local province = decodeAddr(self._info.Address)
            node:setString(province)
        end
        node:setPlaceHolderColor(cc.c3b(0x99, 0x9a, 0x9a))
        node:setTextColor(display.COLOR_BLACK)
    elseif name == "input_area_bg" then
        -- 输入区
        if self._flagHistory then node:getChildByName("flag_history"):setVisible(true) end
        node = node:getChildByName("input_area")
        if self._flagHistory then node:setEnabled(false); end
        node:onEvent(handler(self, self._textFieldCallback))
        if self._info.Address then
            local _, area, _1 = decodeAddr(self._info.Address)
            node:setString(area)
        end
        node:setPlaceHolderColor(cc.c3b(0x99, 0x9a, 0x9a))
        node:setTextColor(display.COLOR_BLACK)
    elseif name == "input_loc_bg" then
        -- 输入具体位置
        if self._flagHistory then node:getChildByName("flag_history"):setVisible(true) end
        node = node:getChildByName("input_loc")
        if self._flagHistory then node:setEnabled(false) end
        node:onEvent(handler(self, self._textFieldCallback))
        if self._info.Address then
            local _, loc, _1 = decodeAddr(self._info.Address)
            node:setString(loc)
        end
        node:setPlaceHolderColor(cc.c3b(0x99, 0x9a, 0x9a))
        node:setTextColor(display.COLOR_BLACK)
    end
end

function Exchange_item:_textFieldCallback(event)
    --    wwlog(self.logTag, "输入字符:" .. event.target:getString())
    if event.target == self.uis.input_name then
        event.target:setString(subUtf8Str(event.target:getString(), 10))
    elseif event.target == self.uis.input_phone then
        event.target:setString(string.match(subUtf8Str(event.target:getString(), 11), "^(%d*)"))
    elseif event.target == self.uis.input_province then
        event.target:setString(subUtf8Str(event.target:getString(), 18))
    elseif event.target == self.uis.input_area then
        event.target:setString(subUtf8Str(event.target:getString(), 18))
    elseif event.target == self.uis.input_loc then
        event.target:setString(subUtf8Str(event.target:getString(), 44))
    end
    --    if event.name == "ATTACH_WITH_IME" then
    --    elseif event.name == "DETACH_WITH_IME" then
    --    elseif event.name == "INSERT_TEXT" then
    --    elseif event.name == "DELETE_BACKWARD" then
    --    end
end

function Exchange_item:_handleProxy(event)
    local data = event._userdata
    if event.name == ExchangeCfg.InnerEvents.EXCHANGE_RECEIVERLIST then
        -- 收货人信息
        self._receiverInfo = data.info[1]
        if data.info[1] then
            -- 名字
            if self.uis.input_name then
                self.uis.input_name:setString(data.info[1].RealName)
            end
            if self.uis.input_phone then
                -- 手机号
                self.uis.input_phone:setString(data.info[1].Phone)
            end
            if self.uis.input_loc then
                local prov, area, loc = decodeAddr(data.info[1].Address)
                self.uis.input_province:setString(prov)
                self.uis.input_area:setString(area)
                self.uis.input_loc:setString(loc)
            end
        end
    elseif event.name == ExchangeCfg.InnerEvents.ROOT_RET_REQ_SET_RECEIVER then
        -- 设置收货人响应
        if data.kReasonType == 0 then
            -- 新增收货人，请更新RecordID
            -- 设置成功
            if self._tmpRequestParam then
                self._receiverInfo = self._receiverInfo or { }
                self._receiverInfo.Address = self._tmpRequestParam.Address
                self._receiverInfo.Phone = self._tmpRequestParam.Phone
                self._receiverInfo.RealName = self._tmpRequestParam.RealName
                self._receiverInfo.RecordID = self._receiverInfo.RecordID or tonumber(data.kReason)
                -- 先添加(更新)收货人信息再兑换
                ExchangeProxy:requestExchange(self._tmpRequestParam)
                self._tmpRequestParam = nil
            end
        end
    elseif event.name == ExchangeCfg.InnerEvents.ROOT_RET_REQ_EXCHANGE then
        if data.kReasonType == 0 then
            ExchangeProxy:requestExchangeList()
            -- 兑换成功
            if self.uis.flag_error_phone then
                self.uis.flag_error_phone:setVisible(false)
            end
            if self.uis.flag_error_name then
                self.uis.flag_error_name:setVisible(false)
            end
            if self.uis.flag_error_addr then
                self.uis.flag_error_addr:setVisible(false)
            end
            if self.uis.flag_error_prov then
                self.uis.flag_error_prov:setVisible(false)
            end
            if self.uis.flag_error_area then
                self.uis.flag_error_area:setVisible(false)
            end
        end
    end
end

return Exchange_item
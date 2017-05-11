-------------------------------------------------------------------------
-- Title:       兑换中心消息代理
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ExchangeProxy = class("ExchangeProxy", require("packages.mvc.Proxy"))
local ExchangeCfg = require("hall.mediator.cfg.ExchangeCfg")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local userData = DataCenter:getUserdataInstance()

function ExchangeProxy:init()
    self.logTag = "ExchangeProxy.lua"
    self._netModel = require("hall.model.exchangenetModel")
    self._msgHeaders = nil
    self:start()
end

function ExchangeProxy:start()
    self._msgHeaders = ToolCom.registerNetMsgListener(self, self._response, self._rootResponse, self._netModel)
end

function ExchangeProxy:stop()
    ToolCom.unregisterNetMsgListener(self, self._netModel)
    self._msgHeaders = nil
end

function ExchangeProxy:_response(msgId, msgTable)
    LoadingManager:endLoading()
    wwlog(self.logTag, "兑换中心模块收到消息:" .. msgId)

    local dispatchEventId = nil
    local dispatchData = nil
    if msgId == self._msgHeaders.Msg_ConvertibleEquipList_Ret then
        -- 兑换列表
        assert(msgTable.UserID == userData:getValueByKey("userid"))
        dispatchEventId = ExchangeCfg.InnerEvents.EXCHANGE_EQUIPLIST

        table.map(msgTable.otherInfo, function(v, k)
            table.map(v, function(v1, k1)
                msgTable.exchangeInfo[k][k1] = v1
            end )
        end )
        table.map(msgTable.statusInfo, function(v, k)
            table.map(v, function(v1, k1)
                msgTable.exchangeInfo[k][k1] = v1
            end )
        end )
        msgTable.otherInfo, msgTable.statusInfo = nil, nil
        dispatchData = msgTable
    elseif msgId == self._msgHeaders.Msg_ConvertibleEquipInfo_Ret then
        -- 兑换商品详情
        dispatchEventId = ExchangeCfg.InnerEvents.EXCHANGE_EQUIPINFO
        dispatchData = msgTable
    elseif msgId == self._msgHeaders.Msg_MyAwardList_Ret then
        -- 兑换历史记录
        dispatchEventId = ExchangeCfg.InnerEvents.EXCHANGE_MYAWARDLIST
        table.map(msgTable.userInfo, function(v, k)
            table.map(v, function(v1, k1)
                msgTable.info[k][k1] = v1
            end )
        end )
        table.map(msgTable.magicInfo, function(v, k)
            table.map(v, function(v1, k1)
                msgTable.info[k][k1] = v1
            end )
        end )
        table.map(msgTable.recipientInfo, function(v, k)
            table.map(v, function(v1, k1)
                msgTable.info[k][k1] = v1
            end )
        end )
        msgTable.userInfo, msgTable.magicInfo, msgTable.recipientInfo = nil, nil, nil
        dispatchData = msgTable
    elseif msgId == self._msgHeaders.Msg_ReceiverList_Ret then
        -- 收货人信息
        dispatchEventId = ExchangeCfg.InnerEvents.EXCHANGE_RECEIVERLIST
        dispatchData = msgTable
    end
    dump(dispatchData)
    if dispatchEventId and ExchangeCfg.innerEventComponent then
        ExchangeCfg.innerEventComponent:dispatchEvent( {
            name = dispatchEventId,
            _userdata = dispatchData
        } )
    end
end

-- 通用消息
function ExchangeProxy:_rootResponse(msgId, msg)
    LoadingManager:endLoading()
    wwdump(msg, "兑换中心模块收到通用消息:" .. msgId)

    local dispatchEventId = nil
    local dispatchData = msg

    if msgId == self._msgHeaders.Msg_ExchangeDataReq_send then
        -- 请求兑换中心数据
        dispatchEventId = ExchangeCfg.InnerEvents.ROOT_RET_REQ_EQUIPLIST
    elseif msgId == self._msgHeaders.Msg_ExchangeCommit_send then
        -- ReasonType0:成功兑换或提交成功等待发货  1:库存不足  2:道具数量不足  3:兑换项不存在或过期  4:兑换次数限制已到上限  5:提交失败
        -- 6:需绑定手机才能兑换  -1:其他异常
        -- 微信提现兑换特有:  10：未授权  11：没有权限  12：付款金额不能小于最低限额  13：参数错误   14：Openid错误  15：余额不足
        -- 16：系统繁忙，请稍后再试。  17：姓名校验出错  18：签名错误  19：Post内容出错  20：两次请求参数不一致	  21：证书出错
        dispatchEventId = ExchangeCfg.InnerEvents.ROOT_RET_REQ_EXCHANGE
        if msg.kResult == 0 then
            toast(i18n:get("str_exchange", "exchange_success"))
        else
            toast(i18n:get("str_exchange", "exchange_fail"))
        end
    elseif msgId == self._msgHeaders.Msg_setReceiver_send then
        -- 设置收货人
        -- Result = 0:成功 -1:异常 1:出现重复地址 2:参数错误当Type=0时Reason = 新增记录ID
        dispatchEventId = ExchangeCfg.InnerEvents.ROOT_RET_REQ_SET_RECEIVER
    elseif msgId == self._msgHeaders.Msg_ThirdpartyAccessReq_send then
        -- 第三方授权相关操作
        dispatchEventId = ExchangeCfg.InnerEvents.ROOT_RET_REQ_THIRDPARTYACCESS
    end
    if msg.kResult ~= 0 then toast(msg.kReason) end
    if dispatchEventId and ExchangeCfg.innerEventComponent then
        ExchangeCfg.innerEventComponent:dispatchEvent( {
            name = dispatchEventId,
            _userdata = dispatchData
        } )
    end
end

-- 请求兑换中心数据
function ExchangeProxy:requestExchangeList()
    self:_requestExchangeAct(24)
end

-- 兑换物品
-- objectID 兑换ID
function ExchangeProxy:requestExchangeItemDetail(objectID)
    self:_requestExchangeAct(5, objectID)
end

-- 我的兑换记录，默认最近50条。
function ExchangeProxy:requestExchangeHistory(exchgCenterID)
    self:_requestExchangeAct(22, exchgCenterID, 1, 50)
end

-- 我的送货地址
function ExchangeProxy:requestReceiverInfo()
    self:_requestExchangeAct(2)
end

function ExchangeProxy:_requestExchangeAct(Type, objectID, param1, param2)
    LoadingManager:startLoading(1.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    local paras = {
        bit.band(bit.rshift(self._msgHeaders.Msg_ExchangeDataReq_send,4 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_ExchangeDataReq_send,2 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_ExchangeDataReq_send,0 * 4),0xff),
        -- (int1)0=大奖赛奖品兑换（使用兑换券兑换）
        -- 1=我的中奖列表(实物)
        -- 2=我的送货地址列表
        -- 3=兑换说明信息
        -- 4=免责声明
        -- 5=兑换商品详情
        -- 6=综合中奖列表(转盘)
        -- 11=碎片兑换奖品列表
        -- 12=蛙卡兑换奖品列表
        -- 13=我的中奖列表(转盘)
        -- 14=晶石兑换奖品列表
        -- 15=话费兑换奖品列表
        -- 16=金块兑换奖品列表
        -- 17=麻将话费券兑换奖品列表
        -- 18=我的中奖记录列表(用FID区分游戏)
        -- 19 =全局实物中奖记录(用FID区分游戏)
        -- 20 =斗牛金块兑换奖品列表
        -- 21= 斗地主兑换奖品列表
        -- 22 =我的中奖记录列表(用ExchCenterID区分)
        -- 23 =微信兑换现金列表
        Type,-- Type = 24,掼蛋兑换中心
        wwConfigData.GAME_ID,-- gameid
        objectID or 0,-- objectID
        param1 or 0,-- param1
        param2 or 0,-- param2
    }
    self:sendMsg(self._msgHeaders.Msg_ExchangeDataReq_send, paras)
end



-- 请求兑换
-- 返回通用消息
function ExchangeProxy:requestExchange(params)
    dump(params)
    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    local paras = {
        bit.band(bit.rshift(self._msgHeaders.Msg_ExchangeCommit_send,4 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_ExchangeCommit_send,2 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_ExchangeCommit_send,0 * 4),0xff),
        -- 1=话费卡兑换
        -- 2=实物兑换
        -- 3=道具兑换
        -- 4=现金兑换
        -- 99=实物领取
        params.Type,
        params.ExchID,-- 兑换ID
        params.EquipID,-- 物品ID
        1,-- 兑换数量，目前定死1
        params.RealName or "",-- 收件人实名/第三方帐号名, Type = 2/4 时必须填写
        params.Phone or "",-- 电话,Type = 1/2 时必须填写
        params.Address or "",-- (String)详细地址/第三方帐号, Type = 2/4 时必须填写微信提现时为openid
        params.MagicName or "",-- 道具名称
    }
    self:sendMsg(self._msgHeaders.Msg_ExchangeCommit_send, paras)
end

-- 新增收货人
function ExchangeProxy:addReceiverInfo(params)
    params.Type = 0
    self:_updateReceiverInfo(params)
end

-- 修改收货人
function ExchangeProxy:modifyReceiverInfo(params)
    params.Type = 2
    self:_updateReceiverInfo(params)
end

-- 删除收货人
function ExchangeProxy:delReceiverInfo(params)
    params.Type = 1
    self:_updateReceiverInfo(params)
end

-- 设置收货人
-- 返回通用消息
function ExchangeProxy:_updateReceiverInfo(params)
    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    -- 记录ID,新增写0
    params.RecordID = params.RecordID or 0
    -- 收货人实名,为空表示不修改
    params.RealName = params.RealName or ""
    -- 收货人电话,为空表示不修改
    params.Phone = params.Phone or ""
    -- 收货人详细地址,为空表示不修改
    params.Address = params.Address or ""
    params.Default = params.Default or 0
    dump(params)
    local paras = {
        bit.band(bit.rshift(self._msgHeaders.Msg_setReceiver_send,4 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_setReceiver_send,2 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_setReceiver_send,0 * 4),0xff),
        assert(params.Type),-- (int1)0=新增 1=删除 2=修改
        params.RecordID,-- 记录ID,新增写0
        params.RealName,-- 收货人实名,为空表示不修改
        params.Phone,-- 收货人电话,为空表示不修改
        params.Address,-- 收货人详细地址,为空表示不修改
        params.Default,-- 1=设置为默认,=0表示不修改
    }
    self:sendMsg(self._msgHeaders.Msg_setReceiver_send, paras)
end

-- 第三方授权请求
-- Type=1时, param1=APPID,param2=Code, Param3 = secret
function ExchangeProxy:requestThirdpartyAccess()
    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    local paras = {
        bit.band(bit.rshift(self._msgHeaders.Msg_ThirdpartyAccessReq_send,4 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_ThirdpartyAccessReq_send,2 * 4),0xff),
        bit.band(bit.rshift(self._msgHeaders.Msg_ThirdpartyAccessReq_send,0 * 4),0xff),
        Type,-- (int1)1=微信提现授权
        Param1,-- 参数1
        Param2,-- 参数2
        Param3,-- 参数3
    }
    self:sendMsg(self._msgHeaders.Msg_ThirdpartyAccessReq_send, paras)
end

return ExchangeProxy
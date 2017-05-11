-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.20
-- Last:
-- Content:  兑换中心配置管理
-- 		包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ExchangeCfg = { }
ExchangeCfg.innerEventComponent = nil
ExchangeCfg.InnerEvents = {
    -- 请求兑换列表
    EXCHANGE_REQ_EQUIPLIST = "EXCHANGE_REQ_EQUIPLIST",
    -- 兑换请求
    EXCHANGE_REQ_EXCHANGE = "EXCHANGE_REQ_EXCHANGE",
    -- 设置收货人信息
    EXCHANGE_REQ_UPDATERECEIVER = "EXCHANGE_REQ_UPDATERECEIVER",
    -- 可兑换商品列表
    EXCHANGE_EQUIPLIST = "EXCHANGE_EQUIPLIST",
    -- 各种说明文字信息
    EXCHANGE_EXCHANGETEXTINFO = "EXCHANGE_EXCHANGETEXTINFO",
    -- 兑换商品详情
    EXCHANGE_EQUIPINFO = "EXCHANGE_EQUIPINFO",
    -- 收货人信息
    EXCHANGE_RECEIVERLIST = "EXCHANGE_RECEIVERLIST",
    -- 我的奖品列表，也就是历史记录
    EXCHANGE_MYAWARDLIST = "EXCHANGE_MYAWARDLIST",
    -- 第三方授权请求
    EXCHANGE_REQ_THIRDPARTYACCESS = "EXCHANGE_REQ_THIRDPARTYACCESS ",
    -- 微信授权信息详情
    EXCHANGE_WXACCESSINFO = "EXCHANGE_WXACCESSINFO ",

    -- 通用响应请求
    -- 兑换列表
    ROOT_RET_REQ_EQUIPLIST = "ROOT_RET_REQ_EQUIPLIST",
    -- 兑换请求
    ROOT_RET_REQ_EXCHANGE = "ROOT_RET_REQ_EXCHANGE",
    -- 设置收货人
    ROOT_RET_REQ_SET_RECEIVER = "ROOT_RET_REQ_SET_RECEIVER",
    -- 第三方授权
    ROOT_RET_REQ_THIRDPARTYACCESS = "ROOT_RET_REQ_THIRDPARTYACCESS",
}

return ExchangeCfg
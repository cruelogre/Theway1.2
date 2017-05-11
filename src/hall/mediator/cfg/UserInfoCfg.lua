-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.20
-- Last:
-- Content:  个人信息配置管理
-- 		包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UserInfoCfg = { }
UserInfoCfg.innerEventComponent = nil
UserInfoCfg.InnerEvents = {
    -- 收到个人详情数据广播
    MESSAGE_EVENT_USERINFO = "MESSAGE_EVENT_USERINFO",
    -- 修改性别
    MESSAGE_EVENT_MODIFY_SEX = "MESSAGE_EVENT_MODIFY_SEX",
    -- 修改姓名
    MESSAGE_EVENT_MODIFY_NICKNAME = "MESSAGE_EVENT_MODIFY_NICKNAME",
    -- 绑定手机号成功或失败
    MESSAGE_EVENT_BIND_PHONE = "MESSAGE_EVENT_BIND_PHONE",
    -- 解绑手机号成功或失败
    MESSAGE_EVENT_UNBIND_PHONE = "MESSAGE_EVENT_UNBIND_PHONE",
    -- 重置密码成功或失败
    MESSAGE_EVENT_RESET_PSW = "MESSAGE_EVENT_RESET_PSW",
    -- 注销账号成功或失败
    MESSAGE_EVENT_UNREGISTER_ACCOUNT = "MESSAGE_EVENT_UNREGISTER_ACCOUNT",
    -- 验证码发送成功或失败
    MESSAGE_EVENT_SEND_VERIFY_CODE = "MESSAGE_EVENT_SEND_VERIFY_CODE",
    -- 道具生效之后的有效期剩余时间
    MESSAGE_EVENT_PROP_VALID_PERIOD = "MESSAGE_EVENT_PROP_VALID_PERIOD",
    -- 收到对局中玩家数据
    MESSAGE_EVENT_GAMEPLAYINFO = "MESSAGE_EVENT_GAMEPLAYINFO",
}

return UserInfoCfg
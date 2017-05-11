-------------------------------------------------------------------------
-- Title:       玩家个人信息代理
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:    不是简要个人信息
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local UserInfoProxy = class("UserInfoProxy", require("packages.mvc.Proxy"))

local netModel = require "hall.model.userInfoModel"
local msgHeader = netModel.MSG_ID
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local Toast = require("app.views.common.Toast")
local userData = DataCenter:getUserdataInstance()
local UserInfoRequest = require("hall.request.UserInfoRequest")

function UserInfoProxy:init()
    self.logTag = "UserInfoProxy.lua"
    self._netModel = netModel:create(self)
    self.regionInfo = nil
    self:registerMsg()
end

function UserInfoProxy:registerMsg()
    self:registerMsgId(msgHeader.Msg_GDUserInfo_Ret, handler(self, self.response))
	
	self:registerMsgId(msgHeader.Msg_RUserGameScore_Ret, handler(self, self.response))
	
    -- 注册Root消息 Type = 1 3 4
    self:registerRootMsgId(msgHeader.Msg_GDUserInfo_send, handler(self, self.response))
    -- 绑定手机
    self:registerRootMsgId(msgHeader.Msg_BindPhoneReq_send, handler(self, self.response))
    -- 注销请求
    self:registerRootMsgId(msgHeader.Msg_unregisterReq_send, handler(self, self.response))
    -- 注册Root消息 更新用户信息，定位信息
    self:registerRootMsgId(msgHeader.Msg_NewUpdateUserInfo_send, handler(self, self.response))
end

function UserInfoProxy:response(msgId, msgTable)
    wwdump(msgTable, "个人详情模块收到消息:" .. msgId)
    LoadingManager:endLoading()
    local dispatchEventId = nil
    local dispatchData = nil
    if msgId == msgHeader.Msg_GDUserInfo_Ret then
        -- 个人详情
        dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO
		dispatchData = msgTable
        DataCenter:cacheData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, msgTable)
    elseif msgId == msgHeader.Msg_GDUserInfo_send then
        -- 请求个人详情通用消息，一般是信息请求失败
        if msgTable.kReasonType == 11 then
            -- 修改性别
            dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_SEX
            DataCenter:cacheData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_SEX, {
                isSucc = msgTable.kResult == 0,
                sex = msgTable.kReason
            } )
            if msgTable.kResult == 0 then
                -- 修改成功
                DataCenter:getUserdataInstance():setUserInfoByKey("gender", tonumber(msgTable.kReason))
                self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 1)
            end
        elseif msgTable.kReasonType == 12 then
            -- 修改昵称
            dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_NICKNAME
            DataCenter:cacheData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_NICKNAME, {
                isSucc = msgTable.kResult == 0,
                nickname = msgTable.kReason
            } )
            if msgTable.kResult == 0 then
                -- 修改成功
                DataCenter:getUserdataInstance():setUserInfoByKey("nickname", msgTable.kReason)
                self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 1)
            end
        elseif msgTable.kReasonType == 3 then
            -- 破产状态
        elseif msgTable.kReasonType == 15 or msgTable.kReasonType == 17 then
            -- 任务分享通知
        elseif msgTable.kReasonType == 16 then
            -- 道具生效之后，剩余的有效期时间
            self:dispatchEvent(UserInfoCfg.InnerEvents.MESSAGE_EVENT_PROP_VALID_PERIOD, tonumber(msgTable.kReason) or 0)
        else
            Toast:makeToast(i18n:get("str_userInfo", "request_fail"), 2.0):show()
        end
    elseif msgId == msgHeader.Msg_NewUpdateUserInfo_send then
        -- 获取头像成功
        DataCenter:getUserdataInstance():setUserInfoByKey("Region", self.regionInfo)
        self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 1)

    elseif msgId == msgHeader.Msg_BindPhoneReq_send then
        -- 绑定/解绑手机号，验证码，重置密码
        local Type, result = msgTable.kReasonType, tonumber(msgTable.kResult)
        if Type == 1 or Type == 2 or Type == 3 then
            -- 1 -请求绑定手机验证码。2 -请求解绑手机验证码。3 -请求重置密码手机验证码
            dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_SEND_VERIFY_CODE
            dispatchData = result == 1
        elseif Type == 4 then
            -- 绑定手机号
            dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_BIND_PHONE
            dispatchData = result == 1
        elseif Type == 5 then
            -- 解除绑定手机号
            dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_UNBIND_PHONE
            dispatchData = result == 1
        elseif Type == 6 then
            -- 重置密码
            dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_RESET_PSW
            -- isSucc是否成功，account对应的蛙号
            dispatchData = { isSucc = result == 1, account = msgTable.kUserId }
        end
        Toast:makeToast(msgTable.kReason, 1.5):show()
    elseif msgId == msgHeader.Msg_unregisterReq_send then
        -- 注销账号
        dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_UNREGISTER_ACCOUNT
	elseif msgId == msgHeader.Msg_RUserGameScore_Ret then
		dispatchEventId = UserInfoCfg.InnerEvents.MESSAGE_EVENT_GAMEPLAYINFO
		local gameData = DataCenter:getData(dispatchEventId)
		if not gameData then
			gameData = {}
			DataCenter:cacheData(dispatchEventId,gameData)
		end
		
		if gameData[msgTable.UserID] and gameData[msgTable.UserID][msgTable.GameID] then
			removeAll(gameData[msgTable.UserID][msgTable.GameID])
		end
		gameData[msgTable.UserID] = gameData[msgTable.UserID] or {}
		gameData[msgTable.UserID][msgTable.GameID] = clone(msgTable)
		
    end

    if dispatchEventId and UserInfoCfg.innerEventComponent then
        UserInfoCfg.innerEventComponent:dispatchEvent( {
            name = dispatchEventId,
            _userdata = dispatchData
        } )
    else
        -- 排行榜需要个人详情
        if dispatchEventId then
            self:dispatchEvent(dispatchEventId, msgTable)
        end
    end
end

-- 个人信息，userID为空，则请求自己的信息
function UserInfoProxy:requestUserInfo(userID)
    return self:_requestUserInfo(2, userID or userData:getValueByKey("userid"), nil)
end
--请求游戏数据
--@param userID 用户ID 空则表示自己
--@param plaType 游戏玩法 string 用逗号分开
function UserInfoProxy:requestGameInfo(userID,plaType,gameid)
	local ureq = UserInfoRequest:create()
	ureq:formatRequest(5,userID or userData:getValueByKey("userid"),plaType,gameid)
	ureq:send(self)
end
-- 更新昵称
function UserInfoProxy:modifyNickname(nickname)
    return self:_requestUserInfo(12, userData:getValueByKey("userid"), nickname)
end

-- 改为男性，1男2女
function UserInfoProxy:modifyMale()
    return self:_requestUserInfo(11, userData:getValueByKey("userid"), "1")
end

-- 修改头像
function UserInfoProxy:modifyHead()
    return self:_requestUserInfo(13, userData:getValueByKey("userid"), 101)
end
-- 修改女性
function UserInfoProxy:modifyFemale()
    return self:_requestUserInfo(11, userData:getValueByKey("userid"), "2")
end

-- 请求道具使用有效期剩余时间。比如记牌器使用时开始24小时倒计时，就是这个倒计时剩余时间。
function UserInfoProxy:requestValidPeriod(fid)
    wwlog(self.logTag, "请求道具使用有效期剩余时间：" .. fid)
    return self:_requestUserInfo(16, userData:getValueByKey("userid"), tostring(fid))
end

-- 绑定手机
function UserInfoProxy:bindPhone(phoneNo, verifyCode)
    self:_requestBind(4, phoneNo, verifyCode)
end

-- 验证码
function UserInfoProxy:bindPhoneVerify(phoneNo)
    self:_requestBind(1, phoneNo)
end

-- 解除绑定手机
function UserInfoProxy:unbindPhone(phoneNo, verifyCode)
    self:_requestBind(5, phoneNo, verifyCode)
end

-- 验证码
function UserInfoProxy:unbindPhoneVerify(phoneNo)
    self:_requestBind(2, phoneNo)
end

-- 找回密码（重置密码）
function UserInfoProxy:resetPswByPhone(phoneNo, verifyCode, psw)
    self:_requestBind(6, phoneNo, verifyCode, psw)
end

-- 找回密码的验证码
function UserInfoProxy:resetPswVerify(phoneNo)
    self:_requestBind(3, phoneNo)
end

-- exitType:(int1)退出方式.默认为1
-- 1 正常退出
-- 2 超时退出(掉线)
-- 3重复登录强制退出
-- 4系统超时(挂线、空闲超时) 
function UserInfoProxy:logout(exitType)
    exitType = exitType or 1
    local paras = {
        bit.band(bit.rshift(msgHeader.Msg_unregisterReq_send,4 * 4),0xff),
        bit.band(bit.rshift(msgHeader.Msg_unregisterReq_send,2 * 4),0xff),
        bit.band(bit.rshift(msgHeader.Msg_unregisterReq_send,0 * 4),0xff),
        userData:getValueByKey("userid"),
        exitType
    }
    self:sendMsg(msgHeader.Msg_unregisterReq_send, paras)
end

-- 请求灌蛋玩家个人数据
-- mType(int1)请求类型,
-- 1=对局中玩家数据
-- 2=个人信息
-- 11=更新性别
-- 12=更新昵称
function UserInfoProxy:_requestUserInfo(mType, userID, param)
    LoadingManager:startLoading(1.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    local paras = {
        bit.band(bit.rshift(msgHeader.Msg_GDUserInfo_send,4 * 4),0xff),
        bit.band(bit.rshift(msgHeader.Msg_GDUserInfo_send,2 * 4),0xff),
        bit.band(bit.rshift(msgHeader.Msg_GDUserInfo_send,0 * 4),0xff),
        mType,
        userID,
        param,
		wwConfigData.GAME_ID,
    }
    dump(paras)
    self:sendMsg(msgHeader.Msg_GDUserInfo_send, paras)

    if (mType == 11) or(mType == 12) then
        self:getAndUpdateCity()
    end
end

function UserInfoProxy:getAndUpdateCity()
    -- 更新定位信息
    local function locationCallBack(locationInfos)
        local citeCode, proname, cityname
        if locationInfos.content then
            citeCode = locationInfos.content.address_detail.city_code
            proname = locationInfos.content.address_detail.province
            cityname = locationInfos.content.address_detail.city

            self:updataLocation(citeCode, proname, cityname)

            self.regionInfo = locationInfos.content.address
        end

    end
    -- 定位
    ToolCom:getLocation(locationCallBack)
end

-- 更新定位信息 百度定位
function UserInfoProxy:updataLocation(citeCode, proname, cityname)
    local paras = {
        1,
        1,
        46,
        3,
        citeCode,
        proname,
        cityname,
        ""
    }
    wwdump(paras, "上传定位信息")

    self:sendMsg(msgHeader.Msg_NewUpdateUserInfo_send, paras)
end

-- Type::(int1)请求类型：
-- 1 -请求绑定手机验证码
-- 2 -请求解绑手机验证码
-- 3 -请求重置密码手机验证码
-- 4 -绑定手机号
-- 5 -解除绑定手机号
-- 6 -重置密码
-- verifyCode::(int4)验证码。Type=1/2/3时填0
-- userPsw::Type=4时有效
function UserInfoProxy:_requestBind(Type, phoneNo, verifyCode, userPsw)
    verifyCode = verifyCode or 0
    userPsw = userPsw or ww.WWGameData:getInstance():getStringForKey("pwd", "")
    local userid = 0
    if Type ~= 3 and Type ~= 6 and Type ~= 2 and Type ~= 5 then
        userid = tonumber(userData:getValueByKey("userid"))
    end
    wwlog(self.logTag, "Type:%s,phoneNo:%s,verifyCode:%s,userPsw:%s", Type, phoneNo, verifyCode, userPsw)
    local paras = {
        bit.band(bit.rshift(msgHeader.Msg_BindPhoneReq_send,4 * 4),0xff),
        bit.band(bit.rshift(msgHeader.Msg_BindPhoneReq_send,2 * 4),0xff),
        bit.band(bit.rshift(msgHeader.Msg_BindPhoneReq_send,0 * 4),0xff),
        userid,
        phoneNo,
        Type,
        verifyCode,
        wwConst.SP,
        userPsw,
        wwConfigData.GAME_ID,
    }
    self:sendMsg(msgHeader.Msg_BindPhoneReq_send, paras)
end

return UserInfoProxy
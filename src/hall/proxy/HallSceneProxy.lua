-------------------------------------------------------------------------
-- Desc:
-- Author:  diyal.yin
-- Date:    2016.08.13
-- Last:
-- Content:  常见数据中心结构定义  不允许自己用，需要再DataCenter中获取实例
-- 20160809  新建
-- 20160809  添加大厅协议数据，并且将登录后收到的玩家信息存到用户数据中心
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HallSceneProxy = class("HallSceneProxy", require("packages.mvc.Proxy"))
local ChooseRoomRequest = require("hall.request.ChooseRoomRequest")
local UserInfoRequest = require("hall.request.UserInfoRequest")
local GoodsBoxRequest = require("hall.request.GoodsBoxRequest")
local LoveotaRequest = require("hall.request.LoveotaRequest")

local HallCfg = require("hall.mediator.cfg.HallCfg")
local TaskCfg = require("hall.mediator.cfg.TaskCfg")

local RequestInfoRequest = require("app.request.RequestInfoRequest")
local userData = DataCenter:getUserdataInstance()
import(".HallEvent", "hall.event.")
function HallSceneProxy:init()
    self.logTag = "HallSceneProxy.lua"
    wwlog(self.logTag, "HallSceneProxy.lua init")

    self.hallMsgModel = import(".HallNetModel", "hall.model."):create(self)
	self.hallMsgModel2 = import(".HallNetModel2", "hall.model."):create(self)
	
    self.ReqClientADInfo = import(".ReqClientADInfo", "hall.model."):create(self)
    -- 比赛中物品箱
    self.goodsBoxMsgModel = import(".goodsBoxModel", "hall.model."):create(self)
    -- 消息实体
    self._messageModel = require("hall.model.messageModel"):create(self)

    self._userInfoModel = require("hall.model.userInfoModel"):create(self)

    self._userIssueNotifyModel = require("app.netMsgBean.userIssueNotifyModel"):create(self)

	self.LoveotaModel = require("hall.model.LoveotaModel"):create(self)

    local emtpyT = { }
    emtpyT[1] = { }
    emtpyT[2] = { }
    emtpyT[3] = { }
    DataCenter:cacheData(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST, emtpyT)
    self:registerMsg()
end

function HallSceneProxy:registerMsg()
    self:registerMsgId(self.hallMsgModel.MSG_ID.Msg_GDGameZoneList_Ret,
    handler(self, self.response))

    self:registerMsgId(self.hallMsgModel.MSG_ID.Msg_GDBriefUserInfo_ret,
    handler(self, self.response))

    -- 物品箱列表
    self:registerMsgId(self.goodsBoxMsgModel.MSG_ID.Msg_EquipList_Ret, handler(self, self.response))
    -- 比赛物品的说明信息
    self:registerMsgId(self.goodsBoxMsgModel.MSG_ID.Msg_MatchEquipInfo_Ret, handler(self, self.response))
    -- 游戏物品的详细说明信息
    self:registerMsgId(self.goodsBoxMsgModel.MSG_ID.Msg_GameEquipInfo_Ret, handler(self, self.response))
    -- 游戏物品的数量信息刷新
    self:registerMsgId(self.goodsBoxMsgModel.MSG_ID.Msg_GameEquipNumber_Ret, handler(self, self.response))
	
	self:registerMsgId(self.goodsBoxMsgModel.MSG_ID.Msg_GameEquipDesc_Ret, handler(self, self.response))
	
    self:registerRootMsgId(self.hallMsgModel2.MSG_ID.Msg_GDHallAction_send2,
    handler(self, self.onHallSceneListReceived), HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST)

    -- 注册公告消息
    self:registerMsgId(self._messageModel.MSG_ID.Msg_NoticeList_Ret, handler(self, self.response))
    self:registerMsgId(self._messageModel.MSG_ID.Msg_MsgContent_Ret, handler(self, self.response))

    --注册监听广告列表
    self:registerMsgId(self.ReqClientADInfo.MSG_ID.Msg_RespClientADInfo_Ret, handler(self, self.response))
	--平台奖励通知
	self:registerMsgId(self._userInfoModel.MSG_ID.Msg_GDAwardNotify_Ret, handler(self, self.handleAwardNotify))
	--道具物品发放通知
	self:registerMsgId(self._userIssueNotifyModel.MSG_ID.Msg_IssueNotify_Ret,handler(self, self.response))
	--操作反馈通知
	self:registerMsgId(self._userIssueNotifyModel.MSG_ID.Msg_ResultInfo_Ret, handler(self, self.handleResultInfo))
	
    self:registerRootMsgId(self._userInfoModel.MSG_ID.Msg_GDUserInfo_send, handler(self, self.handleUserInfo))
	
    self:registerRootMsgId(self._userIssueNotifyModel.MSG_ID.Msg_RequestInfo_Send, handler(self, self.handleUserInfo))
	
	self:registerRootMsgId(self.LoveotaModel.MSG_ID.Msg_CheckVersion_send, handler(self, self.handleRoot))
	
    -- 登录成功即获取物品箱信息
    NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK, function()
        -- 获取游戏物品箱列表
        self:requestGoodsBoxInfo()
    end )
end
-- 请求大厅人数
-- @param param1 请求类型 1 比赛场 2 经典场 3 私人定制
function HallSceneProxy:requestHallSceneList(param1, gameID, playtype)
    print("HallSceneProxy:requestHallSceneList", param1)
    local msgIds = self.hallMsgModel.MSG_ID
    DataCenter:updateData(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST, param1, { })
    local crquest = ChooseRoomRequest:create()

    if gameID and playtype then
        crquest:formatRequest(6, param1, gameID)
    else
        crquest:formatRequest(6, param1)
    end
    crquest:send2(self) --使用新版消息

end

-- 物品箱物品列表
function HallSceneProxy:requestGoodsBoxInfo()
    self:requestGoodsBox(0, 1011)
end

-- 及时比赛物品箱
function HallSceneProxy:requestGoodsBoxInfoRunTime()
    self:requestGoodsBox(0, 9211)
end

-- 比赛物品说明信息,magicIDorFID=物品ID magicID
function HallSceneProxy:requestMatchGoodsInfo(Type, magicIDorFID)
    self:requestGoodsBox(1, magicIDorFID)
end

-- 请求道具物品数量fid表示物品FID
-- 收到响应之后会发出广播，告知什么物品数量刷新了，各个子块根据fid来判断是否需要刷新自己的模块。
function HallSceneProxy:requestGoodsCount(fid)
    self:requestGoodsBox(3, fid)
end

-- 游戏道具详细信息magicIDorFID=物品ID magicID
function HallSceneProxy:requestGoodsInfoDetail(magicID)
    self:requestGoodsBox(2, magicID)
end

-- 游戏道具详细信息ObjectID=功能ID FID。同上。
function HallSceneProxy:requestGoodsInfoDetail1(fid)
    self:requestGoodsBox(4, fid)
end

-- 比赛|游戏物品箱
function HallSceneProxy:requestGoodsBox(Type, magicIDorFID)
    print("HallSceneProxy:requestGoodsBox", Type, magicIDorFID)
    LoadingManager:startLoading(2.0,LOADING_MODE.MODE_NORMAL)
    local msgIds = self.goodsBoxMsgModel.MSG_ID
    --    DataCenter:updateData(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST, params, { })
    local quest = GoodsBoxRequest:create()
    quest:formatRequest(Type, magicIDorFID)
    quest:send(self)
end
-- 判断我是否破产
function HallSceneProxy:requestIsBankrupt()
    local userinfo = UserInfoRequest:create()
    userinfo:formatRequest(3, tonumber(userData:getValueByKey("userid")))
    userinfo:send(self)
end
--查询首充状态
function HallSceneProxy:requestFirstChargeState()
	local userinfo2 = RequestInfoRequest:create()
	userinfo2:formatRequest(tonumber(userData:getValueByKey("userid")),
        63,
        -- wwConfigData.GAME_ID,
        wwConfigData.CHARGE_BANKID_DIAMOND,
        1)
	userinfo2:send(self)
end

-- 请求破产补助
function HallSceneProxy:requestBankruptAward()
    local req = RequestInfoRequest:create()
    req:formatRequest(tonumber(userData:getValueByKey("userid")), 35, wwConfigData.GAME_ID)
    req:send(self)
end
function HallSceneProxy:sendZhuomengData(javaData)
	if javaData then
		wwlog(self.logTag,javaData)
		local zmdata = string.split(javaData,"|")
		if zmdata and type(zmdata)=="table" and table.getn(zmdata)>=4 then
			wwdump(zmdata,"卓盟更新数据")
			local halloldversion = zmdata[1]
			local hallnewversion = zmdata[2]
			local updated = zmdata[3]
			local zmuserid = zmdata[4]
			if updated=="true" then
				local LoveotaRequest = LoveotaRequest:create()
				local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
				LoveotaRequest:formatRequest(tostring(userid),halloldversion,hallnewversion,zmuserid)
				LoveotaRequest:send(self)
				--wwlog(os.date("%Y-%m-%d% H:%M:%S", os.time()))
			end

		end
	end

end

function HallSceneProxy:onHallSceneListReceived(msgId, msgTable)

    wwdump(msgTable, msgId)
    if msgTable.kReason and type(msgTable.kReason) == "string" then
        local temp = string.split(msgTable.kReason, ",")
        if temp and next(temp) and #temp >= 3 then
            local retGameID = tonumber(temp[1])
            local retType = tonumber(temp[2])
            local retNumber = tonumber(temp[3])
            DataCenter:updateData(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST, retGameID.."_"..retType, { retGameID = retGameID, retType = retType, number = retNumber })

            self:dispatchEvent(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST, retGameID.."_"..retType)
        end
    end


    -- self:unregisterRootMsgId(msgId,HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST..param1)
end

function HallSceneProxy:response(msgId, msgTable)
    print("HallSceneProxy:response")
    print(msgId)
    local dispatchId = nil
    local dispatchData = nil
    if msgId == self.hallMsgModel.MSG_ID.Msg_GDGameZoneList_Ret then
    elseif msgId == self.hallMsgModel.MSG_ID.Msg_GDBriefUserInfo_ret then
        -- 大厅收到简要玩家信息，将有效用户信息存到用户数据中心
        DataCenter:getUserdataInstance():setUserInfoByTable(msgTable)

        local curBindPhone = DataCenter:getUserdataInstance():getValueByKey("BindPhone")
        local curPwd = curBindPhone ~= "" and ww.WWGameData:getInstance():getStringForKey("pwd") or ""
        ww.WWGameData:getInstance():setStringForKey("cur_account_bind_phone_no", curBindPhone)
        ww.WWGameData:getInstance():setStringForKey("cur_account_bind_phone_psw", curPwd)

        wwdump(msgTable, "简要玩家信息")
        local cash = DataCenter:getUserdataInstance():getValueByKey("GameCash")
        if cash and tonumber(cash) < HallCfg.bankRuptLimit then
            -- 不要频繁发送 本地先判断我的金币
            self:requestIsBankrupt()
        end
        -- 设置个人信息
        self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 1)
    elseif msgId == self._messageModel.MSG_ID.Msg_NoticeList_Ret then
        -- 公告列表  这里直接用页面事件ID发送通知组件
        -- 缓存当前的MsgID
        wwdump(msgTable)
        local lastMsgID = ww.WWGameData:getInstance():getIntegerForKey(HallCfg.KEY_NOTICECACHE, 0)
        if (table.nums(msgTable) > 0) and(next(msgTable.notices)) then
            local curMsgID = msgTable.notices[1].MsgID
            wwlog(self.logTag, "lastMsgID/curMsgID %s - %s ", lastMsgID, curMsgID)
            -- if lastMsgID < curMsgID then
            -- 如果当前消息ID大于缓存的，则保存，并且去获取内容
            ww.WWGameData:getInstance():setIntegerForKey(HallCfg.KEY_NOTICECACHE, curMsgID)
            self:requestNoticeContent(msgTable)
            -- end
        end
    elseif msgId == self._messageModel.MSG_ID.Msg_MsgContent_Ret then
        self:dispatchEvent(COMMON_EVENTS.C_EVENT_NOTICE, msgTable)
    elseif msgId == self.ReqClientADInfo.MSG_ID.Msg_RespClientADInfo_Ret then
        -- 收到广告列表
        -- wwdump(msgTable)

        self:dispatchEvent(HALL_SCENE_EVENTS.NETEVENT_ADVERTRET, msgTable)
    elseif msgId == self.goodsBoxMsgModel.MSG_ID.Msg_EquipList_Ret then
        LoadingManager:endLoading()
        -- 物品箱
        -- 重构一下返回的网络消息结构，便于代码中访问。缓存下来的消息结构如下：
        -- {
        --    --EquipID和EquipID一样。
        --    [1001102] =
        --    {
        --        UserEquipID = 100101, --用户物品ID
        --        EquipID = 1001102, --物品ID
        --        EquipCount = 100, --物品数量
        --        Name = "Fucker", --物品名称
        --        ExpireTime = "20170101", --有效期
        --        Fid = 10010, --功能ID
        --        MagicType = 1, --1普通道具 9 道具包
        --        Status = 0, --0：正常状态 1：使用中（头像框、气泡框）
        --    }
        -- }
        wwdump(msgTable, "收到物品信息")
        local cacheGoodsBox = { }
        for k, v in ipairs(msgTable.goodsInfo) do
            v.MagicType = msgTable.magicType[k].MagicType
            v.Status = msgTable.status[k].Status
            cacheGoodsBox[v.Fid] = v
        end
        DataCenter:getUserdataInstance():setUserInfoByTable( { goodsInfo = cacheGoodsBox }) --缓存物品 按照FID
        DataCenter:getUserdataInstance():setUserInfoByTable( { bagInfo = msgTable.goodsInfo })  --缓存背包 按照物品ID
        dispatchId = HallCfg.InnerEvents.HALL_EVENT_GOODS_BOX_INFO
        dispatchData = cacheGoodsBox
    elseif msgId == self.goodsBoxMsgModel.MSG_ID.Msg_MatchEquipInfo_Ret then
        -- 比赛物品的说明信息
    elseif msgId == self.goodsBoxMsgModel.MSG_ID.Msg_GameEquipInfo_Ret then
        -- 游戏物品的详细说明信息 ObjectID：type=2  表示magicID type=4  表示FID
        -- 物品箱有用到
        LoadingManager:endLoading()
        dispatchId = HallCfg.InnerEvents.HALL_EVENT_GOODS_DETAIL_INFO
        dispatchData = msgTable
    elseif msgId == self.goodsBoxMsgModel.MSG_ID.Msg_GameEquipNumber_Ret then
        -- 游戏物品的数量信息刷新
        updataGoods(msgTable.Fid, msgTable.Count, true)
        self:dispatchEvent(COMMON_EVENTS.C_GOODS_COUNT_UPDATE, msgTable.Fid, msgTable.Count)
    elseif msgId == self.goodsBoxMsgModel.MSG_ID.Msg_GameEquipDesc_Ret then
        dispatchId = HallCfg.InnerEvents.HALL_EVENT_EQUIPMENT_NUMBER
        dispatchData = msgTable

        local oldData = DataCenter:getData(dispatchId)
		local tempT = {}
		copyTable(msgTable,tempT)
		if not oldData then
			oldData = {}
			oldData[dispatchData.magicID] = tempT
			DataCenter:cacheData(dispatchId,oldData)
		else
			oldData[dispatchData.magicID] = tempT
		end
	elseif msgId == self._userIssueNotifyModel.MSG_ID.Msg_IssueNotify_Ret then --道具物品发放通知
		if msgTable.issueType == 1009 then
			local retData = { }
			if msgTable.gameCash and string.len(msgTable.gameCash) then
				local cellData = { }
				cellData.fid = 10170998
				--cellData.MagicID = v.MagicID
				--cellData.name = v.MagicName
				cellData.num = tonumber(msgTable.gameCash)
				table.insert(retData, cellData)
				updataGoods(cellData.fid, cellData.num)
			end
			if msgTable.signArr then
				
				for _,v in pairs(msgTable.signArr) do
					updataGoods(v.magicFid, v.magicCount)
					self:dispatchEvent(COMMON_EVENTS.C_GOODS_COUNT_UPDATE, v.magicFid, v.magicCount)
					local cellData = { }
					cellData.fid = v.magicFid
					cellData.MagicID = v.magicId
					cellData.name = v.magicName
					cellData.num = v.magicCount
					table.insert(retData, cellData)
				end
				wwdump(retData,"道具物品发放通知",4)
				if next(retData) then
					import(".ItemShowView", "app.views.customwidget."):create(retData,true):show()
				end
			end
			self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO,1) --刷新
		end
		
    end

    if dispatchId and dispatchData and HallCfg.innerEventComponent then
        HallCfg.innerEventComponent:dispatchEvent( {
            name = dispatchId;
            _userdata = dispatchData;
        } )
    end
end

function HallSceneProxy:handleRoot(msgId, msgTable)
	if msgId==self.LoveotaModel.MSG_ID.Msg_CheckVersion_send then
		wwdump(msgTable,"卓盟数据返回")
	end
end

function HallSceneProxy:handleUserInfo(msgId, msgTable)
    if msgId == self._userInfoModel.MSG_ID.Msg_GDUserInfo_send then
        if msgTable.kReasonType == 15 or msgTable.kReasonType == 17 then
            wwdump(msgTable, "收到分享成功消息")
            if msgTable.kResult == 0 then
                -- 分享成功
                local dispatchId = TaskCfg.InnerEvents.TASK_EVENT_SHAREMESSAGE
                local dispatchData = msgTable
                if dispatchId and dispatchData and HallCfg.innerEventComponent then
                    HallCfg.innerEventComponent:dispatchEvent( {
                        name = dispatchId;
                        _userdata = dispatchData;
                    } )
                end
            end
		elseif msgTable.kReasonType == 3 then --破产消息标志 
            wwdump(msgTable, "收到破产消息")
            if msgTable.kResult == 0 then
                wwlog(self.logTag, "当我收到这个消息的时候，说明我破产了")
                -- cash/已经领取次数/总的可领次数/下次领取时间计时(秒)
                local tempStr = msgTable.kReason
                local strArr = string.split(tempStr, "/")
                if strArr and type(strArr) == "table" and table.getn(strArr) == 4 then
                    -- 还可以领取的次数
                    local restCount = math.abs(tonumber(strArr[3]) - tonumber(strArr[2]))
                    -- 下次领取的时间
                    local restTime = tonumber(strArr[4])
                    wwlog(self.logTag, "下次领取的时间差值%d", restTime)
                    restTime = os.time() + restTime
                    wwlog(self.logTag, "下次领取的时间戳%d", restTime)
                    wwlog(self.logTag, "可以领取多少次%d", restCount)
                    DataCenter:getUserdataInstance():setUserInfoByKey("awardCount", restCount)
                    DataCenter:getUserdataInstance():setUserInfoByKey("nextAwardTime", restTime)
                end
                DataCenter:getUserdataInstance():setUserInfoByKey("bankrupt", true)
            end
        end

    elseif msgId == self._userIssueNotifyModel.MSG_ID.Msg_RequestInfo_Send then

        dump(msgTable)
        if msgTable.kReasonType == 12 then
            -- 查询首充状态
            print("获取到首充状态")
			wwdump(msgTable,"首充状态")
            -- HALL_EVENT_FIRSTCHARGE_STATE
            local dispatchId = HallCfg.InnerEvents.HALL_EVENT_FIRSTCHARGE_STATE
            local dispatchData = msgTable
            if dispatchId and dispatchData and HallCfg.innerEventComponent then
                HallCfg.innerEventComponent:dispatchEvent( {
                    name = dispatchId;
                    _userdata = dispatchData;
                } )
            end

        else
            print("领取金币了")
            self:dispatchEvent(COMMON_EVENTS.C_EVENT_BANKRUPT, msgTable)
        end


    end
end
function HallSceneProxy:handleResultInfo(msgId,msgTable)
	wwdump(msgTable,"操作返回数据")
	if msgId==self._userIssueNotifyModel.MSG_ID.Msg_ResultInfo_Ret then
		if msgTable.Type==4 then --查询当前财富余额
			if msgTable.Result==1 then --成功了
				--msgTable.Parameter
				if wwConfigData.CHARGE_BANKID_GOLD==tonumber(msgTable.Parameter3) then
					wwlog(self.logTag,"更新了金币")
					updataGoods(10170998, msgTable.Parameter,true)
				elseif wwConfigData.CHARGE_BANKID_DIAMOND == tonumber(msgTable.Parameter3) then
					wwlog(self.logTag,"更新了钻石")
					updataGoods(20010993, msgTable.Parameter,true)
				end
				
			end
		end
	end
end

function HallSceneProxy:handleAwardNotify(msgId,msgTable)
	wwlog(self.logTag,"handleAwardNotify")
	wwdump(msgTable,msgId)
	if msgId == self._userInfoModel.MSG_ID.Msg_GDAwardNotify_Ret then
		--Type 通知类型 1=比赛奖励	2=任务完成奖励
		if msgTable.Type==2 or msgTable.Type==0 then
			wwlog(self.logTag,"任务奖励通知")
			self:dispatchEvent(TaskCfg.InnerEvents.TASK_EVENT_AWARDNOTIFY, msgTable)
		end
		--更新数据
		--updataGoods(v.MagicFID,v.MagicCount)
		if msgTable and msgTable.awardList then
			table.walk(msgTable.awardList,function (v,k)				
				updataGoods(v.FID,v.AwardData)
				
			end)
		end
	end
	
	
end

--[[
游戏大厅操作
type   1：返回游戏区列表 2:进入游戏区（速配） 3:快速开始
param1  type＝1 时（1=比赛 2=经典场 3=私人订制） type＝2时 游戏区ID
--]]
function HallSceneProxy:requestHallHandle(type, param1, param2, param3)
    self:sendMsg(self.hallMsgModel.MSG_ID.Msg_GDHallAction_send,
    {
        6,
        8,
        2,
        type,
        param1,
        param2 or 0,
        param3 or 0
    }
    )
end

-- 获取公告列表
-- 只取最新的一条
function HallSceneProxy:requestNoticeInfo()

    local paras = {
        4,
        1,
        1,
        1,
        0,
        1,
    }
    self:sendMsg(self._messageModel.MSG_ID.Msg_MsgListRequest_send, paras)
end

-- 获取公告详细
-- 只取最新的一条
function HallSceneProxy:requestNoticeContent(msgTable)

    -- 判断是否是最新的消息

    local noticeMsgID = msgTable.notices[1].MsgID

    local paras = {
        4,
        1,
        4,
        noticeMsgID,
        1,
    }
    self:sendMsg(self._messageModel.MSG_ID.Msg_MsgContentRequest_send, paras)
end

--[[
-- 获取广告轮播信息
--]]
function HallSceneProxy:requestAdInfo()

    wwlog(self.logTag, "请求广告列表")
    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
    local paras = {
        1,
        1,
        66,
        userid,
        wwConfigData.GAME_ID,
        wwConst.SP,
        wwConfigData.GAME_HALL_ID,
        1
    }
    self:sendMsg(self.ReqClientADInfo.MSG_ID.Msg_UserSignInReq_send, paras)
end

--[[
-- 获取大厅数据
-- 进大厅，（登录进来、断线后重新拉取数据）
--]]
function HallSceneProxy:getHallDatas()
    -- 到大厅就拉取玩家将要信息，刷新金币等信息
    local GDUserInfoRequest = require("WhippedEgg.request.GDUserInfoRequest")
    local userReq = GDUserInfoRequest:create()
    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
    userReq:formatRequest(4, userid)
    userReq:send(self)

    -- 请求房间列表信息
    self:requestHallSceneList(1)
    self:requestHallSceneList(2)
    self:requestHallSceneList(2, wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID
    , wwConfigData.GAMELOGICPARA.BULLFIGHT.PLAYTYPE) --斗牛人数
    self:requestHallSceneList(3)

    -- 拉取公告消息
    self:requestNoticeInfo()
    --    -- 获取游戏物品箱列表，注释by刘龙，HallSceneProxy收到登录成功的消息就请求物品箱，因为可能存在恢复对局的情况。
    --    self:requestGoodsBoxInfo()
	--请求广告信息
	self:requestAdInfo()
	
    -- 请求首充状态
    self:requestFirstChargeState()
    -- 先从登录消息里边获取是否需要更新的内容

    local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
    -- VerStatus 版本更新提示
    -- int1)客户端版本状态：
    -- 0 没有新版本可更新
    -- 1 有新版本，非必需更新
    -- 2 有新版本，必需更新
    if loginMsg and loginMsg.VerStatus and not loginMsg.hasRequestUpdate then
        -- 拉取热更数据
        local HotUpdateProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HOT_UPDATE)
        HotUpdateProxy:requestLuahotData(loginMsg.VerStatus ~= 2)
        -- 新版本 强制更新的才需要更新
        if loginMsg.VerStatus == 0 then

        else
            -- 更新整包
            -- http://a4.pc6.com/lxf2/majiangtuidaohu.pc6.apk
        end

        loginMsg.hasRequestUpdate = true
    end

    -- 消息箱消息，红点更新用。
    local MessageProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MessageProxy)
    MessageProxy:requestMessageInfo(2, "", 1, 1)
	
	local LuaNativeBridge = require('app.utilities.LuaNativeBridge'):create()
	LuaNativeBridge:getZhuomengData(handler(self,self.sendZhuomengData))
end


return HallSceneProxy
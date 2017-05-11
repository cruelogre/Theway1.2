-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  签到的代理类
-- Modify: 2017/1/21 添加请求失败的处理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SignInProxy = class("SignInProxy",require("packages.mvc.Proxy"))
local SignInRequest = require("hall.request.SignInRequest")
local SignCfg = require("hall.mediator.cfg.SignCfg")
local Toast = require("app.views.common.Toast")
import(".wwGoodsInfo","app.config.")
function SignInProxy:init()
	print("SignInProxy init")
	self._signInModel = require("hall.model.userSignInModel"):create(self)
	self._issueNotifyModel = require("app.netMsgBean.userIssueNotifyModel"):create(self)
	self:registMsg()
end

function SignInProxy:registMsg()
	self:registerRootMsgId(self._signInModel.MSG_ID.Msg_UserSignInReq_send,handler(self,self.rootMsgReponse))
	
	
end

function SignInProxy:rootMsgReponse(msgId,msgTable)
	if msgId== self._signInModel.MSG_ID.Msg_UserSignInReq_send then
		LoadingManager:endLoading()
		if msgTable.kResult and tonumber(msgTable.kResult)==0 
		and msgTable.kReason and tostring(msgTable.kReason)>0 then --失败了
			Toast:makeToast(tostring(msgTable.kReason),2.0):show()
		end
	end
end

function SignInProxy:requestSignInCalendar(showloading)
	if showloading then
		LoadingManager:startLoading()
	end
	local msgIds = self._signInModel.MSG_ID
	self:registerMsgId(msgIds.Msg_UserSignInCalendar_Ret, handler(self, self.onSignInDataReceived), SignCfg.InnerEvents.SIGN_EVENT_CALENDAR)
	
	local signrequest = SignInRequest:create()
	signrequest:formatRequest(0,0)
	signrequest:send(self)
end

function SignInProxy:requestSignType(typeid,dayNo)
	local msgIds = self._issueNotifyModel.MSG_ID
	LoadingManager:startLoading(0.8,LOADING_MODE.MODE_TOUCH_CLOSE)
	self:registerMsgId(msgIds.Msg_IssueNotify_Ret, function (msgId,msgTable)		
			self:onSignInDataReceived(msgId, msgTable,typeid,dayNo)
		end, SignCfg.InnerEvents.SIGN_EVENT_ISSUENOTIFY)
	
	
	local signrequest = SignInRequest:create()
	signrequest:formatRequest(typeid,dayNo==nil and 0 or dayNo)
	signrequest:send(self)
end

function SignInProxy:onSignInDataReceived(msgId, msgTable,tag,dayNo)
	print("SignInProxy onSignInDataReceived")
	print(msgId)
	LoadingManager:endLoading()
	--dump(msgTable)
	if msgId==self._signInModel.MSG_ID.Msg_UserSignInCalendar_Ret then
		--判断成功或者失败
		if msgTable.kResult and tonumber(msgTable.kResult)==1 then
			--失败
			isOk = false
			local result = msgTable.kReason
			Toast:makeToast(result,1.0):show()
		else
			--成功
			DataCenter:cacheData(SignCfg.InnerEvents.SIGN_EVENT_CALENDAR,msgTable)
			if SignCfg.innerEventComponent then
				SignCfg.innerEventComponent:dispatchEvent({
					name = SignCfg.InnerEvents.SIGN_EVENT_CALENDAR;
				})
			end

		
		end
		
		self:unregisterMsgId(self._signInModel.MSG_ID.Msg_UserSignInCalendar_Ret, SignCfg.InnerEvents.SIGN_EVENT_CALENDAR)
		
	elseif msgId==self._issueNotifyModel.MSG_ID.Msg_IssueNotify_Ret then
		--判断成功或者失败
		--dump(msgTable)
		
		if msgTable.kResult and tonumber(msgTable.kResult)==1 then
			--失败
			
			local result = msgTable.kReason
			Toast:makeToast(result,1.0):show()
		else
			--成功
			--DataCenter:cacheData(SignCfg.InnerEvents.SIGN_EVENT_ISSUENOTIFY,msgTable)
			
					--签到			补签 		连续签到
			if msgTable.issueType==2001 or msgTable.issueType==2002 or msgTable.issueType==2003 then
				
			--添加财产
			--event._userdata
				local awardGoods = {}
				for _,v in pairs(msgTable.signArr) do
				
					local ginfo = getGoodsByFid(v.magicFid)
					if ginfo then
						table.insert(awardGoods,{name =ginfo.name,count=v.magicCount })
						--v.magicCount
						local oldNumberStr = DataCenter:getUserdataInstance():getValueByKey(ginfo.dataKey)
						local oldNumber = oldNumberStr ~=nil and tonumber(oldNumberStr) or 0
						DataCenter:getUserdataInstance():setUserInfoByKey(ginfo.dataKey,oldNumber+v.magicCount)
					end
				end
				self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO,1) --刷新
				if DataCenter:getUserdataInstance():getValueByKey("bankrupt") then
					DataCenter:getUserdataInstance():setUserInfoByKey("bankrupt",false)
					local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)				
					HallSceneProxy:requestIsBankrupt()
				end
				if SignCfg.innerEventComponent then
					SignCfg.innerEventComponent:dispatchEvent({
						name = SignCfg.InnerEvents.SIGN_EVENT_ISSUENOTIFY;
						_userdata = msgTable;
						msgTag = tag;
						msgNo = dayNo;
						award = awardGoods
					})
				end
			end
		
			
		end
		self:unregisterMsgId(self._issueNotifyModel.MSG_ID.Msg_IssueNotify_Ret, SignCfg.InnerEvents.SIGN_EVENT_ISSUENOTIFY)
	end
	
end
function SignInProxy:finalizer()
	self:unregisterRootMsgId(self._signInModel.MSG_ID.Msg_UserSignInReq_send)
end

return SignInProxy
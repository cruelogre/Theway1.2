-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  设置界面的代理类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local SettingProxy = class("SettingProxy",require("packages.mvc.Proxy"))
local FeedBackRequest = require("hall.request.FeedBackRequest")
local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local WWHttpRequest = require("app.utilities.WWHttpRequest")
local JsonDecorator = import(".JsonDecorator", "app.utilities.")

local Toast = require("app.views.common.Toast")

function SettingProxy:init()
	print("SettingProxy init")
	self._settingModel = require("hall.model.settingModel"):create(self)
	self._httprequests = {}
	self._jsonDecorator = JsonDecorator:create()
end
--发送返回信息到服务器
function SettingProxy:requestFeedBack(content)
	local msgIds = self._settingModel.MSG_ID
	self:registerRootMsgId(msgIds.Msg_SettingFeedback_Ret, handler(self, self.onMsgRecieved), SettingCfg.InnerEvents.SETTING_EVENT_FEEDBACK)
	
	local feedbackreq = FeedBackRequest:create()
	feedbackreq:formatRequest(content)
	feedbackreq:send(self)
end

function SettingProxy:onMsgRecieved(msgId, msgTable)
	print("SettingProxy onMsgRecieved")
	print(msgId)
	dump(msgTable)
	if msgId==self._settingModel.MSG_ID.Msg_SettingFeedback_Ret then
		--判断成功或者失败
		DataCenter:cacheData(SettingCfg.InnerEvents.SETTING_EVENT_FEEDBACK,msgTable)
			if SettingCfg.innerEventComponent then
				SettingCfg.innerEventComponent:dispatchEvent({
					name = SettingCfg.InnerEvents.SETTING_EVENT_FEEDBACK;
					_userdata = msgTable.kReason
				})
		end
		if msgTable.kReason then
			Toast:makeToast(msgTable.kReason,1.0):show()
		end
	end
	
end
--请求服务协议（服务协议，隐私政策）
function SettingProxy:requestProtocol(cid)
	if not cid then
		return
	end
	local eventData = DataCenter:getData(SettingCfg.getEventByCid(cid))
	if eventData and next(eventData) then
		SettingCfg.innerEventComponent:dispatchEvent({
					name = SettingCfg.getEventByCid(cid);
				})
	else
		
		self:cancelProtocol(cid)
		local http = WWHttpRequest:create(function (text)
			local status, result = self._jsonDecorator:decode(text)
			if not status then
				return
			end
			local textContent = ww.IPhoneTool:getInstance():decodeChar(result["content"])
			--dump(textContent)
			DataCenter:cacheData(SettingCfg.getEventByCid(cid),{content = textContent})
			self:cancelProtocol(cid)
			SettingCfg.innerEventComponent:dispatchEvent({
					name = SettingCfg.getEventByCid(cid);
				})
		end)
		local requesturl = string.format("http://%s:9565/help/helpapi.jsp?gameid=%d&hallid=%d&clientver=%s&sp=%d&op=%d&subjectid=%s&categoryid=%s",
		wwConfigData.HTTP_IP,wwConfigData.GAME_ID,
		wwConfigData.GAME_HALL_ID,wwConfigData.GAME_VERSION,
		wwConst.SP,wwConst.OP,
		tostring(cid),wwConst.CATEGORY_ID)
		
		print(requesturl)
		http:request("GET",requesturl)
		if not self._httprequests[cid] then
			self._httprequests[cid] = http
		end
	end
	
	
end
function SettingProxy:cancelProtocol(cid)
	if not cid then
		return
	end
	if self._httprequests[cid] then
		local request = self._httprequests[cid]
		--取消回调
		request:clear()
		self._httprequests[cid] = nil
		request = nil
	end
end

function SettingProxy:clearCache()
	--释放下载的图片
	ToolCom.clearTexture()
	--清除下载的文本内容
	for _,v in pairs(SettingCfg.cids) do
		DataCenter:clearData(v[2])
	end
	
	Toast:makeToast(i18n:get('str_setting','setting_clear_cache_ok'), 1.0):show()
	
end

return SettingProxy
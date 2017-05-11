---------------------------------------------
-- module : 聊天消息过滤器
-- auther : cruelogre
-- Date:    2017.1.23
-- comment: 大厅未读消息过滤器 获取未读好友消息
--  		1. 核心过滤方法doFilter 触发状态机事件

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local ChatMsgFilter = class("ChatMsgFilter",require("packages.statebase.FSFilter"))

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")

function ChatMsgFilter:ctor(filterId,priority)
	ChatMsgFilter.super.ctor(self,filterId,priority)
	self.jumpEventName = nil
	self.jumpParam = nil
	--self.filterId = filterId
	self.filterCount = -1 --无限次数
	self.filterType = bit._or(FSConst.FilterType.Filter_Enter,FSConst.FilterType.Filter_Resume)
	self.handlers = {}
	
	
end

function ChatMsgFilter:registerListener()			
	self.shareListener = WWFacade:addCustomEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST,handler(self,self.sessionMsg))
end
function ChatMsgFilter:unRegisterListener()
	if self.shareListener then
		WWFacade:removeEventListener(self.shareListener)
		self.shareListener = nil
	end
end

function ChatMsgFilter:sessionMsg(event)
	WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "cardPartner",true)
	wwlog(self.logTag,"您有未读消息")
end

function ChatMsgFilter:doFilter(filterChain,filterType)

		if bit._and(filterType,FSConst.FilterType.Filter_Enter)> 0 then
			if not self.handlers or not next(self.handlers) then
				self:registerListener()
			end
		elseif bit._and(filterType,FSConst.FilterType.Filter_Exit)> 0 then
			self:unRegisterListener()
		end

	if ChatMsgFilter.super.doFilter(self,filterChain,filterType) then
		wwlog(self.logTag,"doFilter filterId %s 自有类型 %d 分发类型 %d 剩余次数 %d",
		tostring(self.filterId),self.filterType,filterType,self.filterCount)
		
		wwlog(self.logTag,"未读聊天消息过滤器 filterId %s",tostring(self.filterId))
		self:getSocialContactProxy():requestUnreadMsg()
		--onEnter的时候才请求
		if filterType==FSConst.FilterType.Filter_Enter then
			self:getSocialContactProxy():requestAllCardPartner()
		end
		 --有红点 通知是否显示
		WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "cardPartner",self:getHallChatService():hasUnreadMsg())
	end
	
	return true
end

function ChatMsgFilter:getSocialContactProxy()
	return ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)
end
function ChatMsgFilter:getHallChatService()
	return ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)
end
function ChatMsgFilter:eventComponent()
	return CardPartnerCfg.innerEventComponent
end


function ChatMsgFilter:finalizer()
	self:unRegisterListener()
end

return ChatMsgFilter
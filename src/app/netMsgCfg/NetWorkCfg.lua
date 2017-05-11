cc.exports.NetWorkCfg = {}

NetWorkCfg.innerEventComponent = nil
NetWorkCfg.InnerEvents = {

	NETWORK_EVENT_STATE_CHANGE = "NETWORK_EVENT_STATE_CHANGE", --网络连接变化
	NETWORK_EVENT_ERROR = "NETWORK_EVENT_ERROR", --网络异常
	NETWORK_EVENT_CONNECTED = "NETWORK_EVENT_CONNECTED", --网络连接成功
	NETWORK_EVENT_RELOGIN = "NETWORK_EVENT_RELOGIN", --重新登录
	
	NETWORK_EVENT_LOGINOK = "NETWORK_EVENT_LOGINOK", --登录成功
    NETWORK_EVENT_LOGINERROR = "NETWORK_EVENT_LOGINERROR", --登录失败
    NETWORK_EVENT_LOGOUTOK = "NETWORK_EVENT_LOGOUTOK", --登出成功
    NETWORK_EVENT_MODIFY_USERINFO = "NETWORK_EVENT_MODIFY_USERINFO", --修改用户信息成功
    NETWORK_EVENT_MODIFY_USERINFO_ERROR = "NETWORK_EVENT_MODIFY_USERINFO_ERROR", --修改用户信息失败
}

NetWorkCfg.eventMap = {
	{NetEventId.Event_onExceptionCaught,NetWorkCfg.InnerEvents.NETWORK_EVENT_ERROR},
	{NetEventId.Event_onConnected,NetWorkCfg.InnerEvents.NETWORK_EVENT_CONNECTED},
	{NetEventId.Event_reLogin,NetWorkCfg.InnerEvents.NETWORK_EVENT_RELOGIN},
	
}
function NetWorkCfg.getEventById(eid)
	local eventName = nil
	for _,v in pairs(NetWorkCfg.eventMap) do
		if v[1]==eid then
			eventName = v[2]
		end
	end
	return eventName
end
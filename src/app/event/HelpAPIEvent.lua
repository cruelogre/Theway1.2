local prefixFlag = "HELP_API_EVENT_"

--[[
	游戏中与场景切换相关事件的定义
--]]
cc.exports.HELP_API_EVENTS = {
	--[[
	--	HelpAPI返回结果
	--  _userdata -> {tag, result(boolean), content(string)}
	--]]
	HELP_API_RESP		= prefixFlag .. "HelpAPIResp";
}
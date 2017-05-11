-------------------------------------------------------------------------
-- Desc:
-- Author:  cruelogre
-- Date:    2016.11.7
-- Last:
-- Content:  lua 热更数据请求
-- 20161107  新建
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local LuaHotRequest = class("LuaHotRequest",require("app.request.BaseRequest"))

local luahotModel = require("app.netMsgBean.luaHotModel")
LuaHotRequest.orders = {
	{"hallID","int"}, -- 大厅ID
 
	{"Op","short"}, -- Op
	{"Sp","int"}, -- sp
	{"Version","string"}, -- 客户端大版本
	{"Subversion","string"}, -- 客户端小版本号
	{"LuaModel","string"}, --机型标识 请求时固定 LUA_HOT_UPDATE
}
			
LuaHotRequest.headers = {1,1,72}
function LuaHotRequest:ctor()
	print("LuaHotRequest ctor")
	LuaHotRequest.super.ctor(self)
	self:init(LuaHotRequest.orders)
end
function LuaHotRequest:formatRequest(Version,subversion)
	
	self:setField("Subversion",subversion)
	
	self:setField("hallID",wwConfigData.GAME_HALL_ID)
	self:setField("Op",wwConst.OP)
	self:setField("Sp",wwConst.SP)
	self:setField("Version",Version)
	
	self:setField("LuaModel","LUA_HOT_UPDATE")
	
	return self.data
end
function LuaHotRequest:send(target)
	print("LuaHotRequest send")
	local msgParam = self:formatHeader2(self.data,luahotModel.MSG_ID.Msg_LUAhotData_send)
	dump(msgParam)
	
	NetWorkBridge:send(luahotModel.MSG_ID.Msg_LUAhotData_send, msgParam, target)
	removeAll(msgParam)
end




return LuaHotRequest
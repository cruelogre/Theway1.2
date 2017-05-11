-------------------------------------------------------------------------
-- Title:       用户物品箱请求
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local GoodsBoxRequest = class("GoodsBoxRequest", require("app.request.BaseRequest"))
local GoodsBoxNetModel = import("..model.goodsBoxModel")

GoodsBoxRequest.orders = {
    -- (int1)
    -- 0=物品箱物品列表
    -- 1=比赛物品说明信息
    -- 2=游戏道具详细信息
    -- 4=游戏道具详细信息
    -- 3=请求道具物品数量
    { "Type", "char" },
    -- (int4)游戏ID
    { "GameID", "int" },
    -- (int4)物品ID
    -- Type=2  表示magicID
    -- Type=4  表示FID
    { "ObjectID", "int" },
}
GoodsBoxRequest.headers = { 17, 8, 1 }
function GoodsBoxRequest:ctor()
    print("GoodsBoxRequest ctor")
    GoodsBoxRequest.super.ctor(self)
    self:init(GoodsBoxRequest.orders)
end

-- Type=0,ObjectID=9211表示及时比赛物品箱  返回17,8,2
-- Type=0,ObjectID=1011表示游戏物品箱
-- Type=1时ObjectID=物品ID magicID返回17,8,3
-- Type=2时ObjectID=物品ID magicID 返回17,8,4
-- Type=4时ObjectID=功能ID FID返回17,8,4
-- Type=3,ObjectID表示物品FID 麻将话费券fid=10161504返回17,8,5
function GoodsBoxRequest:formatRequest(Type, magicIDorFID)
    self:setField("Type", Type)
    self:setField("GameID", wwConfigData.GAME_ID)
    self:setField("ObjectID", magicIDorFID)
    return self.data
end

function GoodsBoxRequest:send(target)
    print("GoodsBoxRequest send")
    local msgParam = self:formatHeader2(self.data, GoodsBoxNetModel.MSG_ID.Msg_EquipReq_send)
    dump(msgParam)

    NetWorkBridge:send(GoodsBoxNetModel.MSG_ID.Msg_EquipReq_send, msgParam, target)
    removeAll(msgParam)
end

return GoodsBoxRequest
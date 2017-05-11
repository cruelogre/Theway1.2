-------------------------------------------------------------------------
-- Title:        所有物品基本信息配置
-- Author:    Jackie Liu
-- Date:       2016/09/28 10:36:58
-- Desc:
-- 1、物品图片目录定为：common/goods/。
-- 2、物品图片命名格式定为：item_物品fid.png，完整路径为：common/goods/item_物品fid.png
-- 3、增加物品配置，只需在wwGoodsInfo中添加。
-- 4、物品完整配置例子请看wwGoodsInfo中第一个item的配置，也就是金币配置。
-- 5、有问题找我，有话好说。
-- 用法：
--        -- 通过fid获取物品信息
--        local goodsInfo1 = getGoodsByFid(10170998)
--        -- goodsInfo1的结构如下：
--        {
--            fid = 10170998
--            name = "金币",
--            keyUsedInCode = "GOLD",
--            dataKey = "GameCash",
--            src = "common/goods/item_10170998.png",
--        }
--        -- 通过常用名获取物品信息，如DIAMOND,GOLD等，返回的table的结构同上。
--        local goodsInfo2 = getGoodsByFlag("GOLD")
--        -- 返回fid为10170998对应的图片完整路径
--        local src1 = getGoodsSrcByFid(10170998)
--        -- 返回GOLD对应的图片完整路径
--        local src2 = getGoodsSrcByFlag("GOLD")
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local dir = "common/goods/"
local TAG = "wwGoodsInfo.lua"
-- 只需在这儿配置物品信息
local wwGoodsInfo = {
    -- fid
    ["10170998"] =
    {
        -- UserDataCenter 中的key
        dataKey = "GameCash",
        -- 物品名字
        name = "金币",
        -- 代码中用到的Key，比如GOLD，Diamond这些常用的物品，记fid太麻烦了。
        -- getGoodsByFlag("GOLD")即可。
        keyUsedInCode = "GOLD",
        -- 道具类型：1：普通道具  2：比赛门票  3：会员  4:虚拟货币  5:实物  9:道具包
        Type = 4,
        -- 功效期：单位次、天等。
        EffectTime = "1",
        -- 物品图片路径,配置好common/goods/目录下的图片就可以。
        src = nil,
        -- 物品fid，代码配置好，无需填写。
        fid = nil,
    },
    ["20010993"] =
    {
        dataKey = "Diamond",
        name = "钻石",
        Type = 4,
        ExpireTime = "永不过期",
        EffectTime = "1",
        keyUsedInCode = "Diamond",
    },
    ["10171107"] =
    {
        name = "记牌器",
        dataKey = "RecordCard",
        Type = 1,
        ExpireTime = "永不过期",
        EffectTime = "1",
        keyUsedInCode = "jpq",

    },
    ["10200101"] =
    {
        name = "补签卡",
        dataKey = "ResignCard",
        Type = 1,
        ExpireTime = "永不过期",
        EffectTime = "1",
        keyUsedInCode = "bqk",
    },
    ["10172001"] =
    {
        name = "比赛门票",
        dataKey = "MatchTicket",
        Type = 2,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "bsmp",
    },
    ["10170101"] =
    {
        name = "VIP日卡",
        dataKey = "VIPDay",
        Type = 3,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "rk",
    },
    ["10170102"] =
    {
        name = "VIP周卡",
        dataKey = "VIPWeek",
        Type = 3,
        ExpireTime = "次年年底",
        EffectTime = "7",
        keyUsedInCode = "zk",
    },
    ["10170103"] =
    {
        name = "VIP月卡",
        dataKey = "VIPMonth",
        Type = 3,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "yk",
    },
    ["10170104"] =
    {
        name = "VIP年卡",
        dataKey = "VIPYear",
        Type = 3,
        ExpireTime = "次年年底",
        EffectTime = "365",
        keyUsedInCode = "nk",
    },
    ["10171101"] =
    {
        name = "踢人卡",
        dataKey = "KickCard",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "trk",
    },

    ["10171102"] =
    {
        name = "双倍卡",
        dataKey = "DoubleCard",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "sbk",
    },
    ["10171121"] =
    {
        name = "鲜花",
        dataKey = "Flower",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "xh",
    },
    ["10171123"] =
    {
        name = "炸弹",
        dataKey = "Bomb",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "zd",
    },
    ["10171124"] =
    {
        name = "拖鞋",
        dataKey = "Slippers",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "tx",
    },
    ["10171126"] =
    {
        name = "鸡蛋",
        dataKey = "Egg",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "jd",
    },
    ["10171201"] =
    {
        -- 负分清零之标准玩法后两位是玩法。
        name = "负分清零",
        dataKey = "ZeroCard",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "ffql",
    },
    ["10172002"] =
    {
        name = "私人房房卡",
        dataKey = "RoomCard",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "fangk",
    },
    ["10171501"] =
    {
        name = "水晶",
        dataKey = "Crystal",
        Type = 1,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "shuij",
    },
    ["20020001"] =
    {
        name = "实物",
        dataKey = "ShiWu",
        Type = 5,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "sw",
    },
    ["20020002"] =
    {
        name = "道具包",
        dataKey = "DaoJuBao",
        Type = 9,
        ExpireTime = "次年年底",
        EffectTime = "1",
        keyUsedInCode = "djb",
    },
}

-- 在配置中添加fid和src字段
for k, v in pairs(wwGoodsInfo) do
    v.fid = tonumber(k)
    v.src = string.format("%sitem_%d.png", dir, v.fid)
end

-- 建立keyUsedInCode和fid的一一映射，这样通过keyUsedInCode也可以找到物品基本信息
local _key_fid_reflect = { }
for k, v in pairs(wwGoodsInfo) do
    if v.keyUsedInCode then
        _key_fid_reflect[v.keyUsedInCode] = k
    end
end

-- 通过fid获取物品信息
function cc.exports.getGoodsByFid(fid)
    return wwGoodsInfo[tostring(fid)]
end

-- 代码中用到的Key，比如GOLD，Diamond这些常用的物品，记fid太麻烦了。
-- getGoodsByFlag("GOLD")即可。
function cc.exports.getGoodsByFlag(flag)
    return wwGoodsInfo[_key_fid_reflect[flag]]
end

-- fid获取图片
function cc.exports.getGoodsSrcByFid(fid)
    return wwGoodsInfo[tostring(fid)] and wwGoodsInfo[tostring(fid)].src or nil
end

-- 代码中用到的Key，比如GOLD，Diamond这些常用的物品，记fid太麻烦了。
function cc.exports.getGoodsSrcByFlag(flag)
    return wwGoodsInfo[_key_fid_reflect[flag]] and wwGoodsInfo[_key_fid_reflect[flag]].src or nil
end

-- flag就是wwGoodsInfo中的keyUsedInCode字段。
-- flag获取fid
function cc.exports.getFidByFlag(flag)
    return wwGoodsInfo[_key_fid_reflect[flag]] and wwGoodsInfo[_key_fid_reflect[flag]].fid or nil
end
-------------------------------------------------------------------------
-- Desc:
-- Author:  diyal.yin
-- Date:    2016.08.13
-- Last:
-- Content:  常见数据中心结构定义  不允许自己用，需要再DataCenter中获取实例
-- 20160826  用户信息结构定义  按照登录返回信息为基础定义（方便设置的时候table merge）
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UserDataCenter = class("UserDataCenter")

local TAG = "UserDataCenter"

function UserDataCenter:ctor()
    self:initUserData()
    self.hadGetUserInfo = false
end

function UserDataCenter:initUserData()

    self.cdataTable = {
        -- 性别 1 男 2 女
        gender = 2,
        -- 大厅版本号
        hallversion = "",
        -- 昵称
        nickname = "",
        -- 客户端更新状态	
        updateState = 0,
        -- 用户ID
        userid = 0,
        -- vip
        vip = 0,
        -- 金币数量
        GameCash = "0",
        -- 钻石数量
        Diamond = "0",
        -- 头像ID
        IconID = 0,
        card = 0,
        -- 地区信息
        Region = "",
        -- 空为未绑定手机号。
        BindPhone = "",
        -- 手动注销的标识符。切记管理好标识符的生命周期。
        -- 使用原因：在切换账号的时候，注销当前账号后会马上收到网络连接成功消息，然后回进行快速登录。
        -- 这打乱了切换账号的进程，所以当是手动注销时，收到网络连接成功消息不处理。
        Flag_Logout_Manually = false,
        -- 是不是第三方登录。
        IS_THIRD_PARTY_LOGIN = false,
        -- 破产标识
        bankrupt = false,
        -- 今日还可以领取的次数
        awardCount = 0,
        -- 下次可以领取的时间间隔
        nextAwardTime = 0,
        appStartGetUserInfo = true,
        -- 下次可以领取的时间间隔        -- 补签卡
        WhippedEggInfo =
        {
            -- 玩家惯蛋中私人信息

        },
        goodsInfo = -- 物品箱信息 独立FID
        {
            ----这是Fid
            -- [10010] =
            -- {
            --    -- 用户物品ID
            --    UserEquipID = 100101,
            --    -- 物品ID
            --    EquipID = 1001102,
            --    -- 物品数量
            --    EquipCount = 100,
            --    -- 物品名称
            --    Name = "Fucker",
            --    -- 有效期
            --    ExpireTime = "20170101",
            --    -- 功能ID
            --    Fid = 10010,
            --    -- 1普通道具 9 道具包
            --    MagicType = 1,
            --    -- 0：正常状态 1：使用中（头像框、气泡框）
            --    Status = 0,
            -- }
        },
        bagInfo = {  --物品箱信息 针对一个FID有多个物品ID的，如门票等

        },
        -- 游戏对局中道具购买配置，目前只在登录时刷新。见StoreProxy
        -- 如果在商店和对局之外的地方也需要购买物品，可以参照这种方法，将相应的道具购买配置缓存到UserData中。
        shopConf_inGame =
        {
            -- [10171107] =
            -- {
            --    -- 描述文字
            --    Description = "记牌器",
            --    -- 有效时间
            --    Expire = "1年",
            --    -- 简介
            --    Introduce = "记牌器",
            --    -- 道具ID
            --    MagicID = "191",
            --    -- 价格,单位分
            --    Money = 10,
            --    -- 商品名称
            --    Name = "记牌器",
            --    -- 商店道具ID
            --    StoreMagicID = 250,
            --    -- 是否允许继续购买0-允许继续购买1-不允许购买
            --    buystatus = 0,
            --    -- 每日购买数量限制0表示无限制
            --    dayLimit = 0,
            --    -- 功能ID
            --    fid = 10171107,
            --    -- 物品道具、数量
            --    magicCount = 1,
            --    -- 市场价格
            --    marketMoney = 0,
            --    monthLimit = 0,-- 每月购买数量限制0表示无限制
            -- }
        }
    }
end

function UserDataCenter:setGetUserInfo(hadGet)
    self.hadGetUserInfo = hadGet
end

function UserDataCenter:getGetUserInfo()
    return self.hadGetUserInfo
end

-- 赋多个值  自动配值
function UserDataCenter:setUserInfoByTable(valuetable)
    if valuetable and type(valuetable) == "table" then
        -- 如果传递进来的是table
        -- table.merge(self.cdataTable, valuetable)
        for k, v in pairs(valuetable) do
            if self.cdataTable[k] then
                self.cdataTable[k] = v
            end
        end
    end
    -- wwdump(self.cdataTable, "设置后用户中心数据")
end

-- _adaptAttrNameFunc("name") = "Name"
-- _adaptAttrNameFunc("count") = "EquipCount"
-- 好处：代码中使用name、count、fid字串也能访问正确的属性
local function _adaptAttrNameFunc(attrName)
    if attrName == "name" then
        attrName = "Name"
    elseif attrName == "id" or attrName == "fid" then
        attrName = "Fid"
    elseif attrName == "count" then
        attrName = "EquipCount"
    elseif attrName == "eId" then
        attrName = "EquipID"
    elseif attrName == "uId" then
        attrName = "UserEquipID"
    end
    return attrName
end

-- 通过fid获取用户该物品的信息，参数列表是fids
-- local info1,info2,info3 = getGoodsInfoByID(1001, 1002, 1003)
function UserDataCenter:getGoodsByID(...)
    wwdump(self.cdataTable.goodsInfo, "物品信息")
    local ret = { }
    for k, v in ipairs( { ...}) do
        ret[#ret + 1] = self.cdataTable.goodsInfo[v]
    end
    return unpack(ret)
end

function UserDataCenter:getGoodsByName(flag)
    return self:getGoodsByID(getGoodsByFlag(flag).fid)
end

-- 获取物品属性值
-- getGoodsAttrByID(1001,"name")等同getGoodsAttrByID(1001,"Name")
-- getGoodsAttrByID(1001,"count")等同getGoodsAttrByID(1001,"EquipCount")
-- 字段名称请参考self.cdataTable中的goodsInfo的注释例子
-- 有些常用字段有简值如name，count，id，fid，uId
local tmp = nil
function UserDataCenter:getGoodsAttr(fid, attrName)
    tmp = _adaptAttrNameFunc(attrName)

    wwdump(self.cdataTable.goodsInfo, "[diyal]")

    if self.cdataTable.goodsInfo[fid] then
        return self.cdataTable.goodsInfo[fid][tmp]
    else
        if tmp == "EquipCount" then
            -- 获取数量
            return 0
        end
    end

    --
end

function UserDataCenter:getGoodsAttrByName(flag, attrName)
    return self:getGoodsAttr(tonumber(getGoodsByFlag(flag).fid), attrName)
end

-- 更新物品信息，适用于多物品、多属性更新。
-- updateGoodsInfo( {
--    EquipCount = 100,
--    -- 物品数量
--    id = 1001
-- } )
-- 或者
-- updateGoodsInfo( {
--    [1001] =
--    {
--        EquipCount = 100,-- 物品数量
--    },
--    [1002] =
--    {
--        Status = 1,
--        EquipCount = 100,-- 物品数量
--    },
-- } )
function UserDataCenter:updateGoods(newData)
    local fid = newData.id or newData.Fid or newData.fid
    if fid then
        self.cdataTable.goodsInfo[fid] = self.cdataTable.goodsInfo[fid] or { Fid = fid }
        local cachedData = self.cdataTable.goodsInfo[fid]
        table.walk(newData, function(v, k) cachedData[_adaptAttrNameFunc(k)] = v end)
    else
        for k, v in pairs(newData) do
            self.cdataTable.goodsInfo[k] = self.cdataTable.goodsInfo[k] or { Fid = k }
            local cachedData = self.cdataTable.goodsInfo[k]
            table.walk(v, function(v1, k1) cachedData[_adaptAttrNameFunc(k1)] = v1 end)
        end
    end
end

-- 更新物品属性值，适用于单个物品，单属性更新
-- isUpdated：true则直接覆盖更新，false则newValue为变化量如+1，或者-1。
-- 更新1001物品数量：
-- updateGoodsAttr(1001, "count", 100) 等同 updateGoodsAttr(1001, "EquipCount", 100) 
function UserDataCenter:updateGoodsAttr(fid, attrName, newValue, isUpdated)
    if self.cdataTable.goodsInfo[fid] then
        if isUpdated then
            self.cdataTable.goodsInfo[fid][_adaptAttrNameFunc(attrName)] = newValue
        else
            self.cdataTable.goodsInfo[fid][_adaptAttrNameFunc(attrName)] = newValue +(self.cdataTable.goodsInfo[fid][_adaptAttrNameFunc(attrName)] or 0)
        end
    else
        self.cdataTable.goodsInfo[fid] = {
            Fid = fid,
            [_adaptAttrNameFunc(attrName)] = newValue
        }
    end
end

-- 修改单个值
function UserDataCenter:setUserInfoByKey(key, value)
    if key and self.cdataTable[key] ~= nil then
        -- 如果传递进来的是table
        self.cdataTable[key] = value
    end
end

function UserDataCenter:getValueByKey(key)
    return self.cdataTable[key]
end

function UserDataCenter:getUserInfo()
    return self.cdataTable
end

function UserDataCenter:getHeadIcon()
    local headFile
    if self.cdataTable.gender == 1 then
        headFile = "guandan/head_boy.png"
    else
        headFile = "guandan/head_girl.png"
    end
    return headFile
end

function UserDataCenter:getHeadIconByGender(gender)
    local headFile
    if gender == 1 then
        headFile = "guandan/head_boy.png"
    else
        headFile = "guandan/head_girl.png"
    end
    return headFile
end

return UserDataCenter
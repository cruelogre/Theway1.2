-------------------------------------------------------------------------
-- Title:	        记牌器
-- Author:     Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- 1、生命周期：RoomBase里的一个成员变量，随RoomBase创建和销毁(RoomBase.recycle)
-- 2、_开头的方法为私有方法。
-- 3、三个核心成员变量：
-- self._card_left_info = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }、
-- 除自己(或者队)手牌外的剩余牌型。15张牌，k对应pokerValue，v就是剩余牌数。其实就是234567890JQKAW1W2的顺序。
-- 游戏开局自己可以算，恢复对局消息中有这个数据。

-- self._left_valid_period = 0
-- 剩余有效时间，后台会在使用时就开始倒计时，目前是24个小时。

-- self._licence_key = false
-- 记牌器的UI能不能显示了，数据会不会刷新到UI上了。从用户角度说，就是记牌器能不能用了。
-- 剩余时间为0不一定记牌器就不能用了，比如在对局中时间到0了，在当前局中还是可以使用的。在恢复对局时，务必留意。
-- 决定一些方法会不会真正执行。

-- 4、关键方法：
-- show：
--      企图显示/消失记牌器。点击对局中记牌器按钮时的回调。
--      记牌器还没有生效，就先提示消耗一个记牌器。没有记牌器就提示购买记牌器。使用成功就立马刷新记牌器和数据，并显示出记牌器UI。
--      记牌器已经生效，直接显示出UI或者关闭UI。

-- 以下这些是埋入对局中的回调方法，用来刷新剩余牌数，UI刷新和决定记牌器显示状态
-- onGameOver--对局结束时
-- onGameResume--恢复对局时
-- onGameStart--对局开始时
-- onGetTributeCard--获得贡牌时
-- onGiveTributeCard--给出贡牌时
-- onPlayCard--出牌时
-- onPlayFirstCard--出当前局第一手牌时
-- onQuitRoom--退出房间时

-- _updateData：刷新指定牌的数量。
-- _updateView：根据当前的数据，刷新指定牌的牌数。
-- _updateLaiZiFlag：更新癞子标志。
-- _changeValidPeriod：每秒执行一次的回调。刷新_left_valid_period和_licence_key。刷新记牌器按钮上的时间或者剩余记牌器数。
-- _checkStatusToShow：根据本地数据来判断要不要显示记牌器。例如恢复对局时，根据上一次的显示状态来决定是否显示记牌器。
-- _showAni/_hideAni：动画显示/消失记牌器(没有会创建)，用了_is_in_ani变量，来进行互斥。
-- _createView：创建记牌器UI的实例，
-- _stop：--关闭记牌器，退出房间时调用。
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local CardRecorder = class("CardRecorder", require("packages.mvc.Proxy"))
local StoreProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_StoreProxy)
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local GameManageFactory = require("WhippedEgg.GameManageRoot.GameManageFactory")
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
local GDPokerUtil = require("WhippedEgg.util.GDPokerUtil")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local getStr, getComStr = function(str) return i18n:get("str_cardrecorder", str) end, function(str) return i18n:get("str_common", str) end
local table, string, next, userData, globalEventDispatcher, globalScheduler, director = table, string, next, DataCenter:getUserdataInstance(), cc.Director:getInstance():getEventDispatcher(), cc.Director:getInstance():getScheduler(), cc.Director:getInstance()
local TAG = "CardRecorder"

function CardRecorder:ctor(gameRoom)
    -- 当前牌局能不能使用记牌器：经典玩法和私人房才能用记牌器
    self._is_cur_room_support =(gameRoom.__cname == "Classical") or(gameRoom.__cname == "Personal")
    if self._is_cur_room_support then
        wwlog(TAG, string.format("当前房间[%s]支持记牌器功能", gameRoom.__cname))
    else
        wwlog(TAG, string.format("当前房间[%s]不支持记牌器功能", gameRoom.__cname))
    end
    if not self._is_cur_room_support then return end
    -- 除自己(或者队)手牌外的剩余牌型。k对应pokerValue，v就是剩余牌数
    self._card_left_info = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    -- v是一个table，v的key是pokervalue，v的value是对应的label
    -- 牌数更新时，刷新这里对应的label
    self._listener_view = nil
    -- 剩余有效时间
    self._left_valid_period = 0
    -- 有效标记，还有剩余有效时间，则标记为true即记牌器还能用
    self._licence_key = false
    -- 游戏对局ID，可以用来判断是否在对局中
    self._game_play_id = nil
    -- 游戏房间ID
    self._game_zone_id = nil
    -- 游戏玩法
    self._game_play_type = nil
    -- 记牌器是不是在对局中过期的。在对局中过期的，在本局中还可以继续使用。
    self._tmp_flag_expire_in_game = false
    -- 倒计时的时候，将每秒回调注册的listener
    self._count_down_listener = { }
    -- 收到剩余有效时间时的回到
    self._on_get_period_callback = nil
    -- 当前是否处在显示或者消失的动画中，互斥用。
    self._is_in_ani = false
    -- 记录进入后台的时间
    self._event_listener_enterbackground = nil
    -- 记录返回前台的时间
    self._event_listener_enterforeground = nil
    -- 道具使用和购买立即使用
    self._ShopPropModel = require("hall.model.shopPropModel"):create(self)
    self._listener_msg = { }
    -- 剩余有效时间倒计时
    self._schedule_handle = globalScheduler:scheduleScriptFunc( function() self:_changeValidPeriod(1) end, 1.0, false)
    -- 是否在记牌器内部购买的，也就是购买并立即使用。用来区分记牌器内部购买和对局中商城里购买而不立即使用的情况。
    self._tmpBuyInCardRecorder = false
    -- 要考虑游戏进入后台时的流失时间
    local _tmp_record_time = nil
    self._event_listener_enterbackground = cc.EventListenerCustom:create("applicationDidEnterBackground", function(event)
        if self._licence_key then
            _tmp_record_time = os.time()
        end
    end )
    self._event_listener_enterforeground = cc.EventListenerCustom:create("applicationWillEnterForeground", function(event)
        if self._licence_key then
            if _tmp_record_time then self:_changeValidPeriod(os.time() - _tmp_record_time) end
            _tmp_record_time = nil
            -- 刷新记牌器时间，返回前台刷新记牌器时间
            UserProxy:requestValidPeriod(getGoodsByFlag("jpq").fid)
        end
    end )
    -- 进入后台
    globalEventDispatcher:addEventListenerWithFixedPriority(self._event_listener_enterbackground, 1)
    -- 回到前台
    globalEventDispatcher:addEventListenerWithFixedPriority(self._event_listener_enterforeground, 1)
    -- 接收道具有效期剩余时间
    self._listener_msg[#self._listener_msg + 1] = WWFacade:addCustomEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_PROP_VALID_PERIOD, handler(self, self._gotValidPeriodCallback))
    -- 购买道具消息监听
    self:registerMsgId(self._ShopPropModel.MSG_ID.Msg_BuyMagicResp_Ret, handler(self, self._response), "CardRecorder_Msg_BuyMagicResp_Ret")
    -- 使用道具监听。注意，自己使用道具，所有玩家都会收到这条响应。根据FromUserId过滤。是谁用了。
    self:registerMsgId(self._ShopPropModel.MSG_ID.Msg_UseMagicResp_Ret, handler(self, self._response), "CardRecorder_Msg_UseMagicResp_Ret")
    self:registerRootMsgId(self._ShopPropModel.MSG_ID.Msg_BuyMagicReq_send, handler(self, self._response), "CardRecorder_Msg_BuyMagicReq_send")
    -- 对局界面记牌器按钮上的倒计时UI逻辑和红点逻辑。
    -- self:_attachBtnCardRecorder(GameManageFactory:getCurGameManage().MyPlayer.Button_rmcard)
    --    -- 请求用户当前记牌器剩余时间
    --    UserProxy:requestValidPeriod(getGoodsByFlag("jpq").fid)
end

-- 点击对局中记牌器按钮时的回调。
function CardRecorder:click_btnCardRecorder_callback()
    if not self._is_cur_room_support then return end
    -- 正在播放动画，不予处理
    if self._is_in_ani then return end
    if self._listener_view then
        -- 已经有记牌器view实例
        local bg = self._listener_view[1]:getParent()
        if bg:isVisible() then
            wwlog(TAG, "取消显示记牌器")
            self:_saveShowStatus(false)
            self:_hideAni(bg)
        else
            wwlog(TAG, "显示记牌器")
            self:_saveShowStatus(true)
            self:_showAni(bg)
        end
    else
        if self:_getShopConf() then
            if self._game_play_id then
                -- 当前是否在对局中，只有在对局中才能创建
                if self._licence_key then
                    -- 当前对局已经使用了记牌器，则能创建记牌器界面
                    self:_saveShowStatus(true)
                    self:_showAni()
                    wwlog(TAG, "显示记牌器(创建UI)")
                else
                    -- 消耗记牌器
                    local params = nil
                    if userData:getGoodsAttrByName("jpq", "count") > 0 then
                        -- 物品箱还有记牌器，立即使用记牌器
                        if self:_getShopConf() then
                            params = {
                                MagicID = self:_getShopConf().MagicID,
                                StoreMagicID = self:_getShopConf().StoreMagicID,
                                PlayID = self._game_play_id,
                                GameZoneID = self._game_zone_id,
                                PlayType = self._game_play_type,
                                Count = 1,
                            }
                        end
                    else
                        -- 记牌器不够，购买并使用记牌器
                        -- CHARGE_STORE_GOLD = 1025;-- 钻石兑换金币StoreID
                        -- CHARGE_STORE_PROP = 1026;-- 钻石兑换物品StoreID
                        -- CHARGE_STORE_PROP_GAME = 1027;--购买并使用
                        if self:_getShopConf() then
                            params = {
                                MagicID = self:_getShopConf().MagicID,
                                Money = self:_getShopConf().Money,
                                StoreMagicID = self:_getShopConf().StoreMagicID,
                                PlayID = self._game_play_id,
                                PlayType = self._game_play_type,
                                GameZoneID = self._game_zone_id,
                                Count = 1,
                            }
                        end
                        if params and tonumber(userData:getValueByKey("GameCash")) <(params.Money * params.Count) then
                            -- 钻石不足，请弹快充
                            toast(getStr("not_enough_zuan"))
                            params = nil
                        end
                    end
                    if params then
                        -- 如果物品箱里有，则直接使用。
                        -- 如果物品箱里没有，则购买并立即使用。这里暂定记牌器数量是1.
                        -- 注意响应时：道具数量和钻石数量的刷新问题。
                        if params.Money then
                            -- 购买提醒
                            local para = { }
                            para.leftBtnlabel = getComStr("comm_cancel")
                            para.rightBtnlabel = getComStr("comm_sure")
                            para.leftBtnCallback = nil
                            para.rightBtnCallback = function()
                                StoreProxy:requestBuyProp(params, wwConfigData.CHARGE_STORE_PROP_GAME)
                                --记牌器内部购买时，购买响应中立即生效
                                self._tmpBuyInCardRecorder = true
                            end
                            para.showclose = false
                            -- 是否显示关闭按钮
                            para.content = string.format(getStr("buy_card_recorder_dialog"), params.Money * params.Count)
                            require("app.views.customwidget.CommonDialog"):create(para):show()
                        else
                            -- 使用
                            wwlog(TAG, "背包里有记牌器，直接使用记牌器")
                            StoreProxy:requestBuyProp(params, wwConfigData.CHARGE_STORE_PROP_GAME)
                        end
                    end
                end
            else
                -- 不在对局中，无法使用记牌器
                toast("不在对局中，无法使用记牌器")
            end
        else
            -- wwGoodsInfo需要先从商店道具栏更新道具属性，方便获取记牌器MagicID。
            wwlog(TAG, "还没有获取到记牌器道具属性，无法获得记牌器MagicID")
        end
    end
end

-- 游戏对局开始时调用
function CardRecorder:onGameStart(gameStart)
    if not self._is_cur_room_support then return end
    wwlog(TAG, "记牌器侦测到对局开始")
    -- 请求记牌器的使用有效期剩余时间。
    UserProxy:requestValidPeriod(getGoodsByFlag("jpq").fid)
    self._game_play_id = gameStart.GamePlayID
    local controller = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)
    self._game_zone_id = self._game_zone_id or controller.gameZoneId
    self._game_play_type = self._game_play_type or controller.gameType
    -- 重置牌数，刷新界面
    table.map(self._card_left_info, function(v, k) return(k == 14 or k == 15) and 2 or 8 end)
    -- 对局结束，记牌器就关闭了
    --    self:_updateView(nil, true)
    -- 记牌器不计入自己的牌
    for k, v in ipairs(gameStart.players) do
        if v.UserID == userData:getValueByKey("userid") then
            for k, v in pairs(v.baseCards) do self:_updateData(v.val, -1) end
        end
    end
    table.walk(self._card_left_info, function(v, k) self:_updateView(k) end)
    -- 癞子牌
    self:_updateLaiZiFlag()
end

-- 出第一手牌回调。
function CardRecorder:onPlayFirstCard()
    if not self._is_cur_room_support then return end
    wwlog(TAG, "记牌器侦测到打出第一手牌。")
    self:_checkStatusToShow()
end

-- 自己获得贡牌回调。
function CardRecorder:onGetTributeCard(card)
    if not self._is_cur_room_support then return end
    wwdump(card, "记牌器侦测到自己收到贡牌：")
    self:_updateData(card.val, -1)
    self:_updateView(card.val)
end

-- 自己给出贡牌回调。
function CardRecorder:onGiveTributeCard(card)
    if not self._is_cur_room_support then return end
    wwdump(card, "记牌器侦测到自己给出贡牌：")
    self:_updateData(card.val, 1)
    self:_updateView(card.val)
end

-- 玩家出牌时调用。
-- 记录打出去的牌，和trueCards一样
-- playCards:{
--    [1] = {val = 1,color  =2}
-- }
function CardRecorder:onPlayCard(playCards, userid)
    if not self._is_cur_room_support then return end
    if userid ~= userData:getValueByKey("userid") then
        -- 自己的手牌并未记录到剩余牌中，所以不需要考虑自己出的牌
        if next(playCards) then
            wwlog(TAG, "记牌器侦测到其他玩家出牌")
            for k, v in ipairs(playCards) do
                self:_updateData(v.val, -1)
                self:_updateView(v.val)
            end
        end
    end
    return self
end

-- 恢复对局时调用。可能场景：重启客户端恢复对局。断线重连恢复对局。
function CardRecorder:onGameResume(msg)
    if not self._is_cur_room_support then return end
    wwlog(TAG, "记牌器侦测到对局恢复")
    -- 请求记牌器的使用有效期剩余时间。
    UserProxy:requestValidPeriod(getGoodsByFlag("jpq").fid)
    msg.RemainCard = msg.RemainCard or ""
    wwlog(TAG, "是否使用记牌器：" .. msg.RecordCard)
    wwdump(msg.RemainCard, TAG .. "剩余牌型")
    self._game_play_id = msg.GamePlayID
    self._game_zone_id = msg.GameZoneID
    self._game_play_type = msg.PlayType
    -- 还需要刷新当前剩余牌型,不包含自己的手牌
    for k, v in string.gmatch(msg.RemainCard, "()(.)") do self._card_left_info[k] = tonumber(v) or 0 end
    if msg.RecordCard == 1 then
        -- 当前牌局已使用记牌器
        -- 收到有效剩余时间时的回调，这样的做的目的，保证能还原这种现场：恢复对局时，记牌器已经在本局中过期。
        self._on_get_period_callback = function()
            if self._left_valid_period == 0 then
                -- 进入对局时就过期，记牌器还可以使用的情况
                self._left_valid_period = 1
                self:_changeValidPeriod(1)
            end
            table.walk(self._card_left_info, function(v, k) self:_updateView(k) end)
            self:_checkStatusToShow()
        end
    end
    -- 癞子牌
    self:_updateLaiZiFlag()
    return self
end

-- 游戏结束UI
function CardRecorder:onGameOver()
    if not self._is_cur_room_support then return end
    wwlog(TAG, "记牌器侦测到对局结束")
    self._game_play_id = nil
    -- 游戏结束，如果记牌器已过期，则去除记牌器
    -- 这里需用剩余时间来判断，因为在对局中到期，在本局中记牌器还是有效的。
    -- 刷新有效期
    self._tmp_flag_expire_in_game = false
    self:_changeValidPeriod(0)
    if not self._licence_key then
        if self._listener_view then self._listener_view[1]:getParent():removeFromParent(); self._listener_view = nil end
    end
    if self._listener_view and self._listener_view[1]:getParent():isVisible() then
        -- 缩回记牌器
        self:_hideAni(self._listener_view[1]:getParent(), true)
    end
end

-- 游戏界面记牌器按钮创建时回调，倒计时UI逻辑
function CardRecorder:attachBtnCardRecorder(btnCardRecorder)
    if not self._is_cur_room_support then return end
    local card_recorder, count_down_listener, time_label, redpoint_name, math, tmp = nil, nil, "_card_recorder_valid_time_label", "_redpoint_name", math, nil
    local userData, btn_img = DataCenter:getUserdataInstance(), btnCardRecorder:getChildByName("Image_rm")
    
    card_recorder = MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic:getCardRecorder()
    count_down_listener = card_recorder:registerCountDownListener( function(valid, validTime)
        -- valid:为ture则记牌器还能用，validTime:记牌器剩余有效时间
        if valid then
            -- 当前记牌器还能用的话，还需要继续显示剩余时间
            if btnCardRecorder[time_label] and btnCardRecorder[time_label]._is_visible_flag ~= true then
                btnCardRecorder[time_label]:setVisible(true)
                btnCardRecorder[time_label]._is_visible_flag = true
                btn_img:setVisible(false)
            elseif not btnCardRecorder[time_label] then
                btnCardRecorder[time_label] = cc.Label:createWithSystemFont("", "", 50):addTo(btnCardRecorder):center(btnCardRecorder):offset(30, 0)
                btnCardRecorder[time_label]._is_visible_flag = true
                btn_img:setVisible(false)
            end
            if validTime < 3600 then
                -- 小于1小时，显示分：秒。
                btnCardRecorder[time_label]:setString(string.format("%02d:%02d", math.floor(validTime / 60), validTime % 60))
            else
                -- 大于1小时：显示时：分。
                btnCardRecorder[time_label]:setString(string.format("%02d:%02d", math.floor(validTime / 3600), math.floor(validTime % 3600 / 60)))
            end
            if btnCardRecorder[redpoint_name] and btnCardRecorder[redpoint_name]._is_visible_flag == true then
                btnCardRecorder[redpoint_name]:setVisible(false)
                btnCardRecorder[redpoint_name]._is_visible_flag = false
            end
        else
            -- 记牌器不能用了，取消时间显示
            if btnCardRecorder[time_label] and btnCardRecorder[time_label]._is_visible_flag ~= false then
                btnCardRecorder[time_label]:setVisible(false)
                btnCardRecorder[time_label]._is_visible_flag = false
                btn_img:setVisible(true)
            end

            tmp = userData:getGoodsAttrByName("jpq", "count")
            -- print("*****记牌器数量：" .. userData:getGoodsAttrByName("jpq","count"))
            if tmp == 0 then
                -- 没有记牌器，则不显示红点
                -- print("******************1")
                if btnCardRecorder[redpoint_name] and btnCardRecorder[redpoint_name]._is_visible_flag ~= false then
                    btnCardRecorder[redpoint_name]:setVisible(false)
                    btnCardRecorder[redpoint_name]._is_visible_flag = false
                end
            else
                -- 需要显示红点加数量
                -- print("******************2")
                if btnCardRecorder[redpoint_name] and btnCardRecorder[redpoint_name]._is_visible_flag == false then
                    -- print("******************3")
                    btnCardRecorder[redpoint_name]:setVisible(true)
                    btnCardRecorder[redpoint_name]._is_visible_flag = true
                elseif not btnCardRecorder[redpoint_name] then
                    -- print("******************4")
                    btnCardRecorder[redpoint_name] = display.newSprite("common/red_point.png"):addTo(btnCardRecorder):top1(btnCardRecorder):innerRight(btnCardRecorder):offset(5, -20):setScale(2.0)
                    btnCardRecorder[redpoint_name]._is_visible_flag = true
                end
                if tmp > 99 then tmp = "99+" end
                if not btnCardRecorder[redpoint_name].flag_num_node then
                    -- print("******************5")
                    btnCardRecorder[redpoint_name].flag_num_node = cc.Label:createWithSystemFont(tmp, "", 12):addTo(btnCardRecorder[redpoint_name]):center(btnCardRecorder[redpoint_name]):offset(-1.5, 4)
                    btnCardRecorder[redpoint_name].flag_num_node._tmp_num = tmp
                else
                    if btnCardRecorder[redpoint_name].flag_num_node._tmp_num ~= tmp then
                        -- print("******************6")
                        btnCardRecorder[redpoint_name].flag_num_node._tmp_num = tmp
                        btnCardRecorder[redpoint_name].flag_num_node:setString(tmp)
                    end
                end
            end
        end
    end )
    
    btnCardRecorder:onNodeEvent("exit", function() card_recorder:unregisterCountDownListener(count_down_listener); count_down_listener = nil end)
end

-- 离开房间
function CardRecorder:onQuitRoom()
    -- 退出房间
    wwlog(TAG, "记牌器侦测到退出房间")
    if not self._is_cur_room_support then return end
    self:_stop()
end

local curHandleIdx = 0
-- 注册倒计时监听，每秒执行一次
function CardRecorder:registerCountDownListener(listener)
    if not self._is_cur_room_support then return end
    self._count_down_listener[curHandleIdx] = listener
    curHandleIdx = curHandleIdx + 1
    return curHandleIdx
end

-- 注销监听
function CardRecorder:unregisterCountDownListener(handle)
    if not self._is_cur_room_support then return end
    if self._count_down_listener then
        self._count_down_listener[handle] = nil
    end
end

-- 返回剩余牌数，支持同时返回多个
-- ...：pokerValue
function CardRecorder:getCardCount(...)
    local ret = { }
    for k, v in { ...} do
        ret[#ret + 1] = self._card_left_info[v]
    end
    return unpack(ret)
end

function CardRecorder:_stop()
    self._card_left_info = nil
    if self._listener_view then self._listener_view[1]:getParent():removeFromParent(); self._listener_view = nil end
    self._left_valid_period = 0
    self._licence_key = false
    self._game_play_id = nil
    self._game_zone_id = nil
    self._game_play_type = nil
    self._tmp_flag_expire_in_game = false
    self._count_down_listener = nil
    globalEventDispatcher:removeEventListener(self._event_listener_enterbackground)
    globalEventDispatcher:removeEventListener(self._event_listener_enterforeground)
    -- 记录进入后台的时间
    self._event_listener_enterbackground = nil
    -- 记录返回前台的时间
    self._event_listener_enterforeground = nil
    self._on_get_period_callback = nil
    self._is_in_ani = false
    table.map(self._listener_msg, function(v, k) WWFacade:removeEventListener(v) end)
    self:unregisterMsgId(self._ShopPropModel.MSG_ID.Msg_BuyMagicResp_Ret, "CardRecorder_Msg_BuyMagicResp_Ret")
    self:unregisterMsgId(self._ShopPropModel.MSG_ID.Msg_UseMagicResp_Ret, "CardRecorder_Msg_UseMagicResp_Ret")
    self:unregisterRootMsgId(self._ShopPropModel.MSG_ID.Msg_BuyMagicReq_send, "CardRecorder_Msg_BuyMagicReq_send")
    self._ShopPropModel = nil
    globalScheduler:unscheduleScriptEntry(self._schedule_handle)
    self._tmpBuyInCardRecorder = false
end

-- 创建记牌器图
function CardRecorder:_createView()
    -- k是pokerValue，v是label，也就是对应剩余牌数
    local card_left_count_nodes = { }
    local tmpTbl = { 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 }
    local startPos, offsetX = cc.p(99, 113 -(109 + 54) / 2), 158 - 99
    local tmpCode = nil
    local bg = display.newSprite("guandan/card_recorder.png")
    card_left_count_nodes.parent = bg

    for k, v in ipairs(tmpTbl) do
        tmpCode = cc.Label:createWithSystemFont(self._card_left_info[v], "", 42):addTo(bg):pos(startPos):offsetX(offsetX *(k - 1)):setVisible(self._card_left_info[v] > 0)
        if k >= 12 then
            tmpCode:offsetX(9)
        elseif k >= 9 then
            tmpCode:offsetX(7)
        elseif k >= 8 then
            tmpCode:offsetX(5)
        elseif k >= 6 then
            tmpCode:offsetX(3)
        end
        card_left_count_nodes[v] = tmpCode
    end
    self._listener_view = card_left_count_nodes
    bg:onNodeEvent("exit", function() self._listener_view = nil end)
    self:_updateLaiZiFlag()
    return bg
end

-- 刷新当前牌数
-- isOverWrite = true，直接用count覆盖刷新。
-- isOverWrite = false，count是变化量
-- 默认是变化量
function CardRecorder:_updateData(pokerValue, count, isOverWrite)
    if isUpdated then
        self._card_left_info[pokerValue] = count
    else
        self._card_left_info[pokerValue] = self._card_left_info[pokerValue] + count
    end
    return self
end

-- 刷新界面
-- 刷新pokerValue牌的当前数量，为空时，刷新全部
-- 跳过licence强制更新
function CardRecorder:_updateView(pokerValue, force)
    if (self._licence_key or force) and self._listener_view then
        if pokerValue then
            -- 刷新pokerValue对应的UI
            if self._card_left_info[pokerValue] == 0 then
                self._listener_view[pokerValue]:setVisible(false)
            else
                self._listener_view[pokerValue]:setVisible(true)
                self._listener_view[pokerValue]:setString(self._card_left_info[pokerValue])
            end
        else
            -- 全部刷新
            for pokerValue, leftCount in ipairs(self._card_left_info) do
                if leftCount == 0 then
                    self._listener_view[pokerValue]:setVisible(false)
                    -- v[pokerValue]:setString(leftCount)
                else
                    self._listener_view[pokerValue]:setVisible(true)
                    self._listener_view[pokerValue]:setString(leftCount)
                end
            end
        end
    end
end

function CardRecorder:_response(msgid, msg)
    if msgid == self._ShopPropModel.MSG_ID.Msg_BuyMagicResp_Ret then
        -- 购买道具响应。
        if msg.MagicID == self:_getShopConf().MagicID and self._tmpBuyInCardRecorder == true then
            wwlog(TAG, "记牌器收到购买记牌器的响应消息:" .. msgid)
            self._tmpBuyInCardRecorder = false
            -- 记牌器
            if msg.result == 0 then
                -- 购买成功
                -- 更新钻石数量
                userData:setUserInfoByTable( { Diamond = msg.UseCash })
                -- 更新记牌器数量
                updataGoods(getFidByFlag("jpq"), msg.Count)
                -- 使用记牌器
                StoreProxy:requestBuyProp( {
                    MagicID = self:_getShopConf().MagicID,
                    PlayID = self._game_play_id,
                    GameZoneID = self._game_zone_id,
                    PlayType = self._game_play_type,
                    Count = 1,
                } , wwConfigData.CHARGE_STORE_PROP_GAME)
                -- elseif msg.result == 1 then
                --    -- 1＝用户帐户余额不足
                --    toast("账户余额不足 ")
                -- elseif msg.result == 2 then
                --    -- 2, 用户帐户余额不足,不足房间准入
                --    toast("用户帐户余额不足,不足房间准入")
                -- elseif msg.result == 11 then
                --    toast("物品不存在或者已经售罄")
                -- elseif msg.result == -1 then
                --    -- 1=其它异常
                --    toast("网络异常，请稍后重试")
            end
        end
    elseif msgid == self._ShopPropModel.MSG_ID.Msg_UseMagicResp_Ret then
        wwlog(TAG, "记牌器收到使用记牌器的响应消息:" .. msgid)
        if msg.FromUserID == userData:getValueByKey("userid") then
            -- 因为这条消息是广播，必须先判断是不是自己用的。（坑爹的设计）
            -- 使用道具响应
            -- GamePlayID[int4]	对局标示
            -- MagicID [int4]	道具ID
            -- FromUserID[int4]	实施者
            -- ToUserID[int4]	被实施者
            -- Param[Byte[]]	附加信息
            -- 更新记牌器数量
            updataGoods(self:_getShopConf().fid, -1)
            -- 请求记牌器的使用有效期剩余时间。
            UserProxy:requestValidPeriod(getGoodsByFlag("jpq").fid)
            toast(getStr("success_use_recorder"))
            -- 生成界面
            self:_saveShowStatus(true)
            self:_showAni()
        end
    elseif msgid == self._ShopPropModel.MSG_ID.Msg_BuyMagicReq_send then
        wwlog(TAG, "记牌器收到使用记牌器的通用响应消息:" .. msgid)
        -- 购买道具异常。
        toast(msg.kReason)
    end
end

function CardRecorder:_gotValidPeriodCallback(event)
    wwlog(TAG, string.format("cardrecorder valid period is %s seconds", event._userdata[1]))
    self._left_valid_period = event._userdata[1]
    -- 刷新一下
    self:_changeValidPeriod(0)
    if self._on_get_period_callback then
        self._on_get_period_callback()
        self._on_get_period_callback = nil
    end
end

-- 更新有效期时间，time是时间缩减量
function CardRecorder:_changeValidPeriod(time)
    if time < 0 then
        wwlog(TAG, string.format("时间差是负数%d，很可能作弊了(修改了系统时间)，调整为0", time))
        time = 0
    end
    if self._left_valid_period > 0 and time > 0 then
        -- 还在有效期内
        self._left_valid_period = math.max(self._left_valid_period - time, 0)
        if self._left_valid_period == 0 then
            -- 游戏对局中过期，记牌器在本局中还有效。
            wwlog(TAG, "记牌器在对局中过期，在本局中还可以使用")
            self._licence_key = true
            self._tmp_flag_expire_in_game = true
        end
    end
    if not self._tmp_flag_expire_in_game then
        if self._left_valid_period == 0 and self._licence_key then
            -- 有效期已经结束
            wwlog(TAG, "记牌器在非对局中过期，当前使用的记牌器失效")
            self._licence_key = false
        elseif self._left_valid_period > 0 and not self._licence_key then
            self._licence_key = true
        end
    end
    -- 发出广播，通知记牌器剩余时间
    for k, v in pairs(self._count_down_listener) do
        if v then
            v(self._licence_key, self._left_valid_period)
        end
    end
end

-- 更新癞子标志
function CardRecorder:_updateLaiZiFlag()
    local laiziVal = GameModel.nowCardVal
    if self._listener_view then
        for k, v in pairs(self._listener_view) do
            if laiziVal == k then
                -- 癞子，加上癞子标志
                if not v._laizi_flag_node then
                    v._laizi_flag_node = display.newSprite("#laizi.png"):addTo(v):setScale(0.3):offset(27, 87)
                end
            else
                -- 非癞子去掉标志
                if v._laizi_flag_node then
                    v._laizi_flag_node:removeFromParent()
                    v._laizi_flag_node = nil
                end
            end
        end
    end
end

-- 执行展示动画
function CardRecorder:_showAni(bg)
    if self._is_in_ani then return end
    self._is_in_ani = true
    if not bg or not bg:isVisible() then
        if not bg then
            local gamescene = director:getRunningScene()
            bg = self:_createView():addTo(gamescene, zorderLayer.FoldMenuLayer):top(gamescene):centerX(gamescene)
        end
        bg:setVisible(true)
        bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, - bg:height())), cc.CallFunc:create( function() self._is_in_ani = false end)))
    else
        self._is_in_ani = false
    end
end

-- 执行隐藏动画
function CardRecorder:_hideAni(viewInstance, force)
    if force then
        viewInstance:stopAllActions()
        viewInstance:top(viewInstance:getParent()):setVisible(false)
    else
        if self._is_in_ani then return end
        self._is_in_ani = true
        if viewInstance:isVisible() then
            viewInstance:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, viewInstance:height())), cc.CallFunc:create( function() self._is_in_ani = false end), cc.Hide:create()))
        else
            self._is_in_ani = false
        end
    end
end
 
-- 保存记牌器的打开关闭状态到本地，status：true则保存为打开状态
function CardRecorder:_saveShowStatus(status)
    ww.WWGameData:getInstance():setBoolForKey("card_recorder_open_status", status)
end

-- 根据本地保存的记牌器打开状态来决定是否显示记牌器
function CardRecorder:_checkStatusToShow()
    if self._licence_key then
        if ww.WWGameData:getInstance():getBoolForKey("card_recorder_open_status", false) then
            if self._listener_view then
                self:_showAni(self._listener_view[1]:getParent())
            else
                self:_showAni()
            end
        end
    end
end

function CardRecorder:_getShopConf()
    if not userData:getValueByKey("shopConf_inGame") or not(next(userData:getValueByKey("shopConf_inGame"))) then
        wwlog(TAG, "登录时没有成功获取游戏中购买道具配置")
    else
        return userData:getValueByKey("shopConf_inGame")[getFidByFlag("jpq")]
    end
end

return CardRecorder
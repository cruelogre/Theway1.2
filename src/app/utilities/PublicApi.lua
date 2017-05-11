-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last:
-- Content:  全局公用借口
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
-- 更新金币 钻石  在原来基础上加
-- isUpdate 是否直接更新  否则是加
local userData = nil
function cc.exports.updataGoods(fid, count, isUpdate)
    userData = userData or DataCenter:getUserdataInstance()
    -- body
    if getGoodsByFid(fid) and getGoodsByFid(fid).dataKey == "GameCash" then
        if isUpdate then
            userData:setUserInfoByKey("GameCash", tostring(count))
        else
            local lastGoldCount = userData:getValueByKey("GameCash")
            userData:setUserInfoByKey("GameCash", tostring(tonumber(count or 0) + lastGoldCount))
        end
        wwlog("updataGoods : ", userData:getValueByKey("GameCash"))
    elseif  getGoodsByFid(fid) and getGoodsByFid(fid).dataKey == "Diamond" then
        if isUpdate then
            userData:setUserInfoByKey("Diamond", count)
        else
            local lastGoldCount = userData:getValueByKey("Diamond")
            userData:setUserInfoByKey("Diamond", tostring(tonumber(count or 0) + lastGoldCount))
        end
        wwlog("updataGoods : ", userData:getValueByKey("Diamond"))
    else
        --上面没有更新成功的物品暂且都放物品箱里吧。
        -- 是物品箱里的物品
        userData:updateGoodsAttr(fid, "count", count, isUpdate)
        wwlog("updataGoods : ", userData:getGoodsAttr(fid, "count"))
    end
    WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 1)
end

-- 播放音效
function cc.exports.playSoundEffect(fileName, loop)
    -- body
    ww.WWSoundManager:getInstance():playSoundEffect(fileName, loop)

    local SettingCfg = require("hall.mediator.cfg.SettingCfg")
    local datapercent = ww.WWGameData:getInstance():getIntegerForKey(SettingCfg.ConstData.SETTING_SOUND_PERCENT, 100)
    ww.WWSoundManager:getInstance():setEffectsVolume(datapercent / 100.0)
end

-- 播放音效
function cc.exports.stopSoundEffect(fileName)
    -- body
    ww.WWSoundManager:getInstance():stopEffect(fileName)
end

-- 播放背景音乐
function cc.exports.playBackGroundMusic(fileName, loop)
    -- body
    if device.platform == "windows" then
        ww.WWSoundManager:getInstance():playBackgroundMusic(fileName, loop)
    elseif device.platform == "android" then
        local _filename = rsubStringBack(cc.FileUtils:getInstance():fullPathForFilename(fileName .. ".ogg"), "assets/")
        ww.WWSoundManager:getInstance():playBackgroundMusic(_filename, loop)
    elseif device.platform == "ios" then
        ww.WWSoundManager:getInstance():playBackgroundMusic(fileName, loop)
    end

    local SettingCfg = require("hall.mediator.cfg.SettingCfg")
    local datapercent = ww.WWGameData:getInstance():getIntegerForKey(SettingCfg.ConstData.SETTING_MUSIC_PERCENT, 100)
    ww.WWSoundManager:getInstance():setBackgroundMusicVolume(datapercent / 100.0)
end

-- 播放
function cc.exports.soundEffectControl(...)
    -- body
    -- 播放声音
    cc.Director:getInstance():getScheduler():scheduleScriptFunc( function(delayTime)
        -- body
        ww.WWSoundManager:getInstance():SoundEffectControl(delayTime)
    end , 0, false)
end
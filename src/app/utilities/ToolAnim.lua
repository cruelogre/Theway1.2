-----------------------------------------
-- comment:
--      用途：通过plist创建帧动画工具，返回animate
--      例子：
--          local sprite = cc.Sprite:create();
--          addChild(sprite)
--          cc.SpriteFrameCache:getInstance():addSpriteFrames("test/grossini.plist")
--          local format = "grossini_dance_"
--          local frameCount = 3
--          local delayPerUnit = 0.5
--          local loops = 1
--          local function aniCallback() end
--          local delayUnits = {1,2,3}
--          sprite:runAction(require("app.utilities.ToolAnim"):createAni(format, frameCount, delayPerUnit, loops, aniCallback))
--          sprite:runAction(require("app.utilities.ToolAnim"):createAniEx(format, frameCount, delayPerUnit,delayUnits, loops, aniCallback))
-- author: Jackie
-----------------------------------------
local ToolAnim = { }
-- 播放一个帧间隔相同的帧动画
-- format帧名前缀
-- frameCount3帧
-- delayPerUnit帧间隔
-- loops播放次数，-1一直循环,默认播放1次
-- callback播放完之后的回调
function ToolAnim:createAni(format, frameCount, delayPerUnit, loops, callback)
    local condi = type(format) == "string" and string.len(format) > 0 and type(frameCount) == "number" and frameCount > 0 and type(delayPerUnit) == "number" and delayPerUnit > 0
    assert(condi, "ToolAnim:createAni1:invalid parameters")
    local animation = cc.Animation:create()
    local name
    loops = loops or 1
    local frame1 = nil
    for i = 1, frameCount do
        if i >= 10 then
            name = format .. i .. ".png"
        else
            name = format .. "0" .. i .. ".png"
        end
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(name))
        if i == 1 then
            frame1 = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(name))
        end
    end
    animation:setDelayPerUnit(delayPerUnit)
    animation:setLoops(loops)
    if callback then
        return cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(callback)), frame1
    else
        return cc.Sequence:create(cc.Animate:create(animation)), frame1
    end
end

-- 播放一个帧间隔不同的帧动画
-- format:帧名前缀。帧名统一格式：format_%d.png( 1=< %d <=frameCount)
-- frameCount:帧数
-- delayPerUnit:一单位帧间隔的时间
-- delayUnits:为table，如{1,2,3}，则播放第1帧之前的间隔1*delayPerUnit,播放第2帧之前的间隔2*delayPerUnit以此类推
-- loops:播放次数，-1一直循环，默认播放1次
-- callback:播放完之后的回调
function ToolAnim:createAniEx(format, frameCount, delayPerUnit, delayUnits, loops, callback)
    local condi = type(format) == "string" and string.len(format) > 0 and type(frameCount) == "number" and frameCount > 0 and type(delayPerUnit) == "number" and delayPerUnit > 0 and type(delayUnits) == "table" and #delayUnits == frameCount
    assert(condi, "ToolAnim:createAni2:invalid parameters")
    loops = loops or 1
    local name, frames = nil, { }
    local frame1 = nil
    for i = 1, frameCount do
        if i >= 10 then
            name = format .. i .. ".png"
        else
            name = format .. "0" .. i .. ".png"
        end
        --  _frameDisplayedEventInfo.target = _target;
        -- 	_frameDisplayedEventInfo.userInfo = &dict;
        -- 每播放一祯引擎都会广播一个消息，可通过cc.ANIMATION_FRAME_DISPLAYED_NOTIFICATION接收。
        -- 广播中的userData包含target和userInfo，userInfo就是这里的usrInfo，target是animate所从属的节点
        local usrInfo = { }
        frames[#frames + 1] = cc.AnimationFrame:create(cc.SpriteFrameCache:getInstance():getSpriteFrame(name), delayUnits[i], usrInfo)
        if i == 1 then
            frame1 = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
        end
    end
    local animation = cc.Animation:create(frames, delayPerUnit, loops)
    if callback then
        return cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(callback)), frame1
    else
        return cc.Sequence:create(cc.Animate:create(animation)), frame1
    end
end

return ToolAnim
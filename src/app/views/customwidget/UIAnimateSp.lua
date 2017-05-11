-- region *.lua
-- Date 2015/11/13
-- by Sam

-- filePath：支持本地帧动画文件，和已加载到TextureCache的帧动画文件
-- rowAndColumnIndexTable：table，帧动画Rect的x，y原始坐标表
-- row：行数
-- column：列数
-- delay：可选参数，帧动画间隔时间
-- loop：可选参数，是否循环
-- callback：可选参数，回调

-- return：返回一个正在执行指定帧动画的sprite

-- 示例：一行两列的帧动画 local sp = UIAnimateSp.genAnimateSprite("mj/anim_loading.png", {{0, 0}, {1, 0}}, 1, 2, 0.2)

-- endregion

local UIAnimateSp = { }

function UIAnimateSp.genAnimateSprite(filePath, rowAndColumnIndexTable, row, column, delay, loop, callback)
	assert(type(filePath) == "string")
	assert(type(rowAndColumnIndexTable) == "table")
	assert(type(row) == "number")
	assert(type(column) == "number")

	delay = delay or 0.2
	loop = loop or -1
	callback = callback or nil

	local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(filePath)
	if texture == nil then
		texture = cc.Director:getInstance():getTextureCache():addImage(filePath)
	end

	local textureWidth = texture:getContentSize().width
	local textureHeight = texture:getContentSize().height
	local perWidth = textureWidth / column
	local perHeight = textureHeight / row

	local frames = { }

	for k, v in ipairs(rowAndColumnIndexTable) do
		local frame = cc.SpriteFrame:createWithTexture(texture, cc.rect(v[1] * perWidth, v[2] * perHeight, perWidth, perHeight))
		frames[#frames + 1] = frame
	end

	local animation = cc.Animation:createWithSpriteFrames(frames)
	animation:setDelayPerUnit(delay)
	animation:setLoops(loop)

	local animate = cc.Animate:create(animation)

	local function fun_callback(node)
		if callback ~= nil then
			callback()
		end
	end

	local action = cc.Sequence:create(animate, cc.CallFunc:create(fun_callback))

	local sp = cc.Sprite:createWithSpriteFrame(frames[1])
	sp:runAction(action)

	return sp

end

return UIAnimateSp

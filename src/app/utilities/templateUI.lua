-----------------------------------------------------------
-- Desc:     TemplateUI
-- Author:   Jackie刘龙
-- Date:  	 2015-12-03
-- Last: 	
-- Content: 界面UI模板
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------
local templateUI = {
    -- 一个Sprite
    {
        -- 名称，同一个table，请保持名称唯一
        n = "testSprite",
        -- 精灵
        t = "sp",
        -- 有size属性，被认定是Scale9Sprite,没有则是普通Sprite
        size = { 100, 200 },
        -- 公用属性：锚点
        arc = { 0.5, 0.5 },
        -- 公用属性：x坐标
        x = 100,
        -- 公用属性：y坐标
        y = 200,
        -- 公用属性：是否隐藏
        hd = false,
        -- 公用属性：缩放
        scale = 1.0,
        -- 公用属性：addChild到n是testBtn的节点上
        parent = 'testBtn',
        -- 公用属性：在testBtn上面，以下同理
        top = 'testBtn',
        -- 公用属性：在testBtn的上部边界上，以下同理
        top1 = 'testBtn',
        bottom = 'testBtn',
        bottom1 = 'testBtn',
        right = 'testBtn',
        right1 = 'testBtn',
        left = 'testBtn',
        left1 = 'testBtn',
        -- 公用属性：在testBtnX方向上的中间
        centerX = 'testBtn',
        -- 公用属性：在testBtnY方向上的中间
        centerY = "testBtn",
        -- 公用属性：在testBtn X,Y方向上的中间
        center = 'testBtn',
        -- 公用属性：在testBtn的内部下方，即和testBtn的下条边重叠，以下同上
        innerBottom = 'testBtn',
        innerTop = 'testBtn',
        innerLeft = 'testBtn',
        innerRight = 'testBtn',
        -- 公用属性：x方向偏离当前位置的偏移量，以下同理
        offsetX = 10,
        offsetY = 10,
        -- 公用属性：setFlippedX
        flipX = true,
        flipY = true,
        -- 公用属性：可见性
        visibility = true,
        -- 公用属性：setEnabled
        enable = true,
        -- 公用属性：setLocalZOrder
        order = 1,
        -- 公用属性：setColor()
        color = display.COLOR_BLACK,
    },
    -- Button
    {
        n = "testBtn",
        -- uibutton
        t = "btn",
        -- disabled可省略
        res = { normal, selected, disabled }
    },
    -- ClipNode
    {
        n = "testClip",
        t = "clipnode",
        -- rect = {x,y,width,height}
        rect = { 100, 100, 200, 200 },
        -- 注意和rect不能同时存在,stencil请在代码中初始好，然后再生成界面，不要像下面一样在表中赋值。
        stencil = cc.Sprite:create(test),
        -- setInverted
        inverted = true,
    },
    -- Scale9Sprite
    {
        n = "testScale9",
        t = "sp9",
        res = "test/test/test.png",
        width = 100,
        height = 100,
    },
    -- LabelAtlas
    {
        n = "testAtlas",
        t = "LabelAtlas",
        txt = "12.0001",
        charmap = "test/test.png",
        itemwidth = 10,
        itemheight = 10,
        -- 注意请填写ASCII码值，'0'是字符串不是字符，32是空格
        start = 32,
    },
    -- UIButton
    {
        n = "testUIBtn",
        t = "UIButton",
        normal = "test/norma.png",
        selected = "test/selected.png",
        disabled = "test/disabled.png",
        -- 可以在具体代码中赋值，然后再生成界面
        callback = nil,
        pressAction = true,
        scale9 = true,
        txt = "motherfucker",
        color = display.COLOR_BLACK,
        size = 35,
        fnt = nil,
        zoomScale = 0.9,
    },
    {
        n = "testCustomUI",
        t = "CustomUI",
        -- 可以添加公用属性，在执行GenUiUtils:genUis()之前
    },
}
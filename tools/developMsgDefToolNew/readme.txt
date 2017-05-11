#Lua协议模型自动生成工具 V2.0
-----------------------------------------------------------------------------------------------------------------
history：
新建
2015-12-01 diyal 添加协议解析的loop属性，现在支持readShort readChar
2016-04-12 diyal 重构成2.0版本，将配置跟根脚本分离,并且支持模块标签
2016-09-27 diyal 修复服务端新增，循环字段，使用第一个循环大小的Bug （--新增2016-09-27--）
-----------------------------------------------------------------------------------------------------------------
一、概述
~
工具生成一个模块的Net Model。对于开发者而言，只需要根据协议文档配置好，执行脚本生成NetModelBean
这种Domain Model有个专业名词叫做贫血域模型。只是一个单纯的数据对象。

好处：
    1、委托模式，不再需要关注网络消息的解析之类的，一定程度上解耦和。
	2、大大降低手动敲socketio的二进制读写代码。降低失误率。
	3、聚合，带来的好处是可以为Unit测试带来便利。非常方便的可以写出一些脚本进行自动化测试。
缺点：
    1、灵活性不够，如果一个协议ID根据不同的状况判断

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素 


二、具体操作
1、配置模块基本信息
新建模块文件夹，新建配置脚本文件，如下步骤：（参照Demo文件，进行配置）
a、配置文件头，引入生成的库文件

#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
sys.path.append("..")
from GenMsgFactory import*

b、配置模块信息
注意：旧版本的，可以直接将_fileName和send_type_info_map移植过来
#配置模块信息
_fileName = { 'name' : 'testnetModel', 'context' : '测试模块' };

name : 是这个模块的名称，也是文件生成后的文件名，Model中对象表名，也是这个。
context ： 模块注释

c、尾部执行函数
if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");

三、发送消息配置方法
    'Msg_Test_send': {                                  --名称（最好是跟消息类容挂钩的命名方式）
        'comment': '请求测试',                          --注释
        'msgid' : 0x010101,                             --消息ID
        'msgtype': 'write',                             --消息类型，一定要指定（write为向服务器写消息，read为读消息）
        'fields': [                                     --字段类型 （字段类型、名称），一定要跟协议文档一致
            ('int',                      'id'),         
            ('char',                     'type'),
            ('int',                      'param1'),
            ('int',                      'param2'),
        ],
		
    },

四、解析消息配置
    'Msg_Test_Ret': {
        'comment': '返回测试',
        'msgid' : 0x010137,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'UserID'),
            ('string',                     'GameCash'),
            ('int',                        'IssueType'),
            ('string',                     'Notify'),
			('icondata',                   'icon'),              --读取图片数据
            ('loop',   {                                         --面对有循环的，可以配置loop类型
                'loopTableKey' :           'looptab1',           --loopTableKey名称，使我们在解析得到的一个元素，只不过value是一个table。通过retTable.loopTableKey取得一个table几个,用泛型for迭代出来即可
                'loopReadType' :           'char',               --这里可以兼容 char short none 读取方式。默认是ReadShort 如果配置了none，则不读取循环大小，用之前的count （--新增2016-09-27--）
				'fields': [                                     
                    ('string',             'MagicName'),
                    ('int',                'MagicID'),
                    ('int',                'MagicCount'),
                    ('string',             'MagicUnit'),
                    ('int',                'MagicFID'),
                    ('short',              'MagicFunType'),
                ],
            }),
        ],
    }, 
	
	#支持多个loop，需要注意的是loopTableKey不要重名，否则会被覆盖掉。
	#支持嵌套循环，只不过是把loop当做一个子集。

五、注意事项
1、使用的时候，最好是一个功能模块用一个配置文件，这样不会影响之前已经生成过的脚本文件。
对于嵌套循环，这种稍有的需求，可以后面完善。或者，手动修改Model文件
2、截止2016年4月12日之前使用1.0版本生成的，需要改成2.0版本。具体移植方式如下：
	参照二，将旧版的两个配置文件Copy过来即可。

3、如果有循环需要使用上一个解析字段的情况
例如 充值到账消息，奖励物品循环的读取，需要取个条数，然后后面解析使用这个字段
->我们可以如下配置。配置为一个普通的读取方式，然后使用的时候，直接读取这个table的num 
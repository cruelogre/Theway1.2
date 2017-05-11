#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'testnetModel', 'context' : '测试模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_Test_send': {
        'comment': '请求测试',
        'msgid' : 0x010101,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'id'),
            ('char',                     'type'),
            ('int',                      'param1'),
            ('int',                      'param2'),
        ],
    },
    'Msg_Test_Ret': {
        'comment': '返回测试',
        'msgid' : 0x010137,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'UserID'),
            ('string',                     'GameCash'),
            ('int',                        'IssueType'),
            ('string',                     'Notify'),
            ('icondata',                   'icon'),
            ('loop',   {
                'loopTableKey' :           'looptab1',
                'loopReadType' :           'short',
                 'fields': [
                    ('string',             'MagicName'),
                    ('int',                'MagicID'),
                    ('int',                'MagicCount'),
                    ('string',                'MagicUnit'),
                    ('int',                'MagicFID'),
                    ('short',                'MagicFunType'),
                    ('loop',   {
                        'loopTableKey' :           'looptab2',
                        'loopReadType' :           'short',
                         'fields': [
                            ('string',             'MagicNameSub'),
                            ('int',                'MagicIDSmb'),
                            # ('loop',   {
                            #     'loopTableKey' :           'looptabsub',
                            #     'loopReadType' :           'short',
                            #      'fields': [
                            #         ('string',             'MagicNameSub'),
                            #         ('int',                'MagicIDSmb'),
                            #         ('loop',   {
                            #             'loopTableKey' :           'looptabsub',
                            #             'loopReadType' :           'short',
                            #              'fields': [
                            #                 ('string',             'MagicNameSub'),
                            #                 ('int',                'MagicIDSmb'),
                            #             ],
                            #         })
                            #     ],
                            # }),
                        ],
                    }),
                ],
            }),
        ],
    },    
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");

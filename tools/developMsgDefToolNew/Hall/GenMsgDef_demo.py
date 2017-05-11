#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'HallNetModel', 'context' : '大厅消息' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_GDBriefUserInfo_ret': {
        'comment': '简要玩家信息',
        'msgid' : 0x060801,
        'msgtype': 'read', 
        'fields': [
            ('int',                      'UserID'),
            ('string',                   'Nickname'),
            ('int',                      'IconID'),
            ('short',                    'VIP'),
            ('string',                   'GameCash'),
            ('string',                   'Diamond'),
			('string',                   'BindPhone'),
			('string',                   'Region'),
        ],
    },
    'Msg_GDHallAction_send': {
        'comment': '玩家游戏大厅操作',
        'msgid' : 0x28010B,
        'msgtype': 'write', 
        'fields': [
            ('char',                     'type'),
            ('int',                   'Param1'),
            ('int',                   'Param2'),
            ('int',                   'Param3'),
        ],
    },
    'Msg_GDGameZoneList_Ret': {
        'comment': '游戏区列表',
        'msgid' : 0x060803,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'type'),
            ('short',                        'GameID'),
            ('loop',   {
                'loopTableKey' :           'looptab1',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'GameZoneID'),
                    ('string',          'Name'),
                    ('char',            'ZoneWin'),
                    ('string',          'Description'),
                    ('int',             'Account'),
                    ('int',             'fortuneBase'),
                    ('int',             'FortuneMin'),
                    ('int',             'FortuneMax'),
                    ('short',             'PlayType'),
                ],
            }),

        ],
    },    
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");

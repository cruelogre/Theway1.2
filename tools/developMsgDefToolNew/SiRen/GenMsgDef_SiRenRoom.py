#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'sirennetModel', 'context' : '私人房模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_GDRoomAct_send': {
        'comment': '房间操作',
        'msgid' : 0x060818,
        'msgtype': 'write', 
        'fields': [
            ('short',                   'actType'),
            ('int',                     'RoomID'),
            ('int',                      'GameID'),
        ],
    },
    'Msg_GDCreateRoomReq_send': {
        'comment': '创建房间',
        'msgid' : 0x060816,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'GameID'),
            ('short',                    'Playtype'),
            ('short',                    'PlayData'),
            ('short',                    'RoomCardCount'),
            ('char',                     'DWinPoint'),
            ('string',                   'MultipleData'),
        ],
    },
	'Msg_GDRoomSet_Ret': {
        'comment': '玩法局数配置',
        'msgid' : 0x060815,
        'msgtype': 'read', 
        'fields': [
            ('int',             'GameID'),
            ('loop',   {
                'loopTableKey' :           'roomConf',
                'loopReadType' :           'short',
                 'fields': [
                    ('short',             'PlayType'),
                    ('string',            'PlayData'),
                    ('string',            'RoomCard'),
                ],
            }),
        ],
    },
	'Msg_GDRoomInfo_Ret': {
        'comment': '返回房间信息',
        'msgid' : 0x060817,
        'msgtype': 'read', 
        'fields': [
            ('char',                     'Type'),
            ('int',                      'GameID'),
			('int',                      'RoomID'),
			('int',                      'MasterID'),
			('short',                    'Playtype'),
			('short',                    'PlayData'),
			('char',                     'DWinPoint'),
			('string',                   'MultipleData'),
            ('short',                    'RoomCardCount'),
			('loop',   {
                'loopTableKey' :           'userInfo',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',                'UserID'),
                    ('int',                'IconID'),
					('string',             'Nickname'),
					('char',             'Gender'),
					('char',             'Status'),
                ],
            }),
        ],
    },
	'Msg_GDRoomResult_Ret': {
        'comment': '私人房最终结算',
        'msgid' : 0x060819,
        'msgtype': 'read', 
        'fields': [
            ('int',                      'GameID'),
            ('int',                     'RoomID'),
			('loop',   {
                'loopTableKey' :           'result',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',                'UserID'),
                    ('string',             'Nickname'),
                    ('short',              'Play'),
					('string',             'Winp'),
					('short',              'Rank1'),
					('short',              'Boom'),
					('short',              'StrFlush'),
					('int',                'Score'),
                ],
            }),
        ],
    },
	'Msg_GDRoomHistory_Ret': {
        'comment': '私人房历史记录',
        'msgid' : 0x06081A,
        'msgtype': 'read', 
        'fields': [
            ('int',                      'GameID'),
			('loop',   {
                'loopTableKey' :           'history',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',                'RoomID'),
                    ('string',             'DateStr'),
                    ('short',              'Playtype'),
					('short',              'PlayData'),
					('string',             'MultipleData'),
					('loop',   {
						'loopTableKey' :           'playerInfo',
						'loopReadType' :           'short',
						'fields': [
							('int',                'UserID'),
							('string',             'Nickname'),
							('short',              'Play'),
							('string',             'Winp'),
							('short',              'Rank1'),
							('short',              'Boom'),
							('short',              'StrFlush'),
							('int',                'Score'),
						],
					}),
                ],
            }),
        ],
    },
	'Msg_GDRoomNotify_Ret': {
        'comment': '房间通知消息',
        'msgid' : 0x06081B,
        'msgtype': 'read', 
        'fields': [
            ('char',                    'Type'),
			('int',                     'RoomID'),
			('int',                     'Param1'),
			('string',                  'Desc'),
            ('int',                      'GameID'),
        ],
    },	
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");

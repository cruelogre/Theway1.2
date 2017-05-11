#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'RoomChatModel', 'context' : '牌局聊天模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_RoomChat_send': {
        'comment': '聊天请求',
        'msgid' : 0x060809,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'GamePlayID'),
            ('short',                      'GameID'),
            ('int',                     'RoomID'),
            ('int',                     'UserID'),
            ('string',                      'Content'),
        ], 
    },
    'Msg_RoomChat_Ret': {
        'comment': '聊天返回',
        'msgid' : 0x060809,
        'msgtype': 'read', 
        'fields': [
            ('int',                      'GamePlayID'),
            ('short',                      'GameID'),
            ('int',                     'RoomID'),
            ('int',                     'UserID'),
            ('string',                      'Content'),
        ],
    },

};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");

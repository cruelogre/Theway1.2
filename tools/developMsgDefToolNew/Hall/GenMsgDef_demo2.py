#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'HallNetModel2', 'context' : '大厅消息1.2' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_GDHallAction_send2': {
        'comment': '玩家游戏大厅操作1.2',
        'msgid' : 0x060802,
        'msgtype': 'write', 
        'fields': [
            ('char',                     'type'),
            ('int',                   'Param1'),
            ('int',                   'Param2'),
            ('int',                   'Param3'),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");

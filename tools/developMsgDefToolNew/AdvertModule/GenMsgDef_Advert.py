#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'ReqClientADInfo', 'context' : '客户端广告' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_UserSignInReq_send': {
        'comment': '请求客户端广告信息',
        'msgid' : 0x010142,
        'msgtype': 'write',
        'fields': [
            ('int', 'UserID'),
            ('int', 'GameID'),
            ('int', 'SP'),
            ('int', 'HallID'),
            ('char', 'Size'),
        ],
    },
    'Msg_RespClientADInfo_Ret': {
        'comment': '响应广告信息',
        'msgid' : 0x010143,
        'msgtype': 'read', 
        'fields': [
            ('int',             'UserID'),
            ('int',             'GameID'),
            ('loop',   {
                'loopTableKey' :           'ads',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'adID'),
                    ('string',                'name'),
                    ('string',                'picParam'),
                    ('long long',                'StartTime'),
                    ('long long',                'EndTime'),
                ],
            }),
            ('loop',   {
                'loopTableKey' :           'Counts',
                'loopReadType' :           'short',
                 'fields': [
                    ('string',             'CtrlParam'),
                ],
            }),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");

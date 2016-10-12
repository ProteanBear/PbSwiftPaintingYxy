//
//  UmengData.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/2/24.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation

class UMKeyData
{
    internal static let appKey="56e653d9e0f55aa51700205b"
    internal static let qqAppId="1105251766"
    internal static let qqAppKey="1IAQsH7p3ZEYWhQZ"
    internal static let wxAppId="wx5d92cd1d9ba9a2d2"
    internal static let wxAppSecret="9c014e3de0102c0d5e44cbc5517bf69b"
    internal static let url="http://125.67.237.140:81/zhmj/phone/welcome_paint_yxy.html"
    
    internal static let shareToSnsNames=[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToSina,UMShareToQzone]
    internal static let errorDictionary=["505":"用户被封","510":"内容不符合要求","5007":"内容为空","5016":"内容重复","5020":"无用户uid","5027":"token过期","5050":"网络错误","5051":"获取账户失败","5052":"用户取消"]
}

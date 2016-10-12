//
//  AppDelegate.swift
//  PbSwiftPaintingYxy
//
//  Created by Maqiang on 16/3/9.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import UIKit
import PbSwiftLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window?.backgroundColor=UIColor.darkGray
        
        //设置统一的显示样式
        UINavigationBar.appearance().setBackgroundImage(UIImage(named:"back_navi"), for:.default)
        
        /*初始化数据应用控制器单实例对象*/
        PbDataAppController.instance.initWithPlistName("DataConfig",initLocationManager:PbDataLocationMode.inUse)
        
        /*初始化数据用户控制器单实例对象*/
        PbDataUserController.instance.initWithPlistName("UserData")
        
        /*设置友盟分享*/
        UMSocialData.setAppKey(UMKeyData.appKey)
        UMSocialQQHandler.setQQWithAppId(UMKeyData.qqAppId, appKey:UMKeyData.qqAppKey, url:UMKeyData.url)
        UMSocialWechatHandler.setWXAppId(UMKeyData.wxAppId, appSecret:UMKeyData.wxAppSecret, url: UMKeyData.url)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return UMSocialSnsService.handleOpen(url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return UMSocialSnsService.handleOpen(url)
    }
}


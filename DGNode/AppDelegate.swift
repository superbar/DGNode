//
//  AppDelegate.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/8.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import SVProgressHUD

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        Service.default.viewModelService.resetRootViewModel(NodeListViewModel())
        
        initUMSocial()
        
        SVProgressHUD.setMaximumDismissTimeInterval(1.0)
        
        return true
    }
    
    func initUMSocial() {
        guard let socialManager = UMSocialManager.default() else { return }
        socialManager.umSocialAppkey = Configs.UMeng.appKey
        socialManager.setPlaform(.wechatSession,
                                 appKey: Configs.WeChat.appKey,
                                 appSecret: Configs.WeChat.appSecret,
                                 redirectURL: Configs.UMeng.redirectURL)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let result = UMSocialManager.default().handleOpen(url, options: options)
        return result
    }
}

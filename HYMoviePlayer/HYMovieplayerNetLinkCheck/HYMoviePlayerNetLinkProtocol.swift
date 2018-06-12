//
//  HYMoviePlayerNetLinkProtocol.swift
//  HYMoviePlayer
//
//  Created by hyw on 2018/5/8.
//  Copyright © 2018年 王海洋. All rights reserved.
//

/// 网络连接分为两种WiFi和移动数据
protocol HYMoviePlayerNetLinkListenProtocol {

    /// 链接了Wifi网络
    func hyMoviePlayerNetLinkWifi()
    /// 移动数据流量
    func hyMoviePlayerNetLinkCellular()
    /// 断开了网络连接
    func hyMoviePlayerLoseNetLink()

}

/// 播放进入后台、进入前台
protocol HYMoviePlayerEnterBackOrForegroundProtocol {
    
    /// 进入后台
    func hyMoviePlayerEnterBackground()
    /// 进入前台
    func hyMoviePlayerEnterforeground()
}
import Foundation



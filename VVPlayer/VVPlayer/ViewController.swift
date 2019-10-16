//
//  ViewController.swift
//  VVPlayer
//
//  Created by 王海洋 on 2019/10/11.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let url = "https://devstreaming-cdn.apple.com/videos/wwdc/2018/241fyqqiogmd6sv/241/hls_vod_mvp.m3u8"
        
        let playView = VVPlayerView.init(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.size.width, height: 180))
        view.addSubview(playView)
        
        playView.loadResouce(URL(string: url)!)
        
        

        
        // Do any additional setup after loading the view.
    }
}


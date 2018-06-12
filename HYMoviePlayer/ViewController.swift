//
//  ViewController.swift
//  HYMoviePlayer
//
//  Created by 王海洋 on 2018/5/7.
//  Copyright © 2018年 王海洋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var player:HYMoviePlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton.init(frame: CGRect.init(x: 100, y: 300, width: 140, height: 50))
        btn.setTitle("更换地址", for: .normal)
        btn.backgroundColor = UIColor.orange
        btn.addTarget(self, action: #selector(changeVideoAddress(btn:)), for: .touchUpInside)
        self.view.addSubview(btn)
        
        let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width*9.0/16.0)
        player = HYMoviePlayer.init(frame: frame)
        self.view.addSubview(player!)
        let videoAddress = "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"
        player?.loadVideoByAddress(videoAddress: videoAddress)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func changeVideoAddress(btn:UIButton) {
        let videoAddress = "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"

        player?.loadOthersVideoByAddress(videoAddress: videoAddress)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


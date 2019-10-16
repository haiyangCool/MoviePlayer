//
//  VVPlayerView+Guster.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/16.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit

extension VVPlayerView {
    
    func gusterExtension() {
        coverView.gusterAction = self
    }
}
extension VVPlayerView: VVPlayerGusterAction {
    
    func doubleTap(_ coverView: VVPlayerCoverView) {
        if isPlaying {
            player.pause()
        }else {
            player.play()
        }
    }
}

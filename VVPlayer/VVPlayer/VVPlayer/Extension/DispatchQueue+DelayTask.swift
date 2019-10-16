//
//  DispatchQueue+DelayTask.swift
//  MoviePlayer
//
//  Created by 王海洋 on 2018/2/20.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation

import UIKit

extension DispatchQueue {
    
    typealias Task = (_ cancel: Bool) -> Void
    func delay(_ time: TimeInterval, task: @escaping ()->()) -> Task? {
        
        func dispatch_later(_ block: @escaping ()->()) {
            let t = DispatchTime.now() + time
            self.asyncAfter(deadline: t, execute: block)
        }
        
        var closure: (()->Void)? = task
        var result: Task?
        
        let delayedClosure: Task = { cancel in
            if let internalClosure = closure {
                if cancel == false {
                    self.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        return result
    }
    
    func cancel(_ task: Task?) {
        task?(true)
    }
}

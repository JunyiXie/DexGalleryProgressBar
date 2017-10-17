//
//  ViewController.swift
//  DexGalleryProgressBarDemo
//
//  Created by 谢俊逸 on 16/10/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DexGalleryProgressBarDelegate {

    


    override func viewDidLoad() {
       super.viewDidLoad()
       let bar = DexGalleryProgressBar(frame: CGRect(x: 0, y: 20, width: 375, height: 40) , progressBarLength: 375, photoCount: 10)
        bar.delegate = self
       self.view.addSubview(bar)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "progressBarStateDidNeedChange"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var i = 0

    @IBAction func leftClick(_ sender: Any) {
        
        if i <= 29 && i > 0 {
            i = i - 1
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "progressBarStateDidNeedChange"), object: nil)
        
    }
    @IBAction func rightClick(_ sender: Any) {
        if i < 29 && i >= 0 {
            i = i + 1
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "progressBarStateDidNeedChange"), object: nil)
    
    }
    
    func photoCount() -> Int {
        return 30
    }
    
    
    // 可以和Scroll 绑定 实现 滑动的时候滑块才会现实
    func scrollState() -> Bool {
        return true
    }
    
    func currentIdx() -> Int {
        return i
    }
    
    func  dateString() -> String {
        return "123456"
    }
    
    func isEntryPhoto() -> Bool {
        return false
    }
    
    
    

}


//
//  ViewController.swift
//  SlideAuthorizon
//
//  Created by lotawei on 2018/1/30.
//  Copyright © 2018年 lotawei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var  aview:ManualView = {
       return  ManualView.shareview
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.aview)
        aview.frame = CGRect.init(x:0, y: 100, width: 300, height: 300)
        //配置图片 然后要扣去的大小
        aview.setimageview(#imageLiteral(resourceName: "codeimg"), CGSize.init(width: 70, height: 70))
        aview.center = view.center
        // Do any additional setup after loading the view, typically from a nib.
    }


}


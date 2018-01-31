//
//  ViewController.swift
//  SlideAuthorizon
//
//  Created by lotawei on 2018/1/30.
//  Copyright © 2018年 lotawei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var  circleview:UIView!
    var islight:Bool = false {
        didSet{
            changeTheme()
        }
    }
    @IBAction func sendaction(_ sender: ExpandAnimateButton) {
        sender.animateTouchUpInside {
            print("fuck")
            self.circleview.animateCircular(withDuration: 0.2, center: self.circleview.center, animations: {
                 self.islight = !self.islight
            })
            
        }
    }
    func   changeTheme(){
        
        self.circleview.backgroundColor = islight ? UIColor.orange : UIColor.black
        
    }
    
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
        
//        sendbutton.animateTouchUpInside {
//
//            print("哈哈哈")
//
//
//        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }


}


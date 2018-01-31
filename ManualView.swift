//
//  ManualView.swift
//  SlideAuthorizon
//
//  Created by lotawei on 2018/1/30.
//  Copyright © 2018年 lotawei. All rights reserved.
//

import Foundation
import UIKit

//目前支持两种 从左滑到右的 点击的
enum  ManualType:Int{
    case  leftrightslide=0,clickmusic
}
protocol PanViewDelegate {
    func     poschange(_ pos:CGPoint)
    //每次end产生一个结果
    func    isendchange( ispass:Bool , _ usetime:String)
    
}
//一个元组  右边界 用于记录 图片大小的位置 和 抠出方块的x起点位置
var   targetpos:(CGFloat,CGFloat) = (0,50)
extension  CGPoint {
    static  func  checkinValue(_ prevalue:Int,px1:CGFloat,px2:CGFloat) -> Bool{
        let  hasx = abs(Int32( px1 - px2))
        if hasx < Int32(prevalue){
            return true
        }
        return  false
    }
}
extension Date{
    //返回两个时间差值的毫秒数 最先的时间 之后的时间
    static  func   -(_ before:Date,_ lasttime:Date) -> Double {
        let  res = lasttime.timeIntervalSince1970 - before.timeIntervalSince1970
        return  abs(res)
        
    }
}
extension  String{
    static  func  distime(_ usertime:Double)->String{
        var  res = "超越10%玩家"
        
        if  usertime > 1.5{
            res = String.init(format: "用时%.1f秒超越20%玩家", usertime)
            
        }
        else if usertime < 1.0{
            res =  String.init(format: "用时%.1f秒超越97%玩家", usertime)
            
        }
        else {
           res =  String.init(format: "用时%.1f秒超越90%玩家", usertime)
            
        }
        return res
    }
}


class  PanView:UIView{
 
    var   delegate:PanViewDelegate?
    private  var  originalcentx:CGFloat = 0
    //目标矩形框
    private  var  tartrec:CGRect = CGRect.zero
    //当前移动的矩形框
    private  var  currect:CGRect = CGRect.zero
    var   begindata:Date!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //改变x
        originalcentx = self.center.x
        begindata = Date()
        
        
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pos    = touches.first?.location(in: self.superview)
        
        let asuperview = self.superview!
        let  maxx = asuperview.frame.size.width
        
        if  (pos?.x)! <= maxx - self.frame.size.width{
            
            self.frame.origin.x =  (pos?.x)!
        }
        else{
            self.frame.origin.x =   maxx - self.frame.size.width
        }
        //记录当前的矩形框
        currect  = CGRect.init(x:  self.frame.origin.x, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        
        if  delegate  != nil {
            
            
            self.delegate?.poschange(pos!)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        let pos    = touches.first?.location(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 1, options: .curveLinear, animations: {() -> Void in
                self.center.x = self.originalcentx
        })
//        这种是纯计算的方式
//        let  ispass = CGPoint.checkinValue(2, px1: pos!.x, px2: targetpos.0)
  //    也可以联合两个rect查看是否在
        let  rec1 = CGRect.init(x: currect.minX ,y: currect.minY, width: targetpos.1, height: targetpos.1)
        let  tartgetrec = CGRect.init(x: targetpos.0, y: rec1.minY, width: targetpos.1, height: targetpos.1)
        let   unionrec = rec1.union(tartgetrec)
        var  ispass = false
        var  res = ""
        if  unionrec.width >= targetpos.1 &&  unionrec.width <= targetpos.1 + 4{
            let  enddate = Date()
            let  fixtime = enddate - begindata
            res =  String.distime(fixtime)
            
            
            
            ispass = true
        }
        if  delegate != nil {
            
            self.delegate?.isendchange(ispass: ispass,res)
        }
    }
    override func awakeFromNib() {
        clipsToBounds = true
        layer.cornerRadius = 15
        backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
    func   setdelegate(_ delegate:PanViewDelegate){
        self.delegate = delegate
    }
}
class  ManualView:UIView,PanViewDelegate{
    private var  originalx:CGFloat = 10
    private  var  originaly:CGFloat = 0
    @IBOutlet weak var panview: PanView!
    @IBOutlet weak var codeimg: UIImageView!
    //需要移动的滑块
    lazy  var   movesizeview:UIImageView = {
        let  aview = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        return aview
    }()
    lazy  var   fadeview:UIView = {
        let  aview = UIView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        aview.alpha = 0.5
        aview.backgroundColor = UIColor.white
        return aview
    }()
    lazy  var   lbldisname:UILabel = {
        let  alable = UILabel(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        alable.backgroundColor = UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 0.9)
        alable.font = UIFont.systemFont(ofSize: 14)
        alable.layer.borderColor = UIColor.black.cgColor
        alable.layer.borderWidth = 3.0
        alable.textAlignment = .right
        alable.textColor = UIColor.orange
        return alable
    }()
    static  let  shareview:ManualView = {
        let aview = Bundle.main.loadNibNamed("ManualView", owner: nil, options: nil)?.first as! ManualView
        return  aview
    }()
    @IBOutlet weak var   slideview:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    func  setimageview(_ codeimg:UIImage,_ targetsize:CGSize){
        movesizeview.frame.size = targetsize
        
        let   disimage = UIImage.convertView(toImage: self.codeimg)
        //产生随机数的间距
        var rightpadding:CGFloat = 80
        let  randpading:CGFloat = CGFloat(arc4random_uniform(100) )
        rightpadding = rightpadding+randpading
        let  atrrec = CGRect.init(x: self.codeimg.frame.size.width - rightpadding, y: self.codeimg.center.y - targetsize.height/2.0 , width: targetsize.width, height: targetsize.height)
        movesizeview.image = UIImage.clipfacnewimage(disimage, atrrec)
        //带阴影的区域
        fadeview.frame = atrrec
        movesizeview.frame.origin = CGPoint.init(x: originalx, y: atrrec.minY)
        self.panview.delegate = self
        
        //更改全局的位置信息
        targetpos.0 = self.codeimg.frame.size.width - rightpadding
        targetpos.1 = targetsize.width
    }
    override func draw(_ rect: CGRect) {
        debugPrint("draw")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        debugPrint("awakeFromNib")
        
        slideview.clipsToBounds  = true
        slideview.layer.cornerRadius = 15
        self.codeimg.addSubview(movesizeview)
        self.codeimg.addSubview(fadeview)
        self.codeimg.addSubview(lbldisname)
       
        lbldisname.alpha = 0
        
    }
    override func layoutSubviews() {
        lbldisname.frame  = CGRect.init(x: 3, y: self.codeimg.frame.maxY - 46, width:self.codeimg.frame.size.width - 6 , height: 40)
    }
    /// 获取到的坐标改变
    ///
    /// - Parameter pos: 移动到的坐标
    func poschange(_ pos: CGPoint) {
        self.movesizeview.frame.origin.x = pos.x
    }
    func isendchange(ispass: Bool,_ usertime:String) {
        if  ispass {
            
            print("验证成功")
            //fadeview的动画
           self.lbldisname.text = "恭喜验证成功!" + usertime
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 1, options: .curveLinear, animations: {() -> Void in
                self.movesizeview.frame.origin.x = self.originalx
                self.movesizeview.transform  = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
                self.movesizeview.transform  = CGAffineTransform.identity
                
                self.fadeview.transform  = CGAffineTransform.init(scaleX: 2, y: 1)
                self.fadeview.transform  = CGAffineTransform.init(scaleX: 0.5, y: 1)
                self.fadeview.transform  = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            
            UIView.animate(withDuration: 3.0, animations: {
                self.lbldisname.alpha = 1.0
            }, completion: { (finish) in
                self.lbldisname.alpha = 0.0
                self.lbldisname.text = ""
            })
            setimageview(codeimg.image!, CGSize.init(width: targetpos.1, height: targetpos.1))
            
        }else{
           self.lbldisname.text = "拼图被👾吃掉了"
           UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 1, options: .curveLinear, animations: {() -> Void in
                self.movesizeview.frame.origin.x = self.originalx
                self.fadeview.transform  = CGAffineTransform.init(scaleX: 2, y: 1)
                self.fadeview.transform  = CGAffineTransform.init(scaleX: 0.5, y: 1)
                self.fadeview.transform  = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            UIView.animate(withDuration: 3.0, animations: {
                self.lbldisname.alpha = 1.0
                
            }, completion: { (finish) in
                self.lbldisname.alpha = 0.0
                self.lbldisname.text = ""
            })
        }
    }
}

extension  UIImage {
    static   func  clipfacnewimage(_ orimg:UIImage,_ rec:CGRect) -> UIImage {
       let   ref =  orimg.cgImage!.cropping(to: rec)
        let  scal = UIImage.init(cgImage: ref!)
   
        return  scal
        
        
    }
   static   func convertView(toImage v: UIView) -> UIImage {
        let s: CGSize = v.frame.size
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
        UIGraphicsBeginImageContextWithOptions(s, true, UIScreen.main.scale)
        v.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}


//
//  PhotoGalleryProgressBar.swift
//  Apollon
//
//  Created by 谢俊逸 on 19/07/2017.
//  Copyright © 2017 njsqrt3. All rights reserved.
//

import UIKit



class LCTextLayer : CATextLayer {
    
    // REF: http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
    // CREDIT: David Hoerl - https://github.com/dhoerl
    // USAGE: To fix the vertical alignment issue that currently exists within the CATextLayer class. Change made to the yDiff calculation.

    override func draw(in ctx: CGContext) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/10
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}


@objc protocol DexGalleryProgressBarDelegate {
    func scrollState() -> Bool
    func currentIdx() -> Int
    func dateString() -> String
    func photoCount() -> Int
    func isEntryPhoto() -> Bool
}


class DexGalleryProgressBar: UIView {
    
   
    weak var delegate: DexGalleryProgressBarDelegate?
    
    fileprivate var progressLineContainer: UIView = {
        var view = UIView()
        view.layer.backgroundColor = UIColor.gray.cgColor
        return view
    }()
   
    fileprivate var progressLine: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.yellow.cgColor
        
        return layer
    }()
    

    fileprivate var dateLayer: LCTextLayer = {
        var layer = LCTextLayer()
        layer.backgroundColor = UIColor.gray.cgColor
        layer.foregroundColor = UIColor.black.cgColor
        
        // Text
        layer.alignmentMode = kCAAlignmentCenter
        let font = UIFont.systemFont(ofSize: 12)
        let fontName = font.fontName
        layer.font = font
        layer.fontSize = font.pointSize
        layer.contentsScale = UIScreen.main.scale
        // shape 
        let maskPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 43, height: 20), byRoundingCorners: .bottomRight, cornerRadii: CGSize(width: 4, height: 4))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: 43, height: 20)
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
        // border
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskPath.cgPath
        borderLayer.lineWidth = 1.0
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)

        return layer
    }()

    private var myContext = 0
    
    /// determine progressline and datelayer frame
    var currentIdx: Int = -1 {
        didSet {
                // ProgressLine
                progressLine.frame = CGRect(x: progressState.getX(photoIdx: currentIdx), y: 0, width: Double(progressState.perSegementWidth), height: 5)
                // dateLayer
                dateLayer.frame = CGRect(x: dateState.getX(idx: currentIdx), y: 6, width: 43, height: 20)
        }
    }
    /// manager progressline info
    var progressState: ProgressState
    /// manager dateLayer info
    @objc dynamic var dateState: DateState
    /// manager scorll state
    @objc dynamic var scrollInfluence: ScrollInfluence
    
    @objc dynamic var inOutInfulence: InOutInfuence = InOutInfuence()

    init(frame: CGRect, progressBarLength: Double, photoCount: Int) {
        // Dex Progress Bar 初始化
        let albumInfluence = AlbumInfulence(photoCount: photoCount)
        self.progressState = ProgressState(viewWidth: progressBarLength, albumInfulence: albumInfluence)
        self.dateState = DateState(dateString: "", progressState: self.progressState)
        self.scrollInfluence = ScrollInfluence()
        super.init(frame: frame)
        
        // view
        self.layer.opacity = 0.0
        self.layer.masksToBounds = true
        self.progressLineContainer.frame = CGRect(x: 0, y: 0, width: frame.width, height: 5)
        self.addSubview(progressLineContainer)
        self.layer.addSublayer(dateLayer)
        self.progressLineContainer.layer.addSublayer(progressLine)
        
        
        // text
        dateLayer.string = dateState.dateString
        
        // 状态Update
        NotificationCenter.default.addObserver(self, selector: #selector(progressBarStateDidNeedChange), name: NSNotification.Name("progressBarStateDidNeedChange"), object: nil)
        // isScroll
        NotificationCenter.default.addObserver(self, selector: #selector(isScrollStateChange(notification:)), name: Notification.Name("isScrollStatechange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDateString(notification:)), name: NSNotification.Name("dateStringUpdate"), object: nil)
        
    }
   

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
        }
    }
    
}



extension DexGalleryProgressBar {
    func getOpaqueAnimation() -> CABasicAnimation {
        return {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.2
            animation.setValue("opaqueAnimation", forKey: "key")
            return animation
        }()
    }
    
    func getTransparentAnimation() -> CABasicAnimation {
        return {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = 0.3
            animation.setValue("transparentAnimation", forKey: "key")
            return animation
        }()
    }
    
    func getTransparentKeyAnimation() -> CAKeyframeAnimation {
        return {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            animation.values = [1,1,0]
            animation.duration = 0.65
            animation.keyTimes = [0,0.48,1.0]
            animation.isAdditive = true
            animation.setValue("transparentKeyAnimation", forKey: "key")
            return animation
        }()
    }
    
    func geteEntryOpaqueAnimation() -> CAKeyframeAnimation {
        return {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            animation.values = [0,1,0]
            animation.duration = 0.7
            animation.keyTimes = [0,0.6,1.0]
            animation.isAdditive = true
            animation.setValue("entryOpaqueAnimation", forKey: "key")
            return animation
        }()
    }
    
}

// MARK: - CAAnimationDelegate

extension DexGalleryProgressBar: CAAnimationDelegate {
    //Mark: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if anim.value(forKey: "key") as! String == "transparentAnimation" {
            
            return
        }
        
        if anim.value(forKey: "key") as! String == "opaqueAnimation" {
            
            return
        }
        
        
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        if anim == self.layer.animation(forKey: "transparent") {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.layer.opacity = 0
            CATransaction.commit()
            return
        }
        
        if anim == self.layer.animation(forKey: "opaque") {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.layer.opacity = 1
            CATransaction.commit()
            return
        }
    }
}


// MARK: - Notification Action
extension DexGalleryProgressBar {
    
    /// scrollview dragging change notification action
    @objc func progressBarStateDidNeedChange(notification: Notification) {
        //⚠️: photoCount 要在 currentIdx 之前从代理更新
        progressState.albumInfulence.photoCount = (delegate?.photoCount())!
        currentIdx = (delegate?.currentIdx())!
        dateState.dateString = (delegate?.dateString())!
        scrollInfluence.isScroll = (delegate?.scrollState())!
        inOutInfulence.isEntry = (delegate?.isEntryPhoto())!
    }
    /// crollInfulence isScroll change notification action
    @objc func isScrollStateChange(notification:Notification) {
        if let userInfo = notification.userInfo {
            
            if let isScroll = userInfo["isScroll"] as? Bool {
                if isScroll == true {
                    // normal scroll
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    let opaqueAnimation = self.getOpaqueAnimation()
                    opaqueAnimation.delegate = self
                    self.layer.add(opaqueAnimation, forKey: "opaque")
                    CATransaction.commit()
                } else {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    let transparentAnimation = self.getTransparentKeyAnimation()
                    transparentAnimation.delegate = self
                    self.layer.add(transparentAnimation, forKey: "transparent")
                    CATransaction.commit()
                }
            }
        }
    }
    /// datestate datestring change notification action
    @objc func updateDateString(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let dateString = userInfo["dateString"] as? String {
                dateLayer.string = dateString
            }
        }
        
    }
    
}



class ProgressState : NSObject {
    var idx: Int = 0
    var viewWidth: Double
    var albumInfulence: AlbumInfulence
    var perSegementWidth: Double {
        get {
            return viewWidth/Double(albumInfulence.realSegmentCount)
        }
    }
    func getX(photoIdx: Int) -> Double {
        return Double(photoIdx/albumInfulence.numberOfPhotoPerSegment) * perSegementWidth
    }
    
    init(viewWidth: Double, albumInfulence: AlbumInfulence) {
        self.viewWidth = viewWidth
        self.albumInfulence = albumInfulence
    }
}


// DateState 根据 ProgressState 来决定
class DateState : NSObject {

    let dateLayerWidth: Double = 43
    var progressLineLength: Double
    var dateString: String {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("dateStringUpdate"), object: nil, userInfo: ["dateString":dateString])
        }
    }
    
    var progressState: ProgressState
    func getX(idx: Int) -> Double {
        
        // 决定 日期模块 X 的核心因素 1. dateLayerWidth 2. persegementWidth 3. idx
        // 两端 dateLayer 不能再移动问题
        if dateLayerWidth > progressState.perSegementWidth {
           
            // 正常计算
            // 进度条center.x > dateLayerwidth/2
            if progressState.getX(photoIdx: idx) + progressState.perSegementWidth/2 >= dateLayerWidth/2 {
                
                // 右端处理
                // 如果 progress.x + dalyerWidth >= viewWidth 则datelayerview 固定在末尾
                if progressState.getX(photoIdx: idx) + dateLayerWidth >= progressLineLength {
                    return progressLineLength - dateLayerWidth
                }
                
                return progressState.getX(photoIdx:idx) + progressState.perSegementWidth/2 - dateLayerWidth/2
            } else {
                //左端处理
                return 0
            }
            
            
        }
        // 1. 照片密集度不大，则正常处理，也就是中心对其在进度条的一半
        return progressState.getX(photoIdx:idx) + progressState.perSegementWidth/2 - dateLayerWidth/2
        
        
        
        
    }
    
    init(dateString: String,progressState: ProgressState) {
        self.dateString = dateString
        self.progressLineLength = progressState.viewWidth
        self.progressState = progressState
    }
    
}


class AlbumInfulence : NSObject {
    var photoCount: Int
    let estimationPerPhotoCanScrollCount: Int = 75
    
    // 计算多少张照片一个分组
    var numberOfPhotoPerSegment: Int {
        get {
            
            // 大于预估值判断能否整除
            if photoCount > estimationPerPhotoCanScrollCount {
                // 例如 300 个 photo 那么 300%75==0 代表着 4个一组就可以
                if photoCount % estimationPerPhotoCanScrollCount == 0 {
                    return photoCount/estimationPerPhotoCanScrollCount
                } else {
                    // 向上取整
                    // 301%75 != 0 那么 为了保证质量，则取5个一组
                    return photoCount/estimationPerPhotoCanScrollCount + 1
                }
            }
            
            // 小于直接1
            return 1
            
        }
    }
    
    // 真正可以多少个分组（滑动）
    var realSegmentCount: Int {
        get {
            // 大于预估值判断分组数
            if photoCount > estimationPerPhotoCanScrollCount {
                if photoCount % estimationPerPhotoCanScrollCount == 0 {
                    return photoCount/numberOfPhotoPerSegment
                } else {
                    return photoCount/numberOfPhotoPerSegment + 1
                }
            }
            return photoCount/numberOfPhotoPerSegment
        }
    }
    
    init(photoCount: Int) {
        self.photoCount = photoCount
    }
}

class PhotoInfulence : NSObject {
    let isMarked: Bool
    let isLivePhoto: Bool
    
    init(isMarked: Bool, isLivePhoto: Bool) {
        self.isMarked = isMarked
        self.isLivePhoto = isLivePhoto
    }
    
}

class ScrollInfluence : NSObject {
    var isScroll: Bool = false {
        didSet {
            if isScroll != oldValue {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isScrollStatechange"), object: nil, userInfo: ["isScroll": isScroll])
            }
        }
    }
    
    var scrollDirection: PhotoScrollDirection
    var targetRatio: Double
    override init() {
        scrollDirection = .Right
        targetRatio = 0.0
        isScroll = false
    }
}

class InOutInfuence: NSObject {
    @objc dynamic var isEntry: Bool = false
}

enum PhotoScrollDirection {
    case Left
    case Right
}


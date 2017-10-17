# DexGalleryProgressBar
A ProgressBar For Gallery ...

**Demo**

![static](https://github.com/JunyiXie/DexGalleryProgressBar/raw/master/readme_resources/demo.gif)

### 特征

1. CoreAnimation 动画
2. 滑动时显示进度条/时间块
3. 滑动条&时间块 联动处理
4. 大量照片情况下 滑动条长度处理
5. 大量照片情况下 滑动条 n次滑动照片/一次进度条移动处理
6. 滑块&进度条 边界情况处理

### 图示

![scroll](https://github.com/JunyiXie/DexGalleryProgressBar/raw/master/readme_resources/scroll.PNG)
![static](https://github.com/JunyiXie/DexGalleryProgressBar/raw/master/readme_resources/static.PNG)


### 使用

1. **创建Bar**
- progressBarLength bar的长度
- photoCount 照片总数

```swift
       let bar = DexGalleryProgressBar(frame: CGRect(x: 0, y: 20, width: 375, height: 40) , progressBarLength: 375, photoCount: 10)
       self.view.addSubview(bar)
```

2. **设置代理**
`DexGalleryProgressBarDelegate`

```swift
   bar.delegate = self
```

```swift

    func photoCount() -> Int {
        return 10
    }
    // 可以和Scroll 绑定 实现 滑动时显示
    func scrollState() -> Bool {
        return true
    }
    
    // 当前照片的idx
    // 需要自己计算
    func currentIdx() -> Int {
        return i
    }
    
    func  dateString() -> String {
        return "date"
    }
    
    func isEntryPhoto() -> Bool {
        return false
    }
```

3. **设置滑动通知**
放在`UIScrollViewDelegate` 的 `scrollviewdidScroll` 中即可
```swift
   NotificationCenter.default.post(name: NSNotification.Name(rawValue: "progressBarStateDidNeedChange"), object: nil)
```

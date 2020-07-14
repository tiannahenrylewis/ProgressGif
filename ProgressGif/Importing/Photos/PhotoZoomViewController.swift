//
//  PhotoZoomViewController.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit
import Photos

protocol PhotoZoomViewControllerDelegate: class {
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView)
}

class PhotoZoomViewController: UIViewController {
    
    var hasInitializedPlayer = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: PhotoZoomViewControllerDelegate?
//
    var index: Int = 0
    var asset: PHAsset!
    var imageSize: CGSize = CGSize(width: 0, height: 0)
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }

    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        if #available(iOS 11, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: PHImageRequestOptions()) { (image, userInfo) -> Void in
            if let image = image {
                
                    self.imageView.image = image
                    let rectFrame = CGRect(x: self.baseView.frame.origin.x,
                    y: self.baseView.frame.origin.y,
                    width: self.targetSize.width,
                    height: self.targetSize.width)
                    
                    print("rectFrame: \(rectFrame)")
                    self.imageView.frame = rectFrame
                    
            }
        }
        
        
        self.view.addGestureRecognizer(self.doubleTapGestureRecognizer)
        
//        playVideo()
    }
    
    func playVideo() {
        print("playing viewd")
        if !hasInitializedPlayer {
            hasInitializedPlayer = true
            
            UIView.animate(withDuration: 0.2, animations: {
                self.imageView.alpha = 0
            })
            
            playerView.startPlay(with: asset)
        } else {
            playerView.play()
        }
    }
    
    func pauseVideo() {
        playerView.pause()
    }
    func stopVideo() {
        playerView.pause()
        playerView.player = nil
        hasInitializedPlayer = false
        self.imageView.alpha = 1
    }
    func jumpForward5() {
        hasInitializedPlayer = true
        self.imageView.alpha = 0
        playerView.startPlay(with: asset, shouldJumpForward5: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func didDoubleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        let pointInView = gestureRecognizer.location(in: self.baseView)
        var newZoomScale = self.scrollView.maximumZoomScale
        
        if self.scrollView.zoomScale >= newZoomScale || abs(self.scrollView.zoomScale - newZoomScale) <= 0.01 {
            newZoomScale = self.scrollView.minimumZoomScale
        }
        
        let width = self.scrollView.bounds.width / newZoomScale
        let height = self.scrollView.bounds.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
        self.scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
}

extension PhotoZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return baseView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.photoZoomViewController(self, scrollViewDidScroll: scrollView)
    }
}

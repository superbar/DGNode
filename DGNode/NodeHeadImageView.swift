//
//  NodeHeadImageView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import PureLayout

class NodeHeadImageView: UIView, UIScrollViewDelegate {

    let scrollView = UIScrollView()
    let imageContainerView = UIView()
    let imageView = UIImageView()
    let deleteHeadImageButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200.0)
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.scrollsToTop = false
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = false
        scrollView.clipsToBounds = true
        scrollView.frame = frame
        addSubview(scrollView)
        
        imageContainerView.clipsToBounds = true
        scrollView.addSubview(imageContainerView)
        
        imageContainerView.addSubview(imageView)
        
        deleteHeadImageButton.tintColor = .black
        deleteHeadImageButton.setBackgroundImage(#imageLiteral(resourceName: "close"), for: .normal)
        addSubview(deleteHeadImageButton)
        
        deleteHeadImageButton.frame.size = CGSize(width: 16, height: 16)
        deleteHeadImageButton.right = frame.width - 12
        deleteHeadImageButton.bottom = frame.height - 12
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            let touchPoint = gesture.location(in: scrollView)
            let zoomScale = scrollView.maximumZoomScale
            let x = width / zoomScale
            let y = height / zoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - x / 2, y: touchPoint.y - y / 2, width: x, height: y), animated: true)
        }
    }
    
    func setImage(_ image: UIImage?) {
        guard let image = image else { return }
        scrollView.setZoomScale(1.0, animated: false)
        scrollView.maximumZoomScale = 1
        imageView.image = image
        scrollView.maximumZoomScale = 3
        resize()
    }

    func resize() {
        imageContainerView.frame.origin = .zero
        imageContainerView.width = width
        
        guard let image = imageView.image else { return }
        if image.size.height / image.size.width > height / width {
            imageContainerView.height = floor(image.size.height / (image.size.width / width))
        } else {
            var height = image.size.height / image.size.width * width
            if height < 1 || height.isNaN {
                height = self.height
            }
            height = floor(height)
            imageContainerView.height = height
            imageContainerView.center.y = self.height / 2
        }
        if imageContainerView.height > height && imageContainerView.height - height <= 1 {
            imageContainerView.height = self.height
        }
        scrollView.contentSize = CGSize.init(width: width, height: max(imageContainerView.height, height))
        scrollView.scrollRectToVisible(bounds, animated: false)
        
        if imageContainerView.height <= height {
            scrollView.alwaysBounceVertical = false
        } else {
            scrollView.alwaysBounceVertical = true
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageView.frame = imageContainerView.bounds
        CATransaction.commit()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let frame = scrollView.bounds
        let size = scrollView.contentSize
        let offsetX = (frame.width > size.width) ? (frame.width - size.width) * 0.5 : 0.0;
        let offsetY = (frame.height > size.height) ? (frame.height - size.height) * 0.5 : 0.0;
        imageContainerView.center = CGPoint(x: size.width * 0.5 + offsetX, y: size.height * 0.5 + offsetY);
    }
}

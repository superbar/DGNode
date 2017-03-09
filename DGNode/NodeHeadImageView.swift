//
//  NodeHeadImageView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import PureLayout

class NodeHeadImageView: UIScrollView, UIScrollViewDelegate {

    let imageContainerView = UIView()
    let imageView = UIImageView()
    let addImageButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        delegate = self
        maximumZoomScale = 3
        minimumZoomScale = 1
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = true
        scrollsToTop = false
        bouncesZoom = true
        alwaysBounceVertical = false
        clipsToBounds = true
        
        imageContainerView.clipsToBounds = true
        addSubview(imageContainerView)
        
        imageContainerView.addSubview(imageView)
        
        addImageButton.setTitle("添加题图", for: .normal)
        addImageButton.setTitleColor(.black, for: .normal)
        addImageButton.layer.borderColor = UIColor.black.cgColor
        addImageButton.layer.borderWidth = 1.0
        addSubview(addImageButton)
        
    }
    
    func setFrame(frame: CGRect) {
        self.frame = frame
        
        addImageButton.frame.size = CGSize.init(width: frame.width - 48, height: frame.height - 48)
        addImageButton.top = 24
        addImageButton.left = 24
        
        imageContainerView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        guard let image = image else { return }
        setZoomScale(1.0, animated: false)
        maximumZoomScale = 1
        imageView.image = image
        maximumZoomScale = 3
        resize()
    }

    func resize() {
        imageContainerView.frame = bounds
        guard let image = imageView.image else { return }
        if (image.size.height / image.size.width > frame.height / frame.width) {
            imageContainerView.frame.size.height = floor(image.size.height / (image.size.width / frame.width));
        } else {
            var height = image.size.height / image.size.width * frame.width;
            if (height < 1 || height.isNaN) {
                height = frame.height
            }
            imageContainerView.frame.size.height = floor(height)
            imageContainerView.center.y = frame.height / 2
        }
        if (imageContainerView.frame.height > frame.height && imageContainerView.frame.height - frame.height <= 1) {
            imageContainerView.frame.size.height = frame.height
        }
        contentSize = CGSize(width: frame.width, height: max(imageContainerView.frame.height, frame.height))
        scrollRectToVisible(bounds, animated: false)
        
        if (imageContainerView.frame.height <= frame.height) {
            alwaysBounceVertical = false
        } else {
            alwaysBounceVertical = true
        }
        imageView.frame = imageContainerView.bounds
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
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

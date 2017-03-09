//
//  ShareBoardView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import PureLayout
import Photos
import SVProgressHUD

class ShareBoardView: UIView {

    let shareItem: [ShareBoardItem]
    let shareScrollView = UIScrollView()
    let otherActionsScrollView = UIScrollView()
    var shareImage: UIImage?
    
    override init(frame: CGRect) {
        
        shareItem =
            [ShareBoardItem(title: "分享到朋友圈", image: nil, plaform: .wechatTimeLine),
             ShareBoardItem(title: "分享到微信好友", image: nil, plaform: .wechatTimeLine),
             ShareBoardItem(title: "分享到新浪微博", image: nil, plaform: .wechatTimeLine),
             ShareBoardItem(title: "分享到QQ", image: nil, plaform: .wechatTimeLine)]
        super.init(frame: frame)
        
        shareScrollView.showsVerticalScrollIndicator = false
        shareScrollView.showsHorizontalScrollIndicator = false
        addSubview(shareScrollView)
    
        otherActionsScrollView.showsVerticalScrollIndicator = false
        otherActionsScrollView.showsHorizontalScrollIndicator = false
        addSubview(otherActionsScrollView)
        
        shareScrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        shareScrollView.autoSetDimension(.height, toSize: 105)
        
        otherActionsScrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        otherActionsScrollView.autoSetDimension(.height, toSize: 105)
        
        let btnWidth: CGFloat = 83.0
        let btnHeight: CGFloat = 81.5
        let left: CGFloat = 12.0
        
        for (index, value) in shareItem.enumerated() {
            let button = UIButton()
            button.setTitle(value.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.layer.borderWidth = 1.0
            button.layer.borderColor =  UIColor.black.cgColor
            button.tag = value.plaform.rawValue
            button.frame = CGRect(x: left + (btnWidth + left) * CGFloat(index), y: 12, width: btnWidth, height: btnHeight)
            button.addTarget(self, action: #selector(share(button:)), for: .touchUpInside)
            shareScrollView.addSubview(button)
        }
        
        shareScrollView.contentSize = CGSize(width: (btnWidth + 12.0) * CGFloat(shareItem.count) + 12.0, height: 0);
        
        setOtherActions(actions: [ShareBoardItem(title: "保存图片到相册", image: nil, otherAction: .saveToPhotoLibrary)])
    }
    
    func setOtherActions(actions: [ShareBoardItem]) {
        
        let btnWidth: CGFloat = 83.0
        let btnHeight: CGFloat = 81.5
        let left: CGFloat = 12.0
        
        for (index, value) in actions.enumerated() {
            let button = UIButton()
            button.setTitle(value.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.layer.borderWidth = 1.0
            button.layer.borderColor =  UIColor.black.cgColor
            button.tag = value.otherAction.rawValue
            button.frame = CGRect(x: left + (btnWidth + left) * CGFloat(index), y: 12, width: btnWidth, height: btnHeight)
            button.addTarget(self, action: #selector(saveImageToDisk), for: .touchUpInside)
            otherActionsScrollView.addSubview(button)
        }
        
        otherActionsScrollView.contentSize = CGSize(width: (btnWidth + 12.0) * CGFloat(shareItem.count) + 12.0, height: 0);
    }
    
    func share(button: UIButton) {
        guard let platfrom = UMSocialPlatformType(rawValue: button.tag) else { return }
        shareImageAndTextToPlatformType(platformType: platfrom)
    }
    
    func shareImageAndTextToPlatformType(platformType: UMSocialPlatformType) {
        let msgObj = UMSocialMessageObject()
        
        let shareObject = UMShareImageObject()
        shareObject.shareImage = shareImage
        
        msgObj.shareObject = shareObject
        
        UMSocialManager.default().share(to: platformType, messageObject: msgObj, currentViewController: self) { (data, error) in
            
        }
    }
    
    func saveImageToDisk() {
        guard ImagePickerController.available(source: .savedPhotosAlbum) else { return }
        
        PHPhotoLibrary.shared().performChanges({ 
            guard let image = self.shareImage else { return }
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            if success {
                SVProgressHUD.showSuccess(withStatus: "保存成功")
            } else {
                SVProgressHUD.showError(withStatus: "保存失败")
            }
        }
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

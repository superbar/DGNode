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
import ReactiveCocoa
import ReactiveSwift
import Result

class ShareBoardView: UIView {

    let shareItem: [ShareBoardItem]
    let shareScrollView = UIScrollView()
    let otherActionsScrollView = UIScrollView()
    var shareImage: UIImage?
    let line = UIView()
    
    let closeShareBoardSignal: Signal<Void, NoError>
    private let closeShareBoardObserver: Observer<Void, NoError>
    
    
    override init(frame: CGRect) {
        (closeShareBoardSignal, closeShareBoardObserver) = Signal<Void, NoError>.pipe()

        shareItem =
            [ShareBoardItem(title: "微信好友", image: #imageLiteral(resourceName: "share_wechat"), plaform: .wechatSession),
             ShareBoardItem(title: "朋友圈", image: #imageLiteral(resourceName: "shareToWCSession"), plaform: .wechatTimeLine)]
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 210))
        
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
        
        let btnWidth: CGFloat = 60.0
        let btnHeight: CGFloat = 60.0
        let left: CGFloat = 12.0
        
        for (index, value) in shareItem.enumerated() {
            let button = UIButton()
            button.setImage(value.image, for: .normal)
            button.setBackgroundImage(#imageLiteral(resourceName: "sharemore_other"), for: .normal)
            button.setBackgroundImage(#imageLiteral(resourceName: "sharemore_other_HL"), for: .highlighted)
            button.tag = value.plaform.rawValue
            button.frame = CGRect(x: left + (btnWidth + left) * CGFloat(index), y: 12, width: btnWidth, height: btnHeight)
            button.addTarget(self, action: #selector(share(button:)), for: .touchUpInside)
            shareScrollView.addSubview(button)
            
            let titleLabel = UILabel()
            titleLabel.text = value.title
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.width = button.width
            titleLabel.textColor = UIColor(red: 143/255, green: 143/255, blue: 148/255, alpha: 1.0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.sizeToFit()
            titleLabel.center.x = button.center.x
            titleLabel.top = button.bottom + 5.0
            shareScrollView.addSubview(titleLabel)
        }
        
        shareScrollView.contentSize = CGSize(width: (btnWidth + 12.0) * CGFloat(shareItem.count) + 12.0, height: 0);
        
        setOtherActions(actions: [ShareBoardItem(title: "保存到相册", image: #imageLiteral(resourceName: "sharemore_download"), otherAction: .saveToPhotoLibrary)])
        
        line.backgroundColor = UIColor.lightGray
        line.frame = CGRect.init(x: 12, y: 105, width: self.frame.width - 12, height: 0.5)
        addSubview(line)
    }
    
    deinit {
        closeShareBoardObserver.sendCompleted()
    }
    
    func setOtherActions(actions: [ShareBoardItem]) {
        
        let btnWidth: CGFloat = 60.0
        let btnHeight: CGFloat = 60.0
        let left: CGFloat = 12.0
        
        for (index, value) in actions.enumerated() {
            let button = UIButton()
            button.setTitleColor(.black, for: .normal)
            button.setImage(value.image, for: .normal)
            button.setBackgroundImage(#imageLiteral(resourceName: "sharemore_other"), for: .normal)
            button.setBackgroundImage(#imageLiteral(resourceName: "sharemore_other_HL"), for: .highlighted)
            button.tag = value.otherAction.rawValue
            button.frame = CGRect(x: left + (btnWidth + left) * CGFloat(index), y: 12, width: btnWidth, height: btnHeight)
            button.addTarget(self, action: #selector(saveImageToDisk), for: .touchUpInside)
            otherActionsScrollView.addSubview(button)
            
            let titleLabel = UILabel()
            titleLabel.text = value.title
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.width = button.width
            titleLabel.textColor = UIColor(red: 143/255, green: 143/255, blue: 148/255, alpha: 1.0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.sizeToFit()
            titleLabel.center.x = button.center.x
            titleLabel.top = button.bottom + 5.0
            otherActionsScrollView.addSubview(titleLabel)
        }
        
        otherActionsScrollView.contentSize = CGSize(width: (btnWidth + 12.0) * CGFloat(actions.count) + 12.0, height: 0);
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
            if error == nil {
                self.closeShareBoardObserver.send(value: ())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    SVProgressHUD.showSuccess(withStatus: "分享成功")
                }
            } else if let error: NSError = error as NSError? {
                self.closeShareBoardObserver.send(value: ())
                if error.code != 2009 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        SVProgressHUD.showError(withStatus: "分享失败")
                    }
                }
            }
        }
    }
    
    func saveImageToDisk() {
        guard DGImagePickerController.available(source: .savedPhotosAlbum) else { return }
        
        closeShareBoardObserver.send(value: ())
        PHPhotoLibrary.shared().performChanges({ 
            guard let image = self.shareImage else { return }
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if success {
                    SVProgressHUD.showSuccess(withStatus: "保存成功")
                } else {
                    SVProgressHUD.showError(withStatus: "保存失败")
                }
            }
        }
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

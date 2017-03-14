//
//  NodeEditViewController.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import YYText
import PureLayout
import ReactiveCocoa
import ReactiveSwift
import Result
import TBActionSheetKit
import SVProgressHUD
import SwiftHEXColors

class NodeEditViewController: DGViewController, YYTextViewDelegate, YYTextKeyboardObserver, UIScrollViewDelegate {

    let viewModel: NodeEditViewModel
    
    let keyboardCloseButton = UIButton()
//    let nodeBackgroundView = UIScrollView()
    let textView = NodeTextView()
    let headImageView = NodeHeadImageView()
    lazy var shareBoardView: ShareBoardView = {
        let shareBoardView = ShareBoardView()
        shareBoardView.frame.size = CGSize(width: self.view.width, height: 210)
        return shareBoardView
    }()
    var actionSheet: TBActionSheet?
    
    var textViewHeightConstraint: NSLayoutConstraint?
    var headImageHeightConstraint: NSLayoutConstraint?
    var keyboardTop: CGFloat = 0
    var keyboardHeight: CGFloat = 0
    
    init(viewModel: NodeEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        YYTextKeyboardManager.default()?.add(self)
    }
    
    deinit {
        YYTextKeyboardManager.default()?.remove(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let moreItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_more"), style: .plain, target: self, action: #selector(showShareBoard))
        moreItem.isEnabled = false
        let getNodeImageItem = UIBarButtonItem(barButtonSystemItem: .action, pressed: viewModel.addHeadImageCocoaAction)
        getNodeImageItem.isEnabled = false
        navigationItem.rightBarButtonItems = [moreItem, getNodeImageItem]
        
//        nodeBackgroundView.frame = view.bounds
//        nodeBackgroundView.backgroundColor = .white
//        nodeBackgroundView.delegate = self
//        nodeBackgroundView.alwaysBounceVertical = true
//        nodeBackgroundView.alwaysBounceHorizontal = false
//        nodeBackgroundView.isScrollEnabled = false
//        view.addSubview(nodeBackgroundView)
        
        keyboardCloseButton.backgroundColor = .red
        keyboardCloseButton.frame.size = CGSize(width: 15, height: 15)
        keyboardCloseButton.right = view.right
        keyboardCloseButton.bottom = view.bottom
        keyboardCloseButton.isHidden = true
        keyboardCloseButton.addTarget(self, action: #selector(hiddenKeyboard), for: .touchUpInside)
        view.addSubview(keyboardCloseButton)
        
//        nodeBackgroundView.addSubview(headImageView)
        
        textView.placeholderText = "想要分享什么？"
        textView.placeholderFont = UIFont.systemFont(ofSize: 14.0)
        textView.textContainerInset = UIEdgeInsets(top: 50, left: 55, bottom: 50, right: 55)
//        textView.contentInset = UIEdgeInsets(top: 50, left: 55, bottom: 50, right: 55)
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        textView.delegate = self
//        textView.isScrollEnabled = false
        textView.textParser = NodeTextParser()
        textView.allowsCopyAttributedString = false
        view.addSubview(textView)
        
        headImageView.frame = CGRect(x: 0, y: 0, width: view.width, height: 250)
        textView.frame = CGRect.init(x: 0, y: 64, width: view.width, height: view.height - 64)
//        textView.frame.size.width -= 110
        
        viewModel.addHeadImageAction.values.observeValues { [weak self] image  in
            guard let `self` = self else { return }
            if let image = image {
//                self.viewModel.hasHeadImage.value = true
                self.headImageView.setImage(image)
                self.viewModel.node.value.headImage = image
                let attr = NSMutableAttributedString.yy_attachmentString(withContent: self.headImageView, contentMode: .center, attachmentSize: CGSize(width: self.textView.width - 110, height: 250.0), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                let text = self.textView.attributedText?.mutableCopy() as! NSMutableAttributedString
                text.insert(attr, at: 0)
                self.textView.textContainerInset.top = 0
                self.textView.attributedText = text
//                self.textView.addSubview(self.headImageView)
//                let path = UIBezierPath(roundedRect: CGRect(x: -55, y: 0, width: self.textView.width, height: 200.0), cornerRadius: 0)
//                self.textView.exclusionPaths = [path]
            } else {
                self.viewModel.hasHeadImage.value = false
            }
        }
        
        viewModel.node.producer.on(value: { [weak self] node in
            guard let `self` = self else { return }
            var textHeight: CGFloat = 0
            if !node.content.isEmpty {
                let text = NSMutableAttributedString(string: node.content)
                text.yy_setFont(UIFont.systemFont(ofSize: 14.0), range: text.yy_rangeOfAll())
                text.yy_setColor(UIColor(hexString: "555555"), range: text.yy_rangeOfAll())
                text.yy_setLineSpacing(8.0, range: text.yy_rangeOfAll())
                text.yy_setKern(1.0, range: text.yy_rangeOfAll())
                self.textView.text = node.content
                
                let size = CGSize(width: self.view.width - 110, height: CGFloat.greatestFiniteMagnitude)
                if let textLayout = YYTextLayout(containerSize: size, text: text) {
                    textHeight = textLayout.textBoundingSize.height + 100
                }
            } else {
                self.textView.becomeFirstResponder()
            }
            var headImageHeight: CGFloat = 0
            if let image = node.headImage {
                self.viewModel.hasHeadImage.value = true
                self.headImageView.setImage(image)
                self.headImageView.scrollView.setZoomScale(node.zoomScale, animated: false)
                self.headImageView.scrollView.contentOffset = node.headImageScrollRect.origin
                headImageHeight = 0
            }
            if textHeight > 0 {
//                self.textView.top = headImageHeight
//                self.textView.height = textHeight
//                self.nodeBackgroundView.contentSize = CGSize(width: 0, height: textHeight + headImageHeight)
//                self.nodeBackgroundView.contentOffset = CGPoint(x: 0, y: 0)

            }
        }).start()
        
        headImageView.deleteHeadImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.hasHeadImage.value = false
            self.viewModel.node.value.headImage = nil
        }
        
//        headImageView.reactive.isHidden <~ viewModel.hasHeadImage.map({ [weak self] has in
//            guard let `self` = self else { return !has }
////            let height: CGFloat = has ? 200.0 : 0
////            self.headImageView.frame.size.height = height
////            self.textView.top = height
//            self.nodeBackgroundView.contentSize = CGSize(width: 0, height: self.textView.height)
//            return !has
//        })
//        
//        headImageView.imageContainerView.reactive.isHidden <~ viewModel.hasHeadImage.map { !$0 }
//        headImageView.deleteHeadImageButton.reactive.isHidden <~ viewModel.hasHeadImage.map { !$0 }
        
        shareBoardView.closeShareBoardSignal.observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.actionSheet?.close()
            self.actionSheet = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let node = viewModel.node.value
        if let text = textView.attributedText?.string {
            node.content = text
        }
        
        node.headImageScrollRect.origin = headImageView.scrollView.contentOffset
        node.zoomScale = headImageView.scrollView.zoomScale
        if !node.content.isEmpty {
            DispatchQueue.global().async {
                node.newTextLayout()
                node.save()
                self.viewModel.reloadNodeListObserver.send(value: true)
            }
        } else {
            viewModel.reloadNodeListObserver.send(value: false)
        }
    }
    
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        let y = transition.toFrame.minY
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let selectionView: UIView = self.textView.value(forKeyPath: "selectionView.caretView") as! UIView
            let bottom = selectionView.bottom + (self.viewModel.hasHeadImage.value ? 200.0 : 0) + 64
            if y < bottom {
                let v = self.textView.height - bottom
                print("b:\(bottom - y) v:\(v)")
//                self.nodeBackgroundView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: <#T##CGFloat#>, height: <#T##CGFloat#>), animated: <#T##Bool#>)
            }
        }
        UIView.animate(withDuration: transition.animationDuration, delay: 0, options: [transition.animationOption, .beginFromCurrentState], animations: {
            self.keyboardCloseButton.isHidden = transition.fromVisible.boolValue
            self.keyboardCloseButton.bottom = y
        }, completion: nil)
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        let textHeight = textView.textLayout?.textBoundingSize.height ?? 0.0
        let headImageHeight: CGFloat = viewModel.hasHeadImage.value ? 0 : 0
        guard textHeight > 0 else { return }
//        self.textView.frame.size.height = textHeight
//        nodeBackgroundView.contentSize = CGSize(width: 0, height: textHeight + headImageHeight)
        navigationItem.rightBarButtonItems?.forEach({ item in
            item.isEnabled = !textView.text.isEmpty
        })
    }
    
    func showShareBoard() {
        textView.resignFirstResponder()
        
        headImageView.deleteHeadImageButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.shareBoardView.shareImage = self.convertTextToImage()
            self.headImageView.deleteHeadImageButton.isHidden = false
        }
        
        let actionSheet = TBActionSheet()
        actionSheet.addButton(withTitle: "取消", style: .default)
        actionSheet.sheetWidth = self.view.width
        actionSheet.rectCornerRadius = 0
        actionSheet.customView = self.shareBoardView
        actionSheet.offsetY = 0
        actionSheet.buttonHeight = 44
        actionSheet.backgroundTransparentEnabled = 0
        actionSheet.blurEffectEnabled = 0
        actionSheet.ambientColor = .white
        actionSheet.show()
        self.actionSheet = actionSheet
    }

    func convertTextToImage() -> UIImage? {
        let scale = UIScreen.main.scale
        
        if viewModel.hasHeadImage.value == false {
            let view: UIView = textView.value(forKey: "containerView") as! UIView
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            
            let contentView: UIView = textView.value(forKey: "containerView") as! UIView
            UIGraphicsBeginImageContextWithOptions(contentView.frame.size, false, scale)
            contentView.drawHierarchy(in: contentView.bounds, afterScreenUpdates: false)
            let textImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageView = headImageView
            UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, scale)
            imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: false)
            let headImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let size = CGSize(width: imageView.width, height: contentView.height + imageView.height)
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            headImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.width, height: imageView.height))
            textImage?.draw(in: CGRect(x: 0, y: imageView.height, width: contentView.width, height: contentView.height))
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            return result
        }
    }
    
    func hiddenKeyboard() {
        view.endEditing(true)
    }
}

extension NodeEditViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeEditViewController(viewModel: self)
    }
}
 

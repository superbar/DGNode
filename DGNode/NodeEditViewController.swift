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
    
    let nodeBackgroundView = UIScrollView()
    let textView = NodeTextView()
    let headImageView = NodeHeadImageView()
    lazy var shareBoardView: ShareBoardView = {
        let shareBoardView = ShareBoardView()
        shareBoardView.frame.size = CGSize(width: self.view.width, height: 210)
        return shareBoardView
    }()
    
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
        let getNodeImageItem = UIBarButtonItem(barButtonSystemItem: .action, pressed: viewModel.addHeadImageCocoaAction)
        navigationItem.rightBarButtonItems = [moreItem, getNodeImageItem]
        
        nodeBackgroundView.frame = view.bounds
        nodeBackgroundView.backgroundColor = .white
        nodeBackgroundView.delegate = self
        view.addSubview(nodeBackgroundView)
        
        nodeBackgroundView.addSubview(headImageView)
        
        textView.placeholderText = "想要分享什么？"
        textView.placeholderFont = UIFont.systemFont(ofSize: 14.0)
        textView.textContainerInset = UIEdgeInsets(top: 30, left: 35, bottom: 30, right: 35)
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textParser = NodeTextParser()
        textView.allowsCopyAttributedString = false
        nodeBackgroundView.addSubview(textView)
        
        headImageView.frame = CGRect(x: 0, y: 0, width: view.width, height: 200)
        textView.frame = CGRect(x: 0, y: 0, width: view.width, height: 500)
        
        viewModel.addHeadImageAction.values.observeValues { [weak self] image  in
            guard let `self` = self else { return }
            if let image = image {
                self.viewModel.hasHeadImage.value = true
                self.headImageView.setImage(image)
                self.viewModel.node.value.headImage = image
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
                
                let size = CGSize(width: self.view.width - 70, height: CGFloat.greatestFiniteMagnitude)
                if let textLayout = YYTextLayout(containerSize: size, text: text) {
                    textHeight = textLayout.textBoundingSize.height + 60
                }
            }
            var headImageHeight: CGFloat = 0
            if let image = node.headImage {
                self.viewModel.hasHeadImage.value = true
                self.headImageView.setImage(image)
                self.headImageView.scrollView.setZoomScale(node.zoomScale, animated: false)
                self.headImageView.scrollView.contentOffset = node.headImageScrollRect.origin
                headImageHeight = 200
            }
            if textHeight > 0 {
                self.textView.top = headImageHeight
                self.textView.height = textHeight
                self.nodeBackgroundView.contentSize = CGSize(width: 0, height: textHeight + headImageHeight)
                self.nodeBackgroundView.contentOffset = CGPoint(x: 0, y: 0)

            }
        }).start()
        
        headImageView.deleteHeadImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.hasHeadImage.value = false
            self.viewModel.node.value.headImage = nil
        }
        
        headImageView.reactive.isHidden <~ viewModel.hasHeadImage.map({ [weak self] has in
            guard let `self` = self else { return !has }
            let height: CGFloat = has ? 200.0 : 0
            self.headImageView.frame.size.height = height
            self.textView.top = height
            self.nodeBackgroundView.contentSize = CGSize(width: 0, height: self.textView.height + height)
            return !has
        })
        
        headImageView.imageContainerView.reactive.isHidden <~ viewModel.hasHeadImage.map { !$0 }
        headImageView.deleteHeadImageButton.reactive.isHidden <~ viewModel.hasHeadImage.map { !$0 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            let attr = self.textView.attributedText
            if attr?.string.isEmpty == true {
                self.textView.becomeFirstResponder()
            }
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
            node.save()
            viewModel.reloadNodeListObserver.send(value: true)
        } else {
            viewModel.reloadNodeListObserver.send(value: false)
        }
    }
    
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        let y = transition.toFrame.minY
        keyboardTop = y
        keyboardHeight = transition.toFrame.height
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let selectionView: UIView = self.textView.value(forKeyPath: "selectionView.caretView") as! UIView
            let bottom = selectionView.bottom + (self.viewModel.hasHeadImage.value ? 200.0 : 0) + 64 + 35
            if y < bottom {
                var ry = bottom - y - 29
                if ry > y {
                    ry = y - 29
                }
                UIView.animate(withDuration: transition.animationDuration, delay: 0, options: [transition.animationOption, .beginFromCurrentState], animations: {
                    self.nodeBackgroundView.contentOffset = CGPoint(x: 0, y: ry)
                }, completion: nil)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
//        nodeBackgroundView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        let textHeight = textView.textLayout?.textBoundingSize.height ?? 0.0
        let headImageHeight: CGFloat = viewModel.hasHeadImage.value ? 200.0 : 0
        guard textHeight > 0 else { return }
        self.textView.frame.size.height = textHeight
        nodeBackgroundView.contentSize = CGSize(width: 0, height: textHeight + headImageHeight)
//        let selectionView: UIView = self.textView.value(forKeyPath: "selectionView.caretView") as! UIView
//        let bottom = selectionView.bottom + (self.viewModel.hasHeadImage.value ? 200.0 : 0) + 64 + 35
//        if bottom <= keyboardHeight + keyboardTop {
//            nodeBackgroundView.contentOffset = CGPoint(x: 0, y: bottom - keyboardHeight)
//        } else {
//            nodeBackgroundView.contentOffset = CGPoint(x: 0, y: bottom - keyboardHeight - keyboardTop)
//        }
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
            let view = nodeBackgroundView
            let textView: UIView = self.textView.value(forKey: "containerView") as! UIView
            let size = CGSize(width: view.width, height: headImageView.height + textView.height)
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            view.drawHierarchy(in: CGRect.init(x: 0, y: -64, width: view.width, height: view.height), afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}

extension NodeEditViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeEditViewController(viewModel: self)
    }
}
 

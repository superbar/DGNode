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

class NodeEditViewController: DGViewController, YYTextViewDelegate, YYTextKeyboardObserver {

    let viewModel: NodeEditViewModel
    
    let keyboardCloseButton = UIButton()
    let textView = DGTextView()
    let headImageView = NodeHeadImageView()
    lazy var shareBoardView: ShareBoardView = {
        let shareBoardView = ShareBoardView()
        shareBoardView.frame.size = CGSize(width: self.view.width, height: 210)
        return shareBoardView
    }()
    var actionSheet: TBActionSheet?
    
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
        let getNodeImageItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addHeadImage"), style: .plain, pressed: viewModel.addHeadImageCocoaAction)
        getNodeImageItem.isEnabled = false
        navigationItem.rightBarButtonItems = [moreItem, getNodeImageItem]
        
        textView.placeholderText = "想要分享什么？"
        textView.placeholderFont = UIFont.systemFont(ofSize: 14.0)
        textView.textContainerInset = UIEdgeInsets(top: 50, left: 55, bottom: 50, right: 55)
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textColor = UIColor(hexString: "555555")
        textView.delegate = self
        textView.alwaysBounceVertical = true
        textView.alwaysBounceHorizontal = false
        textView.textParser = NodeTextParser()
        textView.allowsCopyAttributedString = false
        textView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        view.addSubview(textView)
        
        keyboardCloseButton.setBackgroundImage(#imageLiteral(resourceName: "keyboard_dismiss"), for: .normal)
        keyboardCloseButton.frame.size = CGSize(width: 30, height: 30)
        keyboardCloseButton.right = view.right - 7.0
        keyboardCloseButton.bottom = view.bottom + 30
        keyboardCloseButton.addTarget(self, action: #selector(hiddenKeyboard), for: .touchUpInside)
        view.addSubview(keyboardCloseButton)
        
        headImageView.frame = CGRect(x: 0, y: 0, width: view.width, height: 250)
        
        viewModel.addHeadImageAction.values.observeValues { [weak self] image  in
            guard let `self` = self else { return }
            if let image = image {
                let oldHsa = self.viewModel.hasHeadImage.value
                self.viewModel.hasHeadImage.value = true
                self.headImageView.setImage(image)
                self.viewModel.node.value.headImage = image
                if !oldHsa {
                    let attr = NSMutableAttributedString.yy_attachmentString(withContent: self.headImageView, contentMode: .center, attachmentSize: CGSize(width: self.textView.width - 110, height: 250.0), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                    let text = self.textView.attributedText?.mutableCopy() as! NSMutableAttributedString
                    text.insert(attr, at: 0)
                    self.textView.textContainerInset.top = 0
                    self.textView.attributedText = text
                }
            } else {
                self.viewModel.hasHeadImage.value = false
            }
        }
        
        viewModel.node.producer.on(value: { [weak self] node in
            guard let `self` = self else { return }
            if !node.content.isEmpty {
                self.textView.text = node.content
                
                if let image = node.headImage {
                    self.viewModel.hasHeadImage.value = true
                    self.headImageView.setImage(image)
                    self.viewModel.node.value.headImage = image
                    
                    let attr = NSMutableAttributedString.yy_attachmentString(withContent: self.headImageView, contentMode: .center, attachmentSize: CGSize(width: self.textView.width - 110, height: 250.0), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                    let text = self.textView.attributedText?.mutableCopy() as! NSMutableAttributedString
                    text.insert(attr, at: 0)
                    self.textView.textContainerInset.top = 0
                    self.textView.attributedText = text
                }
            } else {
                self.textView.becomeFirstResponder()
            }
        }).start()
        
        headImageView.deleteHeadImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.textView.textContainerInset.top = 55
            self.viewModel.hasHeadImage.value = false
            self.viewModel.node.value.headImage = nil
            let text = self.textView.attributedText?.mutableCopy() as! NSMutableAttributedString
            text.yy_removeAttributes(in: NSRange(location: 0, length: 1))
            text.replaceCharacters(in: NSRange(location: 0, length: 1), with: "")
            self.textView.attributedText = text
        }
        
        headImageView.deleteHeadImageButton.reactive.isHidden <~ viewModel.hasHeadImage.map { [weak self] has in
            self?.textView.isHasHeadImage = has
            return !has
        }
        
        shareBoardView.closeShareBoardSignal.observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.actionSheet?.close()
            self.actionSheet = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let node = viewModel.node.value
        if var text = textView.attributedText?.string {
            if viewModel.hasHeadImage.value {
                let start = text.startIndex
                let end = text.index(text.startIndex, offsetBy: 1)
                text.replaceSubrange(start..<end, with: "")
            }
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
        UIView.animate(withDuration: transition.animationDuration, delay: 0, options: [transition.animationOption, .beginFromCurrentState], animations: {
            if transition.toVisible.boolValue {
                self.keyboardCloseButton.bottom = transition.toFrame.minY
            } else {
                self.keyboardCloseButton.bottom = self.view.bottom + 30
            }
        }, completion: nil)
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        navigationItem.rightBarButtonItems?.forEach({ item in
            item.isEnabled = !textView.text.isEmpty
        })
    }
    
    func textView(_ textView: YYTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if viewModel.hasHeadImage.value {
            if range.location == 0 && range.length == 1 && text == "" {
                return false
            }
        }
        return true
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
        
        let nodeView: UIView = textView.value(forKey: "containerView") as! UIView
        UIGraphicsBeginImageContextWithOptions(nodeView.frame.size, false, scale)
        nodeView.drawHierarchy(in: nodeView.bounds, afterScreenUpdates: false)
        let nodeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let logo = #imageLiteral(resourceName: "logo_gary")
        
        let size = CGSize(width: nodeView.width, height: nodeView.height + 150)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        nodeImage?.draw(in: CGRect(x: 0, y: 0, width: nodeView.width, height: nodeView.height))
        logo.draw(in: CGRect(x: (nodeView.width - 40) / 2, y: nodeView.height + 80, width: 40, height: 40))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
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
 

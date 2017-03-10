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

class NodeEditViewController: ViewController, YYTextViewDelegate, YYTextKeyboardObserver {

    let viewModel: NodeEditViewModel
    
    let nodeBackgroundView = DGScrollView()
    let textView = YYTextView()
//    let headImageView = NodeHeadImageView()
//    let toolBar = NodeToolBarView()
    lazy var shareBoardView: ShareBoardView = {
        let shareBoardView = ShareBoardView()
        shareBoardView.frame.size = CGSize(width: self.view.width, height: 210)
        return shareBoardView
    }()
    
    var textViewHeightConstraint: NSLayoutConstraint?
    
    init(viewModel: NodeEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        nodeBackgroundView.frame = CGRect(x: 0, y: 64, width: view.width, height: view.height - 64)
        nodeBackgroundView.backgroundColor = .white
        nodeBackgroundView.delegate = self
        view.addSubview(nodeBackgroundView)
        
//        headImageView.addImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
//            guard let `self` = self else { return }
//            let alertVM = AlertViewModel(title: nil, message: "选择图片", preferredStyle: .actionSheet)
//            let crameAction = UIAlertAction(title: "拍照", style: .default, handler: { action in
//                self.takeImage(source: .camera)
//            })
//            let photoLibraryAction = UIAlertAction(title: "从相册选取", style: .default, handler: { action in
//                self.takeImage(source: .photoLibrary)
//            })
//            let cancelAciton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//            alertVM.actions.value = [crameAction, photoLibraryAction, cancelAciton]
//            Service.default.viewModelService.presentViewModel(alertVM, animated: true, completion: nil)
//        }
        
//        headImageView.deleteHeadImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
//            guard let `self` = self else { return }
//            self.viewModel.hasHeadImage.value = false
//            self.viewModel.node.value.headImage = nil
//        }
        
//        headImageView.addImageButton.reactive.isHidden <~ viewModel.hasHeadImage
//        headImageView.imageContainerView.reactive.isHidden <~ viewModel.hasHeadImage.map { !$0 }
//        headImageView.deleteHeadImageButton.reactive.isHidden <~ viewModel.hasHeadImage.map { !$0 }
//        
//        nodeBackgroundView.contentView.addSubview(headImageView)
        
//        toolBar.backgroundColor = .red
//        toolBar.frame.size = CGSize(width: view.width, height: 44)
//        toolBar.bottom = view.bottom
//        view.addSubview(toolBar)
        
//        headImageView.setFrame(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        
        textView.placeholderText = "想要分享什么？"
        textView.placeholderFont = UIFont.systemFont(ofSize: 14.0)
        textView.textContainerInset = UIEdgeInsets(top: 30, left: 35, bottom: 30, right: 35)
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        textView.delegate = self
        textView.textParser = NodeTextParser()
        textView.allowsCopyAttributedString = false
        nodeBackgroundView.contentView.addSubview(textView)
        
        textView.autoPinEdge(toSuperviewEdge: .leading)
        textView.autoPinEdge(toSuperviewEdge: .trailing)
        textView.autoPinEdge(toSuperviewEdge: .top)
        
        viewModel.node.producer.on(value: { [weak self] node in
            guard let `self` = self else { return }
            self.viewModel.hasHeadImage.value = node.headImage != nil
            self.textView.text = node.content
            self.textViewHeightConstraint?.autoRemove()
            let height: CGFloat = max(300, self.textView.textLayout?.textBoundingSize.height ?? 0)
            self.textViewHeightConstraint = self.textView.autoSetDimension(.height, toSize: height)
        }).start()
        
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

        view.backgroundColor = UIColor.lightGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_more"), style: .plain, target: self, action: #selector(showShareBoard))
        automaticallyAdjustsScrollViewInsets = false
        
        
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
//        node.headImageScrollRect.origin = headImageView.scrollView.contentOffset
        if node.content.characters.count > 0 {
            node.save()
            viewModel.reloadNodeListObserver.send(value: node)
        }
    }
    
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        
//        UIView.animate(withDuration: transition.animationDuration, delay: 0, options: [transition.animationOption, .beginFromCurrentState], animations: {
//            self.toolBar.bottom = transition.toFrame.minY
//        }, completion: nil)
        
//        let y = transition.toFrame.minY
//        let origOffset = nodeBackgroundView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === nodeBackgroundView {
            return
        }
        let height: CGFloat = max(300, textView.textLayout?.textBoundingSize.height ?? 0)
        textViewHeightConstraint?.autoRemove()
        textViewHeightConstraint = textView.autoSetDimension(.height, toSize: height)
        nodeBackgroundView.contentSize = CGSize(width: 0, height: height + 200)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView === nodeBackgroundView {
            textView.resignFirstResponder()
        }
    }
    
    func showShareBoard() {
        textView.resignFirstResponder()

        self.shareBoardView.shareImage = self.convertTextToImage()
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
            let size = CGSize.init(width: view.width, height: textView.height)
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            view.drawHierarchy(in: CGRect.init(x: 0, y: 0, width: view.width, height: view.height), afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    func takeImage(source: UIImagePickerControllerSourceType) {
        guard ImagePickerController.available(source: source) else { return }
        let viewModel = ImagePickerViewModel(source: source, exec: { (image, url) in
            guard let image = image else { return }
//            self.headImageView.setImage(image)
            self.viewModel.hasHeadImage.value = true
            self.viewModel.node.value.headImage = image
        })
        Service.default.viewModelService.presentViewModel(viewModel, animated: true, completion: nil)
    }
    
}

extension NodeEditViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeEditViewController(viewModel: self)
    }
}
 

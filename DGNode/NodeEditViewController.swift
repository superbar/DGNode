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
import ReactiveSwift
import Result
import TBActionSheetKit

class NodeEditViewController: ViewController, YYTextViewDelegate, YYTextKeyboardObserver {

    let viewModel: NodeEditViewModel
    
    let nodeBackgroundView = DGScrollView()
    let textView = YYTextView()
    let headImageView = NodeHeadImageView()
    let toolBar = NodeToolBarView()
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
        
        headImageView.addImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            let alertVM = AlertViewModel(title: nil, message: "选择图片", preferredStyle: .actionSheet)
            let crameAction = UIAlertAction(title: "拍照", style: .default, handler: { action in
                self.takeImage(source: .camera)
            })
            let photoLibraryAction = UIAlertAction(title: "从相册选取", style: .default, handler: { action in
                self.takeImage(source: .photoLibrary)
            })
            let cancelAciton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertVM.actions.value = [crameAction, photoLibraryAction, cancelAciton]
            Service.default.viewModelService.presentViewModel(alertVM, animated: true, completion: nil)
        }
        
        nodeBackgroundView.contentView.addSubview(headImageView)
        
        toolBar.backgroundColor = .red
        toolBar.frame.size = CGSize(width: view.width, height: 44)
        toolBar.bottom = view.bottom
        view.addSubview(toolBar)
        
        headImageView.setFrame(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 30)
        textView.delegate = self
        nodeBackgroundView.contentView.addSubview(textView)
        
        textView.autoPinEdge(toSuperviewEdge: .leading)
        textView.autoPinEdge(toSuperviewEdge: .trailing)
        textView.autoPinEdge(.top, to: .bottom, of: headImageView)
        textViewHeightConstraint = textView.autoSetDimension(.height, toSize: 300)
        
        viewModel.node.producer.on(value: { [weak self] node in
            guard let `self` = self else { return }
            self.headImageView.setImage(node?.headImage)
            self.textView.text = node?.content
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(showShareBoard))
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var node: NodeModel
        if viewModel.node.value == nil {
            node = NodeModel()
        } else {
            node = viewModel.node.value!
        }
        
        if let text = textView.attributedText?.string {
            node.content = text
        }
        
        if let headImage = headImageView.imageView.image {
            node.headImage = headImage
        }
        
        if node.content.characters.count > 0 {
            node.save()
            viewModel.reloadNodeListObserver.send(value: ())
        }
    }
    
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        
        UIView.animate(withDuration: transition.animationDuration, delay: 0, options: [transition.animationOption, .beginFromCurrentState], animations: {
            self.toolBar.bottom = transition.toFrame.minY
        }, completion: nil)
        
//        let y = transition.toFrame.minY
//        let origOffset = nodeBackgroundView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === nodeBackgroundView {
            return
        }
        let height = max(300, scrollView.contentSize.height)
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
        let image = convertTextToImage()
        self.shareBoardView.shareImage = image
        let actionSheet = TBActionSheet()
        actionSheet.addButton(withTitle: "取消", style: .cancel)
        actionSheet.sheetWidth = view.width
        actionSheet.rectCornerRadius = 0
        actionSheet.customView = self.shareBoardView
        actionSheet.show()
    }
    
    func convertTextToImage() -> UIImage? {
        let scale = UIScreen.main.scale
        
        if headImageView.imageView.image == nil {
            let view: UIView = textView.value(forKey: "containerView") as! UIView
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            let view = nodeBackgroundView
            let textView: UIView = self.textView.value(forKey: "containerView") as! UIView
            let size = CGSize.init(width: view.width, height: headImageView.height + textView.height)
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            view.drawHierarchy(in: CGRect.init(x: 0, y: -64, width: view.width, height: view.height), afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    func takeImage(source: UIImagePickerControllerSourceType) {
        guard ImagePickerController.available(source: source) else { return }
        let viewModel = ImagePickerViewModel(source: source, exec: { (image, url) in
            self.headImageView.setImage(image)
        })
        Service.default.viewModelService.presentViewModel(viewModel, animated: true, completion: nil)
    }
    
}

extension NodeEditViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeEditViewController(viewModel: self)
    }
}
 

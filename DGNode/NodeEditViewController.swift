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

class NodeEditViewController: DGViewController {

    let viewModel: NodeEditViewModel
    
    let tableView = UITableView()
    let textView: NodeTextView
    
    let keyboardCloseButton = UIButton()
    
    let headImageView = NodeHeadImageView()
    lazy var shareBoardView: ShareBoardView = {
        let shareBoardView = ShareBoardView()
        shareBoardView.frame.size = CGSize(width: self.view.width, height: 210)
        return shareBoardView
    }()
    var actionSheet: TBActionSheet?
    
    init(viewModel: NodeEditViewModel) {
        self.viewModel = viewModel
        textView = NodeTextView(frame: .zero, textContainer: nil)
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
        
        tableView.frame = view.bounds
        tableView.delaysContentTouches = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.register(NodeTableViewCell.self)
        tableView.register(NodeHeadImageTableViewCell.self)
        view.addSubview(tableView)
        
        textView.placeholderText = "想要分享什么？"
        textView.textContainerInset = UIEdgeInsets(top: 50, left: 55, bottom: 50, right: 55)
        textView.delegate = self
        textView.isScrollEnabled = false
        let text = NSMutableAttributedString(string: " ")
        text.yy_setColor(.nodeColor, range: text.yy_rangeOfAll())
        text.yy_setFont(.nodeFont, range: text.yy_rangeOfAll())
        text.yy_setLineSpacing(8.0, range: text.yy_rangeOfAll())
        text.yy_setKern(1.0, range: text.yy_rangeOfAll())
        textView.attributedText = text
        textView.setNeedsDisplay()
        
        keyboardCloseButton.setBackgroundImage(#imageLiteral(resourceName: "keyboard_dismiss"), for: .normal)
        keyboardCloseButton.frame.size = CGSize(width: 30, height: 30)
        keyboardCloseButton.right = view.right - 7.0
        keyboardCloseButton.bottom = view.bottom + 30
        keyboardCloseButton.addTarget(self, action: #selector(hiddenKeyboard), for: .touchUpInside)
        view.addSubview(keyboardCloseButton)
        
        headImageView.frame = CGRect(x: 0, y: 0, width: view.width, height: 200)
        
        viewModel.addHeadImageAction.values.observeValues { [weak self] image  in
            guard let `self` = self else { return }
            if let image = image {
                self.viewModel.hasHeadImage.value = true
                self.headImageView.setImage(image)
                self.viewModel.node.value.headImage = image
                self.tableView.reloadData()
                self.updateNode()
            } else {
                self.viewModel.hasHeadImage.value = false
            }
        }
        
        viewModel.node.producer.on(value: { [weak self] node in
            guard let `self` = self else { return }
            let text = NSMutableAttributedString(string: node.content)
            text.yy_setColor(.nodeColor, range: text.yy_rangeOfAll())
            text.yy_setFont(.nodeFont, range: text.yy_rangeOfAll())
            text.yy_setLineSpacing(8.0, range: text.yy_rangeOfAll())
            text.yy_setKern(1.0, range: text.yy_rangeOfAll())
            if !node.content.isEmpty {
                if let image = node.headImage {
                    self.viewModel.hasHeadImage.value = true
                    self.headImageView.setImage(image)
                    self.viewModel.node.value.headImage = image
                }
            } else {
                self.textView.becomeFirstResponder()
            }
            self.textView.attributedText = text
            self.navigationItem.rightBarButtonItems?.forEach({ item in
                item.isEnabled = !text.string.isEmpty
            })
        }).start()
        
        headImageView.deleteHeadImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.textView.textContainerInset.top = 55
            self.viewModel.hasHeadImage.value = false
            self.viewModel.node.value.headImage = nil
            self.updateNode()
        }
        
        headImageView.deleteHeadImageButton.reactive.isHidden <~ viewModel.hasHeadImage.map { [weak self] has in
            guard let `self` = self else { return !has }
            self.tableView.reloadData()
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
        
        updateNode()
    }
    
    func updateNode() {
        let node = viewModel.node.value
        if let text = textView.attributedText?.string {
            node.content = text
        }
        
        node.headImageScrollRect.origin = headImageView.scrollView.contentOffset
        node.zoomScale = headImageView.scrollView.zoomScale
        if !node.content.isEmpty {
            DispatchQueue.global().async {
                node.save()
                self.viewModel.reloadNodeListObserver.send(value: true)
            }
        } else {
            viewModel.reloadNodeListObserver.send(value: false)
        }
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
        updateNode()
    }

    func convertTextToImage() -> UIImage? {
        let scale = UIScreen.main.scale
        
        let nodeTextView = self.textView
        UIGraphicsBeginImageContextWithOptions(nodeTextView.frame.size, false, scale)
        nodeTextView.drawHierarchy(in: nodeTextView.bounds, afterScreenUpdates: false)
        let nodeTextImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let logo = #imageLiteral(resourceName: "logo_gary")
        
        if viewModel.hasHeadImage.value {
            let headImageView = self.headImageView
            UIGraphicsBeginImageContextWithOptions(headImageView.frame.size, false, scale)
            headImageView.drawHierarchy(in: headImageView.bounds, afterScreenUpdates: false)
            let headImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let size = CGSize(width: nodeTextView.width, height: headImageView.height + nodeTextView.height + 150)
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            headImage?.draw(in: CGRect(x: 0, y: 0, width: headImageView.width, height: headImageView.height))
            nodeTextImage?.draw(in: CGRect(x: 0, y: headImageView.height, width: nodeTextView.width, height: nodeTextView.height))
            logo.draw(in: CGRect(x: (nodeTextView.width - 40) / 2, y: headImageView.height + nodeTextView.height + 80, width: 40, height: 40))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        } else {
            let size = CGSize(width: nodeTextView.width, height: nodeTextView.height + 150)
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            nodeTextImage?.draw(in: CGRect(x: 0, y: 0, width: nodeTextView.width, height: nodeTextView.height))
            logo.draw(in: CGRect(x: (nodeTextView.width - 40) / 2, y: nodeTextView.height + 80, width: 40, height: 40))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
    
    func hiddenKeyboard() {
        view.endEditing(true)
    }
}

extension NodeEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hasHeadImage.value ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.hasHeadImage.value && indexPath.row == 0 {
            let cell: NodeHeadImageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.headImageView = headImageView
            cell.contentView.addSubview(headImageView)
            return cell
        }
        let cell: NodeTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        if cell.textView == nil {
            cell.textView = textView
            cell.contentView.addSubview(textView)
            textView.autoPinEdgesToSuperviewEdges()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.hasHeadImage.value && indexPath.row == 0 ? 200.0 : UITableViewAutomaticDimension
    }
}

extension NodeEditViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItems?.forEach({ item in
            item.isEnabled = !textView.text.isEmpty
        })
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        textView.setNeedsDisplay()
    }

}

extension NodeEditViewController: YYTextKeyboardObserver {
    
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        UIView.animate(withDuration: transition.animationDuration, delay: 0, options: [transition.animationOption, .beginFromCurrentState], animations: {
            if transition.toVisible.boolValue {
                self.keyboardCloseButton.bottom = transition.toFrame.minY
            } else {
                self.keyboardCloseButton.bottom = self.view.bottom + 30
            }
        }, completion: nil)
        
        if transition.toVisible.boolValue {
            let kbSize = transition.toFrame.size
            let contentInsets = UIEdgeInsets(top: 64, left: 0, bottom: kbSize.height, right: 0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            
            var rect = self.view.frame
            rect.size.height -= kbSize.height
            if !rect.contains(self.textView.frame.origin) {
                self.tableView.scrollRectToVisible(self.textView.frame, animated: false)
            }
        } else {
            var contentInsets = UIEdgeInsets.zero
            contentInsets.top = 64
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            self.updateNode()
        }
    }
}

extension NodeEditViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeEditViewController(viewModel: self)
    }
}
 

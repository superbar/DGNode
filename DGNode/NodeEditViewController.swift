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
    
    let tableView: UITableView
    let nodeBackgroundView = DGScrollView()
    let textView = NodeTextView()
    let headImageView = NodeHeadImageView()
    lazy var shareBoardView: ShareBoardView = {
        let shareBoardView = ShareBoardView()
        shareBoardView.frame.size = CGSize(width: self.view.width, height: 210)
        return shareBoardView
    }()
    
    var textViewHeightConstraint: NSLayoutConstraint?
    var headImageHeightConstraint: NSLayoutConstraint?
    
    init(viewModel: NodeEditViewModel) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .grouped)
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

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NodeEditTableViewCell.self)
        tableView.register(NodeHeadImageTableViewCell.self)
        view.addSubview(tableView)
        
        let moreItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_more"), style: .plain, target: self, action: #selector(showShareBoard))
        let getNodeImageItem = UIBarButtonItem(barButtonSystemItem: .action, pressed: viewModel.addHeadImageCocoaAction)
        navigationItem.rightBarButtonItems = [moreItem, getNodeImageItem]
        automaticallyAdjustsScrollViewInsets = false
        
        nodeBackgroundView.frame = CGRect(x: 0, y: 64, width: view.width, height: view.height - 64)
        nodeBackgroundView.backgroundColor = .white
        nodeBackgroundView.delegate = self
        view.addSubview(nodeBackgroundView)
        
        nodeBackgroundView.contentView.addSubview(headImageView)
        
        textView.placeholderText = "想要分享什么？"
        textView.placeholderFont = UIFont.systemFont(ofSize: 14.0)
        textView.textContainerInset = UIEdgeInsets(top: 30, left: 35, bottom: 30, right: 35)
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textParser = NodeTextParser()
        textView.allowsCopyAttributedString = false
        nodeBackgroundView.contentView.addSubview(textView)
        
        headImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        textView.autoPinEdge(toSuperviewEdge: .left)
        textView.autoPinEdge(toSuperviewEdge: .right)
        textView.autoPinEdge(.top, to: .bottom, of: headImageView)
        textViewHeightConstraint = textView.autoSetDimension(.height, toSize: 500)
        
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
                self.textView.attributedText = text
                
                let size = CGSize(width: self.view.width - 70, height: CGFloat.greatestFiniteMagnitude)
                if let textLayout = YYTextLayout(containerSize: size, text: text) {
                    textHeight = textLayout.textBoundingSize.height + 60
                }
            }
            var headImageHeight: CGFloat = 0
            if let image = node.headImage {
                self.viewModel.hasHeadImage.value = true
                self.headImageView.setImage(image)
                headImageHeight = 200
            }
            if textHeight > 0 {
                self.textViewHeightConstraint?.autoRemove()
                self.textViewHeightConstraint = self.textView.autoSetDimension(.height, toSize: textHeight)
                self.nodeBackgroundView.contentSize = CGSize(width: 0, height: textHeight + headImageHeight)
            }
        }).start()
        
        headImageView.deleteHeadImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.hasHeadImage.value = false
            self.viewModel.node.value.headImage = nil
        }
        
        headImageView.reactive.isHidden <~ viewModel.hasHeadImage.map({ [weak self] has in
            guard let `self` = self else { return !has }
            self.headImageHeightConstraint?.autoRemove()
            self.headImageHeightConstraint = self.headImageView.autoSetDimension(.height, toSize: has ? 200.0 : 0.0)
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
//        node.headImageScrollRect.origin = headImageView.scrollView.contentOffset
        if !node.content.isEmpty {
            node.save()
            viewModel.reloadNodeListObserver.send(value: true)
        } else {
            viewModel.reloadNodeListObserver.send(value: false)
        }
    }
    
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        nodeBackgroundView.contentOffset = CGPoint(x: 0, y: 200)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        let textHeight = textView.textLayout?.textBoundingSize.height ?? 0.0
        let headImageHeight: CGFloat = viewModel.hasHeadImage.value ? 200.0 : 0
        guard textHeight > 0 else { return }
        textViewHeightConstraint?.autoRemove()
        textViewHeightConstraint = textView.autoSetDimension(.height, toSize: textHeight)
        nodeBackgroundView.contentSize = CGSize(width: 0, height: textHeight + headImageHeight)
        nodeBackgroundView.contentOffset = CGPoint(x: 0, y: 200)
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
            view.drawHierarchy(in: CGRect.init(x: 0, y: 0, width: view.width, height: view.height), afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}

extension NodeEditViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hasHeadImage.value ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.hasHeadImage.value {
            if indexPath.row == 0 {
                let cell: NodeHeadImageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                return cell
            } else {
                let cell: NodeEditTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                return cell
            }
        } else {
            let cell: NodeEditTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        }
    }
}

extension NodeEditViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeEditViewController(viewModel: self)
    }
}
 

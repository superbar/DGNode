//
//  NodeDetailViewController.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift
import TBActionSheetKit

class NodeDetailViewController: ViewController {

    let viewModel: NodeDetailViewModel
    
    let scrollView = UIScrollView()
    let nodeDetailView = NodeDetailView()
    let buttonsView = NodeDetailActionButtonsView()
    lazy var shareBoardView: ShareBoardView = {
        let shareBoardView = ShareBoardView()
        shareBoardView.frame.size = CGSize(width: self.view.width, height: 210)
        return shareBoardView
    }()
    
    init(viewModel: NodeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        
        nodeDetailView.frame = CGRect(origin: .zero, size: CGSize(width: view.width, height: 0))
        nodeDetailView.totalHeight.producer.on(value: { [weak self] height in
            guard let `self` = self else { return }
            self.nodeDetailView.height = height
            self.buttonsView.top = self.nodeDetailView.bottom
            self.scrollView.contentSize = CGSize(width: 0, height: height)
        }).start()
        scrollView.addSubview(nodeDetailView)
        
        buttonsView.frame = CGRect(x: 0, y: 0, width: view.width, height: 180)
        scrollView.addSubview(buttonsView)
        
        viewModel.node.producer.on(value: { [weak self] node in
            guard let `self` = self else { return }
            guard let node = node else { return }
            self.nodeDetailView.setNode(node)
        }).start()
        
        buttonsView.deleteNodeButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            let node = self.viewModel.node.value
            node?.delete()
            viewModel.reloadNodeListObserver.send(value: ())
            Service.default.viewModelService.popViewModelAnimated(animated: true)
        }
        
        buttonsView.modifyNodeButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            let node = self.viewModel.node.value
            let viewModel = NodeEditViewModel()
            viewModel.node.value = node
            viewModel.reloadNodeListSignal.observeValues({ _ in
                self.viewModel.reloadNodeListObserver.send(value: ())
            })
            Service.default.viewModelService.pushViewModel(viewModel, animated: true)
        }
        
        buttonsView.getNodeImageButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.shareBoardView.shareImage = self.convertTextToImage()
            let actionSheet = TBActionSheet()
            actionSheet.addButton(withTitle: "取消", style: .cancel)
            actionSheet.sheetWidth = self.view.width
            actionSheet.rectCornerRadius = 0
            actionSheet.customView = self.shareBoardView
            actionSheet.show()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func convertTextToImage() -> UIImage? {
        let scale = UIScreen.main.scale
        let view = nodeDetailView
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension NodeDetailViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeDetailViewController(viewModel: self)
    }
}

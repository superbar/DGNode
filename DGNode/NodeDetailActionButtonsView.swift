//
//  NodeDetailActionButtonsView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import PureLayout

class NodeDetailActionButtonsView: UIView {

    let modifyNodeButton = UIButton()
    let getNodeImageButton = UIButton()
    let deleteNodeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupModifyNodeButton()
        setupGetNodeImageButton()
        setupDeleteNodeButton()
        
        modifyNodeButton.autoSetDimension(.height, toSize: 44.0)
        modifyNodeButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12.0, left: 12.0, bottom: 0, right: 12.0), excludingEdge: .bottom)
        
        getNodeImageButton.autoPinEdge(toSuperviewEdge: .left, withInset: 12.0)
        getNodeImageButton.autoPinEdge(toSuperviewEdge: .right, withInset: 12.0)
        getNodeImageButton.autoSetDimension(.height, toSize: 44.0)
        getNodeImageButton.autoPinEdge(.top, to: .bottom, of: modifyNodeButton, withOffset: 12.0)
        
        deleteNodeButton.autoPinEdge(toSuperviewEdge: .left, withInset: 12.0)
        deleteNodeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 12.0)
        deleteNodeButton.autoSetDimension(.height, toSize: 44.0)
        deleteNodeButton.autoPinEdge(.top, to: .bottom, of: getNodeImageButton, withOffset: 12.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupModifyNodeButton() {
        modifyNodeButton.setTitle("修改", for: .normal)
        modifyNodeButton.setTitleColor(.white, for: .normal)
        modifyNodeButton.setBackgroundImage(UIImage.image(.blue), for: .normal)
        addSubview(modifyNodeButton)
    }
    
    func setupGetNodeImageButton() {
        getNodeImageButton.setTitle("获取图片", for: .normal)
        getNodeImageButton.setTitleColor(.white, for: .normal)
        getNodeImageButton.setBackgroundImage(UIImage.image(.green), for: .normal)
        addSubview(getNodeImageButton)
    }
    
    func setupDeleteNodeButton() {
        deleteNodeButton.setTitle("删除", for: .normal)
        deleteNodeButton.setTitleColor(.white, for: .normal)
        deleteNodeButton.setBackgroundImage(UIImage.image(.red), for: .normal)
        addSubview(deleteNodeButton)
    }
    
}

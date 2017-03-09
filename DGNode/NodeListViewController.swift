//
//  NodeListViewController.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class NodeListViewController: ViewController {
    
    let viewModel: NodeListViewModel
    
    var tableView: UITableView?
    
    init(viewModel: NodeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        viewModel.nodes.producer.on(value: { [weak self] nodes in
            guard let `self` = self else { return }
            self.tableView?.reloadData()
        }).start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NodeListTableViewCell.self)
        view.addSubview(tableView)
        self.tableView = tableView
        
        let headerView = NodeListHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 100.0))
        tableView.tableHeaderView = headerView
        
        headerView.createNewNodeButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            let viewModel = NodeEditViewModel()
            viewModel.reloadNodeListSignal.observeValues { _ in
                self.viewModel.fetchNodes()
            }
            Service.default.viewModelService.pushViewModel(viewModel, animated: true)
        }
    }
}

extension NodeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nodes.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NodeListTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let node = viewModel.nodes.value[indexPath.row]
        cell.setNode(node)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let node = viewModel.nodes.value[indexPath.row]
        return node.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let node = self.viewModel.nodes.value[indexPath.row]
        let viewModel = NodeDetailViewModel()
        viewModel.node.value = node
        viewModel.reloadNodeListSignal.observeValues { _ in
            self.viewModel.fetchNodes()
        }
        Service.default.viewModelService.pushViewModel(viewModel, animated: true)
    }
    
}

extension NodeListViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return NodeListViewController(viewModel: self)
    }
}

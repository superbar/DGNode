//
//  ImagePickerController.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import SVProgressHUD

class ImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var viewModel: ImagePickerViewModel?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.viewModel?.exec(img, nil)
        } else if let url = info[UIImagePickerControllerMediaURL] as? NSURL {
            self.viewModel?.exec(nil, url)
        }
        Service.default.viewModelService.dismissViewModelAnimated(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.viewModel?.exec(nil, nil)
        Service.default.viewModelService.dismissViewModelAnimated(animated: true, completion: nil)
    }
    
    class func available(source: UIImagePickerControllerSourceType) -> Bool {
        let available = UIImagePickerController.isSourceTypeAvailable(source)
        guard available == true else {
            var title = ""
            switch source {
            case .camera:
                title = "无法访问您的相机"
            case .photoLibrary:
                title = "无法访问您的相册"
            case .savedPhotosAlbum:
                title = "无法访问您的相薄"
            }
            SVProgressHUD.showError(withStatus: title)
            return available
        }
        return available
    }
}

extension ImagePickerViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        let vc = ImagePickerController()
        vc.viewModel = self
        vc.sourceType = self.source
        if let mediaTypes = self.mediaTypes {
            vc.mediaTypes = mediaTypes
        }
        vc.delegate = vc
        return vc
    }
}

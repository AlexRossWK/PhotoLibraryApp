//
//  LargePhotoVC.swift
//  PhotoLibraryApp
//
//  Created by Алексей Россошанский on 03.01.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit
import Photos

class LargePhotoVC: UIViewController {
    
//MARK: - Vars
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index = 0
//MARK: - Outlets

    @IBOutlet weak var largeImageView: UIImageView!
    
    @IBAction func exportPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func trashPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
            //delete photo
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest(for: self.assetCollection)
                request?.removeAssets([self.photosAsset[self.index]] as NSFastEnumeration)
            }, completionHandler: { (success, error) in
                NSLog("Deleted image -> %@", success ? "success": "error")
                alert.dismiss(animated: true, completion: nil)
                
                self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                if self.photosAsset.count==0 {
                    //no photos
                    DispatchQueue.main.sync {
                        self.largeImageView.image = nil
                    }
                    //go to root view controller
                    //if we delete the last photo, change index
                }
                    if self.index >= self.photosAsset.count {
                        self.index = self.photosAsset.count - 1
                    }
                    self.displayPhoto()
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alertAction) in
            //dont delete
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}

//MARK: - View loads
extension LargePhotoVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
        
        self.displayPhoto()
    }
    
}

//MARK: - Display photo that was fetched
extension LargePhotoVC {
    func displayPhoto(){
        let imageManager = PHImageManager.default()
        var ID = imageManager.requestImage(for: self.photosAsset[self.index] as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (result, info) in
            self.largeImageView.image = result
        }
    }
}


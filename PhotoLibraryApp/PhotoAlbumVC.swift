//
//  PhotoAlbumVC.swift
//  PhotoLibraryApp
//
//  Created by Алексей Россошанский on 03.01.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "smallPhotoCell"
let nameOfAlbum = "Own Album"
class PhotoAlbumVC: UIViewController {
//MARK: - Vars
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var albumFound = false
//MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    
 
}

//MARK: - View loads
extension PhotoAlbumVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        librarySettings()
        self.collectionView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = false

        getPhotosFromCollection()
        self.collectionView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLargeImage"{
            let nextController = segue.destination as! LargePhotoVC
            nextController.photosAsset = self.photosAsset
            nextController.assetCollection = self.assetCollection
            //and index which item was tapped
            let indexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)
            nextController.index = (indexPath?.item)!
        }
    }
    
}

//MARK: - CollectionView DataSource and Delegates methods
extension PhotoAlbumVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if self.photosAsset.count != 0 {
            count = self.photosAsset.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCell
        cell.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        let asset = self.photosAsset[indexPath.item] as PHAsset
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (result, info) in
            cell.smallImageView.image = result
        }
        
        return cell
    }
   
}

//MARK: - CollectionView UICollectionViewDelegateFlowLayoutmethods
extension PhotoAlbumVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

//MARK: - Photos framework settings
extension PhotoAlbumVC {
    func librarySettings() {
        
        //Check, if folder exists and create it if id does not
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", nameOfAlbum)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        
        if let album = collection.firstObject {
            //Folder exists and we can do everything with it here
            self.albumFound = true
            self.assetCollection = album
        } else {
            //Folder is not exist and we should create it here
            NSLog("\nFolder \"%@\"does not exist \n Creating...", nameOfAlbum)
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: nameOfAlbum)
            }, completionHandler: { (success, error) -> Void in
                NSLog("Creation of folder: %@", (success ? "success" : "error"))
                self.albumFound = success
            })
        }
    }
    
    func getPhotosFromCollection(){
        //fetch the photo from collection
        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        
    }
}

//MARK: - BUTTONS
extension PhotoAlbumVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            //load camera interface
            var picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        } else {
            //camera is not available
            var alert = UIAlertController(title: "Error", message: "No camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func albumPressed(_ sender: UIBarButtonItem) {
        var picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
}



//MARK: - UIImagePickerControllerDelegate methods
extension PhotoAlbumVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let placeholder = createAssetRequest.placeholderForCreatedAsset
            //add photo to our album (from camera)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset)
            albumChangeRequest?.addAssets([placeholder] as NSFastEnumeration)
        }) { (success, error) in
            picker.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}




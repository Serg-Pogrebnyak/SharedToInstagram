//
//  ViewController.swift
//  InstagramStories
//
//  Created by Michael Miles on 5/22/19.
//  Copyright © 2019 Michael Miles. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var sharingImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Action
    @IBAction func shareToInstaStories(_ sender: Any) {
        shareToFeed()
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(sharingImageView.image!,
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    //MARK: - Callback save image
    @objc fileprivate func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //MARK: - Share to Instagram function
    fileprivate func shareToFeed() {
        if let feedUrl = URL(string: "instagram://app") {
            if UIApplication.shared.canOpenURL(feedUrl) {
                let url = URL(string: "instagram://library?LocalIdentifier=\(self.getLastPhotoLocalIdentifier())")!
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                print("User doesn't have instagram on their device.")
            }
        }
    }
    
    fileprivate func shareToStories() {
        if let storiesUrl = URL(string: "instagram-stories://share") {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                guard let image = sharingImageView.image else { return }
                //image to stories
                guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
                //video to stories
                guard let videoData = self.getVideoDataFromResources() else {return}
                
                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.backgroundVideo": videoData
                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
            } else {
                print("User doesn't have instagram on their device.")
            }
        }
    }
    
    fileprivate func getVideoDataFromResources() -> NSData? {
        guard let filePath = Bundle.main.path(forResource: "small", ofType: ".mp4") else {
            print("file not found")
            return nil
        }
        let filePathURL = NSURL.fileURL(withPath: filePath)
        var videoData: NSData? = nil
        do {
            videoData = try NSData(contentsOf: filePathURL, options: .mappedIfSafe)
            print("All done")
        } catch {
           print(error)
        }
        return videoData
    }
    
    //MARK: - Photo and Video fileprivate function
    fileprivate func getLastVideoLocalIdentifier() -> String {
        let options = PHFetchOptions.init()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let allVideos = PHAsset.fetchAssets(with: .video, options: options)
        allVideos.enumerateObjects { (asset, index, obj) in
            print(asset.localIdentifier, asset.creationDate!)
        }
        return allVideos.lastObject!.localIdentifier
    }
    
    fileprivate func getLastPhotoLocalIdentifier() -> String {
        let options = PHFetchOptions.init()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let allPhotos = PHAsset.fetchAssets(with: options)
        allPhotos.enumerateObjects { (asset, index, obj) in
            print(asset.localIdentifier, asset.creationDate!)
        }
        return allPhotos.lastObject!.localIdentifier
    }
}


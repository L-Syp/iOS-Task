//
//  ArticleDetailsViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class ArticleDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubishedAtLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var URLLabel: UILabel!
    @IBOutlet var rootView: UIView!
    
    // MARK: Properties
    var article: Article? = nil
    var image: UIImage? = nil
    var defaultImage: UIImage? = nil
    
    // MARK: Actions
    
    @IBAction func goToArticleButtnonTouch() {
        UIApplication.shared.open((article?.url)!, options: [:])
    }
    
    
    // MARK: Outlets
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewImage()
        titleLabel.text = article!.title
        pubishedAtLabel.text = "Published at: \(article!.publishedAt ?? "-")"
        descriptionLabel.text = article!.description ?? "No description available"
        authorLabel.text = "Author: \(article!.author ?? "-")"
        URLLabel.text = "URL: \(article!.url?.absoluteString ?? "No url available")"
    }

    // MARK: Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func deviceRotated(){
        setViewImage()
    }
    
    // MARK: Image setting functions
    fileprivate func setViewImage() {
        imageView.image = resizeImage(image!, targetSize: rootView.frame.size) ?? defaultImage!
        if image == defaultImage {
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}


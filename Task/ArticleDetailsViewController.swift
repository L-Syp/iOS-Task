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
    @IBOutlet var rootView: UIView!
    
    // MARK: Properties
    var article: Article? = nil
    var image: UIImage? = nil
    var defaultImage: UIImage? = nil
    var const: NSLayoutConstraint {
        get {
            return imageView.heightAnchor.constraint(lessThanOrEqualToConstant: rootView.frame.size.height * 0.75)
        }
    }
    
    // MARK: Actions
    @IBAction func goToArticleButtnonTouch() {
        UIApplication.shared.open((article?.url)!, options: [:])
    }
    
    // MARK: Outlets
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        const.isActive = true
        setViewImage(deviceOrientation: UIDevice.current.orientation)
        titleLabel.text = article!.title
        if let publishedAt = article!.publishedAt {
            pubishedAtLabel.text = "Published at: \(publishedAt[..<publishedAt.index(publishedAt.startIndex, offsetBy: 10)])"
        } else {
            pubishedAtLabel.text = "Published at: -"
        }
        descriptionLabel.text = article!.articleDescription ?? "No description available"
        setLabelWithBold(bold: "Author: ", normal: "\(article!.author ?? "-")", at: authorLabel )
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
        setViewImage(deviceOrientation: UIDevice.current.orientation)
    }
    
    fileprivate func setLabelWithBold(bold: String, normal: String, at label: UILabel) {
        let boldText  = "Author: "
        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        let normalText = "\(article!.author ?? "-")"
        let normalString = NSMutableAttributedString(string:normalText)
        attributedString.append(normalString)
        label.attributedText = attributedString
    }
    
    // MARK: Image setting functions
    func setViewImage(deviceOrientation: UIDeviceOrientation) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        image = image ?? defaultImage
        imageView.image = image
        if image == defaultImage { setResizedImage(image!, imageView: imageView, deviceOrientation: deviceOrientation, multiplier: 0.5)
        } else { setResizedImage(image!, imageView: imageView, deviceOrientation: deviceOrientation) }
        imageView.setNeedsDisplay()
        loadViewIfNeeded()
        setConstraints(to: imageView, with: const)
        print("IMAGE SIZE: \(imageView.image!.size)")
    }
    
    private func setResizedImage(_ image: UIImage, imageView: UIImageView, deviceOrientation: UIDeviceOrientation, multiplier: CGFloat = 1.0) {
        if deviceOrientation.isPortrait {
            let ratio = image.size.height / image.size.width
            let newSize = CGSize(width: rootView.frame.size.width * multiplier, height: rootView.frame.size.height * ratio * multiplier)
            imageView.image = image.resizeImage(targetSize: newSize) ?? defaultImage?.resizeImage(targetSize: newSize)!
        } else if deviceOrientation.isLandscape {
            let ratio =  image.size.width / image.size.height
            let newSize = CGSize(width: rootView.frame.size.height * ratio * multiplier, height: rootView.frame.size.width * multiplier)
            imageView.image = image.resizeImage(targetSize: newSize) ?? defaultImage?.resizeImage(targetSize: newSize)!
        }
    }
    
    private func setConstraints(to view: UIView, with constraint: NSLayoutConstraint) {
        view.translatesAutoresizingMaskIntoConstraints = false
        if !constraint.isActive {
            constraint.isActive = true
            
        }
        imageView.setNeedsUpdateConstraints()
        imageView.superview?.setNeedsUpdateConstraints()
    }
}


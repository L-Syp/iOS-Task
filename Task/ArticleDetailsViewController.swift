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
    
    // MARK: Actions
    @IBAction func goToArticleButtnonTouch() {
        UIApplication.shared.open((article?.url)!, options: [:])
    }
    
    // MARK: Outlets
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewImage()
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
        setViewImage()
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
    func setViewImage() {
        if let image = image{
            imageView.image = image.resizeImage(targetSize: rootView.frame.size) ?? defaultImage?.resizeImage(targetSize: CGSize(width: rootView.frame.width/4, height: rootView.frame.height/4))!
            //if image == defaultImage {
            //    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
            //}
        }
    }
    
}


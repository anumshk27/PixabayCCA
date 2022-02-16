//
//  DetailViewController.swift
//  Pixabay
//
//  Created by Muhammad Anum on 02/02/2022.
//

import UIKit



class DetailController: UIViewController {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet private weak var detailImage: UIImageView!
    @IBOutlet weak var downloadsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    var imageInfo: ImageInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    func configure () {
        
        self.title = "Details"
        userLabel.text = imageInfo.user

        detailImage.load(url: imageInfo.webformatURL!)
        profileView.layer.cornerRadius = profileView.frame.size.width/2
        profileView.clipsToBounds = true
        profileView.layer.borderColor = UIColor.darkGray.cgColor
        profileView.layer.borderWidth = 1.0
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.darkGray.cgColor
        profileImage.layer.borderWidth = 1.0
        
        if let urlString = imageInfo.userImageURL,
           let url = URL(string: urlString) {
            profileImage.load(url: url)
        }
        
        likesLabel.text = "\(imageInfo.likes.formattedWithSeparator) likes"
        viewsLabel.text = "\(imageInfo.views.formattedWithSeparator)"
        
        let button = UIButton()
        button.setImage(UIImage(named: "navigationBarBackImageBlack"), for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)

    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int{
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension UIImageView {
    func load (url: URL) {
        NetworkService.shared.loadImage(from: url) { [weak self] (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}

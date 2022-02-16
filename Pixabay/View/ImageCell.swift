//
//  ImageCell.swift
//  Pixabay
//
//  Created by Muhammad Anum on 02/02/2022.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
    
}

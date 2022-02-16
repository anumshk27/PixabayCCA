//
//  ImageViewController.swift
//  Pixabay
//
//  Created by Muhammad Anum on 02/02/2022.
//

import UIKit

class GalleryController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var activityIndicator = UIActivityIndicatorView()
    private var images: [UIImage?] = []
    private var imageInfo = [ImageInfo] ()
    
    private let spacing: CGFloat = 5
    private let numberOfItemsPerRow: CGFloat = 3
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        //getCachedImages()
        
        loadImages(query: "")
        
        
    }
    
    private func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.frame = collectionView.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.addSubview(activityIndicator)
        setupSearchController()
        
    }
    
    private func setupSearchController() {
        let searchC = UISearchController(searchResultsController: nil)
        searchC.searchBar.placeholder = "Search"
        //        searchC.searchResultsUpdater = self
        searchC.searchBar.delegate = self
        navigationItem.searchController = searchC
    }
    
    private func loadImages (query: String) {
        images.removeAll()
        updateUI()
        activityIndicator.startAnimating()
        NetworkService.shared.fetchImages(query: query, amount: 200) { (result) in
            self.activityIndicator.stopAnimating()
            switch result {
            case let .failure(error):
                let alerController = UIAlertController(title: "Warning", message: "No internet connection", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in }
                alerController.addAction(okAction)
                self.present(alerController, animated: true, completion: nil)
                print (error)
            case let .success(imagesInfo):
                self.imageInfo = imagesInfo
                self.images = Array(repeating: nil, count: self.imageInfo.count)
                self.updateUI()
            }
        }
    }
    
    private func updateUI() {
        self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
    }
    
    private func getCachedImages() {
        CacheManager.shared.getCachedImages { (images) in
            self.images = images
            self.updateUI()
        }
    }
    
    private func loadImage (for cell: ImageCell, at index: Int) {
        if let image = images [index] {
            cell.configure(with: image)
            return
        }
        
        let info = imageInfo[index]
        NetworkService.shared.loadImage(from: info.webformatURL) { (image) in
            if index < self.images.count {
                self.images[index] = image
                CacheManager.shared.cacheImage(image, with: info.id)
                cell.configure(with: self.images[index])
            }
        }
    }
}

//MARK:- Data Source & Delegate
extension GalleryController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            fatalError("Invalid Cell Kind")
        }
        
        loadImage(for: cell, at: indexPath.row)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dController = self.storyboard?.instantiateViewController(identifier: "DetailController") as! DetailController
        dController.imageInfo = imageInfo [indexPath.row]
        self.navigationController?.pushViewController(dController, animated: true)
    }
}

//MARK:- Flow Layout
extension GalleryController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.bounds.width
        let summarySpacing = spacing * (numberOfItemsPerRow - 1)
        let insets = 2 * spacing  // leftInset + rightInset (of section)
        let rawWidth = width - summarySpacing - insets
        let cellWidth = rawWidth / numberOfItemsPerRow
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: spacing,
                            left: spacing,
                            bottom: spacing,
                            right: spacing
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}

extension GalleryController: UISearchBarDelegate {
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.count >= 3 else {
            return
        }
        loadImages(query: query)
    }
}



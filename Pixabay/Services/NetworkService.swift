//
//  NetworkService.swift
//  Pixabay
//
//  Created by Muhammad Anum on 02/02/2022.
//

import UIKit

class NetworkService {
    
    private init () {}
    
    static let shared = NetworkService()
    
    private let apiKey = "2640910-8cf397490bdfd6c276c2d7c95"
    
    private var baseUrlComponents: URLComponents {
        var _urlComps = URLComponents(string: "https://pixabay.com")!
        _urlComps.path = "/api"
        _urlComps.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        
        return _urlComps
    }
    //    MARK: - Load Image
    func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
            
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            DispatchQueue.main.async {
                if let data = data {
                    completion(UIImage(data: data))
                } else {
                    completion(nil)
                }
                
            }
        } . resume()
    }
    //    MARK: - Fetch Images
    func fetchImages(query: String, amount: Int, completion: @escaping (Result<[ImageInfo], SessionError>) -> Void ) {
        var  urlComps = baseUrlComponents
        urlComps.queryItems? += [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "\(amount)"),
            URLQueryItem(name: "editors_choice", value: "\(true)"),
        ]
        
        guard let url = urlComps.url else{
            completion(.failure(.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.other(error)))
                }
                return
            }
            let response = response as! HTTPURLResponse
            guard let data = data, response.statusCode == 200 else {
                DispatchQueue.main.async{
                    completion(.failure(.serverError(response.statusCode)))
                }
                return
            }
            do {
                let serverResponse = try JSONDecoder().decode(ServerResponse<ImageInfo>.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(serverResponse.hits))
                }
            }
            catch let decodingError {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(decodingError)))
                }
            }
        } .resume()
    }
}

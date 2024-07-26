//
//  NetworkManager.swift
//  RESTApi-Practice
//
//  Created by Amish on 26/07/2024.
//

import SwiftUI
import Combine


class NetworkManager: ObservableObject {
    @Published var users: [UserModel] = []
    
    init() {
           fetchUser { result in
               switch result {
               case .success(let users):
                   DispatchQueue.main.async {
                       self.users = users
                   }
               case .failure:
                   DispatchQueue.main.async {
                       self.users = []
                   }
               }
           }
       }
    
    func fetchUser(completion: @escaping (Result<[UserModel], Error>) -> ()) {
        guard let url = URL(string: "https://66a3e00044aa63704582c25b.mockapi.io/bisckoot/v1/users") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error  in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let users = try JSONDecoder().decode([UserModel].self, from: data)
                completion(.success(users))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }.resume()
    }
    
    
    func postUser(newPhoto: NewUser, completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard let url = URL(string: "https://66a3e00044aa63704582c25b.mockapi.io/bisckoot/v1/users") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newPhoto)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let postedUser = try JSONDecoder().decode(UserModel.self, from: data)
                completion(.success(postedUser))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }.resume()
    }
    
    func deleteUser(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://66a3e00044aa63704582c25b.mockapi.io/bisckoot/v1/users/\(userId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    func putUser(updatedUser: UserModel, completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard let url = URL(string: "https://66a3e00044aa63704582c25b.mockapi.io/bisckoot/v1/users/\(updatedUser.id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedUser)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let updatedUser = try JSONDecoder().decode(UserModel.self, from: data)
                completion(.success(updatedUser))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }.resume()
    }
    
}

// Custom AsyncImage with caching support
struct CachedAsyncImage: View {
    @StateObject private var loader: ImageLoader
    
    init(url: URL?) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
        } else {
            ProgressView()
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL?
    private var cancellable: AnyCancellable?
    private static let imageCache = NSCache<NSURL, UIImage>()
    
    init(url: URL?) {
        self.url = url
        loadImage()
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        if let cachedImage = ImageLoader.imageCache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image = $0
                if let image = $0 {
                    ImageLoader.imageCache.setObject(image, forKey: url as NSURL)
                }
            }
    }
}


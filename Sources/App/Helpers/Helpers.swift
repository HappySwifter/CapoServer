//
//  Helpers.swift
//  App
//
//  Created by Артем Валиев on 10/12/2018.
//

import Foundation
import GraphQL
import Fluent
import Vapor


extension Map {
    func decode<T: Codable>(type: T.Type) throws -> T  {
        do {
            if let jsonData = self.description.data(using: .utf8) {
                return try JSONDecoder().decode(type, from: jsonData)
            } else {
                throw GraphQLError(message: "wrong format")
            }
        } catch {
            throw GraphQLError(message: "\(error)")
        }
        
    }
}

var dateFormatter: DateFormatter {
    get {
        let form = DateFormatter()
        form.dateFormat = "DD MMMM YYYY"
        return form
    }
}


func getUser(on req: Request) throws -> EventLoopFuture<User> {
    guard let bearer = req.http.headers["Authorization"].first,
        let range = bearer.range(of: "Bearer ") else {
            throw GraphQLError(message: "Invalid token")
    }
    let token = bearer[range.upperBound...]
    return UserToken.query(on: req).filter(\UserToken.string == String(token)).first().flatMap{ (userToken) in
        if let userToken = userToken {
            return userToken.user.get(on: req)
        } else {
            throw GraphQLError(message: "Invalid token")
        }
    }
}

class ImageUploader {
    func uploadImage(_ req: Request) throws -> Future<ImageUploadResponse> {
        return try req.content.decode(ImageRequest.self).map(to: ImageUploadResponse.self) { imageRequest in
            
            let workPath = DirectoryConfig.detect().workDir
            let imageFolder = "images/"
            let url = URL(fileURLWithPath: workPath)
                .appendingPathComponent("Public", isDirectory: true)
                .appendingPathComponent(imageFolder, isDirectory: true)
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError {
                throw Abort(.custom(code: 500, reasonPhrase: "Unable to create directory at url: \(url), reason:  \(error.debugDescription)"))
            }
            let name = UUID().uuidString
            let saveURL = url.appendingPathComponent(name, isDirectory: false)
            let pathEnd = imageFolder + name
            do {
                try imageRequest.imageData.write(to: saveURL)
                return ImageUploadResponse(url: pathEnd)
            } catch let error {
                throw Abort(.custom(code: 500, reasonPhrase: error.localizedDescription))
            }
        }
    }
    
    struct ImageUploadResponse: Content {
        var url: String
    }
    struct ImageRequest: Content {
        var imageData: Data
    }

}


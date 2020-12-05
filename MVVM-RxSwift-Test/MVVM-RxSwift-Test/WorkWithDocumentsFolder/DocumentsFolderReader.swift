//
//  DocumentsFolderReader.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 04.12.2020.
//

import Foundation
import RxSwift

enum DataType {
   case user
   case posts
   case comments
}

class DocumentsFolderReader {
   
   private static let entityRead = PublishSubject<Decodable>()
   
   static var neededEntity: Observable<Decodable> {
      return entityRead.asObservable()
   }
   
   class func readDataFromDocuments(for dataType:DataType, at url: URL) { //} -> T? {
      
      guard FileManager.default.fileExists(atPath: url.path) else {
         entityRead.onError(FileError.notExists(message: "file does not exist"))
         return
      }
      
      var result:Decodable?
      
      do {
         let data = try Data(contentsOf: url)
         
         switch dataType {
         case .posts:
            let posts = try JSONDecoder().decode([Post].self, from: data)
            result = posts.isEmpty ? nil : posts
         case .user:
            let user = try JSONDecoder().decode(User.self, from: data)
            result = user
         case .comments:
            let comments = try JSONDecoder().decode([Comment].self, from: data)
            result = comments.isEmpty ? nil : comments
         }
      }
      catch (let dataReadingError) {
         #if DEBUG
         print("DocumentsFolderReader -> ERROR decoding \(dataType) from file: \(dataReadingError.localizedDescription)")
         #endif
         entityRead.onError(dataReadingError)
      }
      
      if let rightResult = result {
         entityRead.onNext(rightResult) //success
      }
      else {
         entityRead.onError(FileError.failedToConvert)
      }
   }
}

//
//  StoragePaths.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

let baseURLString = "http://jsonplaceholder.typicode.com"

enum DocumentsURL {
   case posts
   case comments(Int)
   case user(Int)
}


func urlFor(_ docUrl:DocumentsURL) -> URL? {
   
   var result:URL?
   
   switch docUrl {
      case .posts:
         result = documentsURL()?.appendingPathComponent("Post")
      case .comments(let postId):
         result = documentsURL()?.appendingPathComponent("Comments-\(postId)")
      case .user(let userId):
         result = documentsURL()?.appendingPathComponent("User-\(userId)")
   }
   
   return result
}

fileprivate func documentsURL() -> URL? {
   var docsUrl:URL?
   
   let fileMan = FileManager.default
   
   guard let aUrl = fileMan.urls(for: .documentDirectory,
                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else {
                                    return nil
   }
   
   docsUrl = aUrl
   return docsUrl
}

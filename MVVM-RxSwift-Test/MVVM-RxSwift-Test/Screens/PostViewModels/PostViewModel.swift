//
//  PostViewModel.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 07.12.2020.
//

import Foundation

struct PostViewModel {
   
   private let post:Post
   
   var titleText:String {
      return post.title
   }
   
   var detailsText:String {
      return post.body
   }
   
   init(post:Post) {
      self.post = post
   }
}

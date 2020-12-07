//
//  PostsListViewModel.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 07.12.2020.
//

import Foundation
import RxSwift

final class PostsListViewModel {
   
   let title = "Posts"
   
   let postsService:PostsServiceType
   
   init(postsService:PostsServiceType = PostsService()) {
      self.postsService = postsService
   }
   
   func fetchPostViewModels() -> Observable<[PostViewModel]> {
      postsService.fetchPosts().map {
         $0.map { PostViewModel(post: $0) }
      }
   }
}

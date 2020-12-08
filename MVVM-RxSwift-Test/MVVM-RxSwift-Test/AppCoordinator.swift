//
//  AppCoordinator.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 07.12.2020.
//

import Foundation
import UIKit

protocol PostNavigation : class {
   func navigateToPost(_ post:Post)
}

class AppCoordinator {
   
   private let window:UIWindow
   
   init(window:UIWindow) {
      self.window = window
   }
   
   func start() {
      
      guard let postsListScreen =
               PostsListScreenViewController.create(viewModel:
                                                      PostsListViewModel(postsService: PostsService(),
                                                                         postNavigator: self)) else {
         return
      }
      
      let navigationController = UINavigationController(rootViewController: postsListScreen)
      
      window.rootViewController = navigationController
      window.makeKeyAndVisible()
   }
   
   private func showPostDetailsScreen(post:Post) {
      guard let navController = window.rootViewController as? UINavigationController else {
         return
      }
      
      let postDetailsScreen = PostDetailsScreenViewController.createWithPost(post)
      
      navController.pushViewController(postDetailsScreen, animated: true)
   }
   
   func showPostsListScreen() {
      
   }
}

extension AppCoordinator : PostNavigation {
   func navigateToPost(_ post: Post) {
      showPostDetailsScreen(post:post)
   }
}

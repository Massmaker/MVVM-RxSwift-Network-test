//
//  AppCoordinator.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 07.12.2020.
//

import Foundation
import UIKit

class AppCoordinator {
   
   private let window:UIWindow
   
   init(window:UIWindow) {
      self.window = window
   }
   
   func start() {
      
      guard let postsListScreen = PostsListScreenViewController.create(viewModel: PostsListViewModel()) else {
         return
      }
      
      let navigationController = UINavigationController(rootViewController: postsListScreen)
      
      window.rootViewController = navigationController
      window.makeKeyAndVisible()
   }
}

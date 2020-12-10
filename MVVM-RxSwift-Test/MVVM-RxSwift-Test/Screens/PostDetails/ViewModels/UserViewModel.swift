//
//  UserViewModel.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 09.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

class UserViewModel {
   
   private let userService = UsersService()
   
   var user:Driver<User> {
      return userService.fetchedUser.asDriver(onErrorJustReturn:User.defaultEmptyUser())
   }
   
   func fetchUser(with userId:Int) -> Bool {
      return userService.fetshUser(withId: userId)
   }
}

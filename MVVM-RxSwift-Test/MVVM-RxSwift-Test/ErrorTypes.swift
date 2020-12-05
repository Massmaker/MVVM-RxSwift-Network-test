//
//  ErrorTypes.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 05.12.2020.
//

import Foundation


enum FileError : Error {
   case notExists(message:String? = nil)
   case failedToConvert
}

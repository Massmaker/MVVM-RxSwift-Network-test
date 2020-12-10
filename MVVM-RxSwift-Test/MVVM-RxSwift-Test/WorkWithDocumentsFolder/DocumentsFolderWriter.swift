//
//  DocumentsFolderWriter.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 04.12.2020.
//

import Foundation
import RxSwift

class DocumentsFolderWriter {

   static private let writingQueue = DispatchQueue(label: "DocumentsWriting.queue", qos: DispatchQoS.utility, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
   
   
   class func writeEntity<T:Encodable>(_ entity:T, toURL fileURL:URL){
      
      writingQueue.async(flags: .barrier) {
         #if DEBUG
         print("--------\nDocumentsFolderWriter Begin writing \n - entity: '\(entity.debugName)'\n - to URL: \(fileURL)\n--------")
         #endif
         
         var didWrite = false
         
         do {
            let encodedData = try JSONEncoder().encode(entity)
            
            try encodedData.write(to: fileURL)
            
            didWrite = true
         }
         catch (let encodeError) {
            #if DEBUG
            print("DocumentsFolderWriter -> Encoding \(entity.self) error: \(encodeError.localizedDescription)")
            #endif
         }
         
         #if DEBUG
         print("\(self) - Did Write to file: '\(didWrite)'")
         #endif
      }
     
   }
}

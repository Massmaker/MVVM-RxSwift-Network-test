//
//  ViewController.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 04.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

class PostsListScreenViewController: UIViewController {

   let bag = DisposeBag()
   let postsRelay = BehaviorRelay<[Post]>(value:[])
   var postsResponse: Observable<[Post]>?
   
   @IBOutlet private weak var table:UITableView?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      subscribeOnPostsDidUpdate()
   }
   
   private func subscribeOnPostsDidUpdate() {
      //subscribe on posts received event
      let disposable = postsRelay.asObservable().subscribe { (posts) in
         
         print("Posts count: \(posts.count)")
         //TODO: reload table, subscribe on POST cell tap event
         
      } onError: { (postsError) in
         print("Posts Relay Error: \(postsError.localizedDescription)")
      } onCompleted: {
         print("Posts Relay completed")
      } onDisposed: {
         print("Posts Relay disposed")
      }
      .disposed(by: bag)

      
      postsResponse = createNetworkObservable()
      
      postsResponse?.subscribe(onNext: {[weak self] (event) in
         self?.postsRelay.accept(event)
      })
      .disposed(by: bag)
      
      
   }
   
   private func createNetworkObservable() -> Observable<[Post]>? {
      
      //create network request subscription if no data is on the disk
      guard let postsUrl = URL(string: "http://jsonplaceholder.typicode.com/posts") else {
         return nil
      }
      
      var request = URLRequest(url: postsUrl)
      request.setValue("application/json", forHTTPHeaderField: "ACCEPT")
      
      //create an observable - option 1 (more console debug output)
      let rxResponse = Observable.from(optional: postsUrl)
         .map { (url) -> URLRequest in
            var request = URLRequest(url: postsUrl)
            request.setValue("application/json", forHTTPHeaderField: "ACCEPT")
            return request
         }
         .flatMap { (request) in
            return URLSession.shared.rx.response(request: request)
         }
         .share(replay: 1, scope: SubjectLifetimeScope.forever)
         .filter { response, _ in
            return 200..<300 ~= response.statusCode
         }
         .map {  _ , data -> [Post] in
            do {
               let posts = try JSONDecoder().decode([Post].self, from: data)
               return posts
            }
            catch (let decodeError) {
               print("response on POSTS - decoding error: \(decodeError.localizedDescription)")
               return []
            }
         }
         .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
         .observe(on: MainScheduler.instance)

      return rxResponse
      
//      //create an observable - option 2 (less debug console output)
//      let ob:Observable<[Post]> = Observable.create { (observer) -> Disposable in
//
//         let task = URLSession.shared.dataTask(with: request) { (postsData, response, postsError) in
//
//
//            if let error = postsError {
//               observer.onError(error)
//            }
//            else if let httpResp = response as? HTTPURLResponse {
//               if httpResp.statusCode >= 200 && httpResp.statusCode < 300 {
//                  guard let data = postsData, !data.isEmpty else {
//                     //TODO: Return valid error
//                     return
//                  }
//
//                  do {
//                     let posts = try JSONDecoder().decode([Post].self, from: data)
//                     observer.onNext(posts) //success loading posts and returning
//                  }
//                  catch (let decodeError) {
//                     print("Posts Decoder Error: \(decodeError.localizedDescription)")
//                     //TODO: Return valid error
//                  }
//               }
//               else {
//                  // TODO: Return valid error
//               }
//            }
//         }
//
//         task.resume()
//
//         return Disposables.create {
//            task.cancel()
//         }
//      }
//      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
//      .observe(on: MainScheduler.instance)
//
//      return ob
   }
}


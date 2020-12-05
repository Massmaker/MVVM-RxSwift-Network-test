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
   
   let tableDataSource = BehaviorRelay<[Post]>(value:[])
   
   @IBOutlet private weak var table:UITableView?
   @IBOutlet private weak var postsCountLabel:UILabel?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      bindDataSource()
      
      subscribeOnPostsDidUpdate()
      
      subscribeOnReadFromDocuments()
      
      guard let postsURL = documentsURL()?.appendingPathComponent("Posts.bin") else {
         print("ERROR creating POSTs file URL")
         return
      }
      
      DispatchQueue(label: "ReaddPosts.background.queue").async {
         DocumentsFolderReader.readDataFromDocuments(for: .posts, at: postsURL)
      }
      
   }
   
   private func subscribeOnPostsDidUpdate() {
      
      //subscribe on posts received event
      postsRelay.asObservable().subscribe {[weak self] (posts) in
         
         let postsCount = posts.count
         //TODO: reload table, subscribe on POST cell tap event
         self?.postsCountLabel?.text = "Posts count: \(postsCount)"
         self?.tableDataSource.accept(posts) //reload tableView
         
      } onError: { (postsError) in
         print("Posts Relay Error: \(postsError.localizedDescription)")
      } onCompleted: {
         print("Posts Relay completed")
      } onDisposed: {
         print("Posts Relay disposed")
      }
      .disposed(by: bag)
      
   }
  
   private func tryToLoadPosts() {
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
         .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
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
   
   private func subscribeOnReadFromDocuments() {
      
      DocumentsFolderReader.neededEntity
         .subscribe(on:SerialDispatchQueueScheduler(qos: .default))
         .observe(on:MainScheduler.instance)
         .subscribe {[weak self] (decodable) in
            print("main thread: \(Thread.isMainThread)")
            if let posts = decodable as? [Post] {
               self?.postsRelay.accept(posts)
            }
            
      } onError: {[weak self] (error) in
         print("File POSTS reading error: \(error)")
         
         if let fileError = error as? FileError {
         
            switch fileError {
            case .failedToConvert:
               print("Unknown error while converting POSTs from disk")
            case .notExists(let message):
               if let errorMessage = message {
                  print(#function + " error message received: \(errorMessage)")
               }
               //make a netwotk request and try save to Disk later
               self?.tryToLoadPosts()
            }
         }
      } onCompleted: {
         print("File POSTS reading completed")
      } onDisposed: {
         print("File POSTS reading disposed")
      }
      .disposed(by: bag)
   }
   
   private func bindDataSource() {
      guard let tableView = table else {
         return
      }
      
      
      
      tableDataSource.bind(to:tableView.rx.items(cellIdentifier: "PostCell", cellType:UITableViewCell.self )) { index, post, cell in
         
         var state = cell.defaultContentConfiguration()
         
         state.text = post.title
         
         state.secondaryText = post.body
         
         cell.contentConfiguration = state
         
      }.disposed(by: bag)
   }
}


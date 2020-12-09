//
//  PostDetailsScreenViewController.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 08.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

class PostDetailsScreenViewController: UIViewController {

   let bag = DisposeBag()
   
   private var post:Post? {
      didSet {
         if let realPost = post {
            postViewModel = PostViewModel(post: realPost)
         }
      }
   }
   
   private var postViewModel:PostViewModel?
   
   private var commentsViewModel:CommentsViewModel!
   
   @IBOutlet private weak var ibPostTitleLabel:UILabel?
   @IBOutlet private weak var ibPostAuthorLabel:UILabel?
   @IBOutlet private weak var ibPostTextLabel:UILabel?
   @IBOutlet private weak var ibCommentsTable:UITableView?
   
   class func createWithPost(_ post:Post, coordinator:PostNavigation) -> PostDetailsScreenViewController {
      let instance = PostDetailsScreenViewController.init(nibName: "PostDetailsScreenViewController", bundle: nil)
      instance.post = post
      instance.commentsViewModel = CommentsViewModel(commentsService: CommentsService(), coordinator: coordinator)
      return instance
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      navigationController?.navigationBar.prefersLargeTitles = false
      
      ibCommentsTable?.register(UINib(nibName: "CommentViewCell", bundle: nil), forCellReuseIdentifier: CommentViewCell.reuseIdentifier)
      
      //fast answer to deselect cell on selection
      ibCommentsTable?.rx
         .setDelegate(self)
         .disposed(by: bag)
      
      // Do any additional setup after loading the view.
      if let aPost = post, let table = ibCommentsTable {
         
         commentsViewModel.comments
            .asObservable()
            .bind(to: table.rx.items(cellIdentifier: CommentViewCell.reuseIdentifier,
                                     cellType: CommentViewCell.self)) {_ , comment, cell in
               var state = cell.defaultContentConfiguration()
               
               state.text = comment.body
               
               state.secondaryText = comment.name
               
               cell.contentConfiguration = state
         }.disposed(by: bag)
   
         commentsViewModel.fetchComments(for: aPost.id)
      }
      
      ibPostTitleLabel?.text = post?.title
      ibPostTextLabel?.text = post?.body
      
      //TODO: Bind post author label to downloaded post author
   }
   
}

extension PostDetailsScreenViewController : UITableViewDelegate {
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
   }
}

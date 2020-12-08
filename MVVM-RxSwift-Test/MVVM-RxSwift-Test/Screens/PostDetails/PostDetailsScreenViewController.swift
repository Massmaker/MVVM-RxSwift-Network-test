//
//  PostDetailsScreenViewController.swift
//  MVVM-RxSwift-Test
//
//  Created by Ivan Yavorin on 08.12.2020.
//

import UIKit

class PostDetailsScreenViewController: UIViewController {

   private var post:Post?
   
   class func createWithPost(_ post:Post) -> PostDetailsScreenViewController {
      let instance = PostDetailsScreenViewController.init(nibName: "PostDetailsScreenViewController", bundle: nil)
      instance.post = post
      return instance
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Do any additional setup after loading the view.
   }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

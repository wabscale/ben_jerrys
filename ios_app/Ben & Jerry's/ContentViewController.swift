//
//  ContentViewController.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 8/3/16.
//  Copyright © 2016 JohnCunniff. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

/*
extension ContentViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
 */

class ContentViewController: UIViewController, UIScrollViewDelegate {
    
    // https://www.raywenderlich.com/122139/uiscrollview-tutorial
    // http://www.avocarrot.com/blog/implement-gesture-recognizers-swift/
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var image: UIImage? = nil
    
    //var imageNamed = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image: UIImage = self.image {
            self.imageView.image = image
        } else {
            self.imageView.image = UIImage()
        }
        self.imageView.frame = self.view.frame
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
    }
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { 
        return self.imageView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}

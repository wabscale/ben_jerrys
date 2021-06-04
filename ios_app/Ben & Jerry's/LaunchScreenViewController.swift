//
//  LaunchScreenViewController.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 1/3/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func makeLabel() {
        let imageView = UIImageView()
        let image = UIImage(named: "open.png")
        imageView.image = image!
        imageView.frame = CGRect(x: 0,
                                 y: (view.bounds.height - image!.size.height) / 2.0,
                                 width: image!.size.width,
                                 height: image!.size.height)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        view.addSubview(imageView)
    }

}

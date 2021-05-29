//
//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import MLKit
import UIKit

/// Main view controller class.
@objc(ViewController)
class ViewController: UIViewController, UINavigationControllerDelegate {

  /// A string holding current results from detection.
  var resultsText = ""

  /// An overlay view that displays detection annotations.
  private lazy var annotationOverlayView: UIView = {
    precondition(isViewLoaded)
    let annotationOverlayView = UIView(frame: .zero)
    annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
    annotationOverlayView.clipsToBounds = true
    return annotationOverlayView
  }()





  /// Initialized when one of the pose detector rows are chosen. Reset to `nil` when neither are.
  private var poseDetector: PoseDetector? = nil

    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var HowToPlay: UILabel!
    @IBOutlet weak var Info1: UILabel!
    @IBOutlet weak var Info2: UILabel!
    

  // MARK: - IBOutlets


  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
      self.navigationController!.navigationBar.shadowImage = UIImage()
      self.navigationController!.navigationBar.isTranslucent = true
//    StartButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
    view.addSubview(StartButton)
    view.addSubview(Logo)
    view.addSubview(HowToPlay)
    view.addSubview(Info1)
    view.addSubview(Info2)
    self.view.backgroundColor = .white
    
    
  }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        StartButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        Logo.center = CGPoint(x:view.frame.size.width/2, y: view.frame.size.height/2 - Logo.frame.height)
        HowToPlay.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 + HowToPlay.frame.size.height)
        Info1.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 + 2*Info1.frame.size.height)
        Info2.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 + 20 + 2*Info2.frame.size.height)
    }


  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.navigationBar.isHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    navigationController?.navigationBar.isHidden = false
  }
    
    @objc func openCamera(){
        let vc = CameraViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}



import MLKit
import UIKit

/// Main view controller class.
@objc(ViewController)
class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var startButton: UIButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    view.addSubview(startButton)

  }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        startButton.layer.cornerRadius = 50
        startButton.layer.borderWidth = 10
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.height/2)
    }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.navigationBar.isHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    navigationController?.navigationBar.isHidden = false
  }
    
}


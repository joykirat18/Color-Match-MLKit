

import AVFoundation
import CoreVideo
import MLKit

@objc(CameraViewController)
class CameraViewController: UIViewController {
  private let detectors: [Detector] = [
    .pose,
    .poseAccurate,
    ]

  private var currentDetector: Detector = .poseAccurate
  private var isUsingFrontCamera = true
    private var session: AVCaptureSession?
  private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
  private var lastFrame: CMSampleBuffer?
    
    @IBOutlet weak var LeftButton: UIButton!
    @IBOutlet weak var RightButton: UIButton!
    
    var output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()

  private lazy var previewOverlayView: UIImageView = {

    precondition(isViewLoaded)
    let previewOverlayView = UIImageView(frame: .zero)
    previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
    previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
    return previewOverlayView
  }()

  private lazy var annotationOverlayView: UIView = {
    precondition(isViewLoaded)
    let annotationOverlayView = UIView(frame: .zero)
    annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
    return annotationOverlayView
  }()

  /// Initialized when one of the pose detector rows are chosen. Reset to `nil` when neither are.
  private var poseDetector: PoseDetector? = nil

  /// The detector mode with which detection was most recently run. Only used on the video output
  /// queue. Useful for inferring when to reset detector instances which use a conventional
  /// lifecyle paradigm.
  private var lastDetector: Detector?

  // MARK: - IBOutlets

  @IBOutlet private weak var cameraView: UIView!

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    
//
    view.backgroundColor = .black
    view.layer.addSublayer(previewLayer)
    view.addSubview(LeftButton)
    view.addSubview(RightButton)
    checkCameraPermissions()

//    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//    setUpPreviewOverlayView()
    setUpAnnotationOverlayView()
    setUpCaptureSessionOutput()
    setUpCaptureSessionInput()
  }
    
    
    
    private func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async{
                    self.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera(){
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do{
                let input =  try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output){
                    session.addOutput((output))
                }
                previewLayer.videoGravity = .resizeAspectFill
               
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
                
            }catch{
                print(error)
            }
        }
    }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    startSession()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    stopSession()
  }
//
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    previewLayer.frame = view.frame
    
    LeftButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 - 300)
    LeftButton.backgroundColor = .red
    LeftButton.layer.borderWidth = 6.0
      LeftButton.layer.borderColor = UIColor.red.cgColor
      LeftButton.alpha = 0.3
    RightButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 + 300)
    RightButton.backgroundColor = .red
      RightButton.layer.borderWidth = 6.0
      RightButton.layer.borderColor = UIColor.red.cgColor
      RightButton.alpha = 0.3
  }

  // MARK: - IBActions

  @IBAction func switchCamera(_ sender: Any) {
    isUsingFrontCamera = !isUsingFrontCamera
    removeDetectionAnnotations()
    setUpCaptureSessionInput()
  }

  // MARK: On-Device Detections

  private func detectPose(in image: VisionImage, width: CGFloat, height: CGFloat) {
//    print(image)
    if let poseDetector = self.poseDetector {
      var poses: [Pose]
      do {
        poses = try poseDetector.results(in: image)
      } catch let error {
        print("Failed to detect poses with error: \(error.localizedDescription).")
        return
      }
      weak var weakSelf = self
      DispatchQueue.main.sync {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        strongSelf.updatePreviewOverlayViewWithLastFrame()
        strongSelf.removeDetectionAnnotations()
      }
      guard !poses.isEmpty else {
        print("Pose detector returned no results.")
        return
      }
      DispatchQueue.main.sync {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        // Pose detected. Currently, only single person detection is supported.
//        print(LeftButton.center) // 207,119
        print(RightButton.center) // 207, 719
        poses.forEach { pose in
            let lefthand = pose.landmark(ofType: .leftIndexFinger)
//            print(lefthand.position.x) //40 - 90
//            print(lefthand.position.y) // 150 - 200
//            print(LeftButton.center.x)
//            print(LeftButton.center.y)
            
            if (lefthand.position.x >= LeftButton.center.y - 80 && lefthand.position.x <= LeftButton.center.y - 30) && (lefthand.position.y >= LeftButton.center.x - 50 && lefthand.position.y <= LeftButton.center.x + 15 ){
                LeftButton.backgroundColor = .green
                LeftButton.layer.borderColor = UIColor.green.cgColor
            }else{
                LeftButton.backgroundColor = .red
                LeftButton.layer.borderColor = UIColor.red.cgColor
            }
            let righthand = pose.landmark(ofType: .rightIndexFinger)
            print(righthand.position.x) //370 - 440
            print(righthand.position.y) // 160 - 225
            if (righthand.position.x >= RightButton.center.y - 350 && righthand.position.x <= RightButton.center.y - 280) && (righthand.position.y >= RightButton.center.x - 50 && righthand.position.y <= RightButton.center.x + 15 ){
                RightButton.backgroundColor = .green
                RightButton.layer.borderColor = UIColor.green.cgColor
            }else{
                RightButton.backgroundColor = .red
                RightButton.layer.borderColor = UIColor.red.cgColor
            }
            
//            print(pose)
//          let poseOverlayView = UIUtilities.createPoseOverlayView(
//            forPose: pose,
//            inViewWithBounds: strongSelf.annotationOverlayView.bounds,
//            lineWidth: Constant.lineWidth,
//            dotRadius: Constant.smallDotRadius,
//            positionTransformationClosure: { (position) -> CGPoint in
//              return strongSelf.normalizedPoint(
//                fromVisionPoint: position, width: width, height: height)
//            }
//          )
//          strongSelf.annotationOverlayView.addSubview(poseOverlayView)
        }
      }
    }
  }

  // MARK: - Private

  private func setUpCaptureSessionOutput() {
    weak var weakSelf = self
    sessionQueue.async {
      guard let strongSelf = weakSelf else {
        print("Self is nil!")
        return
      }
        strongSelf.session?.beginConfiguration()
      // When performing latency tests to determine ideal capture settings,
      // run the app in 'release' mode to get accurate performance metrics
        strongSelf.session?.sessionPreset = AVCaptureSession.Preset.medium

      let output = AVCaptureVideoDataOutput()
      output.videoSettings = [
        (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
      ]
      output.alwaysDiscardsLateVideoFrames = true
      let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
      output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
        guard ((strongSelf.session?.canAddOutput(output)) != nil) else {
        print("Failed to add capture session output.")
        return
      }
      strongSelf.session?.addOutput(output)
        strongSelf.session?.commitConfiguration()
    }
  }

  private func setUpCaptureSessionInput() {
    weak var weakSelf = self
    sessionQueue.async {
      guard let strongSelf = weakSelf else {
        print("Self is nil!")
        return
      }
      let cameraPosition: AVCaptureDevice.Position = strongSelf.isUsingFrontCamera ? .front : .back
      guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
        print("Failed to get capture device for camera position: \(cameraPosition)")
        return
      }
      do {
        strongSelf.session?.beginConfiguration()
        let currentInputs = strongSelf.session!.inputs
        for input in currentInputs {
          strongSelf.session?.removeInput(input)
        }

        let input = try AVCaptureDeviceInput(device: device)
        guard ((strongSelf.session?.canAddInput(input)) != nil) else {
          print("Failed to add capture session input.")
          return
        }
        strongSelf.session?.addInput(input)
        strongSelf.session?.commitConfiguration()
      } catch {
        print("Failed to create capture device input: \(error.localizedDescription)")
      }
    }
  }

  private func startSession() {
    weak var weakSelf = self
    sessionQueue.async {
      guard let strongSelf = weakSelf else {
        print("Self is nil!")
        return
      }
      strongSelf.session?.startRunning()
    }
  }

  private func stopSession() {
    weak var weakSelf = self
    sessionQueue.async {
      guard let strongSelf = weakSelf else {
        print("Self is nil!")
        return
      }
        strongSelf.session?.stopRunning()
    }
  }

  private func setUpPreviewOverlayView() {
    view.addSubview(previewOverlayView)
    NSLayoutConstraint.activate([
      previewOverlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      previewOverlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      previewOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      previewOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

    ])
  }

  private func setUpAnnotationOverlayView() {
    view.addSubview(annotationOverlayView)
    NSLayoutConstraint.activate([
      annotationOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
      annotationOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      annotationOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      annotationOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    if #available(iOS 10.0, *) {
      let discoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: .unspecified
      )
      return discoverySession.devices.first { $0.position == position }
    }
    return nil
  }

  private func removeDetectionAnnotations() {
    for annotationView in annotationOverlayView.subviews {
      annotationView.removeFromSuperview()
    }
  }

  private func updatePreviewOverlayViewWithLastFrame() {
    guard let lastFrame = lastFrame,
      let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
    else {
      return
    }
    self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
  }

  private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
    guard let imageBuffer = imageBuffer else {
      return
    }
    let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
    let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
    previewOverlayView.image = image
  }

  private func convertedPoints(
    from points: [NSValue]?,
    width: CGFloat,
    height: CGFloat
  ) -> [NSValue]? {
    return points?.map {
      let cgPointValue = $0.cgPointValue
      let normalizedPoint = CGPoint(x: cgPointValue.x / width, y: cgPointValue.y / height)
      let cgPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
      let value = NSValue(cgPoint: cgPoint)
      return value
    }
  }
//
  private func normalizedPoint(
    fromVisionPoint point: VisionPoint,
    width: CGFloat,
    height: CGFloat
  ) -> CGPoint {
    let cgPoint = CGPoint(x: point.x, y: point.y)
    var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
    normalizedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
    return normalizedPoint
  }

  /// Resets any detector instances which use a conventional lifecycle paradigm. This method is
  /// expected to be invoked on the AVCaptureOutput queue - the same queue on which detection is
  /// run.
  private func resetManagedLifecycleDetectors(activeDetector: Detector) {
    if activeDetector == self.lastDetector {
      // Same row as before, no need to reset any detectors.
      return
    }
    // Clear the old detector, if applicable.
    switch self.lastDetector {
    case .pose, .poseAccurate:
      self.poseDetector = nil
      break
    default:
      break
    }
    // Initialize the new detector, if applicable.
    switch activeDetector {
    case .pose, .poseAccurate:
      let options = activeDetector == .pose ? PoseDetectorOptions() : AccuratePoseDetectorOptions()
      self.poseDetector = PoseDetector.poseDetector(options: options)
      break

    }
    self.lastDetector = activeDetector
  }
//
  private func rotate(_ view: UIView, orientation: UIImage.Orientation) {
    var degree: CGFloat = 0.0
    switch orientation {
    case .up, .upMirrored:
      degree = 90.0
    case .rightMirrored, .left:
      degree = 180.0
    case .down, .downMirrored:
      degree = 270.0
    case .leftMirrored, .right:
      degree = 0.0
    @unknown default:
        fatalError()

    }
    view.transform = CGAffineTransform.init(rotationAngle: degree * 3.141592654 / 180)
  }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      print("Failed to get image buffer from sample buffer.")
      return
    }
    // Evaluate `self.currentDetector` once to ensure consistency throughout this method since it
    // can be concurrently modified from the main thread.
    let activeDetector = self.currentDetector
    resetManagedLifecycleDetectors(activeDetector: activeDetector)

    lastFrame = sampleBuffer
    let visionImage = VisionImage(buffer: sampleBuffer)
    let orientation = UIUtilities.imageOrientation(
      fromDevicePosition: isUsingFrontCamera ? .front : .back
    )

    visionImage.orientation = orientation
    let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
    let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
    var shouldEnableClassification = false
    var shouldEnableMultipleObjects = false


    switch activeDetector {
    case .pose, .poseAccurate:
      detectPose(in: visionImage, width: imageWidth, height: imageHeight)
    }
  }
}

// MARK: - Constants

public enum Detector: String {

  case pose = "Pose Detection"
  case poseAccurate = "Pose Detection, accurate"

}

private enum Constant {
  static let alertControllerTitle = "Vision Detectors"
  static let alertControllerMessage = "Select a detector"
  static let cancelActionTitleText = "Cancel"
  static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
  static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
  static let noResultsMessage = "No Results"
  static let localModelFile = (name: "bird", type: "tflite")
  static let labelConfidenceThreshold = 0.75
  static let smallDotRadius: CGFloat = 4.0
  static let lineWidth: CGFloat = 3.0
  static let originalScale: CGFloat = 1.0
  static let padding: CGFloat = 10.0
  static let resultsLabelHeight: CGFloat = 200.0
  static let resultsLabelLines = 5
  static let imageLabelResultFrameX = 0.4
  static let imageLabelResultFrameY = 0.1
  static let imageLabelResultFrameWidth = 0.5
  static let imageLabelResultFrameHeight = 0.8
  static let segmentationMaskAlpha: CGFloat = 0.5
}


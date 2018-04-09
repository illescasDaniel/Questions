import UIKit
import AVFoundation
	
class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	// MARK: Properties
	
	@IBOutlet weak var allowCameraButton: UIButton!
	@IBOutlet weak var helpButton: UIButton!
	
	var captureDevice: AVCaptureDevice?
	var captureSession = AVCaptureSession()
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		self.loadTheme()
		self.view.dontInvertColors()
		
		let loadingCameraIndicator = UIActivityIndicatorView(frame: self.view.frame)
		self.allowCameraButton.isHidden = true
		self.view.addSubview(loadingCameraIndicator)
		loadingCameraIndicator.startAnimating()
		
		DispatchQueue.main.async {
			if #available(iOS 11.0, *) { self.navigationItem.largeTitleDisplayMode = .never }
			
			self.allowCameraButton.setTitle("Allow camera access".localized, for: .normal)
			
			self.captureDevice = AVCaptureDevice.default(for: .video)
			
			guard let captureDevice = self.captureDevice, let input = try? AVCaptureDeviceInput(device: captureDevice) else {
				self.allowCameraButton.isHidden = false
				loadingCameraIndicator.stopAnimating()
				return
			}
			
			self.captureSession.addInput(input)
			
			let captureMetadataOutput = AVCaptureMetadataOutput()
			self.captureSession.addOutput(captureMetadataOutput)
			
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
			captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
			
			self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
			self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
			self.loadPreview()
			
			if !self.captureSession.isRunning {
				self.captureSession.startRunning()
			}
			
			NotificationCenter.default.addObserver(self, selector: #selector(self.loadTheme), name: .UIApplicationDidBecomeActive, object: nil)
		}
	}

	override func viewWillLayoutSubviews() {
		loadPreview()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme), name: .UIApplicationDidBecomeActive, object: nil)
		loadTheme()
		
		guard self.captureDevice != nil else { return }
		
		DispatchQueue.main.async {
			if !self.captureSession.isRunning {
				self.captureSession.startRunning()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		DispatchQueue.main.async {
			if self.captureSession.isRunning {
				self.captureSession.stopRunning()
			}
		}
	}
	
	// MARK: AVCaptureMetadataOutputObjectsDelegate
	
	func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

		let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
		
		guard let metadata = metadataObject else { return }
		
		if metadata.type == AVMetadataObject.ObjectType.qr {
			
			guard let textFromCode = metadata.stringValue else { return }
			
			let quizContent: String
			if textFromCode.hasPrefix("http") || textFromCode.hasPrefix("https") || textFromCode.hasPrefix("www"),
			  let topicURL = URL(string: textFromCode), let validTextFromURL = try? String(contentsOf: topicURL) {
				quizContent = validTextFromURL
			} else {
				quizContent = textFromCode
			}
			
			guard let validContent = SetOfTopics.shared.quizFrom(content: quizContent) else { invalidQRCodeFormat(); return }
			
			self.captureSession.stopRunning()
			
			SetOfTopics.shared.save(topic: TopicEntry(name: "", content: validContent))
			FeedbackGenerator.notificationOcurredOf(type: .success)
			
			let openQuestionsAlert = UIAlertController(title: nil, message: "Open the first question set?".localized, preferredStyle: .alert)
			openQuestionsAlert.addAction(title: "Open it".localized, style: .default) { _ in
				self.performSegue(withIdentifier: "unwindToQuestions", sender: validContent)
			}
			openQuestionsAlert.addAction(title: "Keep scanning".localized, style: .cancel) { _ in
				self.captureSession.startRunning()
			}
			self.present(openQuestionsAlert, animated: true)
		}
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let content = sender as? Quiz, segue.identifier == "unwindToQuestions" {
			let controller = segue.destination as? QuestionsViewController
			controller?.isSetFromJSON = true
			controller?.set = content.sets[0]
		}
	}
	
	@IBAction func unwindToQRScanner(_ segue: UIStoryboardSegue) { }
	
	// MARK: Alerts
	
	@IBAction func helpButtonAction() {
		
		FeedbackGenerator.impactOcurredWith(style: .light)
		
		if let url = URL(string: "https://github.com/illescasDaniel/Questions#topics-json-format") {
			if #available(iOS 10.0, *) {
				UIApplication.shared.open(url, options: [:])
			} else {
				UIApplication.shared.openURL(url)
			}
		}
	}
	
	@IBAction func allowCameraAction() {
		let alertViewController = UIAlertController(title: "Attention".localized,
		                                            message: "Camera access required for QR Scanning".localized,
		                                            preferredStyle: .alert)
		
		alertViewController.addAction(title: "Cancel".localized, style: .cancel)
		alertViewController.addAction(title: "Allow Camera".localized, style: .default) { action in
			if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.shared.openURL(settingsURL)
			}
		}
		present(alertViewController, animated: true)
	}
	
	// MARK: Convenience
	
	@IBAction internal func loadPreview() {
		
		switch UIApplication.shared.statusBarOrientation {
		case .landscapeLeft:
			videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
		case .landscapeRight:
			videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
		default:
			videoPreviewLayer?.connection?.videoOrientation = .portrait
		}
		
		videoPreviewLayer?.frame = view.layer.bounds
		
		if let newLayer = videoPreviewLayer {
			view.layer.addSublayer(newLayer)
		}
		
		view.bringSubview(toFront: helpButton)
	}
	
	@IBAction internal func loadTheme() {
		navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		view.backgroundColor = .themeStyle(dark: .black, light: .black)
		self.allowCameraButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
		self.helpButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
	}
	
	func invalidQRCodeFormat() {
		self.captureSession.stopRunning()
		FeedbackGenerator.notificationOcurredOf(type: .error)
		let alertViewController = UIAlertController(title: "Attention", message: "Invalid QR Code format", preferredStyle: .alert)
		alertViewController.addAction(title: "OK", style: .default) { _ in
			self.captureSession.startRunning()
		}
		self.present(alertViewController, animated: true)
	}
}


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

		allowCameraButton.setTitle("Allow camera access".localized, for: .normal)
		
		captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		
		guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
		
		captureSession.addInput(input)
		
		let captureMetadataOutput = AVCaptureMetadataOutput()
		captureSession.addOutput(captureMetadataOutput)
		
		captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
		
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
		loadPreview()
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadPreview), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
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
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: AVCaptureMetadataOutputObjectsDelegate
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

		let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
		
		guard let metadata = metadataObject else { return }
		
		if metadata.type == AVMetadataObjectTypeQRCode {
			
			guard let data = metadata.stringValue.data(using: .utf8) else { invalidQRCodeFormat(); return }
			
			var content: [[String: Any]]?
			
			do {
				content = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]]
			} catch { invalidQRCodeFormat(); }
			
			guard let validContent = validQuestions(from: content) else { invalidQRCodeFormat(); return }
			
			performSegue(withIdentifier: "unwindToQuestions", sender: validContent)
			captureSession.stopRunning()
		}
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let content = sender as? [[String: Any]], segue.identifier == "unwindToQuestions" {
			let controller = segue.destination as! QuestionsViewController
			controller.isSetFromJSON = true
			controller.set = content as NSArray
		}
	}
	
	@IBAction func unwindToQRScanner(_ segue: UIStoryboardSegue) { }
	
	// MARK: Alerts
	
	@IBAction func helpButtonAction() {
		
		if #available(iOS 10.0, *), Settings.sharedInstance.hapticFeedbackEnabled {
			let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
			feedbackGenerator.impactOccurred()
		}
		
		let alertViewController = UIAlertController.OKAlert(title: "Text to encode format", message: "READ_QR_FORMAT")
		present(alertViewController, animated: true)
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
	
	private func validQuestions(from content: [[String: Any]]?) -> [[String: Any]]? {
		
		if let validContent = content, validContent.count > 0 {
			
			for question in validContent {
				guard let questionText = question["question"] as? String,
					let answers = question["answers"] as? [String],
					let correct = question["correct"] as? UInt8
					else { return nil }
				
				guard questionText.characters.count > 0, answers.count == 4, correct < 4 else { return nil }
				
				var isAnswersLenghtCorrect = true
				answers.forEach { if ($0.characters.count == 0) { isAnswersLenghtCorrect = false } }
				
				guard isAnswersLenghtCorrect else { return nil }
			}
			
			performSegue(withIdentifier: "unwindToQuestions", sender: validContent)
		}
		else { return nil }
		
		return content
	}
	
	internal func loadPreview() {
		
		switch UIApplication.shared.statusBarOrientation {
		case .landscapeLeft:
			videoPreviewLayer?.connection.videoOrientation = .landscapeLeft
		case .landscapeRight:
			videoPreviewLayer?.connection.videoOrientation = .landscapeRight
		default:
			videoPreviewLayer?.connection.videoOrientation = .portrait
		}
		
		videoPreviewLayer?.frame = view.layer.bounds
		
		if let newLayer = videoPreviewLayer {
			view.layer.addSublayer(newLayer)
		}
		
		view.bringSubview(toFront: helpButton)
	}
	
	internal func loadTheme() {
		
		navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		view.backgroundColor = .themeStyle(dark: .gray, light: .white)
		allowCameraButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
		helpButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
	}
	
	internal func invalidQRCodeFormat() {
		let alertViewController = UIAlertController.OKAlert(title: "Attention", message: "Invalid QR Code format")
		present(alertViewController, animated: true)
	}
}

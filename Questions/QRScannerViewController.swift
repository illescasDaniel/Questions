import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	// MARK: Properties
	
	@IBOutlet weak var allowCameraButton: UIButton!
	@IBOutlet weak var helpButton: UIButton!
	
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var codeIsRead = false
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		allowCameraButton.setTitle("Allow camera access".localized, for: .normal)
		
		let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		
		guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
		
		let captureSession = AVCaptureSession()
		captureSession.addInput(input)
		
		let captureMetadataOutput = AVCaptureMetadataOutput()
		captureSession.addOutput(captureMetadataOutput)
		
		captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
		
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
		loadPreview()
		
		captureSession.startRunning()
		
		view.bringSubview(toFront: helpButton)
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadPreview),
											   name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme),
		                                       name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
		loadTheme()
	}
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: AVCaptureMetadataOutputObjectsDelegate
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		
		let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
		
		guard !codeIsRead, let metadata = metadataObject else { return }
		
		if metadata.type == AVMetadataObjectTypeQRCode {
			
			guard let data = metadata.stringValue.data(using: .utf8) else { invalidQRCodeFormat(); return }

			var content: [[String: Any]]?
			
			do {
				content = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]]
			} catch { invalidQRCodeFormat(); }
			
			if let validContent = content {
				performSegue(withIdentifier: "unwindToQuestions", sender: validContent)
				codeIsRead = true
			}
			else { invalidQRCodeFormat(); }
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
		present(alertViewController, animated: true, completion: nil)
	}
	
	@IBAction func allowCameraAction() {
		let alertViewController = UIAlertController(title: "Attention".localized,
		                                            message: "Camera access required for QR Scanning".localized,
		                                            preferredStyle: .alert)
		
		alertViewController.addAction(title: "Cancel".localized, style: .cancel, handler: nil)
		alertViewController.addAction(title: "Allow Camera".localized, style: .default) { action in
			if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.shared.openURL(settingsURL)
			}
		}
		present(alertViewController, animated: true, completion: nil)
	}
	
	// MARK: Convenience
	
	func loadPreview() {
		
		switch UIDevice.current.orientation {
			case .portrait, .faceUp, .faceDown, .portraitUpsideDown, .unknown:
				videoPreviewLayer?.connection.videoOrientation = .portrait
			case .landscapeRight:
				videoPreviewLayer?.connection.videoOrientation = .landscapeLeft
			case .landscapeLeft:
				videoPreviewLayer?.connection.videoOrientation = .landscapeRight
		}
		videoPreviewLayer?.frame = view.layer.bounds
		
		if let newLayer = videoPreviewLayer {
			view.layer.addSublayer(newLayer)
		}
	}
	
	func loadTheme() {
		view.bringSubview(toFront: helpButton)
		navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		view.backgroundColor = .themeStyle(dark: .gray, light: .white)
		allowCameraButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
		helpButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
	}
	
	func invalidQRCodeFormat() {
		let alertViewController = UIAlertController.OKAlert(title: "Attention", message: "Invalid QR Code format")
		present(alertViewController, animated: true, completion: nil)
	}
}

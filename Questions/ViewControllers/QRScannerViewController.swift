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
			
			self.allowCameraButton.setTitle(Localized.ScanQR_Permissions_Camera_Access, for: .normal)
			
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
			
			NotificationCenter.default.addObserver(self, selector: #selector(self.loadTheme), name: UIApplication.didBecomeActiveNotification, object: nil)
		}
	}

	override func viewWillLayoutSubviews() {
		loadPreview()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme), name: UIApplication.didBecomeActiveNotification, object: nil)
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
			if #available(iOS 10.0, *) { FeedbackGenerator.notificationOcurredOf(type: .success) }
			
			let openQuestionsAlert = UIAlertController(title: nil, message: Localized.ScanQR_Alerts_Open_Title, preferredStyle: .alert)
			openQuestionsAlert.addAction(title: Localized.ScanQR_Alerts_Open_OpenIt, style: .default) { _ in
				self.performSegue(withIdentifier: "unwindToQuestions", sender: validContent)
			}
			openQuestionsAlert.addAction(title: Localized.ScanQR_Alerts_Open_KeepScanning, style: .cancel) { _ in
				self.captureSession.startRunning()
			}
			self.present(openQuestionsAlert, animated: true)
		}
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let content = sender as? Topic, segue.identifier == "unwindToQuestions" {
			let controller = segue.destination as? QuestionsViewController
			controller?.isSetFromJSON = true
			controller?.set = content.sets[0]
		}
	}
	
	@IBAction func unwindToQRScanner(_ segue: UIStoryboardSegue) { }
	
	// MARK: Alerts
	
	@IBAction func helpButtonAction() {
		
		if #available(iOS 10.0, *) { FeedbackGenerator.impactOcurredWith(style: .light) }
		
		if let url = URL(string: "https://github.com/illescasDaniel/Questions#topics-json-format") {
			if #available(iOS 10.0, *) {
				UIApplication.shared.open(url, options: [:])
			} else {
				UIApplication.shared.openURL(url)
			}
		}
	}
	
	@IBAction func allowCameraAction() {
		let alertViewController = UIAlertController(title: Localized.Common_Attention,
		                                            message: Localized.ScanQR_Permissions_Camera_Description,
		                                            preferredStyle: .alert)
		
		alertViewController.addAction(title: Localized.Common_Cancel, style: .cancel)
		alertViewController.addAction(title: Localized.ScanQR_Permissions_Camera_Access, style: .default) { action in
			if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
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
		
		view.bringSubviewToFront(helpButton)
	}
	
	@IBAction internal func loadTheme() {
		
		self.view.backgroundColor = .themeStyle(dark: .black, light: .black)
		self.allowCameraButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
		self.helpButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
			self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		}
	}
	
	func invalidQRCodeFormat() {
		self.captureSession.stopRunning()
		if #available(iOS 10.0, *) { FeedbackGenerator.notificationOcurredOf(type: .error) }
		let alertViewController = UIAlertController(title: Localized.Common_Attention, message: Localized.ScanQR_Error_InvalidFormat, preferredStyle: .alert)
		alertViewController.addAction(title: Localized.Common_OK, style: .default) { _ in
			self.captureSession.startRunning()
		}
		self.present(alertViewController, animated: true)
	}
}


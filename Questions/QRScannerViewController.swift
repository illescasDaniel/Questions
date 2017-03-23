import UIKit
import AVFoundation

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	// MARK: Properties
	
	@IBOutlet weak var allowCameraButton: UIButton!
	
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var codeIsRead = false
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		allowCameraButton.setTitle("Allow camera access".localized, for: .normal)
		
		if !self.codeIsRead {
			
			let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
			let input: AVCaptureInput?
				
			do { input = try AVCaptureDeviceInput(device: captureDevice) }
			catch { return }
			
			let captureSession = AVCaptureSession()
			captureSession.addInput(input)
			
			let captureMetadataOutput = AVCaptureMetadataOutput()
			captureSession.addOutput(captureMetadataOutput)
			
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
			
			self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
			self.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
			self.loadPreview()
			
			captureSession.startRunning()
			
			NotificationCenter.default.addObserver(self, selector: #selector(self.loadPreview),
												   name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		loadTheme()
	}
	
	// MARK: AVCaptureMetadataOutputObjectsDelegate
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		
		if !codeIsRead {
			
			let metadataObj = metadataObjects.first as! AVMetadataMachineReadableCodeObject
			
			if metadataObj.type == AVMetadataObjectTypeQRCode {
				
				// READ JSON format
				
				if let data = metadataObj.stringValue.data(using: .utf8) {
					let content = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String: Any]]
					performSegue(withIdentifier: "unwindToQuestions", sender: content)
					codeIsRead = true
				}
			}
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
		self.present(alertViewController, animated: true, completion: nil)
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
		let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled
		self.navigationController?.navigationBar.barStyle = darkThemeEnabled ? .black : .default
		self.navigationController?.navigationBar.tintColor = darkThemeEnabled ? .orange : .defaultTintColor
		view.backgroundColor = darkThemeEnabled ? .gray : .white
		allowCameraButton.setTitleColor(darkThemeEnabled ? .warmYellow : .coolBlue, for: .normal)
	}
}

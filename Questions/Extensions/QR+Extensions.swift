//
//  QR+Extensions.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 21/05/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

typealias Scale = (width: CGFloat, height: CGFloat)
typealias Color = (FG: CIColor, BG: CIColor)

extension String {
	
	func generateQRImageWith(size: Scale, color: Color = (FG: .black, BG: .white)) -> UIImage? {
		
		let data = self.data(using: .utf8)
		
		guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
		
		filter.setValue(data, forKey: "inputMessage")
		filter.setValue("L", forKey: "inputCorrectionLevel")
		
		guard let QRCodeImage = filter.outputImage else { return nil }
		
		let scaledX = size.width / QRCodeImage.extent.width
		let scaledY = size.height / QRCodeImage.extent.height
		
		let coloredQR = filter.colorImageWith(color: (FG: color.FG, BG: color.BG))
		
		return coloredQR?.nonInterpolatedImageWith(scale: (width: scaledX, height: scaledY))
	}
}

extension CIImage {
	func nonInterpolatedImageWith(scale: Scale) -> UIImage? {
		
		guard let cgImage = CIContext().createCGImage(self, from: extent) else { return nil }
		
		let size = CGSize(width: extent.size.width * scale.width, height: extent.size.height * scale.height)
		
		UIGraphicsBeginImageContextWithOptions(size, true, 0)
		
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		
		context.interpolationQuality = .none
		context.translateBy(x: 0, y: size.height)
		context.scaleBy(x: 1.0, y: -1.0)
		context.draw(cgImage, in: context.boundingBoxOfClipPath)
		
		let finalImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return finalImage
	}
}

extension CIFilter {
	
	func colorImageWith(color: Color) -> CIImage? {
		
		guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
		
		colorFilter.setDefaults()
		colorFilter.setValue(self.outputImage, forKey: "inputImage")
		colorFilter.setValue(color.FG, forKey: "inputColor0")
		colorFilter.setValue(color.BG, forKey: "inputColor1")
		
		return colorFilter.outputImage
	}
}

extension CIColor {
	
	static let white = CIColor(red: 1, green: 1, blue: 1)
	static let black = CIColor(red: 0, green: 0, blue: 0)
	
	static let red = CIColor(RGBred: 198, green: 26, blue: 36)
	static let blue = CIColor(RGBred: 23, green: 95, blue: 199)
	static let green = CIColor(RGBred: 46, green: 126, blue: 46)
	
	convenience init(RGBred: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 255) {
		self.init(red: RGBred/255, green: green/255, blue: blue/255, alpha: alpha/255)
	}
}


//
//  ImageSampling.swift
//  FunWithAccelerateFramework
//
//  Created by Gregory Boland on 2/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit
import Accelerate

extension UIImage {

    open func scale(to size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let sourceRef: CGImage = cgImage
        var format: vImage_CGImageFormat = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuffer: vImage_Buffer = vImage_Buffer()
        
        defer {
            sourceBuffer.data.deallocate(bytes: Int(sourceBuffer.height) * Int(sourceBuffer.height) * 4, alignedTo: 0)
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        //TODO: not sure we need to scale it according to the screen size as we'll be sending this to a service, we only car about filesize
        
        let scale = UIScreen.main.scale
        let destWidth = Int(size.width * scale)
        let destHeight = Int(size.height * scale)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        
        defer {
            destData.deallocate(capacity: destHeight * destBytesPerRow)
        }
        
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        //NOW We SCALE IT
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        
        //AND CREATE IT
        let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)
        guard error == kvImageNoError else { return nil }
        
        
        return destCGImage.flatMap {
            UIImage(cgImage: $0.takeRetainedValue(), scale: 0.0, orientation: self.imageOrientation)
        }
    }
    
    open var fileSize: Int {
        guard let cgImage = self.cgImage else { return 0 }
        let byteSize: Int = cgImage.height * cgImage.bytesPerRow
        return byteSize
    }
    
}

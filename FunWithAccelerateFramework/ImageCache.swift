//
//  ImageCache.swift
//  Zion
//
//  Abstract: Class to add and (eventually) remove images from the ImageCache.  In the case of food photos, we'll eventually want to keep a limited number of images in there.
//
//  Created by Kristina M Brimijoin on 2/18/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class ImageCache: NSObject {
    
    /**
     Returns the path to the food directory in the application's Caches Directory.  If the food directory 
     doesn't exist, it is created.
     */
    static var directoryPath: URL {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true)
        let cachePath = paths[0]
        var path = URL(fileURLWithPath: cachePath)
        path = path.appendingPathComponent("images")
        if !FileManager.default.fileExists(atPath: path.path) {
            //if /food directory doesn't exist, create it
            do {
                try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                //TODO: something other than this?  probably need to not make this a computed property since
                //Swift doesn't yet support error throwing in getters/setters
                print("Error: could not create directory in CachesDirectory")
            }
        }
        return path
    }
    
    /**
     Saves UIImage as JPG to the ImageCache directory; gives it a name with the formatted imageDate
     
     - parameter image: UIImage
     - parameter imageDate: date from which to form file name
     */
    static func saveToImageCache(image: UIImage, fileName: String) throws -> String {
        let imageFileName = fileName
        let pngData = UIImageJPEGRepresentation(image, 1.0)
        let path = ImageCache.directoryPath.appendingPathComponent(fileName)
        print("path thats saved \(path)")
        do {
            try pngData?.write(to: path)
            return imageFileName
        }
    }
    
    /**
     Retrieves jpg data from ImageCache directory and converts it into a UIImage
     
     - parameter entryDate: date image was taken
     - parameter tags: path to where the image lives
     - parameter tags: tags someone added to describe it
     */
    //TODO: should this throw instead of return nil?
    static func getImageFromCache(imageName: String) throws -> UIImage? {
        let filePath = "\(ImageCache.directoryPath)\(imageName)"
        let jpgData = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let image = UIImage(data: jpgData as Data)
        return image
    }
    
    static func imageData(from name: String) throws -> Data {
        print("name \(name)")
        let url = ImageCache.directoryPath.appendingPathComponent(name)
        let data = try Data(contentsOf: url)
        print("data \(data)")
        return data
    }
    
    static func image(from name: String) -> UIImage? {
        let url = ImageCache.directoryPath.appendingPathComponent(name)
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        return image
    }
}

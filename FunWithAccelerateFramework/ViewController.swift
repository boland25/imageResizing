//
//  ViewController.swift
//  FunWithAccelerateFramework
//
//  Created by Gregory Boland on 2/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var index: Int = 0
    var timer: DispatchSourceTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        seedImages()
        loadImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage(fileName: String) -> Void {
        var image = ImageCache.image(from: fileName)
        
        let reSizedImage = image?.scale(to: CGSize(width: 500.0, height: 100.0))
        DispatchQueue.main.async { [weak self] in
            if let thisSelf = self {
                thisSelf.imageView.image = reSizedImage
            }
            
        }
        print("re-sized image \(reSizedImage?.size.width) and \(reSizedImage?.size.height)")
        
        if let sizedImage = reSizedImage, let ddata = UIImageJPEGRepresentation(sizedImage, 1.0) {
            let imageSize: Double = Double(ddata.count) * 0.000001
            print("DATA COMPUTED SIZE \(imageSize)")
            image = nil
        }
        print("Extension FileSize \(reSizedImage?.fileSize)")
    }
    
    func loadImages() -> Void {
        startTimer()
    }
    
    func seedImages() -> Void {
        for incrementIndex in 0...9 {
            let fileName = "DJI_000" + String(incrementIndex)
            if let image = UIImage(named: fileName) {
                do {
                    let resultName = try ImageCache.saveToImageCache(image: image, fileName: fileName)
                    print("new name \(resultName)")
                } catch {
                    print("no dice")
                }
            }
        }
    }
    
    func startTimer() -> Void {
        let queue = DispatchQueue(label: "timer.queue", attributes: .concurrent)
        timer?.cancel()
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(2), leeway: .seconds(1))
        timer?.setEventHandler { [weak self] in
            if let thisSelf = self {
                let imageName = "DJI_000" + String(thisSelf.index)
                print("imageName \(imageName)")
                thisSelf.loadImage( fileName: imageName)
                if thisSelf.index == 9 {
                    thisSelf.stopTimer()
                }
                thisSelf.index += 1
            }
        }
        timer?.resume()
    }
    
    func stopTimer() -> Void {
        timer?.cancel()
        timer = nil
    }

}


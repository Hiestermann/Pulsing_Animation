//
//  ViewController.swift
//  Pulsing_Animation
//
//  Created by Kilian on 17.12.17.
//  Copyright © 2017 Kilian. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    var downloading = false
    
    var pulsatingLayer: CAShapeLayer!

    var shapeLayer = CAShapeLayer()
    
    let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    
    private func createCircleShapeLayer() -> CAShapeLayer{
        let layer = CAShapeLayer()
        layer.path = circularPath.cgPath
        layer.fillColor = UIColor.red.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = view.center
        layer.opacity = 0.5
        return layer
    }
    private func creacteshapeLayer() -> CAShapeLayer{
        let layer = CAShapeLayer()
        layer.path = circularPath.cgPath
        layer.strokeColor = UIColor.red.cgColor
        layer.lineWidth = 10
        layer.fillColor = UIColor.black.cgColor
        layer.lineCap = kCALineCapRound
        layer.strokeEnd = 0
        layer.position = view.center
        layer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        return layer
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObservers()
        
        view.backgroundColor = .black
        
        pulsatingLayer = createCircleShapeLayer()
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        shapeLayer = creacteshapeLayer()
        view.layer.addSublayer(shapeLayer)
        
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
    }
    
    private func animatePulsatingLayer(){
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.5
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    private func beginDownloadinFile(){
        
        shapeLayer.strokeEnd = 0
        
        let urlString = "https://www.videvo.net/?page_id=123&desc=Blue_Sky_and_Clouds_Timelapse_0892__Videvo.mov&vid=2299"
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: urlString) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }

    fileprivate func animationCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
        
    }
    
    @objc private func handleTap() {
        
        if (!downloading){
            beginDownloadinFile()
            downloading = true
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finisched Downloadling")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.shapeLayer.strokeEnd = percentage
            self.percentageLabel.text = "\(Int(percentage * 100))%"
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
}


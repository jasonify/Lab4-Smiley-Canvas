//
//  ViewController.swift
//  SmileyCanvas
//
//  Created by Rahul Pandey on 11/3/16.
//  Copyright © 2016 Rahul Pandey. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    var trayOriginalCenter: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    var trayCenterWhenClosed: CGPoint!
    var originalFaceDimensions: CGFloat!
    
    var newlyCreatedFace: UIImageView!
    
    @IBOutlet weak var happyFace: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        trayCenterWhenOpen = CGPoint(x: trayView.center.x, y: trayView.center.y)
        trayCenterWhenClosed = CGPoint(x: trayView.center.x, y: trayCenterWhenOpen.y + trayView.frame.size.height * 0.8)
        originalFaceDimensions = happyFace.frame.size.width
        print("face dimen: \(originalFaceDimensions)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onPanImage(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let point = panGestureRecognizer.location(in: view)
        if panGestureRecognizer.state == .began {
            
            // Gesture recognizers know the view they are attached to
            let imageView = panGestureRecognizer.view as! UIImageView
            
            // Create a new image view that has the same image as the one currently panning
            newlyCreatedFace = UIImageView(image: imageView.image)
            
            // Add the new face to the tray's parent view.
            view.addSubview(newlyCreatedFace)
            
            // Initialize the position of the new face.
            newlyCreatedFace.center = imageView.center
            
            // Since the original face is in the tray, but the new face is in the
            // main view, you have to offset the coordinates
            newlyCreatedFace.center.y += trayView.frame.origin.y
        } else if panGestureRecognizer.state == .changed {
            newlyCreatedFace.center = point
        } else if panGestureRecognizer.state == .ended {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.faceDragged(panGestureRecognizer:)))
            newlyCreatedFace.addGestureRecognizer(pan)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.faceRotated))
            newlyCreatedFace.addGestureRecognizer(rotate)
            
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.facePinched))
            newlyCreatedFace.addGestureRecognizer(pinch)

            pinch.delegate = self
            newlyCreatedFace.isUserInteractionEnabled = true
        }
    }
    
    func faceRotated(rotationGestureRecognizer: UIRotationGestureRecognizer) {
        var transform = rotationGestureRecognizer.view!.transform
        transform = transform.rotated(by: rotationGestureRecognizer.rotation)
        rotationGestureRecognizer.view!.transform = transform
        rotationGestureRecognizer.rotation = 0
    }
    
    func facePinched(pinchGestureRecognizer: UIPinchGestureRecognizer) {
        let scale = pinchGestureRecognizer.scale
        pinchGestureRecognizer.scale = 1
        
        var transform = pinchGestureRecognizer.view!.transform
        transform = transform.scaledBy(x: scale, y: scale)
        pinchGestureRecognizer.view!.transform = transform
    }
    
    func faceDragged(panGestureRecognizer: UIPanGestureRecognizer) {
        let imageView = panGestureRecognizer.view as! UIImageView
        let point = panGestureRecognizer.location(in: view)
        if panGestureRecognizer.state == .began {
            // do nothing
        } else if panGestureRecognizer.state == .changed {
            imageView.center = point
        } else if panGestureRecognizer.state == .ended {
            // do nothing
        }
    }
    
    @IBAction func onTrayPanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: view)
        let velocity = panGestureRecognizer.velocity(in: view)
        
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        let point = panGestureRecognizer.location(in: view)
        
        if panGestureRecognizer.state == .began {
            print("Gesture began at: \(point)")
            trayOriginalCenter = trayView.center
        } else if panGestureRecognizer.state == .changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            print("Gesture changed at: \(point)")
        } else if panGestureRecognizer.state == .ended {
            UIView.animate(withDuration: 0.3, animations: { 
                if velocity.y > 0 {
                    self.trayView.center = self.trayCenterWhenClosed
                } else {
                    self.trayView.center = self.trayCenterWhenOpen
                }
            })
            print("Gesture ended at: \(point)")
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


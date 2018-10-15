//
//  CanvasViewController.swift
//  Canvas
//
//  Created by Ka Lee on 10/8/18.
//  Copyright © 2018 Ka Lee. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController{

    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var arrow: UIImageView!
    
    @IBAction func didPanTray(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            trayOriginalCenter = trayView.center
            
            print("Gesture began")
        } else if sender.state == .changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            arrow.transform = CGAffineTransform(rotationAngle: CGFloat(180 * Double.pi / 180))

            print("Gesture is changing")
        } else if sender.state == .ended {
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options:[] , animations: { () -> Void in
                    self.trayView.center = self.trayDown
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                    self.trayView.center = self.trayUp
                    self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(0 * Double.pi / 180))
                }, completion: nil)
            }
            trayView.backgroundColor = getRandomColor()
            print("Gesture ended")
        }
        

    }
    
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayDownOffset = 270
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset)
        
    }
    @IBAction func didPanFace(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let newFaceGesture = UIPanGestureRecognizer(target: self, action: #selector(newPanFace(_: )))
        let deleteFace = UITapGestureRecognizer(target: self, action: #selector(noFace(_:)))
        deleteFace.numberOfTapsRequired = 2
        
        let pinchFace = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        let rotateFace = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))

        if sender.state == .began {
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            newlyCreatedFace.center = imageView.center
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            
            UIView.animate(withDuration: 0.2, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
            
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.addGestureRecognizer(newFaceGesture)
            newlyCreatedFace.addGestureRecognizer(deleteFace)
            newlyCreatedFace.addGestureRecognizer(pinchFace)
            newlyCreatedFace.addGestureRecognizer(rotateFace)

        } else if sender.state == .changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)

            
        } else if sender.state == .ended {
            newlyCreatedFace.image = newlyCreatedFace.image!.withRenderingMode(.alwaysTemplate)
            newlyCreatedFace.tintColor = getRandomColor()
            UIView.animate(withDuration: 0.4, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            if (newlyCreatedFace.frame.origin.y > trayView.frame.origin.y) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.newlyCreatedFace.center = self.newlyCreatedFaceOriginalCenter
                }, completion: { finished in
                    if finished {
                        self.newlyCreatedFace.removeFromSuperview()
                    }
                })
            }
        }
    }
    
    @objc func newPanFace(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            newlyCreatedFace = sender.view as! UIImageView
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
        }
        else if sender.state == .changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        }
        else if sender.state == .ended {
            if (newlyCreatedFace.frame.origin.y > trayView.frame.origin.y) {
                UIView.animate(withDuration: 2, animations: {
                    self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 0, y: 0)
                }, completion: { finished in
                    if finished {
                        self.newlyCreatedFace.removeFromSuperview()
                    }
                })
            }
        }
    }
    @objc func noFace(_ sender: UIPanGestureRecognizer){
        newlyCreatedFace.removeFromSuperview()
    }
    
    @objc func didPinch(_ sender: UIPinchGestureRecognizer){
        let scale = sender.scale
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }
    
    @objc func didRotate(_ sender: UIRotationGestureRecognizer){
        let rotation = sender.rotation
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.rotated(by: rotation)
        sender.rotation = 0
    }
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

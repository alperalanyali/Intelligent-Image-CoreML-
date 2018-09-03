//
//  ViewController.swift
//  Intelligent Image(CoreML)
//
//  Created by Alper on 3.09.2018.
//  Copyright © 2018 Alper. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    var chosenImage = CIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultLabel.alpha = 0
        
        
    }

    @IBAction func changeClicked(_ sender: Any) {
        resultLabel.alpha = 1
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            self.chosenImage = ciImage
        }
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage){
        resultLabel.text = "Finding..."
        
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    let topResult = results.first
                    
                    DispatchQueue.main.async {
                        
                        let conf = (topResult?.confidence)! * 100
                        
                        let rounded = Int(conf * 100) / 100
                        
                        self.resultLabel.text = "\(rounded)% it's a/an \(topResult!.identifier) "
                        
                    }
                }
            }
            let handler  = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("We have error in handler!!")
                }
            }
                
            
            
        }
    }

}


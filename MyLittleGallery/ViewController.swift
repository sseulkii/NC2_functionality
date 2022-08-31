//
//  ViewController.swift
//  MyLittleGallery
//
//  Created by Seulki Lee on 2022/08/29.
//

import UIKit
import CoreML
import Vision
import VideoToolbox

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var userPickedArtist = ""
    
    let mlModels = [
        "Monet": GalleryStyleTransferMonet().model,
        "Degas": GalleryStyleTransferRenoir().model,
        "Renoir": GalleryStyleTransferVanGogh().model,
        "Manet": GalleryStyleTransferDegas().model,
        "Cassat": GalleryStyleTransferManet().model,
        "Morisot": GalleryStyleTransferCezanne().model,
        "Sisley": GalleryStyleTransferMatisse().model
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("could not convert to CIImage")
            }
            
            guard let artistModel = mlModels[userPickedArtist] else {
                fatalError("could not convert mlmodel")
            }
            convert(image: ciImage, transferModel: artistModel)

        }
        
        imagePicker.dismiss(animated: true)
    }
    
    func convert(image: CIImage, transferModel: MLModel) {
        
        guard let model = try? VNCoreMLModel(for: transferModel) else {
            fatalError("could not load model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let transfer = request.results as? [VNPixelBufferObservation] else {
                fatalError("could not transfer image style")
            }
            
            guard let image = transfer.first?.pixelBuffer else {
                fatalError("error processing image style transfer")
            }
            
            self.imageView.image = UIImage(pixelBuffer: image)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
        userPickedArtist = (sender.titleLabel?.text)!
        
    }
    
    

    @IBAction func showOnWall(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toARView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toARView" {
            let destinationVC = segue.destination as! GalleryViewController
            destinationVC.image = imageView.image
        }
    }
    
    
    
    
}

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}

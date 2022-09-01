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
    
    var pickedImage: UIImage?
    
    let imagePicker = UIImagePickerController()
    
    var userPickedArtist = ""
    
    // 이름 하드코딩한거 리팩토링하자
    let mlModels = [
        "Monet": MyStyleTransferMonet().model,
        "Degas": MyStyleTransferDegas().model,
        "Renoir": MyStyleTransferRenoir().model,
        "Manet": MyStyleTransferManet().model,
        "Pissaro": MyStyleTransferPissaro().model,
        "Cassatt": MyStyleTransferCassat().model,
        "Morisot": MyStyleTransferMorisot().model,
        "Sisley": MyStyleTransferSisley().model
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
            self.pickedImage = UIImage(pixelBuffer: image)
            
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
            if let image = pickedImage {
                destinationVC.image = image
            }
        }
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        // guard문으로
        
        if let imageToSave = pickedImage {
            UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Error", message: "There was an error saving your image.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Image Saved", message: "Your image has been saved in your photo library.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
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

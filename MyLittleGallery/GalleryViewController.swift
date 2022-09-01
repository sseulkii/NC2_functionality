//
//  GalleryViewController.swift
//  MyLittleGallery
//
//  Created by Seulki Lee on 2022/08/31.
//

import UIKit
import ARKit

// https://stackoverflow.com/questions/51888939/place-image-from-gallery-on-a-wall-using-arkit
// 액자 넣고 싶당
class GalleryViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!

    var image: UIImage?
    
    let arSession = ARSession()
    let configuration = ARWorldTrackingConfiguration()
    var additionalNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.session = arSession
        sceneView.delegate = self
        configuration.planeDetection = .vertical
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if additionalNode == nil {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
            
            let width = CGFloat(image!.size.width * 0.002)
            let height = CGFloat(image!.size.height * 0.002)
            
            additionalNode = SCNNode(geometry: SCNPlane(width: width, height: height))
            
            additionalNode?.eulerAngles.x = -.pi / 2
            
            additionalNode?.geometry?.firstMaterial?.diffuse.contents = image
            
            node.addChildNode(additionalNode!)
        }
        
    }
}

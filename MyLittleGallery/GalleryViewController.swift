//
//  GalleryViewController.swift
//  MyLittleGallery
//
//  Created by Seulki Lee on 2022/08/31.
//

import UIKit
import ARKit

// 액자 넣고 싶당
class GalleryViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!

    var image: UIImage?
    
    let arSession = ARSession()
    let configuration = ARWorldTrackingConfiguration()
    var additionalNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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
            
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            
            additionalNode = SCNNode(geometry: SCNPlane(width: width, height: height))
            // width, height 그림에 맞춰야할듯
            
            additionalNode?.eulerAngles.x = -.pi / 2
            
            additionalNode?.geometry?.firstMaterial?.diffuse.contents = image
            
            node.addChildNode(additionalNode!)
        }
        
    }
}

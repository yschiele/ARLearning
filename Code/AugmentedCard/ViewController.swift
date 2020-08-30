//
//  ViewController.swift
//  AugmentedCard
//
//  Created by Prayash Thapa on 11/12/18.
//  Copyright © 2018 Prayash Thapa. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import SceneKit.ModelIO
class ViewController: UIViewController, ARSessionDelegate, UIGestureRecognizerDelegate {
    
    /// Primary SceneKit view that renders the AR session
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var slider: UISlider!
    
    private weak var elephant: SCNNode?
    var currentAngleY: Float = 0.0
    var currentAngleX: Float = 0.0
    
    var counter = 0
    var arrayImagesleft = ["Elefant_01", "Elefant_02", "Elefant_03", "Elefant_04", "Elefant_05"]
    var ArrayImagesRight = ["Elefant_01_right", "Elefant_02_right", "Elefant_03_right", "Elefant_04_right", "Elefant_05_right"]
    
    /// A serial queue for thread safety when modifying SceneKit's scene graph.
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
    
    // MARK: - Lifecycle
    
    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as FPS and timing information (useful during development)
        sceneView.showsStatistics = true
        
        // Enable environment-based lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        setupGestures()
        slider.alpha = 0
    }
    
    func showSlider(){
        DispatchQueue.main.async {
            self.slider.alpha = 1
        }
    }
    
    @IBAction func sliderForAlpha(_ sender: UISlider) {
         elephant!.opacity = CGFloat(sender.value)
    }
    
    
    // Notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = refImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: [.resetTracking, .removeExistingAnchors]))
    }
    
    // Notifies the view controller that its view is about to be removed from a view hierarchy.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - UIGestureRecognizer
    private func setupGestures() {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateObject(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.numberOfTouches == otherGestureRecognizer.numberOfTouches
    }
    
    
    @objc func didTap(_ gesture: UITapGestureRecognizer){
        
        //1. Get The Current Touch Location In The View
        let currentTouchLocation = gesture.location(in: self.sceneView)
        
        //2. Perform An SCNHitTest To Determine If We Have Hit An SCNNode
        guard let hitTestNode = self.sceneView.hitTest(currentTouchLocation, options: nil).first?.node else { return }
        
        
        if hitTestNode.name == "left"{ //TODO: Feedback
            
            if counter < (arrayImagesleft.count - 1) {
                SCNTransaction.begin()
                SCNTransaction.commit()
                let actionSmall = SCNAction.scale(to: 0.1, duration: 0.2)
                let actionBig = SCNAction.scale(to: 0.4, duration: 0.4)
                let actionNormal = SCNAction.scale(to: 0.2, duration: 0.2)
                let action = SCNAction.sequence([actionSmall,actionBig, actionNormal])
                hitTestNode.runAction(action)
                
                let detailView = self.sceneView.scene.rootNode.childNode(withName: "detailView_left", recursively: true)
                detailView!.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: arrayImagesleft[counter + 1])
                
                let detailView_right = self.sceneView.scene.rootNode.childNode(withName: "detailView_right", recursively: true)
                detailView_right!.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: ArrayImagesRight[counter + 1])
                
                counter = counter + 1
                
            }
            
        } else {
            
            if counter >= 1 {
                
                SCNTransaction.begin()
                SCNTransaction.commit()
                let actionSmall = SCNAction.scale(to: 0.1, duration: 0.2)
                let actionBig = SCNAction.scale(to: 0.4, duration: 0.4)
                let actionNormal = SCNAction.scale(to: 0.2, duration: 0.2)
                let action = SCNAction.sequence([actionSmall,actionBig, actionNormal])
                hitTestNode.runAction(action)
                
                let detailView = self.sceneView.scene.rootNode.childNode(withName: "detailView_left", recursively: true)
                detailView!.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: arrayImagesleft[counter - 1]) //TODO: ABSICHERN
                let detailView_right = self.sceneView.scene.rootNode.childNode(withName: "detailView_right", recursively: true)
                detailView_right!.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: ArrayImagesRight[counter - 1])
                
                counter = counter - 1
            }
        }
        
        
        //Anzeigen/Entfernen der Pfeile je nach Info
        if counter < 1 {
            let arrowRight = self.sceneView.scene.rootNode.childNode(withName: "right", recursively: true)
            
            let actionSmall = SCNAction.scale(to: 0.1, duration: 0.2)
            let actionBig = SCNAction.scale(to: 0.4, duration: 0.4)
            let actionNormal = SCNAction.scale(to: 0.2, duration: 0.2)
            let disapear = SCNAction.fadeOpacity(to: 0, duration: 0.2)
            let action = SCNAction.sequence([actionSmall,actionBig, actionNormal, disapear])
            arrowRight!.runAction(action)
            
        } else if (1 <= counter && counter < arrayImagesleft.count - 1){
            let arrowRight = self.sceneView.scene.rootNode.childNode(withName: "right", recursively: true)
            let apear = SCNAction.fadeOpacity(to: 1, duration: 1.0)
            arrowRight!.runAction(apear)
            
            let arrowLeft = self.sceneView.scene.rootNode.childNode(withName: "left", recursively: true)
            arrowLeft!.runAction(apear)
        } else {
            let arrowLeft = self.sceneView.scene.rootNode.childNode(withName: "left", recursively: true)
            
            let actionSmall = SCNAction.scale(to: 0.1, duration: 0.2)
            let actionBig = SCNAction.scale(to: 0.4, duration: 0.4)
            let actionNormal = SCNAction.scale(to: 0.2, duration: 0.2)
            let disapear = SCNAction.fadeOpacity(to: 0, duration: 0.2)
            let action = SCNAction.sequence([actionSmall,actionBig, actionNormal, disapear])
            arrowLeft!.runAction(action)
        }
    }
    
    
    /// Rotates An Object On It's YAxis
    ///
    /// - Parameter gesture: UIPanGestureRecognizer
    
    var PCoordx: Float = 0.0
    var PCoordy: Float = 0.0
    // the location of the touch point in the scene when the last movement happened
    var lastPanLocation: SCNVector3?
    // the z poisition of the dragging point
    var panStartZ: CGFloat?
    
    @objc func rotateObject(_ gesture: UIPanGestureRecognizer) {
        
        guard let nodeToRotate = elephant else {
            return
        }
        
        if gesture.numberOfTouches == 2 {       //Rotation
            let translation = gesture.translation(in: gesture.view!)
            var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
            newAngleY += currentAngleY
            nodeToRotate.eulerAngles.z = newAngleY
            if(gesture.state == .ended) {
                currentAngleY = newAngleY
            }
        } else if gesture.numberOfTouches == 1 {        //Bewegen
            
//            guard let view = sceneView else { return }
//            let location = gesture.location(in: self.sceneView)
//            switch gesture.state {
//            case .began:
//                guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
//                lastPanLocation = hitNodeResult.worldCoordinates
//                panStartZ = CGFloat(view.projectPoint(lastPanLocation!).z)
//
//
//            case .changed:
//                guard panStartZ != nil else { return }
//
//                let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))
//
//                let movementVector = SCNVector3(worldTouchPosition.x - lastPanLocation!.x,
//                                                worldTouchPosition.y - lastPanLocation!.y,
//                                                worldTouchPosition.z - lastPanLocation!.z)
//                nodeToRotate.localTranslate(by: movementVector)
//
//                self.lastPanLocation = worldTouchPosition
//                print(nodeToRotate.position)
//
//            default:
//                break
//            }
//
//
            
             guard let view = sceneView else { return }
             let location = gesture.location(in: self.view)
             switch gesture.state {
             case .began:
               guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
               // panStartZ and draggingNode should be defined in the containing class
               lastPanLocation = hitNodeResult.worldCoordinates
               panStartZ = CGFloat(view.projectPoint(lastPanLocation!).z)
               //elephant = hitNodeResult.node
                
             case .changed:
               let location = gesture.location(in: view)
               let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))
               elephant?.worldPosition = worldTouchPosition
                print(elephant?.position)
             default:
               break
             }
            
        } else {
        }
    }
    
    // Zoom Geste
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer){
        guard let nodeToRotate = elephant else { return }
        
        if (gesture.state == .changed) {
            let pinchScaleX = Float(gesture.scale) * nodeToRotate.scale.x
            let pinchScaleY =  Float(gesture.scale) * nodeToRotate.scale.y
            let pinchScaleZ =  Float(gesture.scale) * nodeToRotate.scale.z
            nodeToRotate.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
            gesture.scale=1
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            // Create a plane geometry to visualize the initial position of the detected image
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            // Create a SceneKit root node with the plane geometry to attach to the scene graph
            // This node will hold the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
            
            // Add the plane visualization to the scene
            node.addChildNode(mainNode)
            node.geometry?.firstMaterial?.diffuse.contents  = UIColor(red: 30.0 / 255.0, green: 150.0 / 255.0, blue: 30.0 / 255.0, alpha: 1)
            
            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
            self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                
                // Introduce virtual content
                self.displayDetailView(on: mainNode, xOffset: physicalWidth)
                
                // Animate the WebView to the right
                self.displayImageView(on: mainNode, xOffset: physicalWidth)
                
                //self.showAnimalModal(on: mainNode, xOffset: physicalWidth)
                
                let elephantScene = SCNScene(named: "Elephant_02.scn")
                guard let elephantNode = elephantScene?.rootNode.childNode(withName: "elephant_02", recursively: true) else {
                    fatalError("ERROR")
                }
                
                elephantNode.position = SCNVector3(0 , 30 , 30)
                //elephantNode.opacity = 0
                elephantNode.eulerAngles.x = -.pi / 2
                node.addChildNode(elephantNode)
                elephantNode.runAction(.sequence([
                    .wait(duration: 3.0),
                    .fadeOpacity(to: 1.0, duration: 2),
                ])
                )
                
                self.showSlider()
                self.elephant = elephantNode
                
            })
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        DispatchQueue.main.async {
        self.slider.alpha = 0
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        DispatchQueue.main.async {
        self.slider.alpha = 0
        }
    }
    
    
    func showAnimalModal(on rootNode: SCNNode, xOffset: CGFloat) {
        
        //1. Modell
        let elephantScene = SCNScene(named: "Elephant_02.scn")
        guard let elephantNode = elephantScene?.rootNode.childNode(withName: "elephant_02", recursively: true) else {
            fatalError("ERROR")
        }
        
        elephantNode.position = SCNVector3(rootNode.position.x , rootNode.position.y - 30 , rootNode.position.z + 50)
        //elephantNode.opacity = 0
        rootNode.addChildNode(elephantNode)
        elephantNode.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 1.0, duration: 2),
            //.move(to: SCNVector3(rootNode.position.x , rootNode.position.y, rootNode.position.z + 8), duration: 1.7)
        ])
        )
        
        showSlider()
        elephant = elephantNode
    }
    
    func displayDetailView(on rootNode: SCNNode, xOffset: CGFloat) {
        let detailPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
        detailPlane.cornerRadius = 0.25
        
        let detailNode = SCNNode(geometry: detailPlane)
        detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "Elefant_01")
        detailNode.name = "detailView_left"
        
        // Due to the origin of the iOS coordinate system, SCNMaterial's content appears upside down, so flip the y-axis.
        detailNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        detailNode.position.z -= 0.5
        detailNode.opacity = 0
        
        rootNode.addChildNode(detailNode)
        detailNode.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 1.0, duration: 1.5),
            .moveBy(x: xOffset * -1.1, y: 0, z: -0.1, duration: 1.5),
        ])
        )
        
        let arrowSceneLeft = SCNScene(named: "arrow_Left.dae")
        guard let arrowNodeLeft = arrowSceneLeft?.rootNode.childNode(withName: "arrowLeft_modal", recursively: true) else {
            fatalError("ERROR")
        }
        
        arrowNodeLeft.opacity = 0
        arrowNodeLeft.position.z -= 0.5
        arrowNodeLeft.name = "left"
        
        
        rootNode.addChildNode(arrowNodeLeft)
        arrowNodeLeft.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 1.0, duration: 1.5),
            .moveBy(x: xOffset * -2.1 , y: 0, z: -0.1, duration: 1.5),
        ])
        )
    }
    
    func displayImageView(on rootNode: SCNNode, xOffset: CGFloat) {
        
        let detailPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
        detailPlane.cornerRadius = 0.25
        
        let detailNode = SCNNode(geometry: detailPlane)
        detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "Elefant_01_right")
        detailNode.name = "detailView_right"
        
        // Due to the origin of the iOS coordinate system, SCNMaterial's content appears upside down, so flip the y-axis.
        detailNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        detailNode.position.z -= 0.5
        detailNode.opacity = 0
        
        
        rootNode.addChildNode(detailNode)
        detailNode.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 1.0, duration: 1.5),
            .moveBy(x: xOffset * 1.1, y: 0, z: -0.1, duration: 1.5),
        ])
        )
        
        
        let arrowSceneRight = SCNScene(named: "arrow.dae")
        guard let arrowNodeRight = arrowSceneRight?.rootNode.childNode(withName: "arrow_modal", recursively: true) else {
            fatalError("ERROR")
        }
        
        arrowNodeRight.opacity = 0
        arrowNodeRight.position.z -= 0.5
        arrowNodeRight.name = "right"
        
        rootNode.addChildNode(arrowNodeRight)
        arrowNodeRight.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 0.0, duration: 1.5),
            .moveBy(x: xOffset * 2.1 , y: 0, z: -0.1, duration: 1.5),
        ])
        )
    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
        ])
    }
}

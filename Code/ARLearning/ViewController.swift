//
//  ViewController.swift
//  AR Learning
//
//  Created by Yannick Schiele
//

import UIKit
import ARKit
import SceneKit
import SceneKit.ModelIO

class ViewController: UIViewController, ARSessionDelegate, UIGestureRecognizerDelegate {
    
    // Primary SceneKit view that renders the AR session
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var slider: UISlider!
    
    //Variables to render Animal Model
    private weak var elephant: SCNNode?
    var currentAngleY: Float = 0.0
    var currentAngleX: Float = 0.0
    
    //Variables to show Informations
    var counter = 0
    var arrayImagesleft = ["Elefant_01", "Elefant_02", "Elefant_03", "Elefant_04", "Elefant_05"]
    var ArrayImagesRight = ["Elefant_01_right", "Elefant_02_right", "Elefant_03_right", "Elefant_04_right", "Elefant_05_right"]
    
    // A serial queue for thread safety when modifying SceneKit's scene graph.
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
    
    
    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as FPS and timing information (useful for my development)
        sceneView.showsStatistics = true
        
        // Enable environment-based lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        setupGestures() //Set up all Gestures that the User can use
        slider.alpha = 0 //The alpha of the Slider is set to zero when no Animal is shown
    }
    
    /// Function that makes the Slider visible when an animal modal is shown
    func showSlider(){
        DispatchQueue.main.async {
            self.slider.alpha = 1
        }
    }
    
    /// Function to change the alpha of the animal modal with the Slider
    /// Value is between 0 and 1
    @IBAction func sliderForAlpha(_ sender: UISlider) {
         elephant!.opacity = CGFloat(sender.value)
    }
    
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("Missing expected asset catalog resources.") //Reference Image is loaded from the given Folder - if not found error is thrown
        }
        
        // Session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = refImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // View's session is executed
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: [.resetTracking, .removeExistingAnchors]))
    }
    
    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    /// Function to set up all three gestures with the 3D models
    private func setupGestures() {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateObject(_:)))
        sceneView.addGestureRecognizer(panGesture) //Pan Gesture to rotate or move the anmimal model
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture) //Tap Gesture to change the Informations
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer) // Pinch Gesture to zoom the anmimal model
        
    }
    
    /// Function get the Number of touches from the user
    /// to check if the user uses one ore more fingers to interact
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.numberOfTouches == otherGestureRecognizer.numberOfTouches
    }
    
    /// Callback Funtion from the Tap Gesture to change the Informations
    @objc func didTap(_ gesture: UITapGestureRecognizer){
        
        // Get the current touch location in the view
        let currentTouchLocation = gesture.location(in: self.sceneView)
        
        //Perform an SCNHitTest to determine if the user has hit an SCNNode
        guard let hitTestNode = self.sceneView.hitTest(currentTouchLocation, options: nil).first?.node else { return }
        
        
        if hitTestNode.name == "left"{ //If the User tabs on the left Arrow
            
            if counter < (arrayImagesleft.count - 1) { //if there are more Informations left
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
            
        } else { //if the User tabs on the right arrow
            
            if counter >= 1 {   //if it is not the first Information
                
                SCNTransaction.begin()
                SCNTransaction.commit()
                let actionSmall = SCNAction.scale(to: 0.1, duration: 0.2)
                let actionBig = SCNAction.scale(to: 0.4, duration: 0.4)
                let actionNormal = SCNAction.scale(to: 0.2, duration: 0.2)
                let action = SCNAction.sequence([actionSmall,actionBig, actionNormal])
                hitTestNode.runAction(action)
                
                let detailView = self.sceneView.scene.rootNode.childNode(withName: "detailView_left", recursively: true)
                detailView!.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: arrayImagesleft[counter - 1])
                let detailView_right = self.sceneView.scene.rootNode.childNode(withName: "detailView_right", recursively: true)
                detailView_right!.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: ArrayImagesRight[counter - 1])
                
                counter = counter - 1
            }
        }
        
        
        //Show or remove the arrows if the first/last Information is shown
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
        
        if gesture.numberOfTouches == 2 {       //Rotation of the model
            let translation = gesture.translation(in: gesture.view!)
            var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
            newAngleY += currentAngleY
            nodeToRotate.eulerAngles.z = newAngleY
            if(gesture.state == .ended) {
                currentAngleY = newAngleY
            }
        } else if gesture.numberOfTouches == 1 {        //Moving the model
             guard let view = sceneView else { return }
             let location = gesture.location(in: self.view)
             switch gesture.state {
             case .began:
               guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
               lastPanLocation = hitNodeResult.worldCoordinates
               panStartZ = CGFloat(view.projectPoint(lastPanLocation!).z)
                
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
    
    // Zoom Callback Function
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            // a plane geometry to visualize the initial position of the detected image with no color
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            // a SceneKit root node with the plane geometry to attach to the scene graph
            // This node holds the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
            
            // the plane visualization of the scene
            node.addChildNode(mainNode)
            node.geometry?.firstMaterial?.diffuse.contents  = UIColor(red: 30.0 / 255.0, green: 150.0 / 255.0, blue: 30.0 / 255.0, alpha: 1)
            
            // An animation to visualize the plane on which the image was detected
            // To let the users know that the app is responding to the tracked image
            self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                
                // Introduce virtual content
                self.displayDetailView(on: mainNode, xOffset: physicalWidth)
                
                // Animation of the ImageView to the right
                self.displayImageView(on: mainNode, xOffset: physicalWidth)
                
                // Animation of the Animal Model
                let elephantScene = SCNScene(named: "Elephant_02.scn")
                guard let elephantNode = elephantScene?.rootNode.childNode(withName: "elephant_02", recursively: true) else {
                    fatalError("ERROR")
                }
                
                elephantNode.position = SCNVector3(0 , 30 , 30)
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
        // Present an error message to the user if the Session failed
        
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

    /// Function to show the Information View next to the detected Image
    func displayDetailView(on rootNode: SCNNode, xOffset: CGFloat) {
        let detailPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
        detailPlane.cornerRadius = 0.25
        
        let detailNode = SCNNode(geometry: detailPlane)
        detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "Elefant_01")
        detailNode.name = "detailView_left"
        
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
    
    /// Function to show the Image View next to the detected Image
    func displayImageView(on rootNode: SCNNode, xOffset: CGFloat) {
        
        let detailPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
        detailPlane.cornerRadius = 0.25
        
        let detailNode = SCNNode(geometry: detailPlane)
        detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "Elefant_01_right")
        detailNode.name = "detailView_right"
        
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
    
    ///Callback Function when the Reference Image is detected
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
    
    ///Animation that is performed when the Image is detected 
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

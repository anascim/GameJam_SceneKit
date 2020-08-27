//
//  GameViewController.swift
//  GameJam_SceneKit
//
//  Created by Alex Nascimento on 26/08/20.
//  Copyright © 2020 Alex Nascimento. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var scene: SCNScene!
    var world: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(frame: CGRect(x: view.frame.size.width/2 - 35, y: view.frame.size.height*7/8, width: 70, height: 70))
        let longPressOrb = UILongPressGestureRecognizer(target: self, action: #selector(orbPress(_:)))
        button.addGestureRecognizer(longPressOrb)
        if let img = UIImage(named: "art.scnassets/fire_orb.png") {
            button.setImage(img, for: .normal)
        }
        
//        button.imageView = UIImageView(image: )
//        button.backgroundColor = .yellow
        view.addSubview(button)
        
        scene = SCNScene(named: "art.scnassets/level1.scn")!
        world = scene.rootNode.childNode(withName: "mundo", recursively: true)!
        
        let scnView = self.view as! SCNView
        scnView.backgroundColor = UIColor.black
        scnView.scene = scene
        scnView.delegate = self
        scnView.rendersContinuously = true
        //scnView.allowsCameraControl = true
        //scnView.showsStatistics = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        setupScene()
    }
    
    func setupScene() {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 10

        // lighting
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .directional
        lightNode.look(at: SCNVector3(0, -100, 0))
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Physics
        if let verde = world.childNode(withName: "MundoVerde reference", recursively: false) {
            print(verde)
            if let vg = verde.childNodes.first?.geometry {
                verde.physicsBody =  SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: vg, options: nil))
                print("verde pb")
            }
        }
        
        if let azul = world.childNode(withName: "MundoAzul reference", recursively: false) {
            if let ag = azul.childNodes.first?.geometry {
                azul.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: ag, options: nil))
                print("azul pb")
                if let vertexSources = azul.geometry?.sources(for: .vertex) {
                    for v in vertexSources {
                        v.dataStride
                    }
                }
            }
        }
        
        let redbox = SCNNode()
        redbox.geometry = SCNBox(width: 0.03, height: 0.03, length: 0.03, chamferRadius: 0)
        redbox.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        redbox.position = SCNVector3(0,0,1)
        scene.rootNode.addChildNode(redbox)
        
        let url = URL(fileURLWithPath: "art.scnassets/Dragon.scn")
        if let dragon = SCNReferenceNode(url: url) {
            scene.rootNode.addChildNode(dragon)
            dragon.position = SCNVector3(0, 0, 2)
        }
    }
    
    var rot: Float = 0.0
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var q1 = simd_quatf(angle: 0.004, axis: [1,0,0])
        world.simdRotate(by: q1, aroundTarget: [0,0,0])
        var q2 = simd_quatf(angle: panRot/100, axis: [0,0,1])
        world.simdRotate(by: q2, aroundTarget: [0,0,0])
        rot += 0.01
    }
    
    @objc
    func orbPress(_ sender: UILongPressGestureRecognizer) {
        print("fogo")
    }
    
    var panRot: Float = 0.0
    @objc
    func panGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if (gestureRecognizer.state == .cancelled || gestureRecognizer.state == .ended) {
            panRot = 0.0
            return
        }
        let totalT = gestureRecognizer.translation(in: self.view)
        let nx = totalT.x/self.view.frame.size.width
        let trans = simd_clamp(Double(nx), -0.3, 0.3) * (1/0.3) // [-1...1]
        panRot = Float(trans)
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
//        let hitResults = scene.physicsWorld.rayTestWithSegment(from: SCNVector3(0, 0, 5), to: SCNVector3(0,0,0), options: [SCNPhysicsWorld.TestOption.searchMode : SCNPhysicsWorld.TestSearchMode.closest])
//        // [SCNPhysicsWorld.TestOption.searchMode : SCNPhysicsWorld.TestSearchMode.closest]
//        var count = 0
//        if hitResults.count > 0 {
//            for h in hitResults {
//                print("\(count): \(h.node.name)")
//                count += 1
//            }
//        }
        // retrieve the SCNView
        let scnView = self.view as! SCNView

        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        var count = 0
        if hitResults.count > 0 {
            for h in hitResults {
                print("\(count): \(h.node.name)")
                count += 1
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

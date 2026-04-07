//
//  ARAssessmentView.swift
//  Examar
//
//  Created by Rohan Katyayani on 07/04/26.
//

import SwiftUI
import ARKit
import RealityKit
import SceneKit

// MARK: - Portal Manager
class PortalManager {
    
    static func makePortal() -> SCNNode {
        let portalNode = SCNNode()
        
        // Portal dimensions
        let wallWidth: CGFloat = 3.0
        let wallHeight: CGFloat = 3.0
        let wallDepth: CGFloat = 0.05
        let roomDepth: CGFloat = 4.0
        
        // Back wall - Milk section
        let backWall = makeWallNode(
            width: wallWidth,
            height: wallHeight,
            depth: wallDepth,
            imageName: "milk",
            position: SCNVector3(0, wallHeight/2, -roomDepth/2)
        )
        portalNode.addChildNode(backWall)
        
        // Left wall - Eggs section
        let leftWall = makeWallNode(
            width: roomDepth,
            height: wallHeight,
            depth: wallDepth,
            imageName: "eggs",
            position: SCNVector3(-wallWidth/2, wallHeight/2, -roomDepth/4)
        )
        leftWall.eulerAngles.y = Float.pi / 2
        portalNode.addChildNode(leftWall)
        
        // Right wall - Bread section
        let rightWall = makeWallNode(
            width: roomDepth,
            height: wallHeight,
            depth: wallDepth,
            imageName: "bread",
            position: SCNVector3(wallWidth/2, wallHeight/2, -roomDepth/4)
        )
        rightWall.eulerAngles.y = Float.pi / 2
        portalNode.addChildNode(rightWall)
        
        // Floor
        let floor = makeWallNode(
            width: wallWidth,
            height: roomDepth,
            depth: wallDepth,
            imageName: nil,
            color: UIColor.white,
            position: SCNVector3(0, 0, -roomDepth/4)
        )
        floor.eulerAngles.x = Float.pi / 2
        portalNode.addChildNode(floor)
        
        // Ceiling
        let ceiling = makeWallNode(
            width: wallWidth,
            height: roomDepth,
            depth: wallDepth,
            imageName: nil,
            color: UIColor.lightGray,
            position: SCNVector3(0, wallHeight, -roomDepth/4)
        )
        ceiling.eulerAngles.x = Float.pi / 2
        portalNode.addChildNode(ceiling)
        
        // Door frame - left side
        let doorLeft = makeWallNode(
            width: 0.3,
            height: wallHeight,
            depth: wallDepth,
            imageName: nil,
            color: UIColor.white,
            position: SCNVector3(-0.65, wallHeight/2, 0)
        )
        portalNode.addChildNode(doorLeft)
        
        // Door frame - right side
        let doorRight = makeWallNode(
            width: 0.3,
            height: wallHeight,
            depth: wallDepth,
            imageName: nil,
            color: UIColor.white,
            position: SCNVector3(0.65, wallHeight/2, 0)
        )
        portalNode.addChildNode(doorRight)
        
        // Door frame - top
        let doorTop = makeWallNode(
            width: wallWidth,
            height: 0.3,
            depth: wallDepth,
            imageName: nil,
            color: UIColor.white,
            position: SCNVector3(0, wallHeight - 0.15, 0)
        )
        portalNode.addChildNode(doorTop)
        
        return portalNode
    }
    
    static func makeWallNode(
        width: CGFloat,
        height: CGFloat,
        depth: CGFloat,
        imageName: String?,
        color: UIColor = .white,
        position: SCNVector3
    ) -> SCNNode {
        let geometry = SCNBox(
            width: width,
            height: height,
            length: depth,
            chamferRadius: 0
        )
        
        let material = SCNMaterial()
        if let imageName = imageName,
           let image = UIImage(named: imageName) {
            material.diffuse.contents = image
        } else {
            material.diffuse.contents = color
        }
        material.isDoubleSided = true
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        node.position = position
        return node
    }
}

// MARK: - AR View Controller (UIKit Bridge)
class ARViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var studentName: String = ""
    var studentGrade: String = ""
    var portalPlaced: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupTapGesture()
    }
    
    func setupAR() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        view.addSubview(sceneView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        sceneView.session.run(config)
    }
    
    func setupTapGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard !portalPlaced else { return }
        
        let location = recognizer.location(in: sceneView)
        
        let results = sceneView.hitTest(
            location,
            types: [.existingPlaneUsingExtent]
        )
        
        if let result = results.first {
            placePortal(at: result)
        }
    }
    
    func placePortal(at hitResult: ARHitTestResult) {
        portalPlaced = true
        
        let portal = PortalManager.makePortal()
        
        let matrix = hitResult.worldTransform
        portal.position = SCNVector3(
            matrix.columns.3.x,
            matrix.columns.3.y,
            matrix.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(portal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

// MARK: - SwiftUI Wrapper
struct ARViewContainer: UIViewControllerRepresentable {
    var studentName: String
    var studentGrade: String
    
    func makeUIViewController(context: Context) -> ARViewController {
        let controller = ARViewController()
        controller.studentName = studentName
        controller.studentGrade = studentGrade
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: ARViewController,
        context: Context
    ) {}
}

// MARK: - AR Assessment View
struct ARAssessmentView: View {
    var studentName: String
    var studentGrade: String
    
    var body: some View {
        ZStack {
            ARViewContainer(
                studentName: studentName,
                studentGrade: studentGrade
            )
            .ignoresSafeArea()
            
            VStack {
                // Top HUD
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(studentName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(studentGrade)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text("Examar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                
                Spacer()
                
                // Bottom instruction
                Text("Tap on a flat surface to place the portal")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.bottom, 30)
                    .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

//
//  ARAssessmentView.swift
//  Examar
//
//  Created by Rohan Katyayani on 07/04/26.
//

import SwiftUI
import ARKit
import SceneKit
import Combine

// MARK: - Portal Manager
class PortalManager {
    
    static func makePortal() -> SCNNode {
        let portalNode = SCNNode()
        
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
        
        // Floor - white tiles
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
        
        // Ceiling - white
        let ceiling = makeWallNode(
            width: wallWidth,
            height: roomDepth,
            depth: wallDepth,
            imageName: nil,
            color: UIColor.white,
            position: SCNVector3(0, wallHeight, -roomDepth/4)
        )
        ceiling.eulerAngles.x = Float.pi / 2
        portalNode.addChildNode(ceiling)
        
        // Single clean door frame - top only
        let doorTop = makeWallNode(
            width: wallWidth,
            height: 0.2,
            depth: wallDepth,
            imageName: nil,
            color: UIColor.white,
            position: SCNVector3(0, wallHeight - 0.1, 0)
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

// MARK: - AR View Controller
class ARViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var studentName: String = ""
    var studentGrade: String = ""
    var portalPlaced: Bool = false
    var assessmentManager: AssessmentManager?
    var onAssessmentComplete: (() -> Void)?
    var onPortalPlaced: (() -> Void)?
    
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
        
        // Start update loop for section detection
        Timer.scheduledTimer(
            withTimeInterval: 0.3,
            repeats: true
        ) { [weak self] _ in
            self?.updateSectionDetection()
        }
    }
    
    func updateSectionDetection() {
        guard portalPlaced,
              let manager = assessmentManager,
              let pointOfView = sceneView.pointOfView else { return }
        
        let cameraTransform = pointOfView.transform
        
        manager.updateFacingSection(
            cameraTransform: cameraTransform,
            portalPosition: manager.portalAnchorPosition
        )
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
        onPortalPlaced?()
        assessmentManager?.portalAnchorPosition = portal.position
        
        // Start assessment after portal is placed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.assessmentManager?.startAssessment()
        }
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
    @ObservedObject var manager: AssessmentManager
    @Binding var portalPlaced: Bool
    var onComplete: () -> Void
    
    func makeUIViewController(context: Context) -> ARViewController {
        let controller = ARViewController()
        controller.studentName = studentName
        controller.studentGrade = studentGrade
        controller.assessmentManager = manager
        controller.onAssessmentComplete = onComplete
        controller.onPortalPlaced = {
            DispatchQueue.main.async {
                portalPlaced = true
            }
        }
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
    var onReset: () -> Void
    
    @StateObject private var assessmentManager = AssessmentManager()
    @State private var navigateToResults = false
    @State private var portalPlaced = false
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(
                studentName: studentName,
                studentGrade: studentGrade,
                manager: assessmentManager,
                portalPlaced: $portalPlaced,
                onComplete: {
                    navigateToResults = true
                }
            )
            .ignoresSafeArea()
            
            // HUD
            VStack {
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
                    if portalPlaced {
                        Text("£\(String(format: "%.0f", assessmentManager.currentBudget))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    Spacer()
                    Text("Examar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                
                Spacer()
                
                if !portalPlaced {
                    Text("Point your camera at a flat surface and tap to enter the supermarket")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                } else {
                    AssessmentOverlayView(
                        manager: assessmentManager,
                        onComplete: {
                            navigateToResults = true
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            
            // Navigate to results
            if navigateToResults {
                ResultView(
                    studentName: studentName,
                    studentGrade: studentGrade,
                    finalScore: assessmentManager.finalScore,
                    performanceLabel: assessmentManager.performanceLabel,
                    milkAttempts: assessmentManager.milkAttempts,
                    eggsAttempts: assessmentManager.eggsAttempts,
                    breadAttempts: assessmentManager.breadAttempts,
                    remainingBudget: assessmentManager.currentBudget,
                    onReset: onReset
                )
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            assessmentManager.studentName = studentName
            assessmentManager.studentGrade = studentGrade
        }
    }
}

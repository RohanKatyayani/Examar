//
//  ARAssessmentView.swift
//  Examar
//
//  Created by Rohan Katyayani on 07/04/26.
//

import SwiftUI
import ARKit
import RealityKit

// MARK: - AR View Controller (UIKit Bridge)
class ARViewController: UIViewController {
    var arView: ARView!
    var studentName: String = ""
    var studentGrade: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
    }
    
    func setupAR() {
        arView = ARView(frame: view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
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
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {}
}

// MARK: - AR Assessment View
struct ARAssessmentView: View {
    var studentName: String
    var studentGrade: String
    
    var body: some View {
        ZStack {
            // AR View fills the screen
            ARViewContainer(
                studentName: studentName,
                studentGrade: studentGrade
            )
            .ignoresSafeArea()
            
            // HUD overlay at the top
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
                    Text("Examar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                
                Spacer()
                
                // Bottom instruction
                Text("Point your camera at a flat surface to place the portal")
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

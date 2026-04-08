//
//  AssessmentModel.swift
//  Examar
//
//  Created by Rohan Katyayani on 08/04/26.
//

import Foundation
import Combine
import SceneKit

// MARK: - Assessment Item
struct AssessmentItem {
    let name: String
    let price: Double
    let imageName: String
    let section: String
}

// MARK: - Assessment State
enum AssessmentStage {
    case notStarted
    case milk
    case eggs
    case bread
    case completed
}

// MARK: - Assessment Manager
class AssessmentManager: ObservableObject {
    
    // Student info
    var studentName: String = ""
    var studentGrade: String = ""
    
    // Budget
    @Published var currentBudget: Double = 10.0
    let initialBudget: Double = 10.0
    
    // Current stage
    @Published var currentStage: AssessmentStage = .notStarted
    
    // Answer tracking
    @Published var userAnswer: String = ""
    @Published var isAnswerWrong: Bool = false
    @Published var attemptCount: Int = 0
    @Published var showStageComplete: Bool = false
    
    // Results tracking
    var milkAttempts: Int = 0
    var eggsAttempts: Int = 0
    var breadAttempts: Int = 0
    // Section detection
    @Published var facingSection: AssessmentStage = .notStarted
    @Published var portalAnchorPosition: SCNVector3 = SCNVector3(0, 0, 0)
    
    // Items
    let items: [AssessmentStage: AssessmentItem] = [
        .milk: AssessmentItem(
            name: "Milk",
            price: 2.0,
            imageName: "milk",
            section: "Milk Section"
        ),
        .eggs: AssessmentItem(
            name: "Eggs",
            price: 4.0,
            imageName: "eggs",
            section: "Eggs Section"
        ),
        .bread: AssessmentItem(
            name: "Bread",
            price: 3.0,
            imageName: "bread",
            section: "Bread Section"
        )
    ]
    
    // Current item
    var currentItem: AssessmentItem? {
        return items[currentStage]
    }
    
    // Start assessment
    func startAssessment() {
        currentBudget = initialBudget
        currentStage = .milk
        resetAnswer()
    }
    
    // Check answer
    func checkAnswer() -> Bool {
        guard let item = currentItem else { return false }
        
        let correctAnswer = currentBudget - item.price
        let userDouble = Double(userAnswer.trimmingCharacters(
            in: .whitespaces
        ))
        
        attemptCount += 1
        
        if let userDouble = userDouble,
           abs(userDouble - correctAnswer) < 0.01 {
            // Correct!
            currentBudget = correctAnswer
            isAnswerWrong = false
            showStageComplete = true
            trackAttempts()
            return true
        } else {
            // Wrong
            isAnswerWrong = true
            return false
        }
    }
    
    // Track attempts per item
    func trackAttempts() {
        switch currentStage {
        case .milk: milkAttempts = attemptCount
        case .eggs: eggsAttempts = attemptCount
        case .bread: breadAttempts = attemptCount
        default: break
        }
    }
    
    // Move to next stage
    func nextStage() {
        showStageComplete = false
        resetAnswer()
        
        switch currentStage {
        case .milk: currentStage = .eggs
        case .eggs: currentStage = .bread
        case .bread: currentStage = .completed
        default: break
        }
    }
    
    // Reset answer
    func resetAnswer() {
        userAnswer = ""
        isAnswerWrong = false
        attemptCount = 0
    }
    
    // Score out of 100
    var finalScore: Int {
        let totalAttempts = milkAttempts + eggsAttempts + breadAttempts
        switch totalAttempts {
        case 3: return 100
        case 4: return 85
        case 5: return 70
        case 6: return 55
        default: return 40
        }
    }
    
    // Performance label
    var performanceLabel: String {
        switch finalScore {
        case 90...100: return "Excellent"
        case 75...89: return "Good"
        case 55...74: return "Needs Practice"
        default: return "Needs More Work"
        }
    }

    // Detect which section student is facing
    func updateFacingSection(
        cameraTransform: SCNMatrix4,
        portalPosition: SCNVector3
    ) {
        // Get camera position
        let cameraPosition = SCNVector3(
            cameraTransform.m41,
            cameraTransform.m42,
            cameraTransform.m43
        )
        
        // Get camera forward direction
        let cameraForward = SCNVector3(
            -cameraTransform.m31,
            -cameraTransform.m32,
            -cameraTransform.m33
        )
        
        // Vector from camera to portal
        let toPortal = SCNVector3(
            portalPosition.x - cameraPosition.x,
            0,
            portalPosition.z - cameraPosition.z
        )
        
        // Normalize
        let length = sqrt(
            toPortal.x * toPortal.x + toPortal.z * toPortal.z
        )
        guard length > 0.01 else { return }
        
        let normalizedToPortal = SCNVector3(
            toPortal.x / length,
            0,
            toPortal.z / length
        )
        
        // Dot product to determine facing direction
        let dot = cameraForward.x * normalizedToPortal.x +
                  cameraForward.z * normalizedToPortal.z
        
        // Cross product to determine left/right
        let cross = cameraForward.x * normalizedToPortal.z -
                    cameraForward.z * normalizedToPortal.x
        
        // Only update if student is inside or close to portal
        let distanceToPortal = length
        guard distanceToPortal < 4.0 else {
            facingSection = .notStarted
            return
        }
        
        if dot > 0.5 {
            // Facing back wall - Milk
            facingSection = .milk
        } else if cross > 0.3 {
            // Facing left wall - Eggs
            facingSection = .eggs
        } else if cross < -0.3 {
            // Facing right wall - Bread
            facingSection = .bread
        } else {
            facingSection = .notStarted
        }
    }
    
}

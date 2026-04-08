//
//  AssessmentOverlayView.swift
//  Examar
//
//  Created by Rohan Katyayani on 08/04/26.
//

import SwiftUI

struct AssessmentOverlayView: View {
    @ObservedObject var manager: AssessmentManager
    var onComplete: () -> Void

    var body: some View {
        VStack {
            Spacer()

            if manager.currentStage == .completed {
                // Assessment complete
                completedView

            } else if manager.currentStage == .notStarted {
                // Not started yet
                startView

            } else if manager.showStageComplete {
                // Stage complete confirmation
                stageCompleteView

            } else {
                // Active question
                questionView
            }
        }
        .padding(.bottom, 30)
        .padding(.horizontal, 20)
    }

    // MARK: - Start View
    var startView: some View {
        VStack(spacing: 16) {
            Text("Welcome \(manager.studentName)!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text("You have £\(String(format: "%.0f", manager.initialBudget)) to spend.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))

            Text("Buy Milk, Eggs and Bread.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))

            Button(action: {
                manager.startAssessment()
            }) {
                Text("Begin")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(Color.black.opacity(0.75))
        .cornerRadius(16)
    }

    // MARK: - Question View
    var questionView: some View {
        VStack(spacing: 14) {
            
            // Check if student is facing correct section
            let correctSection = manager.facingSection == manager.currentStage
            
            if !correctSection {
                // Not facing the right section
                VStack(spacing: 12) {
                    Text("Go! 🏃")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Find the \(manager.currentItem?.name ?? "") section")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.black.opacity(0.75))
                .cornerRadius(16)
                
            } else {
                // Facing correct section - show question
                VStack(spacing: 14) {
                    
                    // Section label
                    Text(manager.currentItem?.section ?? "")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.green)
                    
                    // Item and price
                    HStack {
                        Text(manager.currentItem?.name ?? "")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("£\(String(format: "%.0f", manager.currentItem?.price ?? 0))")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                    // Budget
                    Text("You have £\(String(format: "%.0f", manager.currentBudget)) left")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Question
                    Text("How much will you have after buying \(manager.currentItem?.name ?? "")?")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Answer input
                    TextField("", text: $manager.userAnswer)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .semibold))
                    
                    // Wrong answer message
                    if manager.isAnswerWrong {
                        Text("That's not right — think again! 🤔")
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    
                    // Submit button
                    Button(action: {
                        let _ = manager.checkAnswer()
                    }) {
                        Text("Submit Answer")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.75))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Stage Complete View
    var stageCompleteView: some View {
        VStack(spacing: 14) {
            Text("✅ Correct!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.green)

            Text("You have £\(String(format: "%.0f", manager.currentBudget)) left")
                .font(.system(size: 18))
                .foregroundColor(.white)

            // Next section label
            let nextLabel: String = {
                switch manager.currentStage {
                case .milk: return "Head to the Eggs Section →"
                case .eggs: return "Head to the Bread Section →"
                case .bread: return "You're done! See your results →"
                default: return ""
                }
            }()

            Text(nextLabel)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Button(action: {
                manager.nextStage()
                if manager.currentStage == .completed {
                    onComplete()
                }
            }) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(Color.black.opacity(0.75))
        .cornerRadius(16)
    }

    // MARK: - Completed View
    var completedView: some View {
        VStack(spacing: 14) {
            Text("🎉 Assessment Complete!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Tap Continue to see your results")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))

            Button(action: {
                onComplete()
            }) {
                Text("See Results")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(Color.black.opacity(0.75))
        .cornerRadius(16)
    }
}

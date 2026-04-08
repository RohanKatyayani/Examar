//
//  ResultView.swift
//  Examar
//
//  Created by Rohan Katyayani on 08/04/26.
//

import SwiftUI

struct ResultView: View {
    let studentName: String
    let studentGrade: String
    let finalScore: Int
    let performanceLabel: String
    let milkAttempts: Int
    let eggsAttempts: Int
    let breadAttempts: Int
    let remainingBudget: Double
    
    @State private var teacherNotes: String = ""
    @State private var assessmentSaved: Bool = false
    var onReset: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Header
                    VStack(spacing: 8) {
                        Text("Assessment Complete")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text(studentName)
                            .font(.system(size: 18))
                            .foregroundColor(.gray)

                        Text(studentGrade)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)

                    // Score circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 12)
                            .frame(width: 140, height: 140)

                        Circle()
                            .trim(from: 0, to: CGFloat(finalScore) / 100)
                            .stroke(scoreColor, lineWidth: 12)
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            Text("\(finalScore)")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            Text("/ 100")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }

                    // Performance label
                    Text(performanceLabel)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(scoreColor)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(scoreColor.opacity(0.15))
                        .cornerRadius(20)

                    // Breakdown
                    VStack(spacing: 0) {
                        resultRow(
                            item: "🥛 Milk",
                            price: "£2",
                            attempts: milkAttempts
                        )
                        Divider().background(Color.white.opacity(0.1))
                        resultRow(
                            item: "🥚 Eggs",
                            price: "£4",
                            attempts: eggsAttempts
                        )
                        Divider().background(Color.white.opacity(0.1))
                        resultRow(
                            item: "🍞 Bread",
                            price: "£3",
                            attempts: breadAttempts
                        )
                        Divider().background(Color.white.opacity(0.1))

                        // Remaining budget
                        HStack {
                            Text("💰 Remaining Budget")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                            Spacer()
                            Text("£\(String(format: "%.0f", remainingBudget))")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(14)
                    .padding(.horizontal, 20)

                    // Teacher Notes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Teacher Observation Notes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        TextEditor(text: $teacherNotes)
                            .frame(minHeight: 120)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .overlay(
                                Group {
                                    if teacherNotes.isEmpty {
                                        Text("Add observations about the student's performance, confidence, reasoning approach...")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 13))
                                            .padding()
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    .padding(.horizontal, 20)

                    // Save button
                    Button(action: {
                        assessmentSaved = true
                    }) {
                        Text(assessmentSaved ? "✅ Saved!" : "Save Assessment")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(assessmentSaved ? Color.green : Color.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .disabled(assessmentSaved)

                    // New assessment button
                    Button(action: {
                        onReset()
                    }) {
                        Text("Start New Assessment")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Result Row
    func resultRow(item: String, price: String, attempts: Int) -> some View {
        HStack {
            Text(item)
                .font(.system(size: 15))
                .foregroundColor(.white)
            Spacer()
            Text(price)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text("\(attempts) \(attempts == 1 ? "attempt" : "attempts")")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(attempts == 1 ? .green : .orange)
        }
        .padding()
        .background(Color.white.opacity(0.05))
    }

    // MARK: - Score colour
    var scoreColor: Color {
        switch finalScore {
        case 90...100: return .green
        case 75...89: return .yellow
        case 55...74: return .orange
        default: return .red
        }
    }
}

//
//  ContentView.swift
//  Examar
//
//  Created by Rohan Katyayani on 07/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var studentName: String = ""
    @State private var studentGrade: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App Logo / Title
                    VStack(spacing: 8) {
                        Text("Examar")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("The AR that takes your exam.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Student Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Student Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("Enter student name", text: $studentName)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 32)
                    
                    // Grade Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Grade")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("Enter grade (e.g. Grade 3)", text: $studentGrade)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 32)
                    
                    // Error message
                    if showError {
                        Text("Please enter student name and grade.")
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    // Start Button
                    NavigationLink(destination: ARAssessmentView(
                        studentName: studentName,
                        studentGrade: studentGrade
                    )) {
                        Text("Start Assessment")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(studentName.isEmpty || studentGrade.isEmpty ? Color.gray : Color.white)
                            .cornerRadius(14)
                    }
                    .disabled(studentName.isEmpty || studentGrade.isEmpty)
                    .padding(.horizontal, 32)
                    .simultaneousGesture(TapGesture().onEnded {
                        if studentName.isEmpty || studentGrade.isEmpty {
                            showError = true
                        }
                    })
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

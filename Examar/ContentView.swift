//
//  ContentView.swift
//  Examar
//
//  Created by Rohan Katyayani on 07/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showAR = false
    
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
                        
                        TextField("Enter student name", text: .constant(""))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 32)
                    
                    // Grade Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Grade")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("Enter grade (e.g. Grade 3)", text: .constant(""))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Start Button
                    NavigationLink(destination: Text("AR View Coming Soon")) {
                        Text("Start Assessment")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

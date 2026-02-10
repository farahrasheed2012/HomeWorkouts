//
//  CelebrationView.swift
//  HomeStrength
//
//  Fun celebration when young kids complete an activity. Bright colors, encouraging message.
//

import SwiftUI

struct CelebrationView: View {
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var starRotation: Double = 0
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                
                Text("You did it!")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("You're a star! Keep moving and having fun!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                
                HStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(HSTheme.accent)
                        .rotationEffect(.degrees(starRotation))
                    Image(systemName: "star.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(HSTheme.accent)
                        .rotationEffect(.degrees(-starRotation * 0.8))
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(HSTheme.accent)
                        .rotationEffect(.degrees(starRotation * 0.6))
                }
                .padding(.top, 8)
                
                Button {
                    onDismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(HSTheme.accent)
                .padding(.horizontal, 48)
                .padding(.top, 24)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                starRotation = 15
            }
        }
    }
}

#Preview {
    CelebrationView(onDismiss: {})
}

//
//  ContentView.swift
//  GeminiChat
//
//  Created by Anup D'Souza on 15/12/23.
//

import SwiftUI
import Combine
import GoogleGenerativeAI

struct ContentView: View {
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    @State var textInput = ""
    @State var aiResponse = "Hello! How can I help you today?"
    @State var loadingResponse = false
    @State var logoAnimating = false
    @State private var timer: Timer?

    var body: some View {
        VStack {
            // MARK: Animating logo
            Image(.geminiLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .opacity(logoAnimating ? 0.5 : 1)
                .animation(.easeInOut, value: logoAnimating)

            // MARK: AI response
            ScrollView {
                Text(aiResponse)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            }

            // MARK: Input fields
            HStack {
                TextField("Enter a message", text: $textInput)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.black)
                Button(action: sendMessage, label: {
                    Image(systemName: "paperplane.fill")
                })
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background {
            // MARK: Background
            ZStack {
                Color.black
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: Fetch response
    func sendMessage() {
        aiResponse = ""
        startLoadingAnimation()
        
        Task {
            let response = try await model.generateContent(textInput)
            
            stopLoadingAnimation()
            
            guard let text = response.text else  {
                textInput = "Sorry, I could not process that.\nPlease try again."
                return
            }
            textInput = ""
            aiResponse = text
        }
    }
    
    // MARK: Response loading animation
    func startLoadingAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            logoAnimating.toggle()
        })
    }
    
    func stopLoadingAnimation() {
        logoAnimating = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  iOS-Download-Manager
//
//  Created by CIPL on 07/11/25.
//

import SwiftUI

struct ContentView: View {
    let downloadLink = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    let downloadLinks = [
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    ]
    
    let downloadManager = DownloadManager()
    @State private var isChecked: Bool = false
    
    var body: some View {
        VStack {
        
            Toggle(isOn: $isChecked) {
                Text("Save in photo")
            }
            .toggleStyle(.switch)
            .padding()
            
            Button("Download Single File"){
                downloadManager.downloadSingleFile(
                    from: downloadLink,
                    fileName: "Sample.mp4",
                    saveToPhotos: isChecked,
                    completion: { message in
                       print("\(message)")
                    },
                    progressCallback: { progress in
                        DispatchQueue.main.async {
                            handleDownloadEvent(progress)
                        }
                    },
                    
                )
            }.buttonStyle(.borderedProminent)
            
            Button("Download Multiple File"){
                downloadManager.downloadMultipleFiles(
                    from: downloadLinks,
                    fileNames: ["1","2"],
                    saveToPhotos: isChecked,
                    completion: { message in
                       print("\(message)")
                    },
                    progressCallback: { progress in
                        DispatchQueue.main.async {
                            handleDownloadEvent(progress)
                        }
                    },
                    
                )
            }.buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func handleDownloadEvent(_ event: [String: Any]) {

        guard let status = event["status"] as? String else {
            print("⚠️ Unknown event: \(event)")
            return
        }

        let fileName = event["fileName"] as? String ?? "unknown"

        switch status {
        case "started":
            print("🚀 Started \(fileName)")

        case "progress":
            let progress = event["progress"] as? Int ?? 0
            print("📊 Progress \(fileName): \(progress)%")

        case "success":
            print("✅ Completed \(fileName)")

        case "saved":
            print("📷 Saved to photo \(fileName)")

        case "failed":
            print("❌ Failed \(fileName)")

        case "completed":
            print("🎉 Download completed")

        case "error":
            let message = event["message"] as? String ?? "Unknown error"
            print("⚠️ Error: \(message)")

        default:
            print("❓ Unknown status: \(status)")
        }
    }

}

#Preview {
    ContentView()
}

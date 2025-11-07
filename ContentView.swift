//
//  ContentView.swift
//  iOS-Download-Manager
//
//  Created by CIPL on 07/11/25.
//

import SwiftUI

struct ContentView: View {
    let downloadLink = [
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    ]
    let downloadManager = DownloadManager()
    @State private var isChecked: Bool = false
    let notificationService = NotificationService()
    
    init() {
        initNotificationDelegate()
        notificationService.requestNotificationPermission()
    }
    
    var body: some View {
        VStack {
        
            Toggle(isOn: $isChecked) {
                Text("Save in photo")
            }
            .toggleStyle(.switch)
            .padding()
            
            Button("Download"){
                downloadManager.downloadFilesParallel(from: downloadLink, saveToPhotos: isChecked ,completion: {
                    print("🎉 All files downloaded!")
                })
            }.buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

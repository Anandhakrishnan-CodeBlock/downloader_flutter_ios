import Foundation

class DownloadManager {
    
    let saveToPhoto = SaveToPhoto()
    let notificationService = NotificationService()
    
//    func downloadFiles(from urls: [String], folderName: String = "MyDownloads") {
//        // 1️⃣ Create (or get) the app’s Documents directory
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        
//        // 2️⃣ Create the subfolder inside Documents (e.g., /Documents/MyDownloads)
//        let folderURL = documentsURL.appendingPathComponent(folderName)
//        
//        do {
//            // Create directory if it doesn't exist
//            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
//            print("📁 Folder created at: \(folderURL.path)")
//        } catch {
//            print("❌ Failed to create folder: \(error)")
//            return
//        }
//        
//        // 3️⃣ Start sequential download of files
//        func downloadNext(index: Int) {
//            guard index < urls.count else {
//                print("✅ All files downloaded to \(folderURL.path)")
//                return
//            }
//            
//            let urlString = urls[index]
//            guard let url = URL(string: urlString) else {
//                print("Invalid URL: \(urlString)")
//                downloadNext(index: index + 1)
//                return
//            }
//            
//            let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
//                if let error = error {
//                    print("❌ Download error for \(url.lastPathComponent): \(error)")
//                    downloadNext(index: index + 1)
//                    return
//                }
//                
//                guard let localURL = localURL else {
//                    print("⚠️ No local file URL for \(url)")
//                    downloadNext(index: index + 1)
//                    return
//                }
//                
//                // 4️⃣ Destination path inside the created folder
//                let destinationURL = folderURL.appendingPathComponent(url.lastPathComponent)
//                
//                do {
//                    // Remove file if it already exists
//                    if FileManager.default.fileExists(atPath: destinationURL.path) {
//                        try FileManager.default.removeItem(at: destinationURL)
//                    }
//                    // Move from temp to destination folder
//                    try FileManager.default.moveItem(at: localURL, to: destinationURL)
//                    print("⬇️ \(url.lastPathComponent) saved to \(folderName)")
//                } catch {
//                    print("❌ File move error: \(error)")
//                }
//                
//                // Continue with next file
//                downloadNext(index: index + 1)
//            }
//            
//            task.resume()
//        }
//        
//        downloadNext(index: 0)
//    }
    
    // Function to download multiple files in parallel (simultaneously)
    func downloadFilesParallel(from urls: [String],saveToPhotos: Bool ,completion: @escaping () -> Void) {
        
        // Create a DispatchGroup to track when all downloads are finished.
        // Think of it like a counter — it enters when a task starts and leaves when it ends.
        let group = DispatchGroup()
        
        // Get the app's Documents directory where we will save all downloaded files
        // This path is inside your app’s sandbox → "On My iPhone → YourAppName"
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Loop through all URLs to start downloading them in parallel
        for urlString in urls {
            // Convert each string into a valid URL object
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL: \(urlString)")
                continue  // Skip invalid URLs
            }
            
            // Tell DispatchGroup a new task (download) is starting
            group.enter()
            
            // Notify user download started
            notificationService.sendNotification(title: "📥 Download Started", body: "\(url.lastPathComponent)")
            
            // Create a download task for this URL
            let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
                
                // This closure runs once the download for this file finishes (success or failure)
                
                // Ensure the DispatchGroup knows this download is done before leaving the closure
                defer { group.leave() }
                
                // Handle any error
                if let error = error {
                    print("❌ Error downloading \(url.lastPathComponent): \(error)")
                    return
                }
                
                // localURL is the temporary file location assigned by iOS
                guard let localURL = localURL else {
                    print("⚠️ No local file URL for \(url.lastPathComponent)")
                    return
                }
                
                // Create the final save location inside the Documents folder
                let destinationURL = documents.appendingPathComponent(url.lastPathComponent)
                
                do {
                    // If a file with the same name already exists, delete it first
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    
                    // Move the downloaded file from temporary folder → to Documents folder
                    try FileManager.default.moveItem(at: localURL, to: destinationURL)
                    
                    // Success message for debugging
                    print("✅ \(url.lastPathComponent) downloaded and saved.")
                    
                    // Notify success for individual file
                    self.notificationService.sendNotification(title: "✅ Download Complete", body: "\(url.lastPathComponent) saved locally")
                    
                    // Save to Photos immediately (if enabled)
                    if saveToPhotos {
                        self.saveToPhoto.saveMediaToPhotos(from: destinationURL) { success, _ in
                            if success {
                                print("📷 \(url.lastPathComponent) saved to Photos")
                            }
                        }
                    }
                    
                } catch {
                    // Handle any file move errors
                    print("❌ File move error: \(error)")
                }
            }
            
            // Start the download task immediately
            task.resume()
        }
        
        // Once all downloads have finished (all .enter() calls are matched by .leave()),
        // this block will be executed on the main queue.
        group.notify(queue: .main) {
            print("🎉 All files downloaded successfully!")
            completion() // Trigger the completion callback passed into the function
        }
    }
}






//
//  MetadataUpdateViewModel.swift
//  Image Metadata App
//
//  ViewModel for handling metadata updates
//

import SwiftUI
import AppKit
import Foundation
import Combine
import UniformTypeIdentifiers

class MetadataUpdateViewModel: ObservableObject {
    @Published var selectedFolderPath: String = ""
    @Published var selectedJSONPath: String = ""
    @Published var isProcessing: Bool = false
    @Published var progress: Double = 0.0
    @Published var statusMessage: String = ""
    @Published var errorMessage: String = ""
    @Published var hasError: Bool = false
    @Published var isComplete: Bool = false
    @Published var showExifToolAlert: Bool = false
    @Published var exifToolErrorMessage: String = ""
    @Published var failedFilesDetails: [FailedFile] = []
    @Published var showFailedFilesAlert: Bool = false
    
    private var selectedFolderURL: URL?
    private var selectedJSONURL: URL?
    private let metadataService = MetadataUpdateService()
    
    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        
        if panel.runModal() == .OK {
            selectedFolderURL = panel.url
            selectedFolderPath = panel.url?.path ?? ""
        }
    }
    
    func selectJSONFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = false
        
        if panel.runModal() == .OK {
            selectedJSONURL = panel.url
            selectedJSONPath = panel.url?.path ?? ""
        }
    }
    
    func startProcessing() {
        guard let folderURL = selectedFolderURL,
              let jsonURL = selectedJSONURL else {
            errorMessage = "Please select both folder and JSON file"
            hasError = true
            return
        }
        
        // Check if metadata service is available (now always true with native implementation)
        guard metadataService.isExifToolAvailable() else {
            exifToolErrorMessage = """
            Metadata service is not available.
            """
            showExifToolAlert = true
            return
        }
        
        isProcessing = true
        hasError = false
        isComplete = false
        progress = 0.0
        statusMessage = "Reading JSON file..."
        
        Task { @MainActor in
            do {
                let result = try await metadataService.updateMetadata(
                    folderURL: folderURL,
                    jsonURL: jsonURL,
                    progressCallback: { current, total, message in
                        Task { @MainActor in
                            self.progress = Double(current) / Double(total)
                            self.statusMessage = message
                        }
                    }
                )
                
                self.isProcessing = false
                self.isComplete = true
                self.progress = 1.0
                self.statusMessage = "Successfully updated \(result.successCount) of \(result.totalCount) images"
                
                if result.failedCount > 0 {
                    self.statusMessage += "\n\(result.failedCount) files failed to update"
                    self.failedFilesDetails = result.failedFiles
                    self.showFailedFilesAlert = true
                }
            } catch {
                self.isProcessing = false
                self.hasError = true
                self.errorMessage = error.localizedDescription
            }
        }
    }
}


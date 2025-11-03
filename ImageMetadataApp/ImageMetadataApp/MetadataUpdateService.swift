//
//  MetadataUpdateService.swift
//  Image Metadata App
//
//  Service for updating image metadata using ExifTool
//

import Foundation

struct UpdateResult {
    let totalCount: Int
    let successCount: Int
    let failedCount: Int
    let failedFiles: [FailedFile]
}

struct FailedFile: Identifiable {
    let id = UUID()
    let fileName: String
    let errorMessage: String
}

class MetadataUpdateService {
    
    func isExifToolAvailable() -> Bool {
        // No longer needed - we use native ImageIO framework
        // Always return true since we have native support
        return true
    }
    
    func updateMetadata(
        folderURL: URL,
        jsonURL: URL,
        progressCallback: @escaping (Int, Int, String) -> Void
    ) async throws -> UpdateResult {
        
        // Read JSON file
        // Supports all image formats that ExifTool supports, including:
        // - JPEG, PNG, TIFF, HEIC
        // - RAW formats: ARW (Sony), CR2 (Canon), NEF (Nikon), DNG, and more
        let jsonData = try Data(contentsOf: jsonURL)
        let metadataArray = try JSONDecoder().decode([ImageMetadata].self, from: jsonData)
        
        var successCount = 0
        var failedCount = 0
        var failedFiles: [FailedFile] = []
        let totalCount = metadataArray.count
        
        // Get all files in the folder for matching by base name (ignoring extensions)
        let fileManager = FileManager.default
        let folderContents = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.nameKey])
        
        // Create a dictionary mapping base filenames (lowercase, no extension) to actual file URLs
        var baseNameToFileMap: [String: URL] = [:]
        if let contents = folderContents {
            for fileURL in contents {
                let baseName = fileURL.deletingPathExtension().lastPathComponent.lowercased()
                // Only keep the first match if there are duplicates (shouldn't happen, but just in case)
                if baseNameToFileMap[baseName] == nil {
                    baseNameToFileMap[baseName] = fileURL
                }
            }
        }
        
        for (index, metadata) in metadataArray.enumerated() {
            // Extract base filename from SourceFile, ignoring extension
            let sourceFileName = (metadata.sourceFile as NSString).lastPathComponent
            // Get base name without extension - use URL API for reliable path handling
            let tempURL = URL(fileURLWithPath: sourceFileName)
            let baseFileName = tempURL.deletingPathExtension().lastPathComponent
            let baseFileNameLower = baseFileName.lowercased()
            
            progressCallback(index, totalCount, "Processing: \(sourceFileName)")
            
            // Try to find file by base name (extension-agnostic, case-insensitive)
            // Priority: 1) Base name match (ignoring extension), 2) Exact/case-insensitive with extension
            var imageURL: URL?
            
            // First priority: Match by base name only (ignoring extension from JSON)
            // This allows JSON to have ".jpg" but find ".ARW" files, etc.
            if let matched = baseNameToFileMap[baseFileNameLower] {
                imageURL = matched
            }
            // Fallback: Try exact match with extension from JSON (in case someone wants exact extension matching)
            else {
                let exactFileName = folderURL.appendingPathComponent(sourceFileName)
                if fileManager.fileExists(atPath: exactFileName.path) {
                    imageURL = exactFileName
                }
                // Then try case-insensitive match with extension from JSON
                else if let folderContents = folderContents,
                        let matched = folderContents.first(where: {
                            $0.lastPathComponent.lowercased() == sourceFileName.lowercased()
                        }) {
                    imageURL = matched
                }
            }
            
            do {
                if let imageURL = imageURL, fileManager.fileExists(atPath: imageURL.path) {
                    try await updateSingleImageMetadata(imageURL: imageURL, metadata: metadata)
                    successCount += 1
                } else {
                    failedCount += 1
                    let errorMsg = "File not found in folder: \(sourceFileName) (looking for base name: \(baseFileName))"
                    failedFiles.append(FailedFile(fileName: sourceFileName, errorMessage: errorMsg))
                    print(errorMsg)
                }
            } catch {
                failedCount += 1
                let errorMsg = error.localizedDescription
                failedFiles.append(FailedFile(fileName: sourceFileName, errorMessage: errorMsg))
                print("Error updating \(sourceFileName): \(errorMsg)")
            }
        }
        
        progressCallback(totalCount, totalCount, "Complete!")
        
        return UpdateResult(
            totalCount: totalCount,
            successCount: successCount,
            failedCount: failedCount,
            failedFiles: failedFiles
        )
    }
    
    /// Updates metadata for a single image file using native ImageIO framework.
    /// This replaces the external ExifTool dependency and avoids permission issues.
    private func updateSingleImageMetadata(imageURL: URL, metadata: ImageMetadata) async throws {
        // Use native Swift/ImageIO implementation instead of external ExifTool
        let exifService = ExifMetadataService()
        
        // Run on background queue since this can be I/O intensive
        try await exifService.updateMetadata(imageURL: imageURL, metadata: metadata)
    }
}

// MARK: - Metadata Models

struct ImageMetadata: Codable {
    let dateTimeOriginal: String?
    let description: String?
    let documentName: String?
    let exposureTime: Double
    let fileSource: Int
    let fNumber: Double
    let focalLength: Int
    let focalLengthIn35mmFormat: Int
    let gpsLatitude: String?
    let gpsLatitudeRef: String?
    let gpsLongitude: String?
    let gpsLongitudeRef: String?
    let imageNumber: Int
    let imageUniqueId: String?
    let iso: Int
    let isoSpeed: Int
    let lensMake: String?
    let lensModel: String?
    let make: String?
    let model: String?
    let notes: String?
    let reelName: String?
    let sensitivityType: Int
    let software: String?
    let sourceFile: String
    let spectralSensitivity: String?
    let userComment: String?
    
    enum CodingKeys: String, CodingKey {
        case dateTimeOriginal = "DateTimeOriginal"
        case description = "Description"
        case documentName = "DocumentName"
        case exposureTime = "ExposureTime"
        case fileSource = "FileSource"
        case fNumber = "FNumber"
        case focalLength = "FocalLength"
        case focalLengthIn35mmFormat = "FocalLengthIn35mmFormat"
        case gpsLatitude = "GPSLatitude"
        case gpsLatitudeRef = "GPSLatitudeRef"
        case gpsLongitude = "GPSLongitude"
        case gpsLongitudeRef = "GPSLongitudeRef"
        case imageNumber = "ImageNumber"
        case imageUniqueId = "ImageUniqueId"
        case iso = "ISO"
        case isoSpeed = "ISOSpeed"
        case lensMake = "LensMake"
        case lensModel = "LensModel"
        case make = "Make"
        case model = "Model"
        case notes = "Notes"
        case reelName = "ReelName"
        case sensitivityType = "SensitivityType"
        case software = "Software"
        case sourceFile = "SourceFile"
        case spectralSensitivity = "SpectralSensitivity"
        case userComment = "UserComment"
    }
}


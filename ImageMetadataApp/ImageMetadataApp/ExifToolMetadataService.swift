//
//  ExifToolMetadataService.swift
//  Image Metadata App
//
//  Fallback service using ExifTool for RAW files that ImageIO cannot handle
//

import Foundation

class ExifToolMetadataService {
    
    /// Get the path to bundled ExifTool in the app's Resources folder
    private func bundledExifToolPath() -> String? {
        guard let bundlePath = Bundle.main.resourcePath else { return nil }
        
        let exiftoolPath = (bundlePath as NSString).appendingPathComponent("exiftool")
        let libPath = (bundlePath as NSString).appendingPathComponent("lib")
        
        // Check that both the script and lib directory exist
        if FileManager.default.fileExists(atPath: exiftoolPath) &&
           FileManager.default.fileExists(atPath: libPath) {
            return exiftoolPath
        }
        
        return nil
    }
    
    private func findExifToolPath() -> String? {
        // First priority: Use bundled ExifTool
        if let bundled = bundledExifToolPath() {
            return bundled
        }
        
        // Fall back to system installation
        let commonPaths = [
            "/usr/local/bin/exiftool",
            "/opt/homebrew/bin/exiftool",
            "/usr/bin/exiftool"
        ]
        
        for path in commonPaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
    
    func updateMetadata(imageURL: URL, metadata: ImageMetadata) async throws {
        guard let exifToolPath = findExifToolPath() else {
            throw NSError(
                domain: "ExifToolMetadataService",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: """
                    ExifTool is required for RAW files (ARW, CR2, NEF, etc.).
                    
                    ImageIO cannot write to RAW formats, so ExifTool is needed as a fallback.
                    
                    Please bundle ExifTool with the app (see BUNDLE_EXIFTOOL.md) or install:
                    brew install exiftool
                    """
                ]
            )
        }
        
        // Build ExifTool command arguments
        // Use -overwrite_original which handles file replacement atomically
        // It creates temp files but handles permissions better than manual replacement
        var arguments: [String] = ["-overwrite_original"]
        
        // Add all metadata fields
        if let value = metadata.dateTimeOriginal, !value.isEmpty {
            arguments.append("-DateTimeOriginal=\(value)")
        }
        if let value = metadata.description, !value.isEmpty {
            arguments.append("-Description=\(value)")
        }
        if let value = metadata.documentName, !value.isEmpty {
            arguments.append("-DocumentName=\(value)")
        }
        if metadata.exposureTime > 0 {
            arguments.append("-ExposureTime=\(metadata.exposureTime)")
        }
        if metadata.fileSource > 0 {
            arguments.append("-FileSource=\(metadata.fileSource)")
        }
        if metadata.fNumber > 0 {
            arguments.append("-FNumber=\(metadata.fNumber)")
        }
        if metadata.focalLength > 0 {
            arguments.append("-FocalLength=\(metadata.focalLength)")
        }
        if metadata.focalLengthIn35mmFormat > 0 {
            arguments.append("-FocalLengthIn35mmFormat=\(metadata.focalLengthIn35mmFormat)")
        }
        if let value = metadata.gpsLatitude, !value.isEmpty {
            arguments.append("-GPSLatitude=\(value)")
        }
        if let value = metadata.gpsLatitudeRef, !value.isEmpty {
            arguments.append("-GPSLatitudeRef=\(value)")
        }
        if let value = metadata.gpsLongitude, !value.isEmpty {
            arguments.append("-GPSLongitude=\(value)")
        }
        if let value = metadata.gpsLongitudeRef, !value.isEmpty {
            arguments.append("-GPSLongitudeRef=\(value)")
        }
        if metadata.imageNumber > 0 {
            arguments.append("-ImageNumber=\(metadata.imageNumber)")
        }
        if let value = metadata.imageUniqueId, !value.isEmpty {
            arguments.append("-ImageUniqueID=\(value)")
        }
        if metadata.iso > 0 {
            arguments.append("-ISO=\(metadata.iso)")
        }
        if metadata.isoSpeed > 0 {
            arguments.append("-ISOSpeed=\(metadata.isoSpeed)")
        }
        if let value = metadata.lensMake, !value.isEmpty {
            arguments.append("-LensMake=\(value)")
        }
        if let value = metadata.lensModel, !value.isEmpty {
            arguments.append("-LensModel=\(value)")
        }
        if let value = metadata.make, !value.isEmpty {
            arguments.append("-Make=\(value)")
        }
        if let value = metadata.model, !value.isEmpty {
            arguments.append("-Model=\(value)")
        }
        if let value = metadata.notes, !value.isEmpty {
            arguments.append("-Notes=\(value)")
        }
        if let value = metadata.reelName, !value.isEmpty {
            arguments.append("-ReelName=\(value)")
        }
        if metadata.sensitivityType > 0 {
            arguments.append("-SensitivityType=\(metadata.sensitivityType)")
        }
        if let value = metadata.software, !value.isEmpty {
            arguments.append("-Software=\(value)")
        }
        if let value = metadata.spectralSensitivity, !value.isEmpty {
            arguments.append("-SpectralSensitivity=\(value)")
        }
        if let value = metadata.userComment, !value.isEmpty {
            arguments.append("-UserComment=\(value)")
        }
        
        // Add source file path - ExifTool will update it in place
        arguments.append(imageURL.path)
        
        // Execute ExifTool - it will handle file replacement with -overwrite_original
        try await executeExifTool(exifToolPath: exifToolPath, arguments: arguments)
    }
    
    private func executeExifTool(exifToolPath: String, arguments: [String]) async throws {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
            
            // Pass the script path as the first argument, then all ExifTool arguments
            var perlArguments = [exifToolPath]
            perlArguments.append(contentsOf: arguments)
            task.arguments = perlArguments
            
            // Set up environment with PERL5LIB
            var environment = ProcessInfo.processInfo.environment
            if let bundlePath = Bundle.main.resourcePath {
                let libPath = (bundlePath as NSString).appendingPathComponent("lib")
                if FileManager.default.fileExists(atPath: libPath) {
                    if let perl5lib = environment["PERL5LIB"] {
                        environment["PERL5LIB"] = "\(libPath):\(perl5lib)"
                    } else {
                        environment["PERL5LIB"] = libPath
                    }
                }
            }
            task.environment = environment
            
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            task.standardOutput = outputPipe
            task.standardError = errorPipe
            
            task.terminationHandler = { process in
                if process.terminationStatus == 0 {
                    continuation.resume()
                } else {
                    // Read both error and standard output
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let standardOutput = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    // Combine outputs and filter out harmless warnings
                    // These warnings don't indicate failures - ExifTool just can't print certain fields
                    let combinedOutput = (errorOutput + "\n" + standardOutput).trimmingCharacters(in: .whitespacesAndNewlines)
                    let lines = combinedOutput.components(separatedBy: .newlines)
                    let importantLines = lines.filter { line in
                        let lowerLine = line.lowercased()
                        return !lowerLine.contains("warning: can't convert") &&
                               !lowerLine.contains("not in printconv") &&
                               !lowerLine.contains("exififd:filesource") &&
                               !lowerLine.contains("exififd:sensitivitytype") &&
                               !line.isEmpty
                    }
                    let filteredError = importantLines.joined(separator: "\n")
                    
                    var finalError = !filteredError.isEmpty ? filteredError : "ExifTool exited with code \(process.terminationStatus)"
                    
                    // Check for common permission-related errors and provide helpful message
                    let lowerError = finalError.lowercased()
                    if lowerError.contains("permission") || 
                       lowerError.contains("couldn't be removed") ||
                       lowerError.contains("access") ||
                       lowerError.contains("operation not permitted") {
                        finalError = """
                        \(finalError)
                        
                        macOS is blocking file modification. To fix:
                        1. System Settings → Privacy & Security → Full Disk Access
                        2. Add \(Bundle.main.bundleIdentifier ?? "ImageMetadataApp") to the list
                        3. Enable the toggle
                        4. Restart the app
                        """
                    }
                    
                    continuation.resume(throwing: NSError(
                        domain: "ExifToolMetadataService",
                        code: Int(process.terminationStatus),
                        userInfo: [NSLocalizedDescriptionKey: finalError]
                    ))
                }
            }
            
            do {
                try task.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}


//
//  ExifMetadataService.swift
//  Image Metadata App
//
//  Native EXIF metadata reading/writing using ImageIO framework
//  Replaces external ExifTool dependency
//

import Foundation
import ImageIO
import CoreGraphics

class ExifMetadataService {
    
    /// Updates EXIF metadata for an image file using native ImageIO framework
    func updateMetadata(imageURL: URL, metadata: ImageMetadata) async throws {
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
            throw NSError(
                domain: "ExifMetadataService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Could not create image source from: \(imageURL.path)"]
            )
        }
        
        guard let imageType = CGImageSourceGetType(imageSource) else {
            throw NSError(
                domain: "ExifMetadataService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Could not determine image type"]
            )
        }
        
        // Check if this is a RAW format that ImageIO can't write to
        let rawFormats: [String] = [
            "com.sony.arw-raw-image",
            "com.canon.cr2-raw-image",
            "com.nikon.nef-raw-image",
            "com.adobe.dng-raw-image",
            "com.fuji.raf-raw-image",
            "com.olympus.orf-raw-image"
        ]
        
        // Check if this is a RAW format by extension (more reliable than UTI)
        let rawExtensions = ["arw", "cr2", "nef", "raf", "orf", "rw2", "raw", "srw", "x3f", "3fr", "mef", "erf"]
        let fileExtension = imageURL.pathExtension.lowercased()
        
        // Standard formats that ImageIO can handle - use native implementation
        let standardExtensions = ["jpg", "jpeg", "png", "tiff", "tif", "heic", "heif", "gif", "bmp", "webp"]
        
        // Only use ExifTool for RAW files
        if let uti = imageType as String?, uti.contains("raw-image") {
            // RAW format detected by UTI - use ExifTool fallback
            return try await updateRAWMetadata(imageURL: imageURL, metadata: metadata)
        }
        
        if rawExtensions.contains(fileExtension) {
            // RAW format detected by extension - use ExifTool fallback
            return try await updateRAWMetadata(imageURL: imageURL, metadata: metadata)
        }
        
        // For standard formats (JPEG, PNG, TIFF, HEIC), use native ImageIO
        // Continue with native ImageIO implementation below...
        
        // Get existing metadata
        guard let existingMetadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            throw NSError(
                domain: "ExifMetadataService",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Could not read existing metadata"]
            )
        }
        
        // Create mutable copy
        let mutableMetadata = NSMutableDictionary(dictionary: existingMetadata)
        
        // Update EXIF dictionary
        var exif = (mutableMetadata[kCGImagePropertyExifDictionary as String] as? NSMutableDictionary) ?? NSMutableDictionary()
        
        // Update TIFF dictionary (for camera/lens info)
        var tiff = (mutableMetadata[kCGImagePropertyTIFFDictionary as String] as? NSMutableDictionary) ?? NSMutableDictionary()
        
        // Update GPS dictionary
        var gps = (mutableMetadata[kCGImagePropertyGPSDictionary as String] as? NSMutableDictionary) ?? NSMutableDictionary()
        
        // Convert and set EXIF fields
        if let value = metadata.dateTimeOriginal, !value.isEmpty {
            exif[kCGImagePropertyExifDateTimeOriginal as String] = value
        }
        if let value = metadata.description, !value.isEmpty {
            exif[kCGImagePropertyExifUserComment as String] = value
        }
        if metadata.exposureTime > 0 {
            exif[kCGImagePropertyExifExposureTime as String] = metadata.exposureTime
        }
        if metadata.fNumber > 0 {
            exif[kCGImagePropertyExifFNumber as String] = metadata.fNumber
        }
        if metadata.focalLength > 0 {
            exif[kCGImagePropertyExifFocalLength as String] = metadata.focalLength
        }
        if metadata.focalLengthIn35mmFormat > 0 {
            exif["FocalLengthIn35mmFilm" as String] = metadata.focalLengthIn35mmFormat
        }
        if metadata.iso > 0 {
            exif[kCGImagePropertyExifISOSpeedRatings as String] = [metadata.iso]
        }
        if metadata.isoSpeed > 0 {
            exif["ISOSpeed" as String] = metadata.isoSpeed
        }
        if metadata.imageNumber > 0 {
            exif["ImageNumber" as String] = metadata.imageNumber
        }
        if metadata.sensitivityType > 0 {
            exif["SensitivityType" as String] = metadata.sensitivityType
        }
        if let value = metadata.software, !value.isEmpty {
            exif["Software" as String] = value
        }
        
        // TIFF (camera/lens) fields
        if let value = metadata.make, !value.isEmpty {
            tiff[kCGImagePropertyTIFFMake as String] = value
        }
        if let value = metadata.model, !value.isEmpty {
            tiff[kCGImagePropertyTIFFModel as String] = value
        }
        
        // GPS fields
        if let value = metadata.gpsLatitude, !value.isEmpty {
            gps[kCGImagePropertyGPSLatitude as String] = parseGPSString(value)
        }
        if let value = metadata.gpsLatitudeRef, !value.isEmpty {
            gps[kCGImagePropertyGPSLatitudeRef as String] = value
        }
        if let value = metadata.gpsLongitude, !value.isEmpty {
            gps[kCGImagePropertyGPSLongitude as String] = parseGPSString(value)
        }
        if let value = metadata.gpsLongitudeRef, !value.isEmpty {
            gps[kCGImagePropertyGPSLongitudeRef as String] = value
        }
        
        // Update mutable metadata
        mutableMetadata[kCGImagePropertyExifDictionary as String] = exif
        mutableMetadata[kCGImagePropertyTIFFDictionary as String] = tiff
        mutableMetadata[kCGImagePropertyGPSDictionary as String] = gps
        
        // Custom fields that might not be in standard dictionaries
        if let value = metadata.imageUniqueId, !value.isEmpty {
            exif["ImageUniqueID" as String] = value
        }
        if let value = metadata.lensMake, !value.isEmpty {
            exif["LensMake" as String] = value
        }
        if let value = metadata.lensModel, !value.isEmpty {
            exif["LensModel" as String] = value
        }
        if let value = metadata.notes, !value.isEmpty {
            mutableMetadata["Notes" as String] = value
        }
        if let value = metadata.reelName, !value.isEmpty {
            mutableMetadata["ReelName" as String] = value
        }
        if let value = metadata.documentName, !value.isEmpty {
            mutableMetadata["DocumentName" as String] = value
        }
        if let value = metadata.description, !value.isEmpty {
            mutableMetadata["Description" as String] = value
        }
        if let value = metadata.userComment, !value.isEmpty {
            exif[kCGImagePropertyExifUserComment as String] = value
        }
        if let value = metadata.spectralSensitivity, !value.isEmpty {
            exif["SpectralSensitivity" as String] = value
        }
        if metadata.fileSource > 0 {
            exif["FileSource" as String] = metadata.fileSource
        }
        
        // Write to temporary file first, then replace original
        // This ensures atomic updates and works better with RAW files
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(imageURL.pathExtension)
        
        defer {
            // Clean up temp file
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        guard let imageDestination = CGImageDestinationCreateWithURL(
            tempURL as CFURL,
            imageType,
            1,
            nil
        ) else {
            throw NSError(
                domain: "ExifMetadataService",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Could not create image destination"]
            )
        }
        
        // Copy image data
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw NSError(
                domain: "ExifMetadataService",
                code: -5,
                userInfo: [NSLocalizedDescriptionKey: "Could not create image from source"]
            )
        }
        
        // Add image with updated metadata
        CGImageDestinationAddImage(imageDestination, image, mutableMetadata as CFDictionary)
        
        // Finalize to temp file
        guard CGImageDestinationFinalize(imageDestination) else {
            throw NSError(
                domain: "ExifMetadataService",
                code: -6,
                userInfo: [NSLocalizedDescriptionKey: "Could not finalize image destination"]
            )
        }
        
        // Replace original with temp file
        let fileManager = FileManager.default
        
        do {
            // Remove original file
            if fileManager.fileExists(atPath: imageURL.path) {
                try fileManager.removeItem(at: imageURL)
            }
            
            // Move temp file to original location
            try fileManager.moveItem(at: tempURL, to: imageURL)
        } catch {
            throw NSError(
                domain: "ExifMetadataService",
                code: -7,
                userInfo: [NSLocalizedDescriptionKey: "Could not replace original file: \(error.localizedDescription)"]
            )
        }
    }
    
    /// Parse GPS coordinate string like "38deg 34' 50\" N" to decimal degrees
    private func parseGPSString(_ gpsString: String) -> Double? {
        // Parse format: "38deg 34' 50\" N" to 38.6138889
        let cleaned = gpsString.trimmingCharacters(in: .whitespaces)
        let parts = cleaned.components(separatedBy: CharacterSet(charactersIn: "deg'\""))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard parts.count >= 3 else { return nil }
        
        guard let degrees = Double(parts[0]),
              let minutes = Double(parts[1]),
              let seconds = Double(parts[2]) else {
            return nil
        }
        
        var decimal = degrees + minutes / 60.0 + seconds / 3600.0
        
        // Check for direction indicator (last part or in string)
        if cleaned.contains("S") || cleaned.contains("W") {
            decimal = -decimal
        }
        
        return decimal
    }
    
    /// Updates metadata for RAW files using ExifTool (fallback for RAW-only)
    /// Since ImageIO cannot write to RAW files, we need ExifTool for RAW formats
    private func updateRAWMetadata(imageURL: URL, metadata: ImageMetadata) async throws {
        // ImageIO cannot write to RAW formats, so we need ExifTool as fallback
        // This is the only case where we need external tool
        let exifToolService = ExifToolMetadataService()
        return try await exifToolService.updateMetadata(imageURL: imageURL, metadata: metadata)
    }
}


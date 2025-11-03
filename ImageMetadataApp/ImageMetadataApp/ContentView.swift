//
//  ContentView.swift
//  Image Metadata App
//
//  Main view for the image metadata updater
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MetadataUpdateViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Image Metadata Updater")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Update EXIF metadata for scanned film images")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Folder selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Images Folder")
                    .font(.headline)
                
                HStack {
                    TextField("No folder selected", text: .constant(viewModel.selectedFolderPath))
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    
                    Button("Select Folder") {
                        viewModel.selectFolder()
                    }
                }
            }
            
            // JSON file selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Metadata JSON File")
                    .font(.headline)
                
                HStack {
                    TextField("No JSON file selected", text: .constant(viewModel.selectedJSONPath))
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    
                    Button("Select JSON") {
                        viewModel.selectJSONFile()
                    }
                }
            }
            
            Divider()
            
            // Status and progress
            if viewModel.isProcessing {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if viewModel.hasError {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            } else if viewModel.isComplete {
                Text(viewModel.statusMessage)
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Action button
            Button(action: {
                viewModel.startProcessing()
            }) {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.7)
                    }
                    Text(viewModel.isProcessing ? "Processing..." : "Update Metadata")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.selectedFolderPath.isEmpty || 
                     viewModel.selectedJSONPath.isEmpty || 
                     viewModel.isProcessing)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("ExifTool Not Found", isPresented: $viewModel.showExifToolAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.exifToolErrorMessage)
        }
        .alert("Failed Files", isPresented: $viewModel.showFailedFilesAlert) {
            Button("OK", role: .cancel) { }
            Button("Show Details") {
                // Open console or show in a better way - for now just console
                for failedFile in viewModel.failedFilesDetails {
                    print("Failed: \(failedFile.fileName) - \(failedFile.errorMessage)")
                }
            }
        } message: {
            let preview = viewModel.failedFilesDetails.prefix(5).map { 
                "\($0.fileName): \($0.errorMessage.prefix(50))..."
            }.joined(separator: "\n\n")
            
            let message = viewModel.failedFilesDetails.count > 5 
                ? preview + "\n\n... and \(viewModel.failedFilesDetails.count - 5) more files (see console)"
                : viewModel.failedFilesDetails.map { 
                    "\($0.fileName): \($0.errorMessage)" 
                }.joined(separator: "\n\n")
            
            Text(message)
        }
    }
}

#Preview {
    ContentView()
}


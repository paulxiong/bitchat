import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct PhotoTransferView: View {
    @StateObject private var photoTransferService = PhotoTransferService.shared
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                photoSelectionSection
                Divider()
                transferStatusSection
                Spacer()
            }
            .navigationTitle("Photo Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var photoSelectionSection: some View {
        VStack(spacing: 15) {
            Text("Send Photo")
                .font(.title2)
                .fontWeight(.bold)
            
            if let selectedImage = selectedImage {
                photoPreviewView(selectedImage)
            } else {
                photoSelectionButton
            }
            
            if selectedImage != nil {
                sendPhotoButton
            }
        }
        .padding()
    }
    
    private func photoPreviewView(_ image: UIImage) -> some View {
        VStack(spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .cornerRadius(10)
            
            Text("Selected Photo")
                .font(.headline)
            
            let originalSize = image.jpegData(compressionQuality: 1.0)?.count ?? 0
            let compressedSize = image.jpegData(compressionQuality: 0.7)?.count ?? 0
            let compressionRatio = Double(compressedSize) / Double(originalSize)
            
            Text("Original: \(formatFileSize(UInt64(originalSize)))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Compressed: \(formatFileSize(UInt64(compressedSize)))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Compression: \(Int((1 - compressionRatio) * 100))% smaller")
                .font(.caption)
                .foregroundColor(.green)
        }
    }
    
    private var photoSelectionButton: some View {
        Button(action: {
            showingImagePicker = true
        }) {
            VStack(spacing: 10) {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Select Photo")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("Tap to choose a photo to send")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private var sendPhotoButton: some View {
        Button(action: sendPhoto) {
            HStack {
                Image(systemName: "paperplane.fill")
                Text("Send Photo")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .disabled(photoTransferService.activeTransfers.count > 0)
    }
    
    private var transferStatusSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Transfer Status")
                .font(.headline)
            
            if !photoTransferService.activeTransfers.isEmpty {
                activeTransfersView
            }
            
            if !photoTransferService.completedTransfers.isEmpty {
                completedTransfersView
            }
            
            if !photoTransferService.failedTransfers.isEmpty {
                failedTransfersView
            }
            
            if photoTransferService.activeTransfers.isEmpty && 
               photoTransferService.completedTransfers.isEmpty && 
               photoTransferService.failedTransfers.isEmpty {
                Text("No photo transfers yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
    }
    
    private var activeTransfersView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Active Transfers")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(Array(photoTransferService.activeTransfers.keys), id: \.self) { fileID in
                if let session = photoTransferService.activeTransfers[fileID] {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(session.metadata.fileName)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        ProgressView(value: session.progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("\(Int(session.progressPercentage * 100))% - \(session.receivedChunks.count)/\(session.metadata.totalChunks) chunks")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    private var completedTransfersView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Completed Transfers")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            
            ForEach(Array(photoTransferService.completedTransfers.keys), id: \.self) { fileID in
                if let session = photoTransferService.completedTransfers[fileID] {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(session.metadata.fileName)
                            .font(.caption)
                        Spacer()
                        Text("\(formatFileSize(session.metadata.compressedSize))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var failedTransfersView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Failed Transfers")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            ForEach(Array(photoTransferService.failedTransfers.keys), id: \.self) { fileID in
                if let session = photoTransferService.failedTransfers[fileID] {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(session.metadata.fileName)
                            .font(.caption)
                        Spacer()
                        if let error = session.errorMessage {
                            Text(error)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private func sendPhoto() {
        guard let image = selectedImage else { return }
        
        photoTransferService.sendPhoto(image, fileName: "photo_\(Date().timeIntervalSince1970).jpg")
        
        alertTitle = "Success"
        alertMessage = "Photo transfer started!"
        showingAlert = true
    }
    
    private func formatFileSize(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoTransferView()
}

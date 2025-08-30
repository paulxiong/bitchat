import SwiftUI

struct PhotoMessageView: View {
    let photoURL: String
    let colorScheme: ColorScheme
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading photo...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
            } else if loadError {
                HStack {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundColor(.red)
                    Text("Failed to load photo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 60)
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(8)
                    .onTapGesture {
                        // TODO: Add full-screen photo viewer
                        print("Photo tapped: \(photoURL)")
                    }
            }
        }
        .onAppear {
            loadPhoto()
        }
    }
    
    private func loadPhoto() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            loadError = true
            isLoading = false
            return
        }
        
        let photosDirectory = documentsPath.appendingPathComponent("Photos", isDirectory: true)
        let fullPhotoURL = photosDirectory.appendingPathComponent(photoURL)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData = try? Data(contentsOf: fullPhotoURL),
               let loadedImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.loadError = true
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    PhotoMessageView(photoURL: "test_photo.jpg", colorScheme: .light)
}

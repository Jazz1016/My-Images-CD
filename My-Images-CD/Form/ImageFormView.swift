//
//  ImageFormView.swift
//  My-Images-CD
//
//  Created by James Lea on 6/2/23.
//

import SwiftUI
import PhotosUI

struct ImageFormView: View {
    @FetchRequest(sortDescriptors: [])
    private var myImages: FetchedResults<MyImage>
    @ObservedObject var viewModel: FormViewModel
//    @StateObject var imagePicker = ImagePicker()
    
    @Environment(\.managedObjectContext) var mock
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(uiImage: viewModel.uiImage)
                    .resizable()
                    .scaledToFit()
                TextField("Image Name", text: $viewModel.name)
                HStack {
                    if viewModel.updating {
                        PhotosPicker("Change Image",
                                     selection: $imagePicker.imageSelection,
                                     matching: .images,
                                     photoLibrary: .shared())
                        .buttonStyle(.bordered)
                    }
                    
                    Button {
                        if viewModel.updating {
                            if let id = viewModel.id,
                               let selectedImage = myImages.first(where: {$0.id == id}) {
                                selectedImage.name = viewModel.name
                                FileManager().saveImage(with: id, image: viewModel.uiImage)
                                if mock.hasChanges {
                                    try? mock.save()
                                }
                            }
                        } else {
                            let newImage = MyImage(context: mock)
                            newImage.name = viewModel.name
                            newImage.id = UUID().uuidString
                            try? mock.save()
                            FileManager().saveImage(with: newImage.imageID, image: viewModel.uiImage)
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .disabled(viewModel.incomplete)
                }
                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.updating ? "Update Image" : "New Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if viewModel.updating {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if let selectedImage = myImages.first(where: {$0.id == viewModel.id}) {
                                FileManager().deleteImage(with: selectedImage.imageID)
                                mock.delete(selectedImage)
                                try? mock.save()
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
            .onChange(of: imagePicker.uiImage) { newImage in
                if let newImage {
                    viewModel.uiImage = newImage
                }
            }
        }
    }
}

struct ImageFormView_Previews: PreviewProvider {
    static var previews: some View {
        ImageFormView(viewModel: FormViewModel(UIImage(systemName: "photo")!))
    }
}

//
//  FormViewModel.swift
//  My-Images-CD
//
//  Created by James Lea on 6/2/23.
//

import UIKit

class FormViewModel: ObservableObject {
    @Published var name = ""
    @Published var uiImage: UIImage
    
    var id: String?
    
    var updating: Bool { id != nil }
    
    init(_ uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    init(_ myImage: MyImage) {
        self.name = myImage.nameView
        self.id = myImage.imageID
        self.uiImage = myImage.uiImage
    }
    
    var incomplete: Bool {
        name.isEmpty || uiImage == UIImage(systemName: "photo")
    }
}

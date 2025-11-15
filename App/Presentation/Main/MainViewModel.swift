//
//  MainViewModel.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import Combine
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    // Product state
    @Published var productImage: UIImage?
    @Published var productName: String = "Long Sleeve T-Shirt"
    @Published var selectedProductColor: ProductColor = .white
    @Published var selectedSize: ProductSize = .medium
    
    // Design elements
    @Published var designImage: UIImage?
    @Published var designPosition: CGPoint = .zero
    @Published var designScale: CGFloat = 1.0
    @Published var designRotation: Double = 0.0
    
    // Text elements
    @Published var textElements: [TextElement] = []
    @Published var selectedTextElement: TextElement?
    @Published var isEditingText: Bool = false
    
    // UI state
    @Published var selectedTool: EditorTool = .design
    @Published var showColorPicker: Bool = false
    @Published var showSizePicker: Bool = false
    @Published var showImagePicker: Bool = false
    
    // Actions
    func selectTool(_ tool: EditorTool) {
        selectedTool = tool
        if tool == .text {
            addTextElement()
        }
    }
    
    func addTextElement() {
        let newText = TextElement(
            id: UUID(),
            text: "Your Text",
            position: CGPoint(x: 0.5, y: 0.5),
            fontSize: 24,
            color: .black,
            fontName: "Helvetica"
        )
        textElements.append(newText)
        selectedTextElement = newText
        isEditingText = true
    }
    
    func updateSelectedText(_ text: String) {
        guard var element = selectedTextElement else { return }
        element.text = text
        if let index = textElements.firstIndex(where: { $0.id == element.id }) {
            textElements[index] = element
            selectedTextElement = element
        }
    }
    
    func deleteSelectedText() {
        guard let element = selectedTextElement,
              let index = textElements.firstIndex(where: { $0.id == element.id }) else { return }
        textElements.remove(at: index)
        selectedTextElement = nil
        isEditingText = false
    }
    
    func selectProductColor(_ color: ProductColor) {
        selectedProductColor = color
    }
    
    func selectSize(_ size: ProductSize) {
        selectedSize = size
    }
    
    func setDesignImage(_ image: UIImage?) {
        designImage = image
    }
    
    func saveDesign() {
        // TODO: Implement save functionality
        print("Saving design...")
    }
}

// MARK: - Models
enum EditorTool: String, CaseIterable {
    case design = "Design"
    case text = "Text"
    case colors = "Colors"
    case sizes = "Sizes"
}

struct TextElement: Identifiable, Equatable {
    let id: UUID
    var text: String
    var position: CGPoint
    var fontSize: CGFloat
    var color: Color
    var fontName: String
}

enum ProductColor: String, CaseIterable {
    case white = "White"
    case black = "Black"
    case navy = "Navy"
    case gray = "Gray"
    case red = "Red"
    case blue = "Blue"
    
    var color: Color {
        switch self {
        case .white: return .white
        case .black: return .black
        case .navy: return Color(red: 0.0, green: 0.0, blue: 0.5)
        case .gray: return .gray
        case .red: return .red
        case .blue: return .blue
        }
    }
}

enum ProductSize: String, CaseIterable {
    case small = "S"
    case medium = "M"
    case large = "L"
    case xlarge = "XL"
    case xxlarge = "XXL"
}

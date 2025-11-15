//
//  MainScreen.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import SwiftUI

struct MainScreen: ScreenView {
    private weak var viewContext: MainViewContext?

    @ObservedObject
    private var mainViewModel: MainViewModel

    init(viewContext: MainViewContext) {
        self.viewContext = viewContext
        self.mainViewModel = viewContext.getMainViewModel()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Product Preview Area
                productPreviewArea
                    .frame(height: geometry.size.height * 0.5)
                
                // Toolbar
                toolbarView
                
                // Tool Content Area
                toolContentView
                    .frame(maxHeight: geometry.size.height * 0.3)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $mainViewModel.showImagePicker) {
            ImagePicker(image: Binding(
                get: { mainViewModel.designImage },
                set: { mainViewModel.setDesignImage($0) }
            ))
        }
        .sheet(isPresented: $mainViewModel.isEditingText) {
            if let textElement = mainViewModel.selectedTextElement {
                TextEditorSheet(
                    textElement: textElement,
                    onSave: { text in
                        mainViewModel.updateSelectedText(text)
                        mainViewModel.isEditingText = false
                    },
                    onDelete: {
                        mainViewModel.deleteSelectedText()
                    }
                )
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text(mainViewModel.productName)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                mainViewModel.saveDesign()
            }) {
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Product Preview Area
    private var productPreviewArea: some View {
        ZStack {
            // Product base
            RoundedRectangle(cornerRadius: 12)
                .fill(mainViewModel.selectedProductColor.color)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            
            // Design Image
            if let designImage = mainViewModel.designImage {
                Image(uiImage: designImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .scaleEffect(mainViewModel.designScale)
                    .rotationEffect(.degrees(mainViewModel.designRotation))
                    .offset(
                        x: mainViewModel.designPosition.x,
                        y: mainViewModel.designPosition.y
                    )
            }
            
            // Text Elements
            ForEach(mainViewModel.textElements) { textElement in
                Text(textElement.text)
                    .font(.custom(textElement.fontName, size: textElement.fontSize))
                    .foregroundColor(textElement.color)
                    .padding(8)
                    .background(
                        mainViewModel.selectedTextElement?.id == textElement.id
                            ? Color.blue.opacity(0.2)
                            : Color.clear
                    )
                    .cornerRadius(4)
                    .offset(
                        x: (textElement.position.x - 0.5) * 200,
                        y: (textElement.position.y - 0.5) * 200
                    )
                    .onTapGesture {
                        mainViewModel.selectedTextElement = textElement
                        mainViewModel.isEditingText = true
                    }
            }
            
            // Upload Design Button (if no design)
            if mainViewModel.designImage == nil {
                Button(action: {
                    mainViewModel.showImagePicker = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                        Text("Upload Design")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(20)
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(12)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Toolbar View
    private var toolbarView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EditorTool.allCases, id: \.self) { tool in
                    ToolButton(
                        tool: tool,
                        isSelected: mainViewModel.selectedTool == tool,
                        action: {
                            mainViewModel.selectTool(tool)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Tool Content View
    @ViewBuilder
    private var toolContentView: some View {
        switch mainViewModel.selectedTool {
        case .design:
            designToolView
        case .text:
            textToolView
        case .colors:
            colorPickerView
        case .sizes:
            sizePickerView
        }
    }
    
    // MARK: - Design Tool View
    private var designToolView: some View {
        VStack(spacing: 16) {
            if mainViewModel.designImage != nil {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Design Controls")
                        .font(.headline)
                        .padding(.horizontal, 16)
                    
                    // Scale Control
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scale: \(Int(mainViewModel.designScale * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Slider(
                            value: $mainViewModel.designScale,
                            in: 0.5...2.0
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Rotation Control
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rotation: \(Int(mainViewModel.designRotation))°")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Slider(
                            value: $mainViewModel.designRotation,
                            in: -180...180
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Replace Design Button
                    Button(action: {
                        mainViewModel.showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text("Replace Design")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Upload your design")
                        .font(.headline)
                    
                    Text("Add an image to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        mainViewModel.showImagePicker = true
                    }) {
                        Text("Choose Image")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Text Tool View
    private var textToolView: some View {
        VStack(spacing: 16) {
            Text("Text Elements")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            if mainViewModel.textElements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text("No text elements")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tap the + button to add text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(mainViewModel.textElements) { element in
                            TextElementRow(
                                element: element,
                                isSelected: mainViewModel.selectedTextElement?.id == element.id,
                                onTap: {
                                    mainViewModel.selectedTextElement = element
                                    mainViewModel.isEditingText = true
                                },
                                onDelete: {
                                    if mainViewModel.selectedTextElement?.id == element.id {
                                        mainViewModel.deleteSelectedText()
                                    } else {
                                        if let index = mainViewModel.textElements.firstIndex(where: { $0.id == element.id }) {
                                            mainViewModel.textElements.remove(at: index)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            Button(action: {
                mainViewModel.addTextElement()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Text")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Color Picker View
    private var colorPickerView: some View {
        VStack(spacing: 16) {
            Text("Product Color")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ProductColor.allCases, id: \.self) { color in
                        ColorOptionView(
                            productColor: color,
                            isSelected: mainViewModel.selectedProductColor == color,
                            onSelect: {
                                mainViewModel.selectProductColor(color)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Size Picker View
    private var sizePickerView: some View {
        VStack(spacing: 16) {
            Text("Product Size")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ProductSize.allCases, id: \.self) { size in
                        SizeOptionView(
                            size: size,
                            isSelected: mainViewModel.selectedSize == size,
                            onSelect: {
                                mainViewModel.selectSize(size)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - Supporting Views
struct ToolButton: View {
    let tool: EditorTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                Text(tool.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .blue : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
    }
    
    private var iconName: String {
        switch tool {
        case .design: return "photo"
        case .text: return "text.bubble"
        case .colors: return "paintpalette"
        case .sizes: return "square.grid.2x2"
        }
    }
}

struct TextElementRow: View {
    let element: TextElement
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(element.text)
                .font(.custom(element.fontName, size: min(element.fontSize, 16)))
                .foregroundColor(element.color)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(8)
        .onTapGesture(perform: onTap)
    }
}

struct ColorOptionView: View {
    let productColor: ProductColor
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Circle()
                    .fill(productColor.color)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )

                Text(productColor.rawValue)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }

    private var size: CGFloat {
        isSelected ? 46 : 50
    }
}

struct SizeOptionView: View {
    let size: ProductSize
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(size.rawValue)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 60, height: 60)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Text Editor Sheet
struct TextEditorSheet: View {
    let textElement: TextElement
    let onSave: (String) -> Void
    let onDelete: () -> Void
    
    @State private var text: String
    @Environment(\.presentationMode) var presentationMode
    
    init(textElement: TextElement, onSave: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.textElement = textElement
        self.onSave = onSave
        self.onDelete = onDelete
        _text = State(initialValue: textElement.text)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter text", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Delete") {
                        onDelete()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(text)
                        presentationMode.wrappedValue.dismiss()
                    }
                    // .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    MainScreen(viewContext: MainViewController())
}

import UIKit
import PhotosUI

class ImageItem {
    let imageView: UIImageView
    var currentRotation: CGFloat = 0
    var lastRotation: CGFloat = 0
    var currentScale: CGFloat = 1.0
    var lastScale: CGFloat = 1.0
    var lastPanLocation: CGPoint = .zero
    var lastSnappedAngle: CGFloat? = nil
    var lastSnappedX: Bool = false
    var lastSnappedY: Bool = false
    var isSelected: Bool = false {
        didSet {
            //updateSelectionIndicator()
        }
    }
    
    private let selectionBorder: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 3.0
        layer.cornerRadius = 4.0
        layer.isHidden = true
        return layer
    }()
    
    init(imageView: UIImageView) {
        self.imageView = imageView
        imageView.layer.addSublayer(selectionBorder)
    }
    
    private func updateSelectionIndicator() {
        selectionBorder.isHidden = !isSelected
        updateSelectionBorderFrame()
    }
    
    func updateSelectionBorderFrame() {
        if !selectionBorder.isHidden {
            // Update frame to match current bounds
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            selectionBorder.frame = imageView.bounds
            CATransaction.commit()
        }
    }
}

class DemoViewController: UIViewController {
    
    // Top bar container
    private let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Edit/Preview segmented control
    private lazy var editPreviewSegmentedControl: UISegmentedControl = {
        // Create with empty strings, we'll use images only
        let control = UISegmentedControl(items: ["", ""])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        
        // Set custom images for segments
        let editImage = UIImage(systemName: "pencil")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        let previewImage = UIImage(systemName: "eye")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        
        // Customize appearance
        control.selectedSegmentTintColor = .blue
        control.backgroundColor = .white
        
        // Set image tint colors - Edit selected (light beige), Preview unselected (dark brown)
        control.setImage(editImage?.withTintColor(UIColor(red: 0.96, green: 0.95, blue: 0.93, alpha: 1.0), renderingMode: .alwaysOriginal), forSegmentAt: 0)
        control.setImage(previewImage?.withTintColor(UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0), renderingMode: .alwaysOriginal), forSegmentAt: 1)
        
        // Remove divider
        control.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        return control
    }()
    
    // Save button
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.93, alpha: 1.0) // Light beige
        button.setTitleColor(UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Divider between top bar and body
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Front/Back segmented control (only visible in Edit mode)
    private let frontBackSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Front side", "Back side"])
        control.selectedSegmentIndex = 0 // Default to Front side
        control.translatesAutoresizingMaskIntoConstraints = false
        
        // Customize appearance
        control.selectedSegmentTintColor = .blue
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0), // Dark brown
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        control.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.93, alpha: 1.0) // Light beige
        
        return control
    }()
    
    // Background image view for canvas (shirt outline)
    private let canvasBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Canvas container view (positioned inside the design area of the shirt)
    private let canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Button to select images from gallery
    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Images from Gallery", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Array to hold all image items
    private var imageItems: [ImageItem] = []
    private var selectedImageItem: ImageItem?
    
    // Current mode: Edit or Preview
    private var isEditMode: Bool = true
    
    // Current side: Front or Back
    private var isFrontSide: Bool = true
    
    // Selected product color
    private var selectedProductColor: ProductColor = .white
    
    // Store original background images
    private var originalFrontImage: UIImage?
    private var originalBackImage: UIImage?
    
    // Color picker title label
    private let colorPickerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Product Color"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Color picker scroll view
    private let colorPickerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // Color picker stack view
    private let colorPickerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Haptic feedback generator
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()
        hapticGenerator.prepare()
        setupUI()
        updateModeAppearance()
        updateColorBlend()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        // Add top bar
        view.addSubview(topBarView)
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Add segmented control to top bar
        topBarView.addSubview(editPreviewSegmentedControl)
        NSLayoutConstraint.activate([
            editPreviewSegmentedControl.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
            editPreviewSegmentedControl.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            editPreviewSegmentedControl.widthAnchor.constraint(equalToConstant: 120),
            editPreviewSegmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Add save button to top bar
        topBarView.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 70),
            saveButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // STEP 2: Add divider below top bar
        view.addSubview(dividerView)
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])

        // STEP 3: Add Front/Back segmented control below dividerView
        view.addSubview(frontBackSegmentedControl)
        NSLayoutConstraint.activate([
            frontBackSegmentedControl.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            frontBackSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frontBackSegmentedControl.widthAnchor.constraint(equalToConstant: 200),
            frontBackSegmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // STEP 4: Add color picker scroll view at the bottom
        view.addSubview(colorPickerScrollView)
        NSLayoutConstraint.activate([
            colorPickerScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            colorPickerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorPickerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorPickerScrollView.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        // Add color picker stack view to scroll view
        colorPickerScrollView.addSubview(colorPickerStackView)
        NSLayoutConstraint.activate([
            colorPickerStackView.topAnchor.constraint(equalTo: colorPickerScrollView.topAnchor),
            colorPickerStackView.leadingAnchor.constraint(equalTo: colorPickerScrollView.leadingAnchor, constant: 16),
            colorPickerStackView.trailingAnchor.constraint(equalTo: colorPickerScrollView.trailingAnchor, constant: -16),
            colorPickerStackView.bottomAnchor.constraint(equalTo: colorPickerScrollView.bottomAnchor),
            colorPickerStackView.heightAnchor.constraint(equalTo: colorPickerScrollView.heightAnchor),
        ])
        
        // Setup color options
        setupColorOptions()

        // STEP 5: Add color picker title label first (this establishes container top)
        view.addSubview(colorPickerTitleLabel)
        NSLayoutConstraint.activate([
            colorPickerTitleLabel.bottomAnchor.constraint(equalTo:  colorPickerScrollView.topAnchor, constant: -16),
            colorPickerTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            colorPickerTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            colorPickerTitleLabel.heightAnchor.constraint(equalToConstant: 22), // Fixed height based on font size
        ])
        
        // Add select image button (positioned within canvas area)
        view.addSubview(selectImageButton)
        NSLayoutConstraint.activate([
            selectImageButton.bottomAnchor.constraint(equalTo: colorPickerTitleLabel.topAnchor, constant: -16),
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectImageButton.widthAnchor.constraint(equalToConstant: 280),
            selectImageButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        // STEP 6: Add canvas background image view - fills space between frontBackSegmentedControl and colorPicker
        view.addSubview(canvasBackgroundImageView)
        NSLayoutConstraint.activate([
            canvasBackgroundImageView.topAnchor.constraint(equalTo: frontBackSegmentedControl.bottomAnchor, constant: 20),
            canvasBackgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasBackgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasBackgroundImageView.bottomAnchor.constraint(equalTo: selectImageButton.topAnchor, constant: -20),
        ])

        // Add canvas view directly to main view (not as subview of background image)
        // This ensures it can receive touches properly
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.centerXAnchor.constraint(equalTo: canvasBackgroundImageView.centerXAnchor),
            canvasView.centerYAnchor.constraint(equalTo: canvasBackgroundImageView.centerYAnchor, constant: -20), // Slightly above center to match design area
            canvasView.widthAnchor.constraint(equalToConstant: 200),
            canvasView.heightAnchor.constraint(equalToConstant: 200),
        ])

        // Add targets
        selectImageButton.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
        editPreviewSegmentedControl.addTarget(self, action: #selector(editPreviewChanged(_:)), for: .valueChanged)
        frontBackSegmentedControl.addTarget(self, action: #selector(frontBackChanged(_:)), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Set initial background image
        updateCanvasBackground()
        updateFrontBackVisibility()
    }
    
    private func setupGestures(for imageItem: ImageItem) {
        let imageView = imageItem.imageView
        
        // Remove existing gestures if any
        imageView.gestureRecognizers?.forEach { imageView.removeGestureRecognizer($0) }
        
        // Tap gesture to select image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGesture)
        
        // Pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        // Rotation gesture
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        imageView.addGestureRecognizer(rotationGesture)
        
        // Pinch gesture for zooming
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        // Long press to delete
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        imageView.addGestureRecognizer(longPressGesture)
        
        // Allow simultaneous gestures
        panGesture.delegate = self
        rotationGesture.delegate = self
        pinchGesture.delegate = self
    }
    
    @objc private func selectImageTapped() {
        if #available(iOS 14.0, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 0 // 0 means unlimited
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            // Fallback for iOS 13
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true)
        }
    }
    
    private func addImage(_ image: UIImage) {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        // Set initial size to fit within canvas while maintaining aspect ratio
        let canvasSize = canvasView.bounds.size
        let imageSize = image.size
        let scale = min(canvasSize.width / imageSize.width, canvasSize.height / imageSize.height) * 0.8
        let scaledSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        
        imageView.bounds = CGRect(origin: .zero, size: scaledSize)
        
        // Position with slight offset for multiple images
        let offset = CGFloat(imageItems.count) * 20.0
        imageView.center = CGPoint(
            x: canvasView.bounds.midX + offset,
            y: canvasView.bounds.midY + offset
        )
        
        canvasView.addSubview(imageView)
        
        let imageItem = ImageItem(imageView: imageView)
        imageItem.lastPanLocation = imageView.center
        imageItems.append(imageItem)
        
        setupGestures(for: imageItem)
        selectImageItem(imageItem)
    }
    
    private func selectImageItem(_ item: ImageItem) {
        // Deselect all
        imageItems.forEach { $0.isSelected = false }
        
        // Select the new one
        item.isSelected = true
        selectedImageItem = item
        
        // Bring to front
        canvasView.bringSubviewToFront(item.imageView)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? UIImageView,
              let imageItem = imageItems.first(where: { $0.imageView == view }) else { return }
        selectImageItem(imageItem)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let view = gesture.view as? UIImageView,
              let imageItem = imageItems.first(where: { $0.imageView == view }),
              let index = imageItems.firstIndex(where: { $0.imageView == view }) else { return }
        
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            imageItem.imageView.removeFromSuperview()
            self?.imageItems.remove(at: index)
            if self?.selectedImageItem === imageItem {
                self?.selectedImageItem = self?.imageItems.last
                self?.selectedImageItem?.isSelected = true
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view as? UIImageView,
              let imageItem = imageItems.first(where: { $0.imageView == view }) else { return }
        
        // Select this image if not already selected
        if selectedImageItem !== imageItem {
            selectImageItem(imageItem)
        }
        
        let translation = gesture.translation(in: canvasView)
        
        switch gesture.state {
        case .began:
            imageItem.lastPanLocation = view.center
            
        case .changed:
            // Allow free movement - image can exceed container bounds
            // Only the visible portion inside the container will be displayed
            var newCenter = CGPoint(
                x: imageItem.lastPanLocation.x + translation.x,
                y: imageItem.lastPanLocation.y + translation.y
            )
            newCenter = snapPosition(newCenter, imageItem: imageItem)
            view.center = newCenter
            
        case .ended, .cancelled:
            var finalCenter = view.center
            finalCenter = snapPosition(finalCenter, imageItem: imageItem)
            view.center = finalCenter
            imageItem.lastPanLocation = finalCenter
            imageItem.updateSelectionBorderFrame()
            
        default:
            break
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view as? UIImageView,
              let imageItem = imageItems.first(where: { $0.imageView == view }) else { return }
        
        // Select this image if not already selected
        if selectedImageItem !== imageItem {
            selectImageItem(imageItem)
        }
        
        switch gesture.state {
        case .began:
            imageItem.lastRotation = imageItem.currentRotation
            
        case .changed:
            var newRotation = imageItem.lastRotation + gesture.rotation
            newRotation = snapRotation(newRotation, imageItem: imageItem)
            imageItem.currentRotation = newRotation
            applyTransform(to: imageItem)
            
        case .ended, .cancelled:
            var finalRotation = imageItem.currentRotation
            finalRotation = snapRotation(finalRotation, imageItem: imageItem)
            imageItem.currentRotation = finalRotation
            imageItem.lastRotation = finalRotation
            applyTransform(to: imageItem)
            imageItem.updateSelectionBorderFrame()
            
        default:
            break
        }
    }
    
    private func snapPosition(_ position: CGPoint, imageItem: ImageItem) -> CGPoint {
        let snapThreshold: CGFloat = 5.0 // pixels
        let centerX = canvasView.bounds.midX
        let centerY = canvasView.bounds.midY
        var snappedX = position.x
        var snappedY = position.y
        var shouldHaptic = false
        
        // Snap to center X
        if abs(position.x - centerX) < snapThreshold {
            snappedX = centerX
            if !imageItem.lastSnappedX {
                shouldHaptic = true
                imageItem.lastSnappedX = true
            }
        } else {
            imageItem.lastSnappedX = false
        }
        
        // Snap to center Y
        if abs(position.y - centerY) < snapThreshold {
            snappedY = centerY
            if !imageItem.lastSnappedY {
                shouldHaptic = true
                imageItem.lastSnappedY = true
            }
        } else {
            imageItem.lastSnappedY = false
        }
        
        if shouldHaptic {
            hapticGenerator.impactOccurred()
        }
        
        return CGPoint(x: snappedX, y: snappedY)
    }
    
    private func snapRotation(_ rotation: CGFloat, imageItem: ImageItem) -> CGFloat {
        let snapThreshold: CGFloat = 0.05 // ~2.9 degrees
        let snapAngles: [CGFloat] = [0, .pi/2, .pi, 3 * .pi/2] // 0°, 90°, 180°, 270°
        
        // Normalize rotation to 0-2π range
        var normalizedRotation = rotation.truncatingRemainder(dividingBy: 2 * .pi)
        if normalizedRotation < 0 {
            normalizedRotation += 2 * .pi
        }
        
        // Check each snap angle
        for snapAngle in snapAngles {
            let diff = abs(normalizedRotation - snapAngle)
            let minDiff = min(diff, 2 * .pi - diff)
            
            if minDiff < snapThreshold {
                // Only trigger haptic if we're snapping to a new angle
                if imageItem.lastSnappedAngle != snapAngle {
                    hapticGenerator.impactOccurred()
                    imageItem.lastSnappedAngle = snapAngle
                }
                return snapAngle
            }
        }
        
        // Reset snap tracking if we're not near any snap angle
        imageItem.lastSnappedAngle = nil
        return normalizedRotation
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view as? UIImageView,
              let imageItem = imageItems.first(where: { $0.imageView == view }) else { return }
        
        // Select this image if not already selected
        if selectedImageItem !== imageItem {
            selectImageItem(imageItem)
        }
        
        switch gesture.state {
        case .began:
            imageItem.lastScale = imageItem.currentScale
            
        case .changed:
            // Apply scale with minimum and maximum limits
            let newScale = imageItem.lastScale * gesture.scale
            imageItem.currentScale = max(0.5, min(5.0, newScale)) // Limit zoom between 0.5x and 5x
            applyTransform(to: imageItem)
            
        case .ended, .cancelled:
            imageItem.lastScale = imageItem.currentScale
            imageItem.updateSelectionBorderFrame()
            
        default:
            break
        }
    }
    
    private func applyTransform(to imageItem: ImageItem) {
        let view = imageItem.imageView
        // Combine scale and rotation transforms
        let scaleTransform = CGAffineTransform(scaleX: imageItem.currentScale, y: imageItem.currentScale)
        let rotationTransform = CGAffineTransform(rotationAngle: imageItem.currentRotation)
        view.transform = scaleTransform.concatenating(rotationTransform)
        imageItem.updateSelectionBorderFrame()
    }
    
    @objc private func editPreviewChanged(_ sender: UISegmentedControl) {
        isEditMode = sender.selectedSegmentIndex == 0
        updateModeAppearance()
        updateFrontBackVisibility()
    }
    
    @objc private func frontBackChanged(_ sender: UISegmentedControl) {
        isFrontSide = sender.selectedSegmentIndex == 0
        updateCanvasBackground()
    }
    
    private func updateModeAppearance() {
        // Update segmented control appearance based on selection
        let editImage = UIImage(systemName: "pencil")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        let previewImage = UIImage(systemName: "eye")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        
        let lightBeige = UIColor(red: 0.96, green: 0.95, blue: 0.93, alpha: 1.0)
        let darkBrown = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        
        if isEditMode {
            // Edit mode selected - Edit icon light beige, Preview icon dark brown
            editPreviewSegmentedControl.setImage(editImage?.withTintColor(lightBeige, renderingMode: .alwaysOriginal), forSegmentAt: 0)
            editPreviewSegmentedControl.setImage(previewImage?.withTintColor(darkBrown, renderingMode: .alwaysOriginal), forSegmentAt: 1)
        } else {
            // Preview mode selected - Edit icon dark brown, Preview icon light beige
            editPreviewSegmentedControl.setImage(editImage?.withTintColor(darkBrown, renderingMode: .alwaysOriginal), forSegmentAt: 0)
            editPreviewSegmentedControl.setImage(previewImage?.withTintColor(lightBeige, renderingMode: .alwaysOriginal), forSegmentAt: 1)
        }
    }
    
    private func updateFrontBackVisibility() {
        // Show Front/Back segmented control only in Edit mode
        frontBackSegmentedControl.isHidden = !isEditMode
    }
    
    private func updateCanvasBackground() {
        // Update canvas background image based on selected side
        let imageName = isFrontSide ? "front_outline" : "back_outline"
        guard let image = UIImage(named: imageName) else { return }
        
        // Store original images
        if isFrontSide {
            originalFrontImage = image
        } else {
            originalBackImage = image
        }
        
        // Apply color blend to the image
        updateColorBlend()
    }
    
    @objc private func saveButtonTapped() {
        // Handle save action
        print("Save button tapped")
        // Add your save logic here
    }
    
    // MARK: - Color Picker Setup
    private func setupColorOptions() {
        // Clear existing color options
        colorPickerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create color option views
        for color in ProductColor.allCases {
            let colorOptionView = createColorOptionView(for: color)
            colorPickerStackView.addArrangedSubview(colorOptionView)
        }
        
        // Update initial selection
        updateColorSelection()
    }
    
    private func createColorOptionView(for productColor: ProductColor) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create circular color view
        let colorCircle = UIView()
        colorCircle.backgroundColor = productColor.uiColor
        colorCircle.layer.cornerRadius = 25 // Will be set to 50/2
        colorCircle.layer.borderWidth = 1
        colorCircle.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        colorCircle.translatesAutoresizingMaskIntoConstraints = false
        colorCircle.tag = 100 // Tag to identify color circle
        
        // Color circle button (overlay for tap)
        let colorButton = UIButton(type: .custom)
        colorButton.translatesAutoresizingMaskIntoConstraints = false
        colorButton.tag = ProductColor.allCases.firstIndex(of: productColor) ?? 0
        colorButton.addTarget(self, action: #selector(colorOptionTapped(_:)), for: .touchUpInside)
        colorButton.backgroundColor = .clear
        
        // Label
        let label = UILabel()
        label.text = productColor.rawValue
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(colorCircle)
        containerView.addSubview(colorButton)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            // Container fills available height from stack view
            containerView.widthAnchor.constraint(equalToConstant: 50),
            
            // Color circle fixed size at top
            colorCircle.topAnchor.constraint(equalTo: containerView.topAnchor),
            colorCircle.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            colorCircle.widthAnchor.constraint(equalToConstant: 50),
            colorCircle.heightAnchor.constraint(equalToConstant: 50),
            
            // Color button matches circle for tap area
            colorButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            colorButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            colorButton.widthAnchor.constraint(equalToConstant: 50),
            colorButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Label fixed below circle, container expands to fill remaining space
            label.topAnchor.constraint(equalTo: colorCircle.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
        ])
        
        return containerView
    }
    
    @objc private func colorOptionTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < ProductColor.allCases.count else { return }
        
        let selectedColor = ProductColor.allCases[index]
        selectedProductColor = selectedColor
        updateColorSelection()
        updateColorBlend()
    }
    
    private func updateColorSelection() {
        let stackViewSubviews = colorPickerStackView.arrangedSubviews
        
        for (index, containerView) in stackViewSubviews.enumerated() {
            guard index < ProductColor.allCases.count else { continue }
            
            let productColor = ProductColor.allCases[index]
            let isSelected = productColor == selectedProductColor
            
            // Find the color circle view by tag
            if let colorCircle = containerView.viewWithTag(100) {
                colorCircle.layer.borderWidth = isSelected ? 3 : 1
                colorCircle.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.gray.withAlphaComponent(0.3).cgColor
                
                // Adjust size for selected state
                UIView.animate(withDuration: 0.2) {
                    if isSelected {
                        colorCircle.transform = CGAffineTransform(scaleX: 0.92, y: 0.92) // 46/50 = 0.92
                    } else {
                        colorCircle.transform = .identity
                    }
                }
            }
        }
    }
    
    private func updateColorBlend() {
        // Get the original image for the current side
        guard let originalImage = isFrontSide ? originalFrontImage : originalBackImage else {
            // If original not stored yet, get it from the image view
            let imageName = isFrontSide ? "front_outline" : "back_outline"
            guard let image = UIImage(named: imageName) else { return }
            if isFrontSide {
                originalFrontImage = image
            } else {
                originalBackImage = image
            }
            return updateColorBlend() // Retry after storing
        }
        
        // Add background color layer behind the image content
        canvasBackgroundImageView.image = originalImage.withBackground(color: selectedProductColor.uiColor)
    }
}

extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let context = UIGraphicsGetCurrentContext(),
              let image = cgImage else { return self }
        
        let rect = CGRect(origin: .zero, size: size)
        context.setFillColor(color.cgColor)
        context.fill(rect)
        context.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        context.draw(image, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

// MARK: - ProductColor UIColor Extension
extension ProductColor {
    var uiColor: UIColor {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        case .navy:
            return UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        case .red:
            return .red
        case .blue:
            return .blue
        case .gray:
            return .gray
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14.0, *)
extension DemoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.addImage(image)
                    }
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate (Fallback for iOS 13)
extension DemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            addImage(image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DemoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


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
        layer.borderColor = UIColor.systemBlue.cgColor
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
    
    // Canvas container view
    private let canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Button to select images from gallery
    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Images from Gallery", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Array to hold all image items
    private var imageItems: [ImageItem] = []
    private var selectedImageItem: ImageItem?
    
    // Haptic feedback generator
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()
        hapticGenerator.prepare()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add canvas view
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            canvasView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            canvasView.widthAnchor.constraint(equalToConstant: 300),
            canvasView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Add select image button
        view.addSubview(selectImageButton)
        NSLayoutConstraint.activate([
            selectImageButton.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 30),
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectImageButton.widthAnchor.constraint(equalToConstant: 280),
            selectImageButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        selectImageButton.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
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


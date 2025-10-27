//
//  UploadImageViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit
import AVFoundation
import Photos

/// View controller responsible for uploading or capturing a profile image.
/// Handles image selection from camera or photo library and passes the image along with the user object.
class UploadImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    // User object passed from previous screen
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Profile Set-Up"
        navigationItem.backButtonTitle = ""
        
        // Set image view appearance
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        loadExistingImageIfAny()
    }

    /// Loads existing profile image if it has been selected before (if user has pressed the back button from the next screen)
    private func loadExistingImageIfAny() {
        if let data = user.profileImageData,
           let img = UIImage(data: data) {
            imageView.image = img
        } else {
            imageView.image = UIImage(systemName: "person.crop.square")
        }
    }
    
    /// Triggered when the "Take Picture" button is tapped
    @IBAction func takePictureTapped(_ sender: Any) {
        checkCameraPermission { granted in
            if granted {
                self.openImagePicker(sourceType: .camera)
            } else {
                self.showPermissionAlert(for: "camera")
            }
        }
    }
    
    /// Triggered when the "Choose From Gallery" button is tapped
    @IBAction func chooseFromGallery(_ sender: Any) {
        checkPhotoLibraryPermission { granted in
            if granted {
                self.openImagePicker(sourceType: .photoLibrary)
            } else {
                self.showPermissionAlert(for: "photo library")
            }
        }
    }
    
    /// Permissions check for if app has permission to access camera. Requests access if not yet authorized.
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    /// Permissions check for if app has permission to access photo library. Requests access if not yet authorized.
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    /// If, upon being prompted to grant access, the user denies it, show permissions alert.
    private func showPermissionAlert(for resource: String) {
        let alert = UIAlertController(
            title: "Permission Denied",
            message: "Please allow access to your \(resource) in Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }
    
    /// Triggered when the "Next" button is tapped
    /// Saves the user with updated image and proceeds to sports selection
    @IBAction func nextTapped(_ sender: Any) {
        UserManager.shared.save(user)
        performSegue(withIdentifier: "selectSportsSegue", sender: user)
    }
    
    /// Prepares data before navigating to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectSportsSegue",
           let destinationVC = segue.destination as? SportsSelectionViewController,
           let user = sender as? User {
            destinationVC.user = user
        }
    }

    /// Presents the image picker with specified source type (camera or photo library)
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
            showAlert(title: "Camera Unavailable", message: "Camera is not available on this device.")
            return
        }
        if sourceType == .photoLibrary && !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            showAlert(title: "Photo Library Unavailable", message: "Photo library is not available.")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    /// Called when the user selects an image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true) }

        let key: UIImagePickerController.InfoKey = picker.allowsEditing ? .editedImage : .originalImage

        guard let selectedImage = info[key] as? UIImage else {
            showAlert(title: "Selection Error", message: "Could not get the selected image.")
            return
        }

        imageView.image = selectedImage

        // Update the user object
        user.profileImageData = selectedImage.jpegData(compressionQuality: 0.8)
    }

    /// Called when the user cancels image selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    /// Displays an alert with a title and message
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

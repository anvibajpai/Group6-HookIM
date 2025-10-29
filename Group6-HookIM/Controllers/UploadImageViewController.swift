//
//  UploadImageViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit
import AVFoundation
import Photos
//import FirebaseStorage

/// View controller responsible for uploading or capturing a profile image.
/// Handles image selection from camera or photo library and passes the image along with the user object.
class UploadImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Profile Set-Up"
        navigationItem.backButtonTitle = ""
        
        // Set image view appearance
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.crop.square") // default
    }
    
    /// Get the UID from partial user data saved during Create Account
    private var uid: String? {
        UserDefaults.standard.dictionary(forKey: "partialUserData")?["uid"] as? String
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
    
    /// Triggered when the "Next" button is tapped
    /// Saves the user with updated image and proceeds to sports selection
    @IBAction func nextTapped(_ sender: Any) {
        performSegue(withIdentifier: "selectSportsSegue", sender: nil)
    }
    
    /// Prepares data before navigating to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectSportsSegue",
           let destinationVC = segue.destination as? SportsSelectionViewController {
            //do nothing
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

        // Update the image to firebase
        uploadProfileImage(selectedImage)
    }

    /// Called when the user cancels image selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    /// Helper to upload image to firebase storage.
    private func uploadProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let uid = uid else { return }

//        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
//        storageRef.putData(imageData, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Upload failed: \(error.localizedDescription)")
//                return
//            }
//            storageRef.downloadURL { url, error in
//                if let url = url {
//                    var data = UserDefaults.standard.dictionary(forKey: "partialUserData") ?? [:]
//                    data["profileImageURL"] = url.absoluteString
//                    UserDefaults.standard.set(data, forKey: "partialUserData")
//                    print("Image uploaded and URL saved locally.")
//                }
//            }
//        }
        
        var data = UserDefaults.standard.dictionary(forKey: "partialUserData") ?? [:]
        data["profileImageURL"] = "default_profile_image"
        UserDefaults.standard.set(data, forKey: "partialUserData")
        print("will upload image later")
    }
    
    // MARK: - Permissions + Alerts
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
    
    /// Displays an alert with a title and message
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

}

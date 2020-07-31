//
//  CardImagePicker.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
//import TOCropViewController

protocol CardImagePickerDelegate: class {
    func cardImagePicker(_ imagePicker: CardImagePicker, didSelect image: UIImage)
    func cardImagePickerDidCancel(_ imagePicker: CardImagePicker)
}

final class CardImagePicker: NSObject, UINavigationControllerDelegate {

    weak var delegate: CardImagePickerDelegate?

    let targetCardSide: CardSide

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?

    init(presentationController: UIViewController, targetCardSide: CardSide) {
        self.pickerController = UIImagePickerController()
        self.targetCardSide = targetCardSide

        super.init()

        self.presentationController = presentationController

        self.pickerController.delegate = self
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    func present() {
        let alertController = AppAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let action = self.action(for: .camera, title: NSLocalizedString("Take Photo", comment: "")) {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: NSLocalizedString("Select Photo", comment: "") ) {
            alertController.addAction(action)
        }
        alertController.addCancelAction()
        self.presentationController?.present(alertController, animated: true)
    }
}

// MARK: - CardSide

extension CardImagePicker {
    enum CardSide {
        case front, back
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CardImagePicker: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.delegate?.cardImagePickerDidCancel(self)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            self.delegate?.cardImagePickerDidCancel(self)
            return
        }

//        let cropViewController = TOCropViewController(image: image)
//        cropViewController.delegate = self
//        cropViewController.aspectRatioPickerButtonHidden = true
//        cropViewController.aspectRatioPreset = .preset16x9
//        cropViewController.resetButtonHidden = true
//        cropViewController.aspectRatioLockEnabled = true
//        picker.pushViewController(cropViewController, animated: true)
    }
}

// MARK: - TOCropViewControllerDelegate

//extension CardImagePicker: TOCropViewControllerDelegate {
//    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
//        self.pickerController.dismiss(animated: true, completion: nil)
//        self.delegate?.cardImagePicker(self, didSelect: image)
//    }
//}


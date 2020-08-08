//
//  EditCardImagesVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol EditCardImagesVCDelegate: class {
    func editCardImagesVC(_ viewController: EditCardImagesVC, didFinishWith frontImage: UIImage, and backImage: UIImage)
}

final class EditCardImagesVC: AppViewController<EditCardImagesView, EditCardImagesVM> {

    weak var delegate: EditCardImagesVCDelegate?

    private var imagePicker: CardImagePicker?

    private lazy var nextButton = UIBarButtonItem(title: viewModel.nextButtonTitle, style: .done, target: self, action: #selector(didTapNextButton))
    private lazy var cancelEditingButton = UIBarButtonItem(title: viewModel.cancelEditingButtonTitle, style: .plain, target: self, action: #selector(didTapCancelButton))

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        setupNavigationItem()
        setupContentView()
        viewModel.delegate = self
    }

    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.title
        navigationItem.leftBarButtonItem = cancelEditingButton
        navigationItem.rightBarButtonItem = nextButton
        nextButton.isEnabled = viewModel.nextButtonEnabled
    }

    private func setupContentView() {
        contentView.frontImageButton.addTarget(self, action: #selector(didTapFrontImageButton), for: .touchUpInside)
        contentView.backImageButton.addTarget(self, action: #selector(didTapBackImageButton), for: .touchUpInside)
        contentView.setFrontImage(viewModel.frontImage)
        contentView.setBackImage(viewModel.backImage)
    }
}

// MARK: - Actions

@objc
private extension EditCardImagesVC {

    func didTapFrontImageButton() {
        imagePicker = CardImagePicker(presentationController: self, targetCardSide: .front)
        imagePicker?.delegate = self
        imagePicker?.present()
    }

    func didTapBackImageButton() {
        imagePicker = CardImagePicker(presentationController: self, targetCardSide: .back)
        imagePicker?.delegate = self
        imagePicker?.present()
    }

    func didTapNextButton() {
        guard let frontImage = viewModel.frontImage, let backImage = viewModel.backImage else { return }
        delegate?.editCardImagesVC(self, didFinishWith: frontImage, and: backImage)
    }

    func didTapCancelButton() {
        dismiss(animated: true)
    }
}

// MARK: - EditCardVMDelegate

extension EditCardImagesVC: EditCardVMDelegate {
    func didUpdateNextButtonEnabled() {
        nextButton.isEnabled = viewModel.nextButtonEnabled
    }
}

// MARK: - CardImagePickerDelegate

extension EditCardImagesVC: CardImagePickerDelegate {
    func cardImagePicker(_ imagePicker: CardImagePicker, didSelect image: UIImage?) {
        if let newImage = image {
            switch imagePicker.targetCardSide {
            case .front:
                viewModel.frontImage = newImage
                contentView.setFrontImage(newImage)
            case .back:
                viewModel.backImage = newImage
                contentView.setBackImage(newImage)
            }
        }
        self.imagePicker = nil
    }
}

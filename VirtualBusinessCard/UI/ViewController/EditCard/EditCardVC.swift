//
//  EditCardVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardVC: AppViewController<EditCardView, EditCardVM> {

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
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.leftBarButtonItem = cancelEditingButton
    }

    private func setupContentView() {
        contentView.frontImageButton.addTarget(self, action: #selector(didTapFrontImageButton), for: .touchUpInside)
        contentView.backImageButton.addTarget(self, action: #selector(didTapBackImageButton), for: .touchUpInside)
    }
}

// MARK: - Actions

@objc
private extension EditCardVC {

    func didTapFrontImageButton() {
        imagePicker = CardImagePicker(presentationController: self, targetCardSide: .front)
        imagePicker?.present()
    }

    func didTapBackImageButton() {
        imagePicker = CardImagePicker(presentationController: self, targetCardSide: .back)
        imagePicker?.present()
    }

    func didTapNextButton() {
//        viewModel.didApproveSelection()
    }

    func didTapCancelButton() {
        dismiss(animated: true)
    }
}

// MARK: - EditCardVMDelegate

extension EditCardVC: EditCardVMDelegate {

}

// MARK: - CardImagePickerDelegate

extension EditCardVC: CardImagePickerDelegate {
    func cardImagePicker(_ imagePicker: CardImagePicker, didSelect image: UIImage) {
        switch imagePicker.targetCardSide {
        case .front:
            contentView.frontImageView.image = image
        case .back:
            contentView.backImageView.image = image

        }
        self.imagePicker = nil
    }

    func cardImagePickerDidCancel(_ imagePicker: CardImagePicker) {
        
    }
}



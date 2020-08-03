//
//  EditCardPhysicalVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

protocol EditCardPhysicalVCDelegate: class {
    func editCardPhysicalVC(_ editCardPhysicalVC: EditCardPhysicalVC, didFinishWith properties: EditCardPhysicalVM.CardPhysicalProperties)
}

final class EditCardPhysicalVC: AppViewController<EditCardPhysicalView, EditCardPhysicalVM>, UINavigationControllerDelegate {

    weak var delegate: EditCardPhysicalVCDelegate?

    private lazy var nextButton = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .done, target: self, action: #selector(didTapNextButton))

    private var hapticEngine: HapticFeedbackEngine?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupContentView()
        setupNavigationItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startUpdatingMotionData(in: 0.1)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.textureEditingView.collectionView.selectItem(at: viewModel.selectedTextureItemIndexPath, animated: false, scrollPosition: .left)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.pauseUpdatingMotionData()
    }

    private func setupContentView() {
        contentView.cardSceneView.setDataModel(viewModel.dataModel())

        contentView.editingViewSegmentedControl.addTarget(self, action: #selector(editingViewSegmentedControlDidChange(_:)), for: .valueChanged)

        contentView.textureEditingView.collectionView.dataSource = self
        contentView.textureEditingView.collectionView.delegate = self
        contentView.textureEditingView.addTextureImageButton.addTarget(self, action: #selector(didTapCustomTextureButton), for: .touchUpInside)

        contentView.surfaceEditingView.normalSlider.value = viewModel.normal
        contentView.surfaceEditingView.normalSlider.maximumValue = viewModel.normalMax
        contentView.surfaceEditingView.normalSlider.addTarget(self, action: #selector(normalSliderValueDidChange(_:)), for: .valueChanged)

        contentView.surfaceEditingView.specularSlider.value = viewModel.specular
        contentView.surfaceEditingView.specularSlider.maximumValue = viewModel.specularMax
        contentView.surfaceEditingView.specularSlider.addTarget(self, action: #selector(specularSliderValueDidChange(_:)), for: .valueChanged)

        contentView.cornersEditingView.slider.value = viewModel.cornerRadiusHeightMultiplier
        contentView.cornersEditingView.slider.maximumValue = viewModel.cornerRadiusHeightMultiplierMax
        contentView.cornersEditingView.slider.addTarget(self, action: #selector(cornerRadiusSliderValueDidChange(_:)), for: .valueChanged)

        contentView.hapticsEditingView.slider.value = viewModel.hapticSharpness
        contentView.hapticsEditingView.slider.maximumValue = viewModel.hapticSharpnessMax
        contentView.hapticsEditingView.slider.addTarget(self, action: #selector(hapticSharpnessSliderValueDidChange(_:)), for: .valueChanged)
    }

    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = nextButton
    }
}

// MARK: - Actions

@objc
private extension EditCardPhysicalVC {

    func specularSliderValueDidChange(_ slider: UISlider) {
        viewModel.specular = slider.value
        contentView.cardSceneView.setDataModel(viewModel.dataModel())
    }

    func normalSliderValueDidChange(_ slider: UISlider) {
        viewModel.normal = slider.value
        contentView.cardSceneView.setDataModel(viewModel.dataModel())
    }

    func cornerRadiusSliderValueDidChange(_ slider: UISlider) {
        viewModel.cornerRadiusHeightMultiplier = slider.value
        contentView.cardSceneView.setDataModel(viewModel.dataModel())
    }

    func hapticSharpnessSliderValueDidChange(_ slider: UISlider) {
        viewModel.hapticSharpness = slider.value
        hapticEngine = HapticFeedbackEngine(sharpness: viewModel.hapticSharpness, intensity: 1)
        hapticEngine?.play()

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.contentView.cardSceneViewTopConstraint.constant -= 30
            self.contentView.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.contentView.cardSceneViewTopConstraint.constant += 30
                self.contentView.layoutIfNeeded()
            })
        }
    }

    func editingViewSegmentedControlDidChange(_ segmentedControl: UISegmentedControl) {
        guard let selectedEditingViewType = EditCardPhysicalView.EditingViewType(rawValue: segmentedControl.selectedSegmentIndex) else { return }

        let viewToShow = contentView.editingView(of: selectedEditingViewType)
        let viewToHide = contentView.editingViews.first(where: { !$0.isHidden })

        UIView.animate(withDuration: 0.2) {
            viewToHide?.isHidden = true
            viewToHide?.alpha = 0
            viewToShow.isHidden = false
            viewToShow.alpha = 1
        }
    }

    func didTapCustomTextureButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }

    func didTapNextButton() {
        delegate?.editCardPhysicalVC(self, didFinishWith: viewModel.cardProperties)
    }
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension EditCardPhysicalVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EditCardPhysicalView.TextureCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.textureItem(at: indexPath))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectTextureItem(at: indexPath)
        contentView.cardSceneView.setDataModel(viewModel.dataModel())
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EditCardPhysicalVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        if let selectedIndexPath = viewModel.selectedTextureItemIndexPath {
            contentView.textureEditingView.collectionView.deselectItem(at: selectedIndexPath, animated: false)
        }
        viewModel.texture = image
        contentView.cardSceneView.setDataModel(viewModel.dataModel())
    }
}

// MARK: - EditCardPhysicalVMDelegate

extension EditCardPhysicalVC: EditCardPhysicalVMDelegate {
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        contentView.cardSceneView.updateMotionData(motion, over: timeFrame)
    }
}

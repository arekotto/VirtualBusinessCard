//
//  EditCardPhysicalVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

final class EditCardPhysicalVC: AppViewController<EditCardPhysicalView, EditCardPhysicalVM> {

    private lazy var nextButton = UIBarButtonItem(title: viewModel.nextButtonTitle, style: .done, target: self, action: #selector(didTapNextButton))

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
        contentView.textureEditingView.collectionView.dataSource = self
        contentView.textureEditingView.collectionView.delegate = self
        contentView.editingViewSegmentedControl.addTarget(self, action: #selector(editingViewSegmentedControlDidChange(_:)), for: .valueChanged)
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

    func didTapNextButton() {
//        guard let nextViewModel = viewModel.editCardPhysicalViewModel() else { return }
//        let vc = EditCardPhysicalVC(viewModel: nextViewModel)
//        show(vc, sender: nil)
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

// MARK: - EditCardPhysicalVMDelegate

extension EditCardPhysicalVC: EditCardPhysicalVMDelegate {
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        contentView.cardSceneView.updateMotionData(motion, over: timeFrame)
    }
}

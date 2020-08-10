//
//  EditCardNotesVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol EditCardNotesVMDelegate: class {
    func presentDismissAlert()
    func dismissSelf()
}

protocol EditCardNotesVMEditingDelegate: class {
    func didEditNotes(to editedNotes: String)
}

final class EditCardNotesVM: AppViewModel {

    weak var delegate: EditCardNotesVMDelegate?
    weak var editingDelegate: EditCardNotesVMEditingDelegate?

    private let originalNotes: String
    var notes: String

    private var hasMadeChanges: Bool {
        notes != originalNotes
    }

    init(notes: String) {
        originalNotes = notes
        self.notes = notes
    }
}

extension EditCardNotesVM {
    var title: String {
        NSLocalizedString("Add Notes", comment: "")
    }
    
    var isAllowedDragToDismiss: Bool {
        !hasMadeChanges
    }

    func didAttemptDismiss() {
        delegate?.presentDismissAlert()
    }

    func didApproveEdit() {
        if hasMadeChanges {
            editingDelegate?.didEditNotes(to: notes)
        }
        delegate?.dismissSelf()
    }

    func didDiscardEdit() {
        delegate?.dismissSelf()
    }
}

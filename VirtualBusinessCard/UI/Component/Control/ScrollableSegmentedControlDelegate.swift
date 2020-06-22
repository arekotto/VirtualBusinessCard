//
//  ScrollableSegmentedControlDelegate.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 22/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol ScrollableSegmentedControlDelegate: class {
    func scrollableSegmentedControl(_ control: ScrollableSegmentedControl, didSelectItemAt index: Int)
}

//
//  UIView+Constrains.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

public extension UIView {
    private var _superview: UIView {
        guard let superview = superview else {
            fatalError("Attempting to constrain to a non-existent superview.")
        }
        return superview
    }

    // MARK: - Helpers
    @discardableResult
    @objc func constrainToEdgesOfSuperview() -> [NSLayoutConstraint] {
        return constrainToSuperview()
    }

    @discardableResult
    func constrainToSuperview(topInset: CGFloat = 0, leftInset: CGFloat = 0, bottomInset: CGFloat = 0, rightInset: CGFloat = 0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(constrainTopToSuperview(inset: topInset, priority: priority))
        layoutConstraints.append(constrainLeftToSuperview(inset: leftInset, priority: priority))
        layoutConstraints.append(constrainBottomToSuperview(inset: bottomInset, priority: priority))
        layoutConstraints.append(constrainRightToSuperview(inset: rightInset, priority: priority))
        return layoutConstraints
    }

    @discardableResult
    func constrainToSuperviewSafeArea(topInset: CGFloat = 0, leftInset: CGFloat = 0, bottomInset: CGFloat = 0, rightInset: CGFloat = 0) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(constrainTopToSuperviewSafeArea(inset: topInset))
        layoutConstraints.append(constrainLeftToSuperview(inset: leftInset))
        layoutConstraints.append(constrainBottomToSuperviewSafeArea(inset: bottomInset))
        layoutConstraints.append(constrainRightToSuperview(inset: rightInset))
        return layoutConstraints
    }

    @discardableResult
    func constrainToSuperviewMargins(topInset: CGFloat = 0, leftInset: CGFloat = 0, bottomInset: CGFloat = 0, rightInset: CGFloat = 0) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(constrainTopToSuperview(inset: topInset))
        layoutConstraints.append(constrainLeftToSuperviewMargin(inset: leftInset))
        layoutConstraints.append(constrainBottomToSuperview(inset: bottomInset))
        layoutConstraints.append(constrainRightToSuperviewMargin(inset: rightInset))
        return layoutConstraints
    }

    @discardableResult
    func constrainVerticallyToSuperview(topInset: CGFloat = 0, bottomInset: CGFloat = 0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(constrainTopToSuperview(inset: topInset, priority: priority))
        layoutConstraints.append(constrainBottomToSuperview(inset: bottomInset, priority: priority))
        return layoutConstraints
    }

    @discardableResult
    func constrainHorizontallyToSuperview(sideInset: CGFloat = 0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(constrainRightToSuperview(inset: sideInset, priority: priority))
        layoutConstraints.append(constrainLeftToSuperview(inset: sideInset, priority: priority))
        return layoutConstraints
    }

    @discardableResult
    func constrainHorizontallyToSuperview(leftInset: CGFloat, rightInset: CGFloat) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(constrainLeftToSuperview(inset: leftInset))
        layoutConstraints.append(constrainRightToSuperview(inset: rightInset))
        return layoutConstraints
    }

    @discardableResult
    func constrainTopToSuperview(inset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constrainTop(to: _superview.topAnchor, constant: inset, priority: priority)
    }

    @discardableResult
    func constrainTopToSuperviewBottom(inset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constrainTop(to: _superview.bottomAnchor, constant: inset, priority: priority)
    }

    @discardableResult
    func constrainTopToSuperviewSafeArea(inset: CGFloat = 0) -> NSLayoutConstraint {
        if #available(iOS 11.0, *) {
            return constrainTop(to: _superview.safeAreaLayoutGuide.topAnchor, constant: inset)
        } else {
            return constrainTop(to: _superview.topAnchor, constant: inset + 20)
        }
    }

    @discardableResult
    func constrainBottomToSuperview(inset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constrainBottom(to: _superview.bottomAnchor, constant: -inset, priority: priority)
    }

    @discardableResult
    func constrainBottomToSuperviewSafeArea(inset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        if #available(iOS 11.0, *) {
            return constrainBottom(to: _superview.safeAreaLayoutGuide.bottomAnchor, constant: -inset, priority: priority)
        } else {
            return constrainBottom(to: _superview.bottomAnchor, constant: -inset, priority: priority)
        }
    }

    @discardableResult
    func constrainLeftToSuperview(inset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constrainLeft(to: _superview.leftAnchor, constant: inset, priority: priority)
    }

    @discardableResult
    func constrainLeftToSuperviewMargin(inset: CGFloat = 0) -> NSLayoutConstraint {
        return constrainLeft(to: _superview.layoutMarginsGuide.leftAnchor, constant: inset)
    }

    @discardableResult
    func constrainRightToSuperview(inset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constrainRight(to: _superview.rightAnchor, constant: -inset, priority: priority)
    }

    @discardableResult
    func constrainRightToSuperviewMargin(inset: CGFloat = 0) -> NSLayoutConstraint {
        return constrainRight(to: _superview.layoutMarginsGuide.rightAnchor, constant: -inset)
    }

    @discardableResult
    func constrainCenterToSuperview() -> [NSLayoutConstraint] {
        return constrainCenter(toView: _superview)
    }

    @discardableResult
    func constrainCenterXToSuperview(offset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constrainCenterX(toView: _superview, offset: offset, priority: priority)
    }

    @discardableResult
    func constrainCenterYToSuperview(offset: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constrainCenterY(toView: _superview, offset: offset, priority: priority)
    }

    // MARK: - Constraints
    @discardableResult
    func constrainTop(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainTopGreaterOrEqual(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(greaterThanOrEqualTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainBottom(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainBottomGreaterOrEqual(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(greaterThanOrEqualTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainBottomLessOrEqual(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(lessThanOrEqualTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainLeft(to anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leftAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainLeftGreaterOrEqual(to anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leftAnchor.constraint(greaterThanOrEqualTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainRight(to anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = rightAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        constraint.priority = priority
        return constraint
    }

    @discardableResult
    func constrainCenter(toView view: UIView) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(constrainCenterX(toView: view))
        layoutConstraints.append(constrainCenterY(toView: view))
        return layoutConstraints
    }

    @discardableResult
    func constrainCenterX(toView view: UIView, offset: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainCenterY(toView view: UIView, offset: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainCenterY(to anchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(equalTo: anchor, constant: offset)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainCenterX(to anchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerXAnchor.constraint(equalTo: anchor, constant: offset)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainHeight(constant: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainHeight(to anchor: NSLayoutDimension, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainHeightEqualTo(_ view: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainHeightLessThan(_ view: UIView, constant: CGFloat = 0, multiplayer: CGFloat = 1, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: multiplayer, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainHeightLessThanOrEqualTo(constant: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(lessThanOrEqualToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func constrainHeightGreaterThanOrEqualTo(constant: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainHeightGreaterThan(_ view: UIView, priority: UILayoutPriority = UILayoutPriority.required, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: multiplier)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainWidthLessThan(_ view: UIView, constant: CGFloat = 0, multiplayer: CGFloat = 1, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: multiplayer, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func constrainWidth(constant: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainWidthEqualTo(_ to: NSLayoutDimension, constant: CGFloat = 0, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: to, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainWidthEqualTo(_ view: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func constrainWidthGreaterThanOrEqualTo(constant: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
}

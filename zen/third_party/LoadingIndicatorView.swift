//
//  LoadingIndicatorView.swift
//  SwiftLoadingIndicator
//
//  Created by Vince Chan on 12/2/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//
import UIKit

class LoadingIndicatorView {
    static var currentOverlay: UIView?
    static var currentOverlayTarget: UIView?
    static var currentLoadingText: String?

    static func show() {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow)
    }

    static func show(_ loadingText: String) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow, loadingText: loadingText)
    }

    static func show(_ overlayTarget: UIView) {
        show(overlayTarget, loadingText: nil)
    }

    static func show(_ overlayTarget: UIView, loadingText: String?) {
        // Clear it first in case it was already shown
        hide()

        // register device orientation notification
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(LoadingIndicatorView.rotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)

        // Create the overlay
        let overlay = UIView()
        overlay.center = overlayTarget.center
        overlay.alpha = 0
        overlay.backgroundColor = UIColor.black
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlayTarget.addSubview(overlay)
        overlayTarget.bringSubviewToFront(overlay)

        let horConstraint = NSLayoutConstraint(item: overlay, attribute: .centerX, relatedBy: .equal,
                                               toItem: overlayTarget, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: overlay, attribute: .centerY, relatedBy: .equal,
                                               toItem: overlayTarget, attribute: .centerY,
                                               multiplier: 1.0, constant: 0.0)
        let widConstraint = NSLayoutConstraint(item: overlay, attribute: .width, relatedBy: .equal,
                                               toItem: overlayTarget, attribute: .width,
                                               multiplier: 1.0, constant: 0.0)
        let heiConstraint = NSLayoutConstraint(item: overlay, attribute: .height, relatedBy: .equal,
                                               toItem: overlayTarget, attribute: .height,
                                               multiplier: 1.0, constant: 0.0)

        overlayTarget.addConstraints([horConstraint, verConstraint, widConstraint, heiConstraint])

        // Create and animate the activity indicator
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        indicator.center = overlay.center
        indicator.startAnimating()
        overlay.addSubview(indicator)

        // Create label
        if let textString = loadingText {
            let label = UILabel()
            label.text = textString
            label.textColor = UIColor.white
            label.sizeToFit()
            label.center = CGPoint(x: indicator.center.x, y: indicator.center.y + indicator.bounds.height)
            overlay.addSubview(label)
        }

        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        overlay.alpha = overlay.alpha > 0 ? 0 : 0.5
        UIView.commitAnimations()

        currentOverlay = overlay
        currentOverlayTarget = overlayTarget
        currentLoadingText = loadingText
    }

    static func hide() {
        if currentOverlay != nil {
            // unregister device orientation notification
            NotificationCenter.default.removeObserver(
                self,
                name: UIDevice.orientationDidChangeNotification,
                object: nil)

            currentOverlay?.removeFromSuperview()
            currentOverlay = nil
            currentLoadingText = nil
            currentOverlayTarget = nil
        }
    }

    @objc private static func rotated() {
        // handle device orientation change by reactivating the loading indicator
        if currentOverlay != nil {
            show(currentOverlayTarget!, loadingText: currentLoadingText)
        }
    }
}

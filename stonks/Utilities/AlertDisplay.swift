//
//  AlertDisplay.swift
//  stonks
//
//  Created by Samuel Hobel on 7/13/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftEntryKit

struct AlertDisplay {
    
    static var dimmedLightBackground = UIColor(white: 100.0/255.0, alpha: 0.5)
    
    public static func sentEmailPopup(_ callback: @escaping () -> Void){
        var attributes:EKAttributes = EKAttributes.init()
        attributes.position = .center
        attributes.hapticFeedbackType = .success
        attributes.displayMode = .inferred
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .standardBackground)
        attributes.screenBackground = .color(color: EKColor(light: dimmedLightBackground, dark: dimmedLightBackground))
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
                )
        )
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(
            swipeable: false,
            pullbackAnimation: .jolt
        )
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            scale: .init(
                from: 1.05,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
                translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        attributes.positionConstraints.verticalOffset = 10
        attributes.positionConstraints.size = .init(
            width: .offset(value: 20),
            height: .intrinsic
        )
//      attributes.positionConstraints.maxSize = .init(
//          width: .constant(value: UIScreen.main.minEdge),
//          height: .intrinsic
//      )
        attributes.statusBar = .dark
        attributes.positionConstraints = .fullWidth
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
        attributes.roundCorners = .all(radius: 25)
        var themeImage: EKPopUpMessage.ThemeImage?
        
        themeImage = EKPopUpMessage.ThemeImage(
            image: EKProperty.ImageContent(
                image: UIImage(named: "mail")!,
                displayMode: .inferred,
                size: CGSize(width: 60, height: 60),
                tint: .none,
                contentMode: .scaleAspectFit
            )
        )
        
        let title = EKProperty.LabelContent(
            text: "Password Reset Email Sent",
            style: EKProperty.LabelStyle.init(
                font: UIFont(name: "HelveticaNeue-Medium", size: CGFloat(24))!,
                color: EKColor(light: Constants.darkPink, dark: Constants.darkPink),
                alignment: .center,
                displayMode: .inferred
            )
        )
        let description = EKProperty.LabelContent(
            text: "Follow the instructions sent to your email to reset your password.",
            style: .init(
                font: UIFont(name: "HelveticaNeue-Medium", size: CGFloat(16))!,
                color: EKColor(light: .darkGray, dark: .darkGray),
                alignment: .center,
                displayMode: .inferred
            )
        )
        let button = EKProperty.ButtonContent(
            label: .init(
                text: "Got it",
                style: .init(
                    font: UIFont(name: "HelveticaNeue-Medium", size: CGFloat(16))!,
                    color: EKColor(light: .darkGray, dark: .darkGray),
                    displayMode: .inferred
                )
            ),
            backgroundColor: EKColor(light: Constants.teal, dark: Constants.teal),
            highlightedBackgroundColor: EKColor(light: Constants.darkPink, dark: Constants.darkPink).with(alpha: 0.05),
            displayMode: .inferred
        )
        let message = EKPopUpMessage(
            themeImage: themeImage,
            title: title,
            description: description,
            button: button) {
                SwiftEntryKit.dismiss()
                callback()
        }
        let contentView = EKPopUpMessageView(with: message)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
}

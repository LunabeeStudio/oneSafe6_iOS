//
//  UIApplication+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 15/05/2023 - 09:59.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit

public extension UIApplication {
    var currentWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundInactive || $0.activationState == .foregroundActive }
            .first { $0 is UIWindowScene }
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }

    var firstWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundInactive || $0.activationState == .foregroundActive }
            .first { $0 is UIWindowScene }
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first
    }

    var statusBarHeight: CGFloat {
        let windowScene: UIWindowScene? = self.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        return windowScene?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
    }

    var keySceneWindow: UIWindow? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .filter { $0.screen === UIScreen.main }
            .first?.windows
            .filter { $0.isKeyWindow } .first
    }

    func dismissSheets(completion: (() -> Void)? = nil) {
        UIApplication.shared.keySceneWindow?
            .rootViewController?
            .dismiss(animated: true, completion: completion)
    }

    func resignCurrentFirstResponder() {
        sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

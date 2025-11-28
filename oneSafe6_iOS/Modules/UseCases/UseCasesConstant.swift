//
//  Constant.swift
//  UseCases
//
//  Created by Lunabee Studio (Nicolas) on 14/02/2023 - 15:32.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Foundation

enum Constant {
    static let deletionDelay: TimeInterval = 30 * 24 * 60 * 60

    enum PasswordCriteria {
        /// 12
        static let minNumberOfCharacters: Int = 12
        /// abcdefghijklmnopqrstuvwxyz
        static let lowerCaseCharacterSet: String = "abcdefghijklmnopqrstuvwxyz"
        /// ABCDEFGHIJKLMNOPQRSTUVWXYZ
        static let uppercaseCharacterSet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        /// 0123456789
        static let numberCharacterSet: String = "0123456789"
        /// ^$*.[]{}()?\"!@#%&/\\,><:;|_-~+=
        static let specialCharacterSet: String = "^$*.[]{}()?\"!@#%&/\\,><:;|_-~+="
        /// [a-z]
        static let containLowercaseRegex: Regex = /[a-z]+/
        /// [A-Z]
        static let containUppercaseRegex: Regex = /[A-Z]+/
        /// [0-9]
        static let containNumberRegex: Regex = /[0-9]+/
        /// [\^$*.\[\]{}()?"!@\#\%&/,><':;|_~`]
        static let containSpecialCharacterRegex: Regex = /[ \^$*.\[\]{}()?"!@#%&\/\\,><':;|_\-~`+=€£¥]+/
    }

    enum Archive {
        enum OldOneSafe {
            /// Value is `onesafe://`
            static let urlScheme: String = "onesafe://"
            /// Value is `exportToOneSafe6`
            static let exportBackupUrlPath: String = "exportToOneSafe6"
        }

        /// Value is 5.
        static let maximumAutoBackups: Int = 5
    }

    enum Image {
        /// Value is `64.0`
        static let emojiHeight: CGFloat = 64.0
        /// Value is `10.0`
        static let emojiMargin: CGFloat = 10.0
    }

    enum FavIcon {
        /// Value is `["ico", "png", "jpg", "jpeg", "webp"]`
        static let supportedFavIconsExtensions: [String] = ["ico", "png", "jpg", "jpeg", "webp"]
        /// Value is `200x200`
        static let finalSize: CGSize = .init(width: 200.0, height: 200.0)
    }

    enum Search {
        static let spolightItemCreator: String = "oneSafe 6"
        static let numberOfLastSearchQueries: Int = 12
    }

    enum ErrorCode {
        static let storageSpace: Int = 34
    }

    enum Delay {
        static let search: Int = 500
    }

    enum TranslationHelp {
        static let appLaunchCountForTranslationHelpBottomSheet: Int = 2
        static let notGeneratedTranslationLanguages: [String] = ["fr", "en"]
    }

    enum File {
        /// 50Mo
        static let maximumFileSizeAcceptedInMB: Int = 50
    }

    enum SupportUs {
        /// 3 months
        static let timeIntervalBetweenRequestsAfterRefusal: TimeInterval = 7890000
        /// 2 months
        static let timeIntervalBetweenRequestsAfterApproval: TimeInterval = 5260000
        /// 10 launchs
        static let numberOfAppLaunchBetweenRequests: Int = 10
    }

    enum ProximityLock {
        /// 3 times
        static let snackBarConfirmationMaxDisplayCount: Int = 3
    }
}

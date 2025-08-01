//
//  AppError.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 21/01/2022 - 12:41.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation

public enum AppError: Error {
    // MARK: - Application
    case appUnknown
    case wrongPasswordConfirmation
    case appCouldNotFindItemInDatabase

    case couldNotFetchWebsiteInformations
    case couldNotDownloadImage
    case obsoleteWebsiteInformationsRequest

    // MARK: - Storage
    case storageUnknown
    case storageModelConvertionIssueFromAppToSDK
    case storageNoDatabaseConfigurationLoaded
    case storageNoMatchingPublishersDatabaseLoaded
    case storageNoObjectMatchingPrimaryKey
    case storageSdkNotStarted
    case storageUnableToAccessApplicationGroupContainer
    case storageICloudDocumentsDirectoryNotAvailable

    // MARK: - Crypto
    case cryptoBiometryCancelled
    case cryptoUnknown(userInfo: String? = nil)
    case cryptoWrongCryptoKeyLength
    case cryptoWrongPassword
    case cryptoWrongPasswordFormat
    case cryptoKeyDerivationError
    case cryptoNoMasterKeyLoaded
    case cryptoNoBiometryMasterKey
    case cryptoBiometryMasterKeySaveError
    case cryptoNoMasterSalt
    case cryptoNoSearchIndexSalt
    case cryptoNoBubblesSalt
    case cryptoNoReencryptionOriginMasterKey
    case cryptoNoReencryptionDestinationMasterKey
    case cryptoBadBase64EncodedString
    case cryptoEncryptionError
    case cryptoItemKeyIdCreationError
    case cryptoBadUTF8String
    case cryptoNoKeyForEncryption
    case cryptoNoKeyForDecryption
    case cryptoNoCryptoToken
    case cryptoNoAutoLoginMasterKey
    case cryptoAutoLoginMasterKeySaveError
    case cryptoAutoLoginMasterKeyDeletionError
    case cryptoNoBubblesMasterKey

    // MARK: - Archive
    case archiveDataEncryptionFailed
    case archiveDataDecryptionFailed
    case archiveDataNoDecryptionPasswordProvided
    case archiveDataNoMasterKeyForImport
    case archiveNoKeyInArchive
    case archiveWrongArchiveKind
    case archiveNoAutoBackupFile

    // MARK: - Search
    case searchIndexNoMasterKeyLoaded
    case searchIndexWrongOperation
    case searchIndexWrongWord

    // MARK: - Icon
    case iconNoFileData

    // MARK: - Maintenance
    case cannotConvertToURL

    // MARK: - Duplication
    case duplicationFailed

    // MARK: - File
    case fileNoData
    case fileNoId
    case fileNotFound
    case filePickerNoUrl
    case addFileWrongKind
    case filePickerMaximumFileSizeExceeded
    case filePickerEmptyFile
    case filesImportFailure(_ maxFileSize: Int, _ fileNames: [String])
    case fileImportFailure
    case fileWrongUrlExtension

    // MARK: - Thumbnails
    case thumbnailsNoCacheDirectory
    case thumbnailsNoImageData
    case thumbnailsGetIconUnknownIssue

    // MARK: - Bubbles
    case base64Convertion
    case sentMessageNotFound
    case invalidMessage
    case safeItemMessageMissingItemId
    case contactKeyNotFound

    // MARK: - KMP
    case noObjectMatchingConditions // KMP datasources might need an object without handling null
    case lbResultNoSuccessData
    case lbResultNoError
}

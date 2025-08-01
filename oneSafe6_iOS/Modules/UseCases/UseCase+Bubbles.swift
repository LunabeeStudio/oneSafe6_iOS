//
//  UseCase+Bubbles.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 09/08/2024 - 11:35.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
import Model
import Combine
import CoreCrypto
import oneSafeKmp
import Errors

public extension UseCase {
    static func isBubblesUrl(url: URL) -> Bool {
        url.absoluteString.contains(Constant.invitationMessageLinkPrefix)
    }

    static func formatMessageAsLink(base64Message: String) -> String {
        "\(Constant.invitationMessageLinkPrefix)\(base64Message.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? base64Message)"
    }

    static func getBase64MessageFromLink(link: String) -> String {
        link.components(separatedBy: Constant.invitationMessageLinkPrefix).last?.removingPercentEncoding ?? link
    }

    static func deleteContact(id: String) async throws {
        try conversationsRepository.deleteConversationForId(id: id)
        try await contactRepository.deleteContact(id: .companion.fromString(uuidString: id))
    }

    static func getLastMessage(contactId: String) throws -> Model.SafeMessage? {
        try messageRepository.getLastMessage(contactId: contactId)
    }

    static func lastMessagePublisher(contactId: String) throws -> AnyPublisher<Model.SafeMessage?, Never> {
        try messageRepository.lastMessagePublisher(contactId: contactId)

    }

    static func getMessagesPublisher(contactId: String) throws -> AnyPublisher<[Model.SafeMessage], Never> {
        try messageRepository.messagesPublisher(contactId: contactId)
    }

    static func deleteMessage(messageId: String) async throws {
        try await messageRepository.deleteMessage(messageId: try .companion.fromString(uuidString: messageId))
    }

    static func deleteAllMessages(contactId: String) async throws {
        try await messageRepository.deleteAllMessages(contactId: try .companion.fromString(uuidString: contactId))
    }

    static func markMessagesAsRead(contactId: String) async throws {
        try await messageRepository.markMessagesAsRead(contactId: try .companion.fromString(uuidString: contactId))
    }

    static func hasContact() throws -> Bool {
        try contactRepository.hasContact()
    }

    static func getAllContacts() -> [oneSafeKmp.Contact] {
        contactRepository.getAllContacts()
    }

    static func safeGetAllContacts() throws -> [oneSafeKmp.Contact] {
        try contactRepository.safeGetAllContacts()
    }

    static func getSentMessage(id: String) async throws -> oneSafeKmp.SentMessage {
        guard let message = try await sentMessageRepository.getSentMessage(id: .companion.fromString(uuidString: id)) else {
            throw AppError.sentMessageNotFound
        }
        return message
    }

    static func safeId() async throws -> DoubleratchetDoubleRatchetUUID {
        try await bubblesSafeRepository.currentSafeId()
    }

    static func getContactLocalKey(contactId: DoubleratchetDoubleRatchetUUID) async throws -> Model.ContactLocalKey {
        guard let key = try await contactKeyRepository.getContactLocalKey(contactId: contactId) else { throw AppError.contactKeyNotFound }
        return .from(kmpModel: key, contactId: contactId)
    }

    static func deleteAllBubblesData() throws {
        try contactRepository.deleteAll()
        try contactKeyRepository.deleteAll()
        try messageRepository.deleteAll()
        try sentMessageRepository.deleteAll()
        try conversationsRepository.deleteAll()
        try handShakeDataRepository.deleteAll()
    }
 }

// MARK: Archive
public extension UseCase {
    static func getMessageArchive(messageData: Data, attachment: URL? = nil) throws -> URL {
        try archiveBubblesRepository.clearExportData()
        try archiveBubblesRepository.writeMessageData(messageData)
        if let attachment {
            try archiveBubblesRepository.addAttachment(url: attachment)
        }
        return try archiveBubblesRepository.zipArchive()
    }

    static func extractMessageDataFromArchive(url: URL) throws -> MessageArchiveContent {
        try archiveBubblesRepository.clearImportData()
        let unzippedUrl: URL = try archiveBubblesRepository.unzipArchive(url: url)
        let attachmentUrl: URL? = archiveBubblesRepository.getAttachmentUrlIfExist(at: unzippedUrl)
        let messageData: Data = try archiveBubblesRepository.getImportedMessageData(at: unzippedUrl)
        return MessageArchiveContent(
            messageData: messageData,
            attachment: attachmentUrl
        )
    }

    static func clearImportMessage() throws {
        try archiveBubblesRepository.clearImportData()
    }

    static func clearExportMessage() throws {
        try archiveBubblesRepository.clearExportData()
    }
}

// MARK: - Private key encoding -
public extension UseCase {
    static func convertBubblesConversationPrivateKeySec1DerToPKCS8Der(encConversation: Model.EncConversation) async throws -> Model.EncConversation {
        let bubblesUseCases: BubblesUseCases = .init()
        let coreCrypto: CoreCrypto = .shared
        let contactId: DoubleratchetDoubleRatchetUUID = try .companion.fromString(uuidString: encConversation.id)
        let result: LbcoreLBResult<KotlinByteArray> = try await bubblesUseCases.contactLocalDecryptUseCase.byteArray(
            data: encConversation.encPersonalPrivateKey.toByteArray(),
            contactId: contactId
        )
        switch onEnum(of: result) {
        case .success(let data):
            guard let successData = data.successData else {
                throw AppError.lbResultNoSuccessData
            }
            let keyData: Data = successData.toNSData()
            let convertedKeyData: Data = try coreCrypto.convertPrivateSec1DerToPKCS8Der(keyData)
            let encResult: LbcoreLBResult<KotlinByteArray> = try await bubblesUseCases.contactLocalEncryptUseCase.invoke(data: convertedKeyData.toByteArray(), contactId: contactId)
            switch onEnum(of: encResult) {
            case .success(let data):
                guard let successData = data.successData else {
                    throw AppError.lbResultNoSuccessData
                }
                let encConvertedKeyData: Data = successData.toNSData()
                return .init(
                    id: encConversation.id,
                    encPersonalPublicKey: encConversation.encPersonalPublicKey,
                    encPersonalPrivateKey: encConvertedKeyData,
                    encMessageNumber: encConversation.encMessageNumber,
                    encSequenceNumber: encConversation.encSequenceNumber,
                    encRootKey: encConversation.encRootKey,
                    encSendingChainKey: encConversation.encSendingChainKey,
                    encReceiveChainKey: encConversation.encReceiveChainKey,
                    encLastContactPublicKey: encConversation.encLastContactPublicKey,
                    encReceivedLastMessageNumber: encConversation.encReceivedLastMessageNumber
                )
            case .failure(let error):
                guard let osError = error.throwable as? OSError else {
                    throw AppError.lbResultNoError
                }
                throw osError.asError()
            }
        case .failure(let error):
            guard let osError = error.throwable as? OSError else {
                throw AppError.lbResultNoError
            }
            throw osError.asError()
        }
    }
}

private extension Constant {
    static let invitationMessageLinkPrefix: String = "https://www.onesafe-apps.com/bubbles#"
}

// MARK: - Migration
public extension UseCase {
    static func migrateMessagesOrderIfNeeded() async throws {
        guard !safeMessagesOrderMigrated() else { return }

        let decryptUseCase: ContactLocalDecryptUseCase = BubblesUseCases().contactLocalDecryptUseCase
        for contact in try safeGetAllContacts() {
            let contactId: DoubleratchetDoubleRatchetUUID = contact.id
            let messages: [oneSafeKmp.SafeMessage] = try await messageRepository.getAllByContact(contactId: contactId)
            guard !messages.isEmpty else { continue }

            var ordered: [(oneSafeKmp.SafeMessage, Date)] = []
            for message in messages {
                let result: oneSafeKmp.LbcoreLBResult<oneSafeKmp.KotlinInstant> = try await decryptUseCase.instant(data: message.encSentAt, contactId: contactId)
                switch onEnum(of: result) {
                case .success(let data):
                    guard let instant = data.successData else { continue }
                    ordered.append((message, instant.toDate() as Date))
                case .failure:
                    continue
                }
            }

            ordered.sort { $0.1 < $1.1 }
            for (index, element) in ordered.enumerated() {
                let kmpMessage: oneSafeKmp.SafeMessage = element.0
                try await messageRepository.__save(message: kmpMessage, order: Float(index))
            }
        }

        setSafeMessagesOrderMigrated()
    }
}

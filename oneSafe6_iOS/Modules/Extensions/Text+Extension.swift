//
//  Text+Extension.swift
//  oneSafe
//
//  Created by Lunabee Studio (François Combe) on 27/06/2024 - 10:43.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import SwiftUI

extension Text {
    init(markdown: String) {
        self.init((try? AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? .init(stringLiteral: ""))
    }
}

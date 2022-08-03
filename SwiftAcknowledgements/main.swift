//
//  main.swift
//  SwiftAcknowledgements
//
//  Created by Mario Iannotta on 21/07/22.
//

import Foundation
import ArgumentParser

struct SwiftAcknowledgements: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swift-acknowledgements",
        subcommands: [GenerateCommand.self])
}

SwiftAcknowledgements.main()

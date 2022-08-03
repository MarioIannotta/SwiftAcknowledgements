//
//  GenerateCommand.swift
//  SwiftAcknowledgements
//
//  Created by Mario Iannotta on 21/07/22.
//

import Foundation
import ArgumentParser
 
enum GenerateCommandError: Error {
    case fileSystemError
    case cannotDecodeLicense(name: String)
}

struct GenerateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "generate")
    
    @Argument(help: "The Swift Package Manager checkous path.")
    var checkoutsPath: String
    
    @Argument(help: "The output where the acknowledgements will be written.")
    var outputPath: String
    
    func run() throws {
        let checkoutURL = URL(fileURLWithPath: checkoutsPath)
        let licenses = try listLicenses(checkoutURL: checkoutURL)
        let acknowledgements = try licenses.compactMap(Acknowledgement.init)
        let acknowledgementEntriesPlists = acknowledgements.map(AcknowledgementEntryPlist.init)
        try acknowledgementEntriesPlists.forEach { try $0.write(to: outputPath) }
        try AcknowledgementsPlist(acknowledgements: acknowledgements)
            .write(to: outputPath)
    }
    
    private func listLicenses(checkoutURL: URL) throws -> [String] {
        guard let enumerator = FileManager.default.enumerator(at: checkoutURL,
                                                              includingPropertiesForKeys: [.isRegularFileKey],
                                                              options: [.skipsHiddenFiles, .skipsPackageDescendants])
        else {
            throw GenerateCommandError.fileSystemError
        }
        
        var paths = [String]()
        for case let fileURL as URL in enumerator {
            let licensePath = fileURL.path + "/LICENSE"
            
            if FileManager.default.fileExists(atPath: licensePath) {
                paths.append(licensePath)
            }
        }
        return paths
    }
}


struct Acknowledgement {
    let name: String
    let license: String
    
    init(path: String) throws {
        let url = URL(fileURLWithPath: path)
        name = url.pathComponents[url.pathComponents.count - 2]
        if let license = String(data: try Data(contentsOf: url), encoding: .utf8) {
            self.license = license
        } else {
            throw GenerateCommandError.cannotDecodeLicense(name: name)
        }
    }
}

struct AcknowledgementEntryPlist: Codable {
    
    struct Entry: Codable {
        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case content = "FooterText"
            case type = "Type"
        }
        let title: String
        let content: String
        let type = "PSGroupSpecifier"
    }
    
    enum CodingKeys: String, CodingKey {
        case entries = "PreferenceSpecifiers"
    }
    
    let entries: [Entry]
    init(acknowledgement: Acknowledgement) {
        entries = [.init(title: acknowledgement.name, content: acknowledgement.license)]
    }
    
    func write(to path: String) throws {
        let data = try PropertyListEncoder().encode(self)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        let outPlist = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        var outPath = path + "/Acknowledgements/"
        if !FileManager.default.fileExists(atPath: outPath) {
            try FileManager.default.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }
        outPath += "\(entries.first!.title).plist"
        let outURL = URL(fileURLWithPath: outPath)
        try outPlist.write(to: outURL)
    }
}


struct AcknowledgementsPlist: Codable {
    
    struct Entry: Codable {
        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case file = "File"
            case type = "Type"
        }
        let title: String
        let file: String
        let type = "PSChildPaneSpecifier"
    }
    
    enum CodingKeys: String, CodingKey {
        case entries = "PreferenceSpecifiers"
    }
    
    let entries: [Entry]
    init(acknowledgements: [Acknowledgement]) {
        entries = acknowledgements.map { Entry(title: $0.name, file: "Acknowledgements/\($0.name)") }
    }
    
    func write(to path: String) throws {
        let data = try PropertyListEncoder().encode(self)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        let outPlist = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        let outPath = path + "/Acknowledgements.plist"
        let outURL = URL(fileURLWithPath: outPath)
        try outPlist.write(to: outURL)
    }
}

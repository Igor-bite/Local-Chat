//
//  FileManager.swift
//  Task3
//
//  Created by Игорь Клюжев on 20.11.2022.
//

import Foundation

class FilesManager {
    enum FilesManagerError: Error {
        case invalidDirectory
        case writtingFailed
        case readingFailed
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func save(fileNamed: String, data: Data) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw FilesManagerError.invalidDirectory
        }
        do {
            try data.write(to: url)
        } catch {
            throw FilesManagerError.writtingFailed
        }
    }

    func read(fileNamed: String) throws -> Data {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw FilesManagerError.invalidDirectory
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw FilesManagerError.readingFailed
        }
    }

    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }

}

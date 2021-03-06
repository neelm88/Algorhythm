//
//  File.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/11/21.
//

import Foundation

class FilesManager {
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
        case readingFailed
        case fileNotExists
    }
    let fileManager: FileManager
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    func save(fileNamed: String, data: Data) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        if fileManager.fileExists(atPath: url.absoluteString) {
            throw Error.fileAlreadyExists
        }
        do {
            print(url.absoluteString)
            try data.write(to: url)
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func read(fileNamed: String) throws -> Data {
           guard let url = makeURL(forFileNamed: fileNamed) else {
                print("1")
               throw Error.invalidDirectory
           }
           //guard fileManager.fileExists(atPath: url.absoluteString) else {
            //print(url.absoluteString)
             //  throw Error.fileNotExists
           //}
           do {
               return try Data(contentsOf: url)
           } catch {
               debugPrint(error)
               throw Error.readingFailed
           }
       }
    
}

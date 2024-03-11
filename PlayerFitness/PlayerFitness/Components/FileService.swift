//
//  FileService.swift
//  PlayerFitness
//
//  Created by MAC on 22/02/2024.
//

import SwiftUI

class FileService {
    
    static let shared = FileService()
    let success = "success"
    
     var relativePath: URL? {
         return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Video-Cached-By-Viet")
    }
    
    func readVideoUrl(urlVideo: String) -> String? {
        guard let url = URL(string: urlVideo) else {return nil}
        
        guard let url = relativePath?.appendingPathComponent("\(success)_\(url.lastPathComponent)") else { return nil }
        if FileManager.default.fileExists(atPath: url.path) {
            return url.absoluteString
        }
        return nil
    }
    

    @MainActor
    func writeToSource(urlVideo: String) async -> String? {

        guard let url = URL(string: urlVideo) else {return nil}
        
        if !FileManager.default.fileExists(atPath: relativePath?.path ?? "") {
            try? FileManager.default.createDirectory(at: FileService.shared.relativePath!, withIntermediateDirectories: false)
        }
        
        if FileManager.default.fileExists(atPath: relativePath?.appendingPathComponent(url.lastPathComponent).path ?? "") {

            return relativePath?.appendingPathComponent(url.lastPathComponent).absoluteString
        }
        
        do {
            print("DEBUG: quan que \(relativePath?.appendingPathComponent(url.lastPathComponent).absoluteString)")
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            try data.write(to: relativePath!.appendingPathComponent(url.lastPathComponent).absoluteURL)
            
            try FileManager.default.moveItem(atPath: relativePath!.appendingPathComponent(url.lastPathComponent).path(), toPath: relativePath!.appendingPathComponent("\(success)_\(url.lastPathComponent)").path())
            return relativePath!.appendingPathComponent("\(success)_\(url.lastPathComponent)").absoluteString
            
        } catch {
            print("DEBUG: \(error.localizedDescription) error")
            return nil
        }
        
        
    }
    

    
}

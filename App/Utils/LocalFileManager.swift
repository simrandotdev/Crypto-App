//
//  LocalFileManager.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-14.
//

import Foundation
import UIKit

class LocalFileManager {
    
    static let instance = LocalFileManager()
    
    private init() {}
    
    private let fm = FileManager.default
    
    func saveImage(image: UIImage, imageName: String, folderName: String) {
        
        createFolderIfNeeded(folderName: folderName)
        
        guard
            let imageData = image.pngData(),
            let url = getURLForImage(imageName: imageName, folderName: folderName)
        else { return }
        
        do {
            try imageData.write(to: url)
            
        } catch {
            print("❌ Error in \(#function) ", error)
        }
    }
    
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        
        guard let url = getURLForImage(imageName: imageName, folderName: folderName),
              fm.fileExists(atPath: url.path) else { return nil }
        
        return UIImage(contentsOfFile: url.path)
    }
    
    private func createFolderIfNeeded(folderName: String) {
        guard let url = getURLForFolder(name: folderName) else { return }
        if !fm.fileExists(atPath: url.path) {
            do {
                try fm.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("❌ Error in \(#function) ", error)
            }
        }
    }
    
    private func getURLForFolder(name: String) -> URL? {
        guard let url = fm.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return nil }
        
        return url.appendingPathComponent(name)
    }
    
    private func getURLForImage(imageName: String, folderName: String) -> URL? {
        guard let url = getURLForFolder(name: folderName)
        else { return nil }
        
        return url.appendingPathComponent(imageName + ".png")
    }
}

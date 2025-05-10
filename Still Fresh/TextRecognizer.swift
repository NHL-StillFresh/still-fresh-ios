//
//  TextRecognizer.swift
//  Still Fresh
//
//  Created by Bram Huiskes on 09/05/2025.
//

import Foundation
import Vision
import UIKit

class TextRecognizer {
    func extractProductLines(from image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            
            var allLines: [String] = []
            for observation in observations {
                if let candidate = observation.topCandidates(1).first {
                    allLines.append(candidate.string)
                }
            }
            
            let productLines = self.filterProductLines(from: allLines)
            completion(productLines)
        }
        
        request.recognitionLanguages = ["nl-NL"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    private func filterProductLines(from lines: [String]) -> [String] {
        var productLines: [String] = []
        let stopWords = ["totaal", "betaald", "akkoord", "kopie", "btw", "betaling", "term", "transactie", "te", "betalen"]
        let priceRegex = try! NSRegularExpression(pattern: #"\d{1,3}[,.]\d{2}$"#)
        
        for i in 0..<lines.count {
            let line = lines[i]
            let lower = line.lowercased()
            if stopWords.contains(where: { lower.contains($0) }) {
                break
            }
            
            let range = NSRange(location: 0, length: line.utf16.count)
            if priceRegex.firstMatch(in: line, options: [], range: range) != nil {
                if line.rangeOfCharacter(from: .letters) != nil {
                    productLines.append(line)
                } else if i > 0 {
                    // Previous line might be the product name
                    let combined = "\(lines[i-1]) \(line)"
                    productLines.append(combined)
                }
            }
        }
        
        return productLines
    }

}

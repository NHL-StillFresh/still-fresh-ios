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
            print("ERROR: Failed to get CGImage from UIImage")
            completion([])
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("ERROR: Text recognition failed: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("ERROR: No text observations found")
                completion([])
                return
            }
            
            print("INFO: Found \(observations.count) text observations")
            
            var allLines: [String] = []
            for observation in observations {
                // Try to get more candidates for better text recognition
                let candidates = observation.topCandidates(3)
                if let candidate = candidates.first {
                    allLines.append(candidate.string)
                    
                    // Print all candidates for debugging
                    print("Candidates for text: \(candidate.string)")
                    for (i, cand) in candidates.enumerated() {
                        print("  Candidate \(i): \(cand.string) (confidence: \(cand.confidence))")
                    }
                }
            }
            
            print("INFO: Extracted \(allLines.count) total lines of text")
            for (index, line) in allLines.enumerated() {
                print("Raw line \(index): \(line)")
            }
            
            let productLines = self.extractProductsFromReceipt(lines: allLines)
            print("INFO: Filtered to \(productLines.count) product lines")
            completion(productLines)
        }
        
        request.recognitionLanguages = ["nl-NL"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.01 // Set minimum text height to detect smaller text
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("ERROR: Failed to perform text recognition: \(error.localizedDescription)")
            completion([])
        }
    }
    
    private func extractProductsFromReceipt(lines: [String]) -> [String] {
        // Remove all items before the first line with at least three '=' characters
        var filteredLines = lines
        if let separatorIndex = lines.firstIndex(where: { $0.range(of: "={3,}", options: .regularExpression) != nil }) {
            if separatorIndex + 1 < lines.count {
                filteredLines = Array(lines[(separatorIndex + 1)...])
            } else {
                filteredLines = []
            }
        }
        // Step 1: Identify store type and receipt structure
        let storeType = identifyStoreType(from: filteredLines)
        print("Identified store type: \(storeType)")
        // Step 2: Find the relevant section of the receipt that contains products
        let (productSectionStart, productSectionEnd) = identifyProductSection(lines: filteredLines, storeType: storeType)
        print("Product section identified from line \(productSectionStart) to \(productSectionEnd)")
        // Step 3: Extract products from the identified section
        let products = extractProducts(from: filteredLines, startIndex: productSectionStart, endIndex: productSectionEnd, storeType: storeType)
        return products
    }
    
    // Identify the store type from receipt content
    private func identifyStoreType(from lines: [String]) -> StoreType {
        for line in lines {
            let lowerLine = line.lowercased()
            if lowerLine.contains("jumbo") {
                return .jumbo
            } else if lowerLine.contains("aldi") {
                return .aldi
            } else if lowerLine.contains("albert heijn") || lowerLine.contains("ah ") {
                return .albertHeijn
            }
        }
        return .unknown
    }
    
    // Find the start and end indices of the product section
    private func identifyProductSection(lines: [String], storeType: StoreType) -> (Int, Int) {
        var startIndex = 0
        var endIndex = lines.count - 1
        
        // General markers for product sections
        let headerKeywords = ["omschrijving", "bedrag", "artikel", "prijs", "product", "item"]
        let footerKeywords = ["totaal", "betaald", "totaal:", "betaald:", "akkoord", "te betalen", "subtotaal"]
        
        // Find start of product section
        for (index, line) in lines.enumerated() {
            let lowerLine = line.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Store-specific start markers
            switch storeType {
            case .aldi:
                if lowerLine.contains("emmen") || lowerLine.contains("peyserhof") {
                    startIndex = index + 1
                    break
                }
            case .jumbo:
                if lowerLine.contains("omschrijving") || lowerLine.contains("bedrag in €") {
                    startIndex = index + 1
                    break
                }
            default:
                break
            }
            
            // General start markers
            if headerKeywords.contains(where: { lowerLine.contains($0) }) {
                startIndex = index + 1
                break
            }
            
            // Look for first product-like line (has price pattern)
            if startIndex == 0 && 
               lowerLine.range(of: #"\d+[.,]\d{2}"#, options: .regularExpression) != nil &&
               lowerLine.rangeOfCharacter(from: .letters) != nil {
                startIndex = index
                break
            }
        }
        
        // Find end of product section
        for (index, line) in lines.enumerated().reversed() {
            if index <= startIndex {
                break // Don't look before the start
            }
            
            let lowerLine = line.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for footer markers
            if footerKeywords.contains(where: { lowerLine.contains($0) }) {
                endIndex = index - 1
                break
            }
        }
        
        // Safety adjustment
        if startIndex >= endIndex {
            startIndex = 0
            endIndex = lines.count - 1
        }
        
        return (startIndex, endIndex)
    }
    
    // Extract products from the identified product section
    private func extractProducts(from lines: [String], startIndex: Int, endIndex: Int, storeType: StoreType) -> [String] {
        var products: [String] = []
        var previousLine = ""
        let stopWords = ["totaal:", "betaald:", "akkoord", "kopie", "btw", "terminal", "maestro", "contant"]
        
        // Process product section line by line
        for i in startIndex...endIndex {
            guard i < lines.count else { break }
            
            let line = lines[i]
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowerLine = trimmedLine.lowercased()
            
            // Skip empty lines or lines with stop words
            if trimmedLine.isEmpty || stopWords.contains(where: { lowerLine.contains($0) }) {
                continue
            }
            
            // Skip footer markers
            if lowerLine == "te betalen" || lowerLine.contains("totaal:") {
                break
            }
            
            print("Processing potential product line: \(line)")
            
            // Pattern matching based on receipt structure
            
            // Pattern 1: Line with product name and price in same line (e.g., "Product 0,99 €")
            let pricePattern = #"\d+[.,]\d{1,2}(\s*[€B])?$"#
            if lowerLine.range(of: pricePattern, options: .regularExpression) != nil && 
               lowerLine.rangeOfCharacter(from: .letters) != nil {
                if !products.contains(trimmedLine) {
                    products.append(trimmedLine)
                    print("Added product with inline price: \(trimmedLine)")
                }
                previousLine = trimmedLine
                continue
            }
            
            // Pattern 2: Multiple lines where first line has product name and next has price
            if lowerLine.rangeOfCharacter(from: .letters) != nil && 
               lowerLine.range(of: pricePattern, options: .regularExpression) == nil {
                
                // Check if next line has a price
                if i + 1 <= endIndex && i + 1 < lines.count {
                    let nextLine = lines[i + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Case where next line is just a price
                    if nextLine.range(of: #"^\s*\d+[.,]\d{1,2}(\s*[€B])?$"#, options: .regularExpression) != nil {
                        let combined = "\(trimmedLine) \(nextLine)"
                        products.append(combined)
                        print("Added product with separate price: \(combined)")
                        previousLine = combined
                        continue
                    }
                }
            }
            
            // Pattern 3: Quantity format (e.g., "2 x 0,50 €")
            if lowerLine.range(of: #"^\d+\s+x\s+\d+[.,]\d{1,2}"#, options: .regularExpression) != nil {
                
                // Check if next line is product name
                if i + 1 <= endIndex && i + 1 < lines.count {
                    let nextLine = lines[i + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if nextLine.rangeOfCharacter(from: .letters) != nil && 
                       !stopWords.contains(where: { nextLine.lowercased().contains($0) }) {
                        let combined = "\(nextLine) (\(trimmedLine))"
                        products.append(combined)
                        print("Added product with quantity: \(combined)")
                        previousLine = combined
                        continue
                    }
                }
                
                // If no product name found, just add the quantity line itself
                products.append(trimmedLine)
                print("Added quantity line as product: \(trimmedLine)")
                previousLine = trimmedLine
            }
            
            // Pattern 4: Price only, use previous line as product name
            if lowerLine.range(of: #"^\s*\d+[.,]\d{1,2}(\s*[€B])?$"#, options: .regularExpression) != nil && 
               !previousLine.isEmpty && !stopWords.contains(where: { previousLine.lowercased().contains($0) }) {
                
                // Check if previous line is not already a product
                if !products.contains(where: { $0.contains(previousLine) }) {
                    let combined = "\(previousLine) \(trimmedLine)"
                    products.append(combined)
                    print("Added product using previous line: \(combined)")
                }
                previousLine = trimmedLine
            }
        }
        
        // Final pass to detect any missed obvious products
        if products.isEmpty {
            products = scanForMissedProducts(in: lines, storeType: storeType)
        }
        
        return products
    }
    
    // Scan for any products that might have been missed with the main algorithm
    private func scanForMissedProducts(in lines: [String], storeType: StoreType) -> [String] {
        var products: [String] = []
        let stopWords = ["totaal:", "betaald:", "akkoord", "kopie", "btw", "terminal", "maestro", "contant", "te betalen", "subtotaal"]
        
        print("Scanning for missed products...")
        
        // Look for lines with price patterns
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowerLine = trimmedLine.lowercased()
            
            // Skip lines with stop words
            if stopWords.contains(where: { lowerLine.contains($0) }) || trimmedLine.isEmpty {
                continue
            }
            
            // Look for price patterns
            if lowerLine.range(of: #"\d+[.,]\d{1,2}"#, options: .regularExpression) != nil {
                
                // If line has both letters and numbers, likely a product
                if lowerLine.rangeOfCharacter(from: .letters) != nil {
                    if !products.contains(trimmedLine) {
                        products.append(trimmedLine)
                        print("Last-chance scan: Added product: \(trimmedLine)")
                    }
                }
                // Otherwise, check previous line
                else if index > 0 {
                    let prevLine = lines[index - 1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if prevLine.rangeOfCharacter(from: .letters) != nil && 
                       !stopWords.contains(where: { prevLine.lowercased().contains($0) }) {
                        
                        let combined = "\(prevLine) \(trimmedLine)"
                        if !products.contains(combined) {
                            products.append(combined)
                            print("Last-chance scan: Added combined product: \(combined)")
                        }
                    }
                }
            }
        }
        
        return products
    }
    
    /// Debug method: returns an image with green boxes around recognized text and all recognized lines
    func debugRecognizeText(in image: UIImage, completion: @escaping (UIImage?, [String]) -> Void) {
        guard let cgImage = image.cgImage else {
            print("ERROR: Failed to get CGImage from UIImage")
            completion(nil, [])
            return
        }
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("ERROR: Text recognition failed: \(error.localizedDescription)")
                completion(nil, [])
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("ERROR: No text observations found")
                completion(nil, [])
                return
            }
            var allLines: [String] = []
            let size = CGSize(width: image.size.width, height: image.size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
            image.draw(at: .zero)
            guard let context = UIGraphicsGetCurrentContext() else {
                UIGraphicsEndImageContext()
                completion(nil, [])
                return
            }
            context.setStrokeColor(UIColor.green.cgColor)
            context.setLineWidth(2.0)
            for observation in observations {
                let candidates = observation.topCandidates(1)
                if let candidate = candidates.first {
                    allLines.append(candidate.string)
                }
                // VNRecognizedTextObservation boundingBox is in normalized coordinates (0,0 bottom-left)
                let rect = observation.boundingBox
                let convertedRect = CGRect(
                    x: rect.origin.x * size.width,
                    y: (1 - rect.origin.y - rect.size.height) * size.height,
                    width: rect.size.width * size.width,
                    height: rect.size.height * size.height
                )
                context.stroke(convertedRect)
            }
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion(resultImage, allLines)
        }
        request.recognitionLanguages = ["nl-NL"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.01
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("ERROR: Failed to perform text recognition: \(error.localizedDescription)")
                completion(nil, [])
            }
        }
    }
    
    // Enum to track different store types for specialized receipt parsing
    enum StoreType {
        case unknown, jumbo, albertHeijn, aldi
    }
}

//
//  TextRecognizer.swift
//  Still Fresh
//
//  Created by Bram Huiskes on 09/05/2025.
//

import SwiftUI
import Foundation
import Vision
import UIKit

class TextRecognizer {
    /// The array of `RecognizedTextObservation` objects to hold the request's results.
    var observations = [RecognizedTextObservation]();
    
    /// The Vision request.
    var request = RecognizeTextRequest()
    
    func performOCR(imageData: Data) async throws {
        /// Clear the `observations` array for photo recapture.
        observations.removeAll()
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = [Locale.Language(identifier: "en-US")]
        
        /// Perform the request on the image data and return the results.
        let results = try await request.perform(on: imageData)
        
        /// Add each observation to the `observations` array.
        for observation in results {
            // Skip observations that match a price pattern (e.g. 0.5 or 0,5)
            let candidate = observation.topCandidates(1).first
            
            if candidate?.string.range(of: #"^\d+[.,]\d+$"#, options: .regularExpression) != nil {
                continue
            }
            
            if candidate?.description.lowercased().contains("statie") ?? false {
                continue
            }
            
            observations.append(observation)
        }
        
        let lastReceiptStartIndex = observations.lastIndex(where: { $0.topCandidates(1).first?.string.lowercased().contains("=") ?? false || $0.topCandidates(1).first?.string.lowercased().contains("omschrijving") ?? false || $0.topCandidates(1).first?.string.lowercased().contains("bedrag in") ?? false }) ?? 0
        
        debugPrint(lastReceiptStartIndex)
        
        if lastReceiptStartIndex > 0 {
            observations.removeSubrange(0..<lastReceiptStartIndex)
        }
        
        let firstReceiptEndIndex = observations.firstIndex(where: { $0.topCandidates(1).first?.string.lowercased().contains("totaal") ?? false || $0.topCandidates(1).first?.string.lowercased().contains("betaald") ?? false
            || $0.topCandidates(1).first?.string.lowercased().contains("mastercard") ?? false
        }) ?? observations.count
        
        if firstReceiptEndIndex < observations.count {
            observations.removeSubrange(firstReceiptEndIndex..<observations.count)
        }
    }
}

/// Create and dynamically size a bounding box.
struct Box: Shape {
    private let normalizedRect: NormalizedRect

    init(observation: any BoundingBoxProviding) {
        normalizedRect = observation.boundingBox
    }

    func path(in rect: CGRect) -> Path {
        let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(rect)
    }
}


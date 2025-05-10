//
//  database.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 10/05/2025.
//

import Supabase
import Foundation

enum DatabaseError: Error {
    case connectionFailed
    case queryFailed
    case invalidResult
}

class Database {
    private static var internalInstance:Database!
    private let client:SupabaseClient!
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://rfaddfahfpssnxrbxplc.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmYWRkZmFoZnBzc254cmJ4cGxjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1MTQ4ODEsImV4cCI6MjA2MjA5MDg4MX0.3cUGivB6XZTWC-7-MrEnatARAWJAap3oC5MCAmqnfo0"
        )
    }
    
    /// A function that returns the database instance whether or not it exists yet.
    ///
    ///  - Returns: Instance of the database connection
    public static func getInstance() -> Database {
        if(internalInstance == nil) {
            internalInstance = Database()
        }
        
        return internalInstance
    }
    
    /// Used to connect to the supabase database
    public func connect() throws {
        
    }
    
    
    public func disconnect() {
        
    }
}

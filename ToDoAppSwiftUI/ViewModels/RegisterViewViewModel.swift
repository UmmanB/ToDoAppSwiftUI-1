//
//  RegisterViewViewModel.swift
//  ToDoAppSwiftUI
//
//  Created by Umman on 22.08.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewViewModel: ObservableObject
{
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    
    init() {}
    
    func register()
    {
        guard validate() else
        {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else
            {
                return
            }
            
            self?.insertUserRecord(id: userId)
        }
    }
    
    private func insertUserRecord(id: String)
    {
        let newUser = User(id: id, name: name, email: email, joined: Date().timeIntervalSince1970)
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary())
    }
    
    private func validate() -> Bool
    {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty, !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty else
        {
            
            errorMessage = "Please fill in all the fields."
            showErrorAlert = true
            return false
        }
        
        guard email.contains("@") && email.contains(".") else
        {
            errorMessage = "Please enter a valid email address."
            showErrorAlert = true
            return false
        }
        
        guard password.count >= 6 else
        {
            errorMessage = "Password must be at least 6 characters long."
            showErrorAlert = true
            return false
        }
        
        return true
    }
}

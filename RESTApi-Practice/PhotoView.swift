//
//  ContentView.swift
//  RESTApi-Practice
//
//  Created by Amish on 26/07/2024.
//

import SwiftUI

struct PhotoView: View {
    @StateObject var networkManager = NetworkManager()
    @State private var newUser = NewUser(createdAt: "1-1-2024", name: "Test", avatar: "https://img.freepik.com/free-photo/painting-mountain-lake-with-mountain-background_188544-9126.jpg")
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var updatedUser = UserModel(createdAt: "1-1-2024", name: "Test", avatar: "https://img.freepik.com/free-photo/painting-mountain-lake-with-mountain-background_188544-9126.jpg", id: "3")
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(networkManager.users, id: \.id) { user in
                        VStack {
                            HStack {
                                CachedAsyncImage(url: URL(string: user.avatar))
                                    .scaledToFill()
                                    .frame(width: 55.0, height: 55.0)
                                    .clipShape(Circle())
                                Text(user.id)
                                Text(user.name)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(user.createdAt)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            HStack {
                                CachedAsyncImage(url: URL(string: user.avatar))
                                    .scaledToFit()
                                    .frame(height: 100.0)
                                    .clipShape(Rectangle())
                                    .padding(.horizontal)
                                Spacer()
                                Button(action: {
                                    networkManager.deleteUser(userId: user.id) { result in
                                        DispatchQueue.main.async {
                                            switch result {
                                            case .success:
                                                networkManager.users.removeAll { $0.id == user.id }
                                                alertMessage = "User deleted successfully!"
                                            case .failure(let error):
                                                alertMessage = "Failed to delete user: \(error.localizedDescription)"
                                            }
                                            showingAlert = true
                                        }
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                Button("Add User") {
                    networkManager.postUser(newPhoto: newUser) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let postedUser):
                                networkManager.users.append(postedUser)
                                alertMessage = "User added successfully!"
                            case .failure(let error):
                                alertMessage = "Failed to add User: \(error.localizedDescription)"
                            }
                            showingAlert = true
                        }
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Button("Update User") {
                    networkManager.putUser(updatedUser: updatedUser) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let updatedUser):
                                if let index = networkManager.users.firstIndex(where: { $0.id == updatedUser.id }) {
                                    networkManager.users[index] = updatedUser
                                }
                                alertMessage = "User updated successfully!"
                            case .failure(let error):
                                alertMessage = "Failed to update user: \(error.localizedDescription)"
                            }
                            showingAlert = true
                        }
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Get/Post Users 🎆")
        }
    }
}

#Preview {
    PhotoView()
}

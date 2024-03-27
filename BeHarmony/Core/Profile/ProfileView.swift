//
//  ProfileView.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/24/24.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
@MainActor
final class ProfileViewModel: ObservableObject{
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var preferences: Preferences? = nil // Add preferences
    @Published private(set) var aboutMe: UserAboutMe? = nil
    
    func loadUser() async throws{
            do {
                let authUser = try AuthManager.shared.getUser()
                print("Authenticated user ID: \(authUser.uid)")
                
                self.user = try await UserManager.shared.getUser(userId: authUser.uid)
                if let user = self.user {
                    print("Loaded user ID: \(user.userId)")
                    self.preferences = user.preferences
                    self.aboutMe = user.aboutMe
                } else {
                    print("Failed to load user")
                }
            } catch {
                print("Error loading user: \(error)")
            }
        }
    
    func updateAboutMe(aboutMe: UserAboutMe) async throws{
        let user = try AuthManager.shared.getUser()
        try await UserManager.shared.updateAboutMe(userId: user.uid, aboutMe: aboutMe)
    }
    
    func updatePreferences(preferences: Preferences) async throws {
        let user = try AuthManager.shared.getUser()
        try await UserManager.shared.updatePreferences(userId: user.uid, preferences: preferences)
    }
    
    func updatePhotoUrl(photoURL : String) async throws {
        let user = try AuthManager.shared.getUser()
        try await UserManager.shared.updatePhotoUrl(userId: user.uid, photoUrl: photoURL)
    }
    
}
struct ProfileView: View {
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var isLoggedIn: Bool
    @State private var isEthnicitiesExpanded = false
    @State private var isUserEthnicitiesExpanded = false
    @State private var isAgeRangeExpanded = false
    @State private var isAgePickerPresented = false
    @State private var isPhotoPickerShowing = false
    @State private var selectedEthnicities: Set<String> = [] // For general selected ethnicities
    @State private var selectedUserEthnicities: Set<String> = [] // For user's selected ethnicities
    @State private var minAge = 25
    @State private var maxAge = 25
    @State private var selectedOrientation = "Heterosexual" // Default selection
    @State private var isNameExpanded = false
    @State private var name = ""
    @State private var age = 25
    @State private var selectedGender = ""
    
    
    let orientations = ["Heterosexual", "Homosexual", "Bisexual", "Pansexual", "Asexual", "Demisexual", "Queer", "Other"]
    let ethnicities = ["African", "African-American", "Arab", "Asian", "Caucasian", "Hispanic/Latino", "Indigenous Peoples", "Middle Eastern", "Native American", "Pacific Islander", "South Asian", "Southeast Asian"]
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
            List {
                if let user = viewModel.user {
                    HStack {
                        Spacer() // Spacer to push the PhotosPicker to the center
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            VStack {
                                Image(uiImage: selectedImage ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fill) // Ensure the entire image fits within the frame
                                    .frame(width: 100, height: 100) // Set fixed size for the image
                                    .clipShape(Circle()) // Clip to make it circular
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1)) // Add a border
                                    .padding(.bottom, 10) // Add some spacing between the image and the text
                                Text("Select Photo")
                                    .padding()
                            }
                        }
                        .onAppear {
                            print("fetch")
                            fetchProfilePhoto(user: user)
                        }
                        .onChange(of: photosPickerItem) {
                            Task {
                                if let photosPickerItem,
                                   let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                                    if let image = UIImage(data: data) {
                                        selectedImage = image
                                        try await uploadPhoto(userId: user.userId)
                                    }
                                }
                            }
                        }
                        Spacer() // Spacer to push the PhotosPicker to the center
                    }
                }
                if let user = viewModel.user {
                    let _ = Binding<String>(
                        get: { user.aboutMe?.name ?? "" },
                        set: { newValue in
                            name = newValue
                        }
                    )
                    let _ = Binding<Int>(
                        get: { user.aboutMe?.age ?? 25 },
                        set: { newValue in
                            age = newValue
                        }
                    )
                    let _ = Binding<[String]>(
                        get: { user.aboutMe?.ethnicity ?? [] },
                        set: { newValue in
                            selectedUserEthnicities = Set(newValue)
                        }
                    )
                    let _ = Binding<String>(
                        get: { user.aboutMe?.gender ?? "" },
                        set: { newValue in
                            selectedGender = newValue
                        }
                    )
                    let _ = Binding<[String]>(
                        get: { user.preferences?.ethnicities ?? [] },
                        set: { newValue in
                            selectedUserEthnicities = Set(newValue)
                        }
                    )
                    let _ = Binding<[Int]>(
                        get: { user.preferences?.ageRange ?? [] },
                        set: { newValue in
                            minAge  = newValue[0]
                            maxAge = newValue[1]
                        }
                    )
                    Text("User ID: \(user.userId)")
                    Section(header: Text("About Me")) {
                        VStack(alignment: .leading, spacing: 10) {
                            VStack {
                                DisclosureGroup(isExpanded: $isNameExpanded) {
                                    TextField("Name", text: $name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                } label: {
                                    HStack {
                                        Text("Display Name:")
                                        Spacer()
                                        Text(name.isEmpty ? "Type Name" : name)
                                            .foregroundColor(name.isEmpty ? .gray : .primary)
                                    }
                                }
                            }
                            
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isNameExpanded.toggle()
                            }
                            HStack {
                                Text("Age: \(age)")
                                Spacer()
                                Button(action: {
                                    isAgePickerPresented.toggle()
                                }) {
                                    Text(isAgePickerPresented ? "\(age)" : "Select Age")
                                        .foregroundColor(isAgePickerPresented ? .primary : .gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.primary))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isAgePickerPresented.toggle()
                            }
                            if isAgePickerPresented {
                                Picker("Age", selection: $age) {
                                    ForEach(18..<100, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                            }
                            DisclosureGroup("Ethnicity: \(selectedUserEthnicitiesText)", isExpanded: $isUserEthnicitiesExpanded) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(ethnicities, id: \.self) { ethnicity in
                                        CheckboxRow(title: ethnicity, isChecked: selectedUserEthnicities.contains(ethnicity)) {
                                            if selectedUserEthnicities.contains(ethnicity) {
                                                selectedUserEthnicities.remove(ethnicity)
                                            } else {
                                                selectedUserEthnicities.insert(ethnicity)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                            
                            Picker("Gender", selection: $selectedGender) {
                                ForEach(genders, id: \.self) { gender in
                                    Text(gender)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: selectedGender) {oldValue, newValue in
                                if oldValue != newValue {
                                    let userAboutMe = UserAboutMe(age: age, name: name, gender: selectedGender, ethnicity: Array(selectedUserEthnicities))
                                    Task{
                                        do {
                                            try await viewModel.updateAboutMe(aboutMe: userAboutMe)
                                            print("tried")
                                        } catch {
                                            print("Error updating about me: \(error)")
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .onChange(of:[isNameExpanded, isAgePickerPresented, isUserEthnicitiesExpanded]){
                            Task{
                                if(!isNameExpanded || !isAgePickerPresented || !isUserEthnicitiesExpanded){
                                    print("went thru")
                                    let userAboutMe = UserAboutMe(age: age, name: name, gender: selectedGender, ethnicity: Array(selectedUserEthnicities))
                                    Task{
                                        do {
                                            try await viewModel.updateAboutMe(aboutMe: userAboutMe)
                                            print("tried")
                                        } catch {
                                            print("Error updating about me: \(error)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Preferences")) {
                        DisclosureGroup("Selected Ethnicities: \(selectedEthnicitiesText)", isExpanded: $isEthnicitiesExpanded) {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(ethnicities, id: \.self) { ethnicity in
                                    CheckboxRow(title: ethnicity, isChecked: selectedEthnicities.contains(ethnicity)) {
                                        if selectedEthnicities.contains(ethnicity) {
                                            selectedEthnicities.remove(ethnicity)
                                        } else {
                                            selectedEthnicities.insert(ethnicity)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding()
                        .onChange(of:selectedEthnicities){
                            let userPreferences = Preferences(ethnicities: Array(selectedEthnicities) , ageRange: [minAge, maxAge])
                            Task{
                                do {
                                    try await viewModel.updatePreferences(preferences: userPreferences)
                                    print("prefs")
                                } catch {
                                    print("Error updating about me: \(error)")
                                }
                            }
                        }
                        DisclosureGroup("Age Range: \(ageRangeString)", isExpanded: $isAgeRangeExpanded) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Min Age:")
                                    Picker(selection: $minAge, label: Text("")) {
                                        ForEach(18..<100, id: \.self) {
                                            Text("\($0)")
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                }
                                .padding(.trailing)
                                
                                VStack(alignment: .leading) {
                                    Text("Max Age:")
                                    Picker(selection: $maxAge, label: Text("")) {
                                        ForEach(minAge..<100, id: \.self) {
                                            Text("\($0)")
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                }
                            }
                            .padding(.vertical)
                        }
                        .padding()
                        .onChange(of: maxAge) {
                            if maxAge < minAge {
                                maxAge = minAge
                                
                            }
                        }
                        .onChange(of: minAge) {
                            if maxAge < minAge {
                                maxAge = minAge
                            }
                        }
                        .onChange(of: [minAge, maxAge]){
                            let userPreferences = Preferences(ethnicities: Array(selectedEthnicities) , ageRange: [minAge, maxAge])
                            Task{
                                do {
                                    try await viewModel.updatePreferences(preferences: userPreferences)
                                    print("prefs")
                                } catch {
                                    print("Error updating about me: \(error)")
                                }
                            }
                        }
                        //                    VStack {
                        //                        Picker("Select Orientation", selection: $selectedOrientation) {
                        //                            ForEach(orientations, id: \.self) {
                        //                                Text($0)
                        //                            }
                        //                        }
                        //                        .padding()
                        //                        .pickerStyle(MenuPickerStyle())
                        //                    }
                    }
                }
                
                
            }
            .task {
                do {
                    try await viewModel.loadUser()
                } catch {
                    print("Error loading user: \(error)")
                }
            }
            .onDisappear{
                print("why")
                isEthnicitiesExpanded = false
                isUserEthnicitiesExpanded = false
                isAgePickerPresented = false
                isNameExpanded = false
                isAgeRangeExpanded = false
            }
            .navigationBarTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(isLoggedIn: $isLoggedIn)
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                    }
                }
            }
            
            
        }
    
        
        var ageRangeString: String {
            if minAge > maxAge {
                maxAge = minAge
            }
            return "\(minAge)-\(maxAge)"
        }
        
        
        var selectedEthnicitiesText: String {
            let maxDisplayedItems = 1 // Change this to the desired maximum number of displayed items
            let displayedEthnicities = selectedEthnicities.sorted().prefix(maxDisplayedItems)
            let additionalCount = selectedEthnicities.count - maxDisplayedItems
            
            var text = displayedEthnicities.joined(separator: ", ")
            if additionalCount > 0 {
                text += " ... \(additionalCount) more"
            }
            return text
        }
        
        var selectedUserEthnicitiesText: String {
            let maxDisplayedItems = 1 // Change this to the desired maximum number of displayed items
            let displayedEthnicities = selectedUserEthnicities.sorted().prefix(maxDisplayedItems)
            let additionalCount = selectedUserEthnicities.count - maxDisplayedItems
            
            var text = displayedEthnicities.joined(separator: ", ")
            if additionalCount > 0 {
                text += " ... \(additionalCount) more"
            } else if additionalCount < 0 {
                text = "None"
            }
            
            return text
        }
        func uploadPhoto(userId: String) async throws {
            guard selectedImage != nil else{
                return
            }
            let storageRef = Storage.storage().reference()
            guard let selectedImage = selectedImage,
                  let imageData = selectedImage.jpegData(compressionQuality: 0.2) else {
                return
            }
            
            let path = "images/\(userId)/profilePhoto.jpg"
            let fileRef = storageRef.child(path)
            
            do {
                // Upload image data to Firebase Storage
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg" // Set content type if needed
                
                fileRef.putData(imageData, metadata: metadata)
                // Upon successful upload, update the photo URL in Firestore
                try await viewModel.updatePhotoUrl(photoURL: path)
                
                print("Photo uploaded and URL updated successfully.")
            } catch {
                print("Error uploading image and updating photo URL: \(error)")
            }
        }
        func fetchProfilePhoto(user : DBUser) {
            guard let path  = user.photoUrl as String? else{
                return
            }
            let storageRef = Storage.storage().reference()
            let fileRef = storageRef.child(path)
            fileRef.getData(maxSize: Int64(5) * 1024 * 1024) {data, error in
                if error == nil && data != nil{
                    let image = UIImage(data:data!)
                    DispatchQueue.main.async{
                        selectedImage  = image
                    }
                    
                }
            }
        }
        
    }



struct CheckboxRow: View {
    let title: String
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isChecked {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(isLoggedIn: .constant(true))
                .navigationBarTitle("Profile") // Set the display mode explicitly
            
        }
    }
}


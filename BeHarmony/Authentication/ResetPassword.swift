import SwiftUI

final class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""
    
    func resetPassword(email:String) async throws{
        guard !email.isEmpty else{
            print("No email found")
            return
        }
        Task {
            do{
                try await AuthManager.shared.resetPassword(email:email)
            }
            catch{
                print(error)
            }
        }
        
    }
    
}
struct ResetPasswordView: View {
    @State private var email = ""
    @StateObject private var viewModel = ResetPasswordViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button(action: {
                Task{
                    do {
                        try await viewModel.resetPassword(email:email)
                        print("reset")
                    }catch{
                        print(error)
                    }
                }
            }) {
                Text("Reset Password")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Reset Password")
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}


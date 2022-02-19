
import SwiftUI
import Firebase

struct ContentView: View {
    let loginComplete: () -> ()

    @State var loginMode = true
    @State var email = ""
    @State var pass = ""
    @State var uName = ""
    @State var verifCode = ""
    @State var showImgPicker = false
    @State var withApple = false
    @State var withGoogle = false

    var body: some View {
        VStack{
            HStack{
                Text("WeSign")
                    .multilineTextAlignment(.leading)
                    .padding()
                    .foregroundColor(Color(.black))
                
            }
                .font(.system(size: 32, weight: .heavy))
                .frame(maxWidth: .infinity, alignment: .leading)
            NavigationView{
                ScrollView{
                    VStack(spacing: 15){
                        //Spacer()
                        Picker(selection: $loginMode, label: Text("Picker here")){
                            Text("Login")
                                .tag(true)
                            Text("With Email")
                                .tag(false)
                        }.pickerStyle(SegmentedPickerStyle())
                            .background(Color(.systemBackground))

                        if !loginMode{
                            Button{
                                showImgPicker.toggle()
                            } label: {

                                VStack{
                                    if let image = self.image{
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 200, height: 130)
                                            .scaledToFill()
                                            .cornerRadius(180)
                                            .shadow(color: .gray, radius: 20)
                                    } else{
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 60))
                                            .padding()
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            // .border(.black, width: 3.5)
                            .overlay(RoundedRectangle(cornerRadius: 90) .stroke(.primary, lineWidth: 3))
                            .padding()
                        }
                        Group{
                            if !loginMode{
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)

                            TextField("Username", text: $uName)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $pass)
                            } else {
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                SecureField("Password", text: $pass)
                                
                                
                            }

                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                            Button{
                                logInClick()
                            } label: {
                                HStack{
                                    Spacer()
                                    Text(loginMode ? "Log In" : "Create An Account")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 15)
                                        .font(.system(size: 20, weight: .heavy))
                                    Spacer()
                                }
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        
                        Text(self.statusLogin)
                            .foregroundColor(.red)
                        }
                        .padding()
                    
                    }
                .navigationTitle(loginMode ? "Log In" : "Create An Account")
                .background(Color(.init(white: 0, alpha: 0.1)) .ignoresSafeArea())
            }
        }
        .background(Color(.init(white: 0, alpha: 0.1)))
        .navigationViewStyle(StackNavigationViewStyle())
                
        }

    @State private var statusLogin = ""
    @State var image: UIImage?
    private func logInClick(){
        if loginMode {
            loginUser()
        } else {
            createNewAcc()
        }
    }

    private func createNewAcc(){
//            if self.image == nil{
//                self.statusLogin = "You must select an avatar to Sign in"
//                return
//            }
            FirebaseManager.shared.auth.createUser(withEmail: email, password: pass) { result, error in
                if let err = error{
                    print("Failed to create User", err)
//                    self.statusLogin = "Failed to create User \(err)"
                    self.statusLogin = "Failed to create User. Please use a different Email-id or Password"
                    return
                }
                print("Succefully created User \(result?.user.uid ?? "" )")
//                self.statusLogin = "Succefully created User \(result?.user.uid ?? "" )"
                self.statusLogin = "Successfully created a new User"
//                self.imageToStorage()
            }
//        }
    }

    private func loginUser(){
            FirebaseManager.shared.auth.signIn(withEmail: email, password: pass){ result, error in
                if let err = error{
                    print("Failed to login User", err)
//                    self.statusLogin = "Failed to login User \(err)"
                    self.statusLogin = "Incorrect Email-Id/Password"
                    return
                }
                print("Succefully logged in as User \(result?.user.uid ?? "" )")
//                self.statusLogin = "Succefully logged in as User \(result?.user.uid ?? "" )"
                self.statusLogin = "Successfully logged in!!"

                self.loginComplete()

            }
//        }

    }

//    private func imageToStorage(){
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
//        else { return }
//        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
//        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)
//        else { return }
//        ref.putData(imageData, metadata: nil){ metadata, err in
//            if let err = err {
////                self.statusLogin = "Failed to push image to Storage: \(err)"
//                self.statusLogin = "Failed to store your Display Picture"
//            }
//            ref.downloadURL{ url, err in
//                if let err = err {
////                    self.statusLogin = "Failed to retrieve downloadURL: \(err)"
//                    self.statusLogin = "Failed to store your Display Picture"
//                    return
//                }
////                    self.statusLogin = "Successfully stored image with url: \(url?.absoluteString ?? "")"
//                self.statusLogin = "Successfully stored your Display Picture"
//
//                guard let url = url
//                else { return }
//                self.storeUserInformation(imageProfileUrl: url)
//            }
//        }
//    }

    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "uName": uName]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.statusLogin = "\(err)"
                    return
                }

                print("Success")
                self.loginComplete()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loginComplete: {
        }
        )
            .preferredColorScheme(.light)
    }
}

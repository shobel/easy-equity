//
//  AuthViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/13/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import AVKit
import VisualEffectView
import Firebase
import TransitionButton
import AuthenticationServices

class AuthViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    @IBOutlet weak var loginButton: TransitionButton!//with apple
    @IBOutlet weak var loginEmail: TransitionButton! //with email
    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = 25
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = CGFloat(1)
//        logo.layer.cornerRadius = logo.layer.bounds.width / 2
        
        loginEmail.layer.cornerRadius = 25
        loginEmail.layer.borderColor = UIColor.white.cgColor
        loginEmail.layer.borderWidth = CGFloat(1)
        
        self.view.addPurpleGradientBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Dataholder.watchlistUpdater != nil {
            Dataholder.watchlistUpdater?.stopWatchlistFetchingTimer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.loginButton.startAnimation()
        self.handleAuthorization()
    }
    
    private func handleAuthorization(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
         
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.loginButton.stopAnimation(animationStyle: .shake)
        print(error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let token = appleIDCredential.identityToken
            let tokenStr = String(data: token!, encoding: .utf8)
            
            if let email = email {
                do {
                    try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userEmail").saveItem(email)
                } catch {
                    print("Unable to save email to keychain.")
                }
            }
            NetworkManager.getMyRestApi().signInWithAppleToken(token: tokenStr!) { json in
                if json != nil {
                    self.loginButton.stopAnimation(animationStyle: .expand, completion: {
                        self.performSegue(withIdentifier: "toHome", sender: self)
                    })
                } else {
                    self.loginButton.stopAnimation(animationStyle: .shake)
                }
            }
        
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print(username)
            print(password)
            
        default:
            break
        }
    }
    
    @IBAction func pp(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/stoccoon/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func tc(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/stoccoon/terms-and-conditions") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func eula(_ sender: Any) {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(url)
        }
    }
    //    private func signInToFirebase() {
    //        Auth.auth().signIn(withEmail: self.emailInput.text!, password: self.passwordInput.text!) { (result, err) in
    //            if err != nil {
    //                self.showError("Wrong username or password.")
    //                self.loginButton.stopAnimation(animationStyle: .shake, completion: nil)
    //            } else {
    //                self.hideError()
    //                self.loginButton.stopAnimation(animationStyle: .expand, completion: {
    //                    self.performSegue(withIdentifier: "toHome", sender: self)
    //                })
    //            }
    //        }
    //    }
    
    
//    func setBackground(){
//        let bg = UIImage(named: "finance-bg9.jpg")!
//        let imageView = UIImageView(frame: view.bounds)
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.image = bg
//        imageView.center = view.center
//        view.addSubview(imageView)
//        self.view.sendSubviewToBack(imageView)
//    }
//
//    func addOpaqueLayer(){
//        let opaqueLayer = UIView()
//        opaqueLayer.frame = self.view.bounds
//        opaqueLayer.backgroundColor = UIColor(white: 0.5, alpha: 0.4)
//        view.addSubview(opaqueLayer)
//    }
//
//    func applyBlur(){
//        //only apply the blur if the user hasn't disabled transparency effects
//        if !UIAccessibility.isReduceTransparencyEnabled {
//            //view.backgroundColor = .clear
//
//            let visualEffectView = VisualEffectView(frame: self.view.bounds)
//            visualEffectView.blurRadius = 6
//
//            view.addSubview(visualEffectView)
//        } else {
//            view.backgroundColor = .black
//        }
//    }
//
//    func setUpVideo(){
//        let bundlePath = Bundle.main.path(forResource: "frog-on-a-log", ofType: "mp4")
//        guard bundlePath != nil else {
//            return
//        }
//        let url = URL(fileURLWithPath: bundlePath!)
//        let item = AVPlayerItem(url: url)
//        videoPlayer = AVPlayer(playerItem: item)
//        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
//        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*0.25, y: 0, width: self.view.frame.size.width*1.5, height: self.view.frame.size.height)
//        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
//        videoPlayer?.playImmediately(atRate: 0.5)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

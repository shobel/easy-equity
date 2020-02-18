//
//  NewsWebViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 2/17/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import WebKit

class NewsWebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.configuration.allowsInlineMediaPlayback = true
        self.webView.configuration.allowsPictureInPictureMediaPlayback = true
        self.webView.configuration.mediaTypesRequiringUserActionForPlayback = [.video]
        self.webView.navigationDelegate = self
        self.loading()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func loading(){
        self.webView.isHidden = true
        self.activityIndicator.startAnimating()
    }
    
    private func loaded(){
        self.webView.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loaded()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

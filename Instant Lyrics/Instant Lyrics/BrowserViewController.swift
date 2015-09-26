//
//  BrowserViewController.swift
//  Instant Lyrics
//
//  Created by Tom Lai on 9/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

import UIKit
import MediaPlayer

class BrowserViewController: ViewController,UIWebViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UISearchBarDelegate, NJKWebViewProgressDelegate {
    var urlmap: ILURLLog?
    let MPMPController = MPMusicPlayerController()
    let userdefaults = NSUserDefaults.standardUserDefaults()
    let progressProxy = NJKWebViewProgress()
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpWebView()
        setUpProgressProxy()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpWebView() {
        webView.scrollView.scrollEnabled = true
        webView.scalesPageToFit = true
        webView.clipsToBounds = false
        webView.scrollView.clipsToBounds = false
        webView.allowsInlineMediaPlayback = false
        webView.mediaPlaybackRequiresUserAction = true
    }
    
    func setUpProgressProxy() {
        progressProxy.webViewProxyDelegate = self
        progressProxy.progressDelegate = self
    }
    
    func addGestureRecognizers() {
        addScreenEdgePanGestureRecognizers("onSwipeRight", edge: .Left)
        addScreenEdgePanGestureRecognizers("onSwipeLeft", edge: .Right)
    }
    
    func addScreenEdgePanGestureRecognizers(selector: Selector, edge: UIRectEdge) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: selector)
        gesture.edges = edge
        view.addGestureRecognizer(gesture)
    }
    
    func subscribeToNotifications() {
        
    }
    
    func onSwipeBack() {
        
    }
}



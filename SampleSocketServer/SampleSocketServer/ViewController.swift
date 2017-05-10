//
//  ViewController.swift
//  SampleSocketServer
//
//  Created by tianshu wei on 2017/5/10.
//  Copyright © 2017年 idlebook. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var hintLabel: NSTextField!
    fileprivate lazy var serverMgr : ServerManager = ServerManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func startServer(_ sender: Any) {
        serverMgr.startRunning()
        hintLabel.stringValue = "服务器已经开启ing"
    }

    @IBAction func stopServer(_ sender: Any) {
        serverMgr.stopRunning()
        hintLabel.stringValue = "服务器未开启"
    }
}


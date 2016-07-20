//
//  ComposeModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class ComposeVC: UIViewController, ComposeUIInput, KeyboardObserver {
    
    var output: ComposeUIOutput?
    
    public lazy var contentView: ComposeView = ComposeView()
    
    let textViewDelegate = ComposeTextViewDelegate()
    
    // MARK: VC overrides
    
    override public func viewDidLoad() {
        startKeyboardObserving()
        contentView.elements.textField.delegate = textViewDelegate
        
        self.navigationItem.title = "Send text"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(self.cancelTap))
        contentView.elements.navigationBar.pushNavigationItem(self.navigationItem, animated: false)
    }
    
    override public func loadView() {
        view = contentView
    }
    
    public override func viewDidAppear(animated: Bool) {
        contentView.elements.textField.becomeFirstResponder()
    }
    
    // MARK: Events
    
    func cancelTap() {
        output!.didTapCancel()
    }

    // MARK: KeyboardObserver
    
    func willChangeKeyboardHeight(height: CGFloat) {
        contentView.bottomSpacer.snp_updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
}
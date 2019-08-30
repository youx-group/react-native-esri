//
//  Popup.swift
//  app
//
//  Created by GT4W on 8/30/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import Foundation

class Popup: UIView{
  @IBAction func closeClicked(_ sender: Any) {
    removeFromSuperview()
  }
  
  @IBAction func continueClicked(_ sender: Any) {
    continueFunction()
  }
  
  @IBOutlet var continueButton: UIButton!
  @IBOutlet var closeButton: UIButton!
  
  @IBOutlet var popupDescription: UILabel!
  @IBOutlet var popupTitle: UILabel!
  @IBOutlet var background: UIView!
  
  private var continueFunction: () -> Void = {() -> Void in print("Called") }
  
  init(frame: CGRect, title: String, description:String, closeText:String, continueText:String, continueCallback:  @escaping () -> Void) {
    super.init(frame:frame)
    setupNib(title:title, description:description, closeText: closeText, continueText: continueText)
    continueFunction = continueCallback
  }
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    setupNib()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setupNib()
  }
  
  private func setupNib( title: String? = "", description:String? = "", closeText:String? = "", continueText:String? = "")
  {
    let nibView = Bundle.main.loadNibNamed("Popup", owner: self, options: nil)?.last as! UIView
    addSubview(nibView)
    
    let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.dismiss))
    background.addGestureRecognizer(gesture)
    
    continueButton.setTitle(continueText, for: .normal)
    closeButton.setTitle(closeText, for: .normal)
    
    popupDescription.text = description
    popupTitle.text = title
  }
  @objc func dismiss(sender : UITapGestureRecognizer) {
    removeFromSuperview()
  }
}

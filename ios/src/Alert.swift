//
//  Alert.swift
//  app
//
//  Created by GT4W on 8/30/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation

public class Alert {
  let title: String
  let description: String
  let closeText: String
  let continueText: String
  
  init(_title: String, _description: String, _closeText:String, _continueText:String)
  {
    self.title = _title
    self.description = _description
    self.closeText = _closeText
    self.continueText = _continueText
  }
  
  init(rawData:NSDictionary)
  {
    self.title = rawData["title"] as! String
    self.description = rawData["description"] as! String
    self.closeText = rawData["closeText"] as! String
    self.continueText = rawData["continueText"] as! String
  }
}

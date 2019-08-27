//
//  RNEsriFeatureLayer.swift
//  app
//
//  Created by GT4W on 8/26/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import ArcGIS
import Foundation
import UIColor_Hex_Swift

class RNEsriFeatureLayer: AGSFeatureLayer {
  let referenceId: NSString
  
  init(rawData: NSDictionary) {
    if let url = rawData["url"] as! String?
    {
      let initialLineSymbol : AGSSimpleLineSymbol = AGSSimpleLineSymbol(style: AGSSimpleLineSymbolStyle.null, color: UIColor("#000000"), width: 1.0)
      let simpleFillSymbol : AGSSimpleFillSymbol = AGSSimpleFillSymbol(style: AGSSimpleFillSymbolStyle.null, color: UIColor("#000000"), outline: initialLineSymbol)
      
      if let outline = rawData["outline"] as? String
      {
        let outlineColor : UIColor = UIColor(outline)
        let lineSymbol : AGSSimpleLineSymbol = AGSSimpleLineSymbol(style: AGSSimpleLineSymbolStyle.solid, color: outlineColor, width: 1.0)
        simpleFillSymbol.outline = lineSymbol
      }
      
      if let fill = rawData["fill"] as? String
      {
        let fillColor : UIColor = UIColor(fill)
        simpleFillSymbol.style = AGSSimpleFillSymbolStyle.solid
        simpleFillSymbol.color = fillColor
      }
      
      let featureTable = AGSServiceFeatureTable(url: URL(string: url)!)
      featureTable.featureRequestMode = AGSFeatureRequestMode.onInteractionCache
      let simpleRenderer : AGSSimpleRenderer = AGSSimpleRenderer(symbol: simpleFillSymbol);
      
      if let referenceIdRaw = rawData["referenceId"] as? NSString
      {
         self.referenceId = referenceIdRaw
      }
      else
      {
        fatalError("Invalid referenceId for feature layer!")
      }
     
      super.init(featureTable: featureTable)
      self.renderer = simpleRenderer
      
    }
    else
    {
      fatalError("Invalid URL for feature layer!")
    }
  }
}

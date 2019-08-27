//
//  RNEsriFeatureLayer.swift
//  app
//
//  Created by GT4W on 8/26/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import ArcGIS
import Foundation

class RNEsriFeatureLayer: AGSFeatureLayer {
  init(url: String) {
    let featureTable = AGSServiceFeatureTable(url: URL(string: url)!)
    featureTable.featureRequestMode = AGSFeatureRequestMode.onInteractionCache
    super.init(featureTable: featureTable)
  }
}

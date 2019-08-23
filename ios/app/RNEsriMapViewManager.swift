//
//  RNEsriMapViewManager.swift
//  app
//
//  Created by GT4W on 8/23/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import ArcGIS


@objc(RNEsriMapViewManager)
class RNEsriMapViewManager: RCTViewManager {
  var agsMapView: RNEsriMapView?
  
  override public func view() -> UIView! {
    if (agsMapView == nil) {
      agsMapView = RNEsriMapView()
      agsMapView!.bridge = self.bridge
    }
    return agsMapView!
  }
  
  override public class func requiresMainQueueSetup() -> Bool {
    return true;
  }
  
  // MARK: Exposed Obj-C bridging functions
  @objc func showCalloutViaManager(_ node: NSNumber, args: NSDictionary) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.showCallout(args)
    }
  }
  
  @objc func centerMapViaManager(_ node: NSNumber, args: NSArray) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.centerMap(args)
    }
  }
  
  @objc func addGraphicsOverlayViaManager(_ node: NSNumber, args: NSDictionary) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.addGraphicsOverlay(args)
    }
  }
  
  @objc func addPointsToOverlayViaManager(_ node: NSNumber, args: NSDictionary) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.addPointsToGraphicsOverlay(args)
    }
  }
  
  @objc func removePointsFromOverlayViaManager(_ node: NSNumber, args: NSDictionary) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.removePointsFromGraphicsOverlay(args)
    }
  }
  
  @objc func removeGraphicsOverlayViaManager(_ node: NSNumber, args: NSString) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.removeGraphicsOverlay(args)
    }
  }
  
  @objc func updatePointsInGraphicsOverlayViaManager(_ node: NSNumber, args: NSDictionary) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.updatePointsInGraphicsOverlay(args)
    }
  }
  
  @objc func routeGraphicsOverlayViaManager(_ node: NSNumber, args: NSDictionary) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.routeGraphicsOverlay(args)
    }
  }
  
  @objc func setRouteIsVisibleViaManager(_ node: NSNumber, args: ObjCBool) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.setRouteIsVisible(args.boolValue)
    }
  }
  
  @objc func getRouteIsVisibleViaManager(_ node: NSNumber, args: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async {
      let component = self.bridge.uiManager.view(forReactTag: node) as! RNEsriMapView
      component.getRouteIsVisible(args)
    }
  }
  
  @objc func dispose(_ node: NSNumber) {
    self.agsMapView?.graphicsOverlays.removeAllObjects()
    self.agsMapView?.map = nil
    self.agsMapView = nil
  }
  
  @objc func setLicenseKey(_ key: String) {
    do {
      try AGSArcGISRuntimeEnvironment.setLicenseKey(key)
    }
    catch let error as NSError {
      print("error: \(error)")
    }
  }
}

@objc(RNEsriMapViewModule)
public class RNEsriMapViewModule: RCTEventEmitter {
  
  // MARK: Event emitting to JS
  @objc func sendIsRoutingChanged(_ value: Bool) {
    sendEvent(withName: "isRoutingChanged", body: [value])
  }
  
  
  // MARK: Overrides
  
  override public func supportedEvents() -> [String]! {
    return ["isRoutingChanged"]
  }
  
  @objc override public static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  override public func constantsToExport() -> [AnyHashable : Any]! {
    return [:]
  }
}

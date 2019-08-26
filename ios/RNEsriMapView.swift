//
//  RNEsriMapView.swift
//  app
//
//  Created by GT4W on 8/23/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import ArcGIS
import Foundation
import UIColor_Hex_Swift

@objc(RNEsriMapView)
public class RNEsriMapView: AGSMapView, AGSGeoViewTouchDelegate {
  var routeGraphicsOverlay = AGSGraphicsOverlay()
  var router: RNEsriRouter?
  var bridge: RCTBridge?
  // MARK: Initializers and helper methods
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUpMap()
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpMap()
  }
  
  func setUpMap() {
    self.map = AGSMap(basemapType: .streetsVector, latitude: 0, longitude: 0, levelOfDetail: 0)
    
    self.map?.load(completion: {[weak self] (error) in
      if (self?.onMapDidLoad != nil){
        var reactResult: [AnyHashable: Any] = ["success" : error != nil]
        if (error != nil) {
          reactResult["errorMessage"] = error!.localizedDescription
        }
        self?.onMapDidLoad!(reactResult)
      }
    })
    self.touchDelegate = self
    self.graphicsOverlays.add(routeGraphicsOverlay)
  }
  
  @objc var initialMapCenter: NSDictionary? {
    didSet{
      if let rawData = initialMapCenter {
        self.setViewpoint(AGSViewpoint(latitude: rawData["latitude"] as! Double, longitude: rawData["longitude"] as! Double, scale: 1500000 * (rawData["scale"] as! Double)), duration: 2, completion: nil)
      }
    }
  }
  
  // MARK: Native methods
  @objc public func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
    self.callout.dismiss()
    if onSingleTap != nil {
      let latLongPoint = AGSGeometryEngine.projectGeometry(mapPoint, to: AGSSpatialReference.wgs84()) as! AGSPoint
      var reactResult: [AnyHashable: Any] = [
        "mapPoint": ["latitude" : latLongPoint.y, "longitude": latLongPoint.x],
        "screenPoint" : ["x": screenPoint.x, "y": screenPoint.y]
      ]
      self.identifyGraphicsOverlays(atScreenPoint: screenPoint, tolerance: 15, returnPopupsOnly: false) { [weak self] (result, error) in
        if let error = error {
          reactResult["success"] = false
          reactResult["errorMessage"] = error.localizedDescription
        } else {
          reactResult["success"] = true
        }
        guard let result = result, !result.isEmpty else {
          self?.onSingleTap!(reactResult)
          return
        }
        for item in result {
          if item.graphicsOverlay is RNEsriGraphicsOverlay, let closestGraphic = item.graphics.first, let referenceId = closestGraphic.attributes["referenceId"] as? NSString{
            reactResult["graphicReferenceId"] = referenceId
            if self?.recenterIfGraphicTapped ?? false {
              self?.setViewpointCenter(mapPoint, completion: nil)
            }
          }
        }
        self?.onSingleTap!(reactResult)
      }
    }
  }
  
  public func geoView(_ geoView: AGSGeoView, didTouchDragToScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
    if let onMapMoved = onMapMoved {
      let reactResult: [AnyHashable: Any] = [
        "mapPoint" : ["latitude" : mapPoint.y, "longitude": mapPoint.x],
        "screenPoint" : ["x": screenPoint.x, "y": screenPoint.y]
      ]
      onMapMoved(reactResult)
    }
  }
  
  // MARK: Exposed RN Event Emitters
  @objc var onSingleTap: RCTDirectEventBlock?
  @objc var onMapDidLoad: RCTDirectEventBlock?
  @objc var onOverlayWasModified: RCTDirectEventBlock?
  @objc var onOverlayWasAdded: RCTDirectEventBlock?
  @objc var onOverlayWasRemoved: RCTDirectEventBlock?
  @objc var onMapMoved: RCTDirectEventBlock?
  
  // MARK: Exposed RN methods
  @objc func showCallout(_ args: NSDictionary) {
    let point = args["point"] as? NSDictionary
    guard let latitude = point?["latitude"] as? NSNumber, let longitude = point?["longitude"] as? NSNumber,
      let title = args["title"] as? NSString, let text = args["text"] as? NSString, let shouldRecenter = args["shouldRecenter"] as? Bool
      else {
        print("WARNING: The point object did not contian a proper latitude and longitude.")
        return
    }
    let agsPoint = AGSPoint(x: longitude.doubleValue, y: latitude.doubleValue, spatialReference: AGSSpatialReference.wgs84())
    self.callout.title = String(title)
    self.callout.detail = String(text)
    self.callout.isAccessoryButtonHidden = true
    if shouldRecenter {
      self.setViewpointCenter(agsPoint) { [weak self](_) in
        self?.callout.show(at: agsPoint, screenOffset: CGPoint.zero, rotateOffsetWithMap: false, animated: true)
      }
    } else {
      self.callout.show(at: agsPoint, screenOffset: CGPoint.zero, rotateOffsetWithMap: false, animated: true)
    }
  }
  
  @objc func centerMap(_ args: NSDictionary) {
    var point: AGSPoint
    if let latitude = args["latitude"] as? NSNumber, let longitude = args["longitude"] as? NSNumber {
      point = (AGSPoint(x: longitude.doubleValue, y: latitude.doubleValue, spatialReference: AGSSpatialReference.wgs84()))
      self.setViewpointCenter(point, completion: nil)
    }
  }
  
  @objc func addGraphicsOverlay(_ args: NSDictionary) {
    let rnRawGraphicsOverlay = RNEsriGraphicsOverlay(rawData: args)
    self.graphicsOverlays.add(rnRawGraphicsOverlay)
    if (onOverlayWasAdded != nil) {
      onOverlayWasAdded!([NSString(string: "referenceId"): rnRawGraphicsOverlay.referenceId]);
    }
  }
  
  @objc func addPointsToGraphicsOverlay(_ args: NSDictionary) {
    guard let name = args["overlayReferenceId"] as? NSString,  let overlay = getOverlay(byReferenceId: name) else {
      print("WARNING: Invalid layer name entered. No points will be added.")
      reportToOverlayDidLoadListener(referenceId: args["overlayReferenceId"] as? NSString ?? NSString(string:"unknown"), action: "add", success: false, errorMessage: "Invalid layer name entered.")
      return
    }
    guard let rawPointsCasted = args["points"] as? [NSDictionary] else {
      print("WARNING: No reference IDs provided. No points will be added.")
      reportToOverlayDidLoadListener(referenceId: name, action: "add", success: false, errorMessage: "No reference IDs provided.")
      
      return
    }
    // Create point image dictionary
    var pointImageDictionary: [NSString: UIImage] = [:]
    if let pointGraphics = args["pointGraphics"] as? [NSDictionary] {
      for item in pointGraphics {
        if let graphicId = item["graphicId"] as? NSString, let graphic = RCTConvert.uiImage(item["graphic"]) {
          pointImageDictionary[graphicId] = graphic
        }
      }
    }
    for item in rawPointsCasted {
      let point = Point(rawData: item)
      let graphic = point.toAGSGraphic(pointImageDictionary: pointImageDictionary)
      overlay.graphics.add(graphic)
      
    }
    reportToOverlayDidLoadListener(referenceId: name, action: "add", success: true, errorMessage: nil)
  }
  
  @objc func removePointsFromGraphicsOverlay(_ args: NSDictionary) {
    guard let name = args["overlayReferenceId"] as? NSString,  let overlay = getOverlay(byReferenceId: name) else {
      print("WARNING: Invalid layer name entered. No points will be removed.")
      reportToOverlayDidLoadListener(referenceId: args["overlayReferenceId"] as? NSString ?? NSString(string:"unknown"), action: "remove", success: false, errorMessage: "Invalid layer name entered.")
      return
    }
    guard let pointsToRemove = args["referenceIds"] as? [NSString] else {
      print("WARNING: No reference IDs provided. No points will be removed.")
      reportToOverlayDidLoadListener(referenceId: name, action: "remove", success: false, errorMessage: "No reference IDs provided.")
      return
    }
    for graphic in overlay.graphics as! [AGSGraphic] {
      let id = graphic.attributes["referenceId"] as! NSString
      if pointsToRemove.contains(id) {
        overlay.graphics.remove(graphic)
      }
    }
    reportToOverlayDidLoadListener(referenceId: name, action: "remove", success: true, errorMessage: nil)
  }
  
  @objc func updatePointsInGraphicsOverlay(_ args: NSDictionary) {
    guard let name = args["overlayReferenceId"] as? NSString,  let overlay = getOverlay(byReferenceId: name) else  {
      print("WARNING: Invalid layer name entered. No points will be modified.")
      reportToOverlayDidLoadListener(referenceId: args["overlayReferenceId"] as? NSString ?? NSString(string: "Unknown"), action: "update", success: false, errorMessage: "Invalid layer name entered.")
      return
    }
    let shouldAnimateUpdate = (args["animated"] as? Bool) ?? false
    overlay.shouldAnimateUpdate = shouldAnimateUpdate
    if let updates = args["updates"] as? [NSDictionary] {
      for update in updates {
        overlay.updateGraphic(with: update)
      }
    }
    reportToOverlayDidLoadListener(referenceId: args["overlayReferenceId"] as! NSString, action: "update", success: true, errorMessage: nil)
  }
  
  @objc func removeGraphicsOverlay(_ name: NSString) {
    guard let overlay = getOverlay(named: name) else {
      print("WARNING: Invalid layer name entered. No overlay will be removed.")
      return
    }
    self.graphicsOverlays.remove(overlay)
    if (onOverlayWasRemoved != nil) {
      onOverlayWasRemoved!([NSString(string: "referenceId"): name])
    }
  }
  
  @objc func routeGraphicsOverlay(_ args: NSDictionary) {
    guard let router = router else {
      print ("RNAGSMapView - WARNING: No router was initialized. Perhaps no routeUrl was provided?")
      return
    }
    guard let name = args["overlayReferenceId"] as? NSString,  let overlay = getOverlay(byReferenceId: name) else {
      print("RNAGSMapView - WARNING: Invalid layer name entered. No overlay will be routed.")
      return
    }
    let excludeGraphics = args["excludeGraphics"] as? [NSString]
    let color = UIColor(String(args["routeColor"] as? NSString ?? "#FF0000"))
    //let color = UIColor(hex: String(args["routeColor"] as? NSString ?? "#FF0000"))!
    let module = self.bridge!.module(forName: "RNEsriMapViewModule") as! RNEsriMapViewModule
    module.sendIsRoutingChanged(true)
    router.createRoute(withGraphicOverlay: overlay, excludeGraphics: excludeGraphics) { [weak self] (result, error) in
      if let error = error {
        module.sendIsRoutingChanged(false)
        print("RNAGSMapView - WARNING: Error while routing: \(error.localizedDescription)")
        return
      }
      guard let result = result else {
        module.sendIsRoutingChanged(false)
        print("RNAGSMapView - WARNING: No result obtained.")
        return
      }
      // TODO: Draw routes onto graphics overlay
      print("RNAGSMapView - Route Completed")
      let generatedRoute = result.routes[0]
      self?.draw(route: generatedRoute, with: color)
      module.sendIsRoutingChanged(false)
      
    }
  }
  
  
  
  @objc func getRouteIsVisible(_ args: RCTResponseSenderBlock) {
    args([routeGraphicsOverlay.isVisible])
  }
  
  @objc func setRouteIsVisible(_ args: Bool){
    routeGraphicsOverlay.isVisible = args
  }
  
  // MARK: Exposed RN props
  @objc var basemapUrl: NSString? {
    didSet{
      // TODO: allow for basemap name to be passed depending on enum
      let basemapUrlString = String(basemapUrl ?? "")
      if (self.map == nil) {
        setUpMap()
      }
      if let url = URL(string: basemapUrlString), let basemap = AGSBasemap(url: url){
        basemap.load { [weak self] (error) in
          if let error = error {
            print(error.localizedDescription)
          } else {
            self?.map?.basemap = basemap
          }
        }
      } else {
        print("==> Warning: Invalid Basemap URL Provided. A stock basemap will be used. <==")
      }
    }
  }
  
  @objc var recenterIfGraphicTapped: Bool = false
  
  @objc var routeUrl: NSString? {
    didSet {
      if let routeUrl = URL(string: String(routeUrl ?? "")) {
        router = RNEsriRouter(routeUrl: routeUrl)
      }
    }
  }
  
  @objc var minZoom:NSNumber = 0 {
    didSet{
      self.map?.minScale = minZoom.doubleValue
    }
  }
  
  @objc var maxZoom:NSNumber = 0 {
    didSet{
      self.map?.maxScale = maxZoom.doubleValue
    }
  }
  
  @objc var rotationEnabled = true{
    didSet{
      self.interactionOptions.isRotateEnabled = rotationEnabled
    }
  };
  
  // MARK: Misc.
  private func getOverlay(byReferenceId referenceId: NSString?) -> RNEsriGraphicsOverlay? {
    if let referenceId = referenceId {
      return self.graphicsOverlays.first(where: {
        if $0 is RNEsriGraphicsOverlay {
          return ($0 as! RNEsriGraphicsOverlay).referenceId == referenceId
        } else {
          return false
        }
      }) as? RNEsriGraphicsOverlay
    } else {
      return nil
    }
  }
  
  func reportToOverlayDidLoadListener(referenceId: NSString, action: NSString, success: Bool, errorMessage: NSString?){
    if (onOverlayWasModified != nil) {
      var reactResult: [AnyHashable: Any] = [
        "referenceId" : referenceId, "action": action, "success": success
      ]
      if let errorMessage = errorMessage {
        reactResult["errorMessage"] = errorMessage
      }
      onOverlayWasModified!(reactResult)
    }
  }
  private func getOverlay(named name: NSString) -> RNEsriGraphicsOverlay?{
    return self.graphicsOverlays.first(where: { (item) -> Bool in
      guard let item = item as? RNEsriGraphicsOverlay else {
        return false
      }
      return item.referenceId == name
    }) as? RNEsriGraphicsOverlay
  }
  
  private func draw(route: AGSRoute, with color: UIColor){
    DispatchQueue.main.async {
      self.routeGraphicsOverlay.graphics.removeAllObjects()
      let routeSymbol = AGSSimpleLineSymbol(style: .solid, color: color, width: 5)
      let routeGraphic = AGSGraphic(geometry: route.routeGeometry, symbol: routeSymbol, attributes: nil)
      self.routeGraphicsOverlay.graphics.add(routeGraphic)
    }
  }
}

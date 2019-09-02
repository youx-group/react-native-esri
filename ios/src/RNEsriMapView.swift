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
  @objc var onSingleTap: RCTDirectEventBlock?
  @objc var onTapPopupButton: RCTDirectEventBlock?
  @objc var onMapDidLoad: RCTDirectEventBlock?
  @objc var onMapMoved: RCTDirectEventBlock?
  
  @objc var onOverlayWasModified: RCTDirectEventBlock?
  @objc var onOverlayWasAdded: RCTDirectEventBlock?
  @objc var onOverlayWasRemoved: RCTDirectEventBlock?
  
  @objc var onFeatureLayerWasAdded: RCTDirectEventBlock?
  @objc var onFeatureLayerWasRemoved: RCTDirectEventBlock?
  
  
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
    self.map = AGSMap(basemapType: .streetsNightVector, latitude: 0, longitude: 0, levelOfDetail: 0)
    
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
          if item.graphicsOverlay is RNEsriGraphicsOverlay
          {
            if self?.recenterIfGraphicTapped ?? false {
              self?.setViewpointCenter(mapPoint, completion: nil)
              if let alert = item.graphics.first?.attributes["alert"] as! Alert? {
                let event: [AnyHashable: Any?] = [
                  "referenceId": item.graphics.first?.attributes["referenceId"]
                ]
                let popup = Popup(frame: UIScreen.main.bounds, title: alert.title, description:alert.description, closeText: alert.closeText, continueText:alert.continueText, continueCallback: { () in self?.onTapPopupButton!(event as [AnyHashable: Any]) })
                let window = UIApplication.shared.windows.last
                window?.addSubview(popup)
              }
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
    if let latitude = args["latitude"] as! Double?, let longitude = args["longitude"] as! Double?
    {
      if let scale = args["scale"] as! Double?, let duration = args["duration"] as! Double?{
        self.setViewpoint(AGSViewpoint(latitude: latitude, longitude: longitude, scale: 1500000 * (scale)), duration: duration, completion: nil)
      }
      else
      {
        self.setViewpointCenter(AGSPoint(x: latitude, y: longitude, spatialReference: AGSSpatialReference.wgs84()), completion: nil)
      }
    }
  }
  
  @objc func addFeatureLayer(_ args: NSDictionary) {
    let rnFeatureLayer = RNEsriFeatureLayer(rawData: args)
    self.map!.operationalLayers.add(rnFeatureLayer)
    if (onFeatureLayerWasAdded != nil) {
      onFeatureLayerWasAdded!([NSString(string: "referenceId"): rnFeatureLayer.referenceId]);
    }
  }
  
  @objc func removeFeatureLayer(_ name: NSString) {
    guard let overlay = getFeatureLayer(named: name) else {
      print("WARNING: Invalid feature layer name entered. No overlay will be removed.")
      return
    }
    self.map!.operationalLayers.remove(overlay)
    if (onFeatureLayerWasRemoved != nil) {
      onFeatureLayerWasRemoved!([NSString(string: "referenceId"): name])
    }
  }
  
  @objc func addGraphicsOverlay(_ args: NSDictionary) {
    let rnRawGraphicsOverlay = RNEsriGraphicsOverlay(rawData: args)
    self.graphicsOverlays.add(rnRawGraphicsOverlay)
    if (onOverlayWasAdded != nil) {
      onOverlayWasAdded!([NSString(string: "referenceId"): rnRawGraphicsOverlay.referenceId]);
    }
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
  
  private func getFeatureLayer(named name:NSString) -> RNEsriFeatureLayer? {
    return self.map!.operationalLayers.first(where: { (item) -> Bool in
      guard let item = item as? RNEsriFeatureLayer else {
        return false
      }
      return item.referenceId == name
    }) as? RNEsriFeatureLayer
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

//
//  RNEsriMapViewManager.m
//  app
//
//  Created by GT4W on 8/23/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(RNEsriMapViewManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(basemapUrl, NSString)
RCT_EXPORT_VIEW_PROPERTY(routeUrl, NSString)
RCT_EXPORT_VIEW_PROPERTY(initialMapCenter, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(recenterIfGraphicTapped, BOOL)
RCT_EXPORT_VIEW_PROPERTY(minZoom, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(maxZoom, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(rotationEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onSingleTap, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMapDidLoad, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(onOverlayWasModified, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onOverlayWasAdded, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onOverlayWasRemoved, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(onFeatureLayerWasAdded, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFeatureLayerWasRemoved, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(onMapMoved, RCTDirectEventBlock)


// MARK: External method exports (these can be called from react via a reference)
RCT_EXTERN_METHOD(addFeatureLayerViaManager:(nonnull NSNumber*) node args:(NSDictionary*)args)
RCT_EXTERN_METHOD(removeFeatureLayerViaManager:(nonnull NSNumber*) node args:(NSString*) args)

RCT_EXTERN_METHOD(showCalloutViaManager:(nonnull NSNumber*)node args:(NSDictionary*)args)
RCT_EXTERN_METHOD(centerMapViaManager:(nonnull NSNumber*)node args:(NSDictionary*)args)

RCT_EXTERN_METHOD(addGraphicsOverlayViaManager:(nonnull NSNumber*) node args:(NSDictionary*)args)
RCT_EXTERN_METHOD(removeGraphicsOverlayViaManager:(nonnull NSNumber*) node args:(NSString*) args)

RCT_EXTERN_METHOD(routeGraphicsOverlayViaManager:(nonnull NSNumber*) node args:(NSDictionary*)args)
RCT_EXTERN_METHOD(routeIsShowing:(nonnull NSNumber*) node callback: (RCTResponseSenderBlock*)callback)
RCT_EXTERN_METHOD(setRouteIsVisibleViaManager:(nonnull NSNumber*) node args:(BOOL*) args)
RCT_EXTERN_METHOD(getRouteIsVisibleViaManager:(nonnull NSNumber*) node args:(BOOL*) args)
RCT_EXTERN_METHOD(setLicenseKey:(nonnull NSString*)key)

RCT_EXTERN_METHOD(dispose:(nonnull NSNumber*) node)
@end

@interface RCT_EXTERN_MODULE(RNEsriMapViewModule, RCTEventEmitter)
RCT_EXTERN_METHOD(sendIsRoutingChanged: (BOOL*)value)
@end

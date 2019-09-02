//  Created by react-native-create-bridge

import React from 'react'
import { NativeEventEmitter, Platform, requireNativeComponent, NativeModules, UIManager, findNodeHandle, DeviceEventEmitter } from 'react-native'
import PropTypes from 'prop-types'

let AGSMap;
let moduleName;
if (Platform.OS === 'ios') {
  AGSMap = requireNativeComponent('RNEsriMapView', RNEsriMapView);
  moduleName = 'RNEsriMapView';
} else {
  AGSMap = requireNativeComponent('RNArcGISMapView', ArcGISMapView);
  moduleName = 'RNArcGISMapView';
}

class ArcGISMapView extends React.Component {
  constructor(props) {
    super(props);
    let eventEmitter;
    if (Platform.OS === 'ios') {
      eventEmitter = new NativeEventEmitter(NativeModules.RNEsriMapViewModule);
    } else {
      eventEmitter = DeviceEventEmitter;
    }
    eventEmitter.addListener('isRoutingChanged', this.props.onRoutingStatusUpdate);
  }

  // MARK: Props
  static propTypes = {
    basemapUrl: PropTypes.string,
    initialMapCenter: PropTypes.arrayOf(PropTypes.object),
    minZoom: PropTypes.number,
    maxZoom: PropTypes.number,
    rotationEnabled: PropTypes.bool,
    routeUrl: PropTypes.string,
    onOverlayWasAdded: PropTypes.func,
    onOverlayWasRemoved: PropTypes.func,
    onOverlayWasModified: PropTypes.func,
    onMapDidLoad: PropTypes.func,
    onMapMoved: PropTypes.func,
    onSingleTap: PropTypes.func,
    addFeatureLayer: PropTypes.arrayOf(PropTypes.object),
    onTapPopupButton: PropTypes.func,
  };

  static defaultProps = {
    initialMapCenter: [
      { latitude: -30.304790, longitude: -53.286374, scale: 7 }
    ],
    minZoom: 0,
    maxZoom: 0,
    rotationEnabled: true,
    basemapUrl: '',
    onSingleTap: () => { },
    onOverlayWasAdded: () => { },
    onOverlayWasRemoved: () => { },
    onOverlayWasModified: () => { },
    onMapDidLoad: () => { },
    onMapMoved: () => { },
    onRoutingStatusUpdate: () => { },
    onTapPopupButton: () => { },
    routeUrl: '',
    addFeatureLayer: [{
      url: '',
      outlineColor: '',
      fillColor: ''
    }]
  };

  isRouting = false;

  // MARK: Exposed native methods
  showCallout = (args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.showCalloutViaManager,
      [args]
    );
  };

  recenterMap = (pointArray) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.centerMapViaManager,
      [pointArray]
    );
  }

  addGraphicsOverlay = (overlayData) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.addGraphicsOverlayViaManager,
      [overlayData]
    );
  }

  removeGraphicsOverlay = (overlayId) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.removeGraphicsOverlayViaManager,
      [overlayId]
    );
  }

  addPointsToOverlay = (args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.addPointsToOverlayViaManager,
      [args]
    );
  }

  updatePointsOnOverlay = (args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.updatePointsInGraphicsOverlayViaManager,
      [args]
    );
  }

  removePointsFromOverlay = (args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.removePointsFromOverlayViaManager,
      [args]
    );
  }

  routeGraphicsOverlay = (args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.routeGraphicsOverlayViaManager,
      [args]
    );
  }

  getRouteIsVisible = (callback) => {
    if (Platform.OS === 'ios') {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.agsMapRef),
        UIManager.getViewManagerConfig(moduleName).Commands.getRouteIsVisibleViaManager,
        [callback]
      );
    } else {
      NativeModules.RNArcGISMapViewManager.getRouteIsVisible(findNodeHandle(this.agsMapRef), callback);
    }
  };

  setRouteIsVisible = (args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.setRouteIsVisibleViaManager,
      [args]
    );
  }

  addFeatureLayer = args => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.addFeatureLayerViaManager,
      [args]
    );
  };


  // MARK: Render
  render() {
    return <AGSMap {...this.props} ref={e => this.agsMapRef = e} />
  }

  // MARK: Disposal
  componentWillUnmount() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig(moduleName).Commands.dispose,
      [args]
    );
  }
}

export const setLicenseKey = (string) => {
  if (Platform.OS === 'ios') {
    NativeModules.RNEsriMapViewManager.setLicenseKey(string);
  } else {
    NativeModules.RNArcGISMapViewManager.setLicenseKey(string);
  }

};

export default ArcGISMapView;
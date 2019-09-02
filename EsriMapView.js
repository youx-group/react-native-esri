import PropTypes from 'prop-types';
import React from 'react';
import {
  DeviceEventEmitter,
  findNodeHandle,
  NativeEventEmitter,
  NativeModules,
  Platform,
  requireNativeComponent,
  UIManager
} from 'react-native';
const AGSMap = requireNativeComponent('RNEsriMapView', RNEsriMapView);

class RNEsriMapView extends React.Component {
  constructor(props) {
    super(props);
    var eventEmitter;
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
  showCallout = args => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.showCalloutViaManager,
      [args]
    );
  };

  recenterMap = pointArray => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.centerMapViaManager,
      [pointArray]
    );
  };

  addFeatureLayer = featureData => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.addFeatureLayerViaManager,
      [featureData]
    );
  };

  removeFeatureLayer = featureId => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.removeFeatureLayerViaManager,
      [featureId]
    );
  };

  addGraphicsOverlay = overlayData => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.addGraphicsOverlayViaManager,
      [overlayData]
    );
  };

  removeGraphicsOverlay = overlayId => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.removeGraphicsOverlayViaManager,
      [overlayId]
    );
  };

  routeGraphicsOverlay = args => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.routeGraphicsOverlayViaManager,
      [args]
    );
  };

  getRouteIsVisible = callback => {
    if (Platform.OS === 'ios') {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.agsMapRef),
        UIManager.getViewManagerConfig('RNEsriMapView').Commands.getRouteIsVisibleViaManager,
        [callback]
      );
    } else {
      NativeModules.RNEsriMapViewManager.getRouteIsVisible(
        findNodeHandle(this.agsMapRef),
        callback
      );
    }
  };

  setRouteIsVisible = args => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.setRouteIsVisibleViaManager,
      [args]
    );
  };

  // MARK: Render
  render() {
    return <AGSMap {...this.props} ref={e => (this.agsMapRef = e)} />;
  }

  // MARK: Disposal
  componentWillUnmount() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.agsMapRef),
      UIManager.getViewManagerConfig('RNEsriMapView').Commands.dispose,
      [args]
    );
  }
}

export const setLicenseKey = string => {
  NativeModules.RNEsriMapViewManager.setLicenseKey(string);
};

export default RNEsriMapView;

import React from 'react';
import { Image, View } from 'react-native';
import EsriMapView, { setLicenseKey } from './EsriMapView';

const overlay1 = {
  referenceId: 'overlay1',
  pointGraphics: [
    {
      graphicId: 'point',
      graphic: Image.resolveAssetSource(require('./marker.png'))
    }
  ],
  points: [
    {
      latitude: 45.51223,
      longitude: -122.658722,
      rotation: 0,
      graphicId: 'point'
    },
    {
      latitude: 38.907192,
      longitude: -77.036873,
      rotation: 0,
      referenceId: '2',
      graphicId: 'point'
    },
    {
      latitude: 39.739235,
      longitude: -104.99025,
      rotation: 0,
      referenceId: '3',
      graphicId: 'point'
    }
  ],

  lines: [
    {
      points: [
        { latitude: 109.6875, longitude: 11.523087506868514 },
        { latitude: 69.9609375, longitude: 68.13885164925573 }
      ],
      outline: '#00FF00'
    }
  ],
  polygons: [
    {
      points: [
        { latitude: -64.68751, longitude: 12.89748 },
        { latitude: 46.40625, longitude: 38.82259 },
        { latitude: 7.03125, longitude: 62.10388 },
        { latitude: -64.68751, longitude: 12.89748 }
      ],
      color: '#0000FF',
      outline: '#FF0000'
    }
  ]
};

class App extends React.Component {
  constructor(props) {
    super(props);
    setLicenseKey('');
  }
  componentDidMount() {
    this.mapView.addGraphicsOverlay(overlay1);
  }
  render() {
    return (
      <View style={{ flex: 1 }}>
        <EsriMapView
          ref={mapView => (this.mapView = mapView)}
          style={{ width: '100%', height: '100%' }}
          initialMapCenter={{ latitude: -30.30479, longitude: -53.286374, scale: 7 }}
          recenterIfGraphicTapped={true}
          rotationEnabled={false}
          mapBasemap={{ type: 'normal' }}
        />
      </View>
    );
  }
}

export default App;

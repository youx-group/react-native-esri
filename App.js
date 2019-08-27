import React from 'react';
import { View } from 'react-native';
import ArcGISMapView from './AGSMapView'

const App = () => {
  return (
    <View style={{ flex: 1 }}>
      <ArcGISMapView
        ref={mapView => this.mapView = mapView}
        style={{ flex: 1 }}
        initialMapCenter={[{ latitude: -30.304790, longitude: -53.286374, initialZoom: 6, fill: false }]}
        recenterIfGraphicTapped={true}
        rotationEnabled={false}
        mapBasemap={{ type: 'normal' }}
      />
    </View>
  );
};

export default App;

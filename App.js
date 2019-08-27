import React from 'react';
import { View, Image, Button } from 'react-native';
import ArcGISMapView, { setLicenseKey } from './AGSMapView';

class App extends React.Component {
  constructor(props) {
    super(props);
    setLicenseKey('runtimelite,1000,rud1919843927,none,ZZ0RJAY3FLJ5EBZNR193');
  }

  async componentDidMount() {
    const response = await fetch('http://homologacao.grd.geotech4web.com.br/public/ocorrencia/ativas/geojson');
    let responseJson = await response.json();

    let overlay = {};
    let points = [];
    let point = {}

    responseJson.features.forEach((coord, index) => {
      point.latitude = coord.geometry.coordinates[0];
      point.longitude = coord.geometry.coordinates[1];
      point.graphicId = coord.geometry.type.toLowerCase();
      point.referenceId = String(index);
      points.push(point);
      point = {};
    });

    overlay = {
      referenceId: 'overlay1',
      pointGraphics: [
        {
          graphicId: 'point',
          graphic: Image.resolveAssetSource(require('./marker.png'))
        }
      ],
      points,
    }

    this.mapView.addGraphicsOverlay(overlay);
    this.mapView.addFeatureLayer(url)
  }

  render() {
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
        <Button
          title='layer'
          onPress={() => {
            this.mapView.addFeatureLayer(url);
          }}
        ></Button>

      </View >
    );
  }
};

const url = {
  url: 'http://sistemas.gt4w.com.br/arcgis/rest/services/rs/MunicipiosRS/MapServer/0/',
  outlineColor: '#000000',
}

export default App;

import React from 'react';
import { Button, Image, SafeAreaView, View } from 'react-native';
import EsriMapView, { setLicenseKey } from './EsriMapView';

const overlay2 = {
  referenceId: 'overlay2',
  polygons: [
    {
      points: [
        { longitude: -55.294189453125, latitude: -29.983486718474694 },
        { longitude: -51.910400390625, latitude: -30.12612436422458 },
        { longitude: -52.28393554687499, latitude: -28.488005204159457 },
        { longitude: -55.294189453125, latitude: -29.983486718474694 }
      ],
      color: '#5ac8fa40',
      outline: '#ff2d55'
    }
  ]
};

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
      longitude: -54.744873046875,
      latitude: -29.382175075145277,
      rotation: 0,
      graphicId: 'point',
      callback: () => {
        alert('Touched');
      }
    },
    {
      longitude: -52.97607421875,
      latitude: -28.246327971048842,
      rotation: 0,
      graphicId: 'point'
    },
    {
      longitude: -53.052978515625,
      latitude: -30.533876572997617,
      rotation: 0,
      graphicId: 'point'
    }
  ]
  // lines: [
  //   {
  //     points: [
  //       { latitude: 109.6875, longitude: 11.523087506868514 },
  //       { latitude: 69.9609375, longitude: 68.13885164925573 }
  //     ],
  //     outline: '#00FF00'
  //   }
  // ],
};

class App extends React.Component {
  constructor(props) {
    super(props);
    setLicenseKey('runtimelite,1000,rud1919843927,none,ZZ0RJAY3FLJ5EBZNR193');
  }

  componentDidMount() {}

  render() {
    return (
      <SafeAreaView style={{ backgroundColor: '#121212', flex: 1 }}>
        <View
          style={{
            flex: 1,
            flexDirection: 'column',
            alignItems: 'stretch',
            justifyContent: 'flex-start'
          }}
        >
          <EsriMapView
            ref={mapView => (this.mapView = mapView)}
            style={{ width: '100%', flex: 1 }}
            initialMapCenter={{ latitude: -30.30479, longitude: -53.286374, scale: 7, duration: 2 }}
            recenterIfGraphicTapped={true}
            rotationEnabled={false}
            mapBasemap={{ type: 'normal' }}
          />
          <View
            style={{
              height: 56,
              backgroundColor: '#121212',
              width: '100%',
              flexDirection: 'row',
              justifyContent: 'space-evenly'
            }}
          >
            <Button
              title='overlay1'
              onPress={() => {
                this.mapView.addGraphicsOverlay(overlay1);
                this.mapView.removeGraphicsOverlay('overlay2');
              }}
            ></Button>
            <Button
              title='overlay2'
              onPress={() => {
                this.mapView.addGraphicsOverlay(overlay2);
                this.mapView.removeGraphicsOverlay('overlay1');
              }}
            ></Button>
            <Button
              title='layer'
              onPress={() => {
                this.mapView.addFeatureLayer({
                  url:
                    'http://sistemas.gt4w.com.br/arcgis/rest/services/rs/MunicipiosRS/MapServer/0/',
                  outline: '#FF0000',
                  fill: '#00FF00'
                });
              }}
            ></Button>
          </View>
        </View>
      </SafeAreaView>
    );
  }
}

export default App;

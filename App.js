import React, { useState } from 'react';
import { Button, Image, SafeAreaView, View } from 'react-native';
import EsriMapView from './EsriMapView';

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
};

const App = () => {
  const [overlay1State, setOverlay1State] = useState(false);
  const [overlay2State, setOverlay2State] = useState(false);
  const [featureState, setFeatureState] = useState(false);

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
          ref={element => (mapView = element)}
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
              if (!overlay1State) {
                if (!overlay2State) {
                  mapView.addGraphicsOverlay(overlay1);
                } else {
                  mapView.addGraphicsOverlay(overlay1);
                  mapView.removeGraphicsOverlay('overlay2');
                }
                setOverlay1State(true);
                setOverlay2State(false);
              }
            }}
          ></Button>
          <Button
            title='overlay2'
            onPress={() => {
              if (!overlay2State) {
                if (!overlay1State) {
                  mapView.addGraphicsOverlay(overlay2);
                } else {
                  mapView.addGraphicsOverlay(overlay2);
                  mapView.removeGraphicsOverlay('overlay1');
                }
                setOverlay1State(false);
                setOverlay2State(true);
              }
            }}
          ></Button>
          <Button
            title='layer'
            onPress={() => {
              if (!featureState) {
                mapView.addFeatureLayer({
                  url:
                    'http://sistemas.gt4w.com.br/arcgis/rest/services/rs/MunicipiosRS/MapServer/0/',
                  outline: '#FF3F80',
                  fill: '#c5116210',
                  referenceId: 'layer1'
                });
                setFeatureState(true);
              }
            }}
          ></Button>
        </View>
      </View>
    </SafeAreaView>
  );
};

export default App;

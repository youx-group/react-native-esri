# **react-native-esri**

### **_⚡ A React Native performance-focused map component for iOS and Android, built around Swift/Java native Esri's ArcGIS SDKs._**

<p align="center">
  <img src="react-native-esri.png">
</p>

## Current features include:

- Render `polygon`s, `line`s and `marker`s with custom assets and properties
- Render `featureLayer`s from web servicewith custom properties
- Customize fills and outlines color of rendered objects

## Available Functions:

```
addFeatureLayer(
  {
    url: <url>,
    outlineColor: <color>,
    fillColor: <color>,
    referenceId: <id>
  }
)
```

```
removeFeatureLayer(<id>)
```

```
addGraphicsOverlay(
  {
    referenceId?: <id>,
    pointGraphics?: <pointGraphics>,
    points?: <point>,
    lines?: <line>,
    polygons?: <polygon>
  }
)
```

```
removeGraphicsOverlay(<id>)
```

### Where:

- **url**: a string pointing to a web service that retrieves a compatible ArcGIS feature layer.
- **color**: a hexadecimal color string to set correspondent element color
- **id**: a string to reference elements during lifecycle
- **alert** an object that represents a popup to be rendered when the element is touched, containing the following fields:
```
alert: {
  title: 'Alert title',
  description: 'Alert body',
  closeText: 'Close button text',
  continueText: 'Confirm button text'
},
```

- **pointGraphics**: an array used to define available marker graphics, containing the following fields:
```
import { Image } from 'react-native';
pointGraphics: [
  {
    graphicId: 'point',
    graphic: Image.resolveAssetSource(require('./marker.png'))
  }
],
```

- **points**: an array used to define markers location and graphics, containing the following fields:

```
points: [
  {
    
    longitude: -54.744873046875,
    latitude: -29.382175075145277,
    rotation: 0,
    graphicId: 'point',
    referenceId?: <id>,
    alert:<alert>
  },
  {
    longitude: -52.97607421875,
    latitude: -28.246327971048842,
    rotation: 0,
    graphicId: 'point',
    referenceId?: <id>,
    alert:<alert>
  },
  {
    longitude: -53.052978515625,
    latitude: -30.533876572997617,
    rotation: 0,
    graphicId: 'point',
    referenceId?: <id>,
    alert:<alert>
  }
]

```

- **lines**: an array used to define lines location and attributes, containing the following fields:

```
lines: [
  {
    points: [
      { longitude: -55.294189453125, latitude: -29.983486718474694 },
      { longitude: -51.910400390625, latitude: -30.12612436422458 },
    ],
    outlineColor: '#00897b',
    referenceId?: <id>,
    alert:<alert>
  }
]
```

- **polygons**: an array used to define polygons location and attributes, containing the following fields:

```
polygons: [
  {
    points: [
      { longitude: -55.294189453125, latitude: -29.983486718474694 },
      { longitude: -51.910400390625, latitude: -30.12612436422458 },
      { longitude: -52.28393554687499, latitude: -28.488005204159457 },
      { longitude: -55.294189453125, latitude: -29.983486718474694 }
    ],
    fillColor: '#0c819c40',
    outlineColor: '#00897b',
    referenceId?: <id>,
    alert:<alert>
  }
]
```

## Authors
- 🍏 [iOS & JS] João Victor Teófilo [@teofilosalgado](https://www.linkedin.com/in/jo%C3%A3o-victor-t-salgado/)
- 🤖 [Android & JS] Leonardo Almeida [@leonardofalmeida](https://www.linkedin.com/in/leonardofalmeida/)

# License

_The ArcGIS SDK for Android/iOS and the ArcGIS logo are properties of [Esri](https://developers.arcgis.com/) 2019, all rights reserved._

# **react-native-esri**

### _⚡ A React Native performance-focused map component for iOS and Android built around Swift and Java Esri's ArcGIS SDKs._

<p align="center">
  <img src="react-native-esri.png">
</p>

### Current features include:

- Render `polygon`s, `line`s and `marker`s with custom assets and properties
- Render `featureLayer`s from web servicewith custom properties
- Customize fills and outlines color of rendered objects

### Functions

```
addFeatureLayer: { url: <url>, outlineColor: <color>, fillColor: <color>, referenceId: <id> }
removeFeatureLayer: <id>,

addGraphicsOverlay: [{ referenceId?: <id>, points?: <point>, lines?: <line?>, polygons?: <polygon> }]
removeGraphicsOverlay: <id>,
```

Where:

- url: a string pointing to a web service that retrieves a compatible ArcGIS feature layer.
- outlineColor: a hexadecimal color string to set outline color of element
- fillColor: a hexadecimal color string to set fill color of element
- id: a string to reference elements during lifecycle

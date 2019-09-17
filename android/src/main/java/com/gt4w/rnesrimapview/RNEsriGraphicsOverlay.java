package com.gt4w.rnesrimapview;

import android.graphics.Color;
import android.util.Log;

import com.esri.arcgisruntime.geometry.Point;
import com.esri.arcgisruntime.geometry.PointCollection;
import com.esri.arcgisruntime.geometry.Polygon;
import com.esri.arcgisruntime.geometry.SpatialReferences;
import com.esri.arcgisruntime.mapping.view.Graphic;
import com.esri.arcgisruntime.mapping.view.GraphicsOverlay;
import com.esri.arcgisruntime.symbology.PictureMarkerSymbol;
import com.esri.arcgisruntime.symbology.SimpleFillSymbol;
import com.esri.arcgisruntime.symbology.SimpleLineSymbol;
import com.esri.arcgisruntime.symbology.SimpleMarkerSymbol;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class RNEsriGraphicsOverlay {
    private GraphicsOverlay graphicsOverlay;
    private HashMap<String, String> pointImageDictionary;
    private String referenceId;
    private Boolean shouldAnimateUpdate = false;

    public RNEsriGraphicsOverlay(ReadableMap rawData, GraphicsOverlay graphicsOverlay) {
        this.referenceId = rawData.getString("referenceId");
        this.graphicsOverlay = graphicsOverlay;
        // Create graphics within overlay
        if (rawData.hasKey("points")) {
            ReadableArray pointImageDictionaryRaw = rawData.getArray("pointGraphics");
            pointImageDictionary = new HashMap<>();

            for (int i = 0; i < pointImageDictionaryRaw.size(); i++) {
                ReadableMap item = pointImageDictionaryRaw.getMap(i);
                if (item.hasKey("graphicId")) {
                    String graphicId = item.getString("graphicId");
                    String uri = item.getMap("graphic").getString("uri");
                    pointImageDictionary.put(graphicId, uri);
                }
            }

            ReadableArray rawPoints = rawData.getArray("points");
            for (int i = 0; i < rawPoints.size(); i++) {
                addGraphicsLoop(rawPoints.getMap(i));

            }
        }

        // If the geometry was a polygon
        if (rawData.hasKey("polygons")) {
            // Get the array of polygons
            ReadableArray rawPoints = rawData.getArray("polygons");

            for(int j = 0; j < rawPoints.size(); j++)
            {
                ReadableMap item = rawPoints.getMap(j);

                PointCollection polygonPoints = new PointCollection(SpatialReferences.getWgs84());
                for (int i = 0; i < item.getArray("points").size(); i++) {

                    Double latitude = item.getArray("points").getMap(i).getDouble("latitude");
                    Double longitude = item.getArray("points").getMap(i).getDouble("longitude");
                    polygonPoints.add(longitude, latitude);
                }

                Polygon polygon = new Polygon(polygonPoints);

                // Style of the polygon
                String fillColor = item.getString("fillColor");
                String outlineColor = item.getString("outlineColor");
                SimpleFillSymbol polygonSymbol = new SimpleFillSymbol(SimpleFillSymbol.Style.SOLID, Color.parseColor(fillColor),
                        new SimpleLineSymbol(SimpleLineSymbol.Style.SOLID, Color.parseColor(outlineColor), 2.0f));

                // Get the reference id
                String referenceId = item.getString("referenceId");

                // Create the attributes, where you can put some information about the polygon,
                // like the referenceID
                Map<String, Object> attributes = new HashMap<>();

                Graphic graphic = new Graphic(polygon, attributes, polygonSymbol);

                // Put the referenceID in the graphics attributes
                graphic.getAttributes().put("referenceId", referenceId);

                // Render the polygon
                graphicsOverlay.getGraphics().add(graphic);
            }

        }
    }

    // Getters
    public GraphicsOverlay getAGSGraphicsOverlay() {
        return graphicsOverlay;
    }

    public String getReferenceId() {
        return referenceId;
    }

    public void setShouldAnimateUpdate(Boolean value) {
        shouldAnimateUpdate = value;
    }

    public void updateGraphics(ReadableArray args) {
        for (int i = 0; i < args.size(); i++) {
            updateGraphicLoop(args.getMap(i));
        }
    }

    private void updateGraphicLoop(ReadableMap args) {
        // Establish variables
        com.esri.arcgisruntime.geometry.Point agsPoint = null;
        // Get references
        String referenceId = args.getString("referenceId");
        Map<String, Object> attributes = null;
        Double rotation = 0.0;

        // Once we have all the required values, we change them
        Graphic graphic = ArrayHelper.graphicViaReferenceId(graphicsOverlay, referenceId);
        if (graphic == null) {
            return;
        }

        if (args.hasKey("attributes")) {
            attributes = RNEsriGraphicsOverlay.readableMapToMap(args.getMap("attributes"));
            graphic.getAttributes().putAll(attributes);

        }
        if (args.hasKey("graphicsId")) {
            String graphicsId = args.getString("graphicsId");
            String graphicUri = pointImageDictionary.get(graphicsId);
            if (graphicUri != null) {
                PictureMarkerSymbol symbol = new PictureMarkerSymbol(graphicUri);
                graphic.setSymbol(symbol);
            }
        }
        if (args.hasKey("latitude") && args.hasKey("longitude")) {
            Double latitude = args.getDouble("latitude");
            Double longitude = args.getDouble("longitude");
            agsPoint = new com.esri.arcgisruntime.geometry.Point(longitude, latitude, SpatialReferences.getWgs84());
        }
        if (args.hasKey("rotation")) {
            rotation = args.getDouble("rotation");
        }
        if (shouldAnimateUpdate) {
            Float initialRotation = (graphic.getSymbol() != null && graphic.getSymbol() instanceof PictureMarkerSymbol)
                    ? ((PictureMarkerSymbol) graphic.getSymbol()).getAngle()
                    : 0;
            animateUpdate(graphic, ((com.esri.arcgisruntime.geometry.Point) graphic.getGeometry()), agsPoint,
                    initialRotation, rotation.floatValue());

        } else {
            graphic.setGeometry(agsPoint);
            ((PictureMarkerSymbol) graphic.getSymbol()).setAngle(rotation.floatValue());
        }
        // End of updates

    }

    private int maxTimesFired = 10;
    private int timerDuration = 500;

    private void animateUpdate(Graphic graphic, com.esri.arcgisruntime.geometry.Point fromPoint,
            com.esri.arcgisruntime.geometry.Point toPoint, Float fromRotation, Float toRotation) {
        // Run animation
        Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                Double dx = (toPoint.getX() - fromPoint.getX()) / maxTimesFired;
                Double dy = (toPoint.getY() - fromPoint.getY()) / maxTimesFired;
                Float dTheta = (toRotation - fromRotation) / maxTimesFired;
                PictureMarkerSymbol symbol = null;
                if (graphic.getSymbol() instanceof PictureMarkerSymbol) {
                    symbol = ((PictureMarkerSymbol) graphic.getSymbol());
                }

                for (int timesFired = 0; timesFired < maxTimesFired; timesFired++) {
                    Double x = fromPoint.getX() + (dx * timesFired);
                    Double y = fromPoint.getY() + (dy * timesFired);
                    Float rotation = fromRotation + (dTheta * timesFired);
                    graphic.setGeometry(new com.esri.arcgisruntime.geometry.Point(x, y, SpatialReferences.getWgs84()));
                    if (symbol != null) {
                        symbol.setAngle(rotation);
                    }
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException e) {
                        return;
                    }
                }
                graphic.setGeometry(toPoint);
                if (symbol != null) {
                    symbol.setAngle(toRotation);
                }
                timer.cancel();
            }
        }, 0, timerDuration);

    }

    public void addGraphics(ReadableArray args) {
        for (int i = 0; i < args.size(); i++) {
            addGraphicsLoop(args.getMap(i));
        }
    }

    private void addGraphicsLoop(ReadableMap map) {
        Point point = Point.fromRawData(map);
        Graphic graphic = RNEsriGraphicsOverlay.rnPointToAGSGraphic(point, pointImageDictionary);
        graphicsOverlay.getGraphics().add(graphic);
    }

    public void removeGraphics(ReadableArray args) {
        for (int i = 0; i < args.size(); i++) {
            removeGraphicsLoop(args.getString(i));
        }
    }

    private void removeGraphicsLoop(String referenceId) {
        // Identify the graphic and remove it
        Graphic graphic = ArrayHelper.graphicViaReferenceId(graphicsOverlay, referenceId);
        if (graphic != null) {
            graphicsOverlay.getGraphics().remove(graphic);
        }
    }

    // MARK: Static methods
    public static Graphic rnPointToAGSGraphic(Point point, Map<String, String> pointImageDictionary) {
        com.esri.arcgisruntime.geometry.Point agsPoint = new com.esri.arcgisruntime.geometry.Point(point.getLongitude(),
                point.getLatitude(), SpatialReferences.getWgs84());
        Graphic result;
        if (point.getGraphicId() != null && pointImageDictionary.get(point.getGraphicId()) != null) {
            String imageUri = pointImageDictionary.get(point.getGraphicId());
            assert imageUri != null;
            PictureMarkerSymbol symbol = new PictureMarkerSymbol(imageUri);
            if (point.getAttributes() != null) {
                result = new Graphic(agsPoint, point.getAttributes(), symbol);
            } else {
                result = new Graphic(agsPoint, symbol);
            }
        } else {
            SimpleMarkerSymbol symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.Style.CIRCLE, Color.GREEN, 10);
            if (point.getAttributes() != null) {
                result = new Graphic(agsPoint, point.getAttributes(), symbol);
            } else {
                result = new Graphic(agsPoint, symbol);
            }
        }
        result.getAttributes().put("referenceId", point.getReferenceId());

        if (point.getAlert() != null) {
            Map<String, Object> alertTransformedToMap = readableMapToMap(point.getAlert());
            result.getAttributes().put("title", alertTransformedToMap.get("title"));
            result.getAttributes().put("description", alertTransformedToMap.get("description"));
            result.getAttributes().put("closeButtonTitle", alertTransformedToMap.get("closeButtonTitle"));
            result.getAttributes().put("continueButtonTitle", alertTransformedToMap.get("continueButtonTitle"));
        }

        return result;

    }

    private static Map<String, Object> readableMapToMap(ReadableMap rawMap) {
        Map<String, Object> map = new HashMap<>();
        ReadableMapKeySetIterator iterator = rawMap.keySetIterator();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            map.put(key, rawMap.getString(key));
        }
        return map;
    }

    // MARK: Inner class
    public static class Point {
        private Double latitude;
        private Double longitude;
        private Double rotation;
        private String referenceId;
        private Map<String, Object> attributes;
        private String graphicId;
        private ReadableMap alert;

        public static Point fromRawData(ReadableMap rawData) {
            // Convert map to attribute map
            Map<String, Object> map = null;
            if (rawData.hasKey("attributes")) {
                ReadableMap rawMap = rawData.getMap("attributes");
                map = RNEsriGraphicsOverlay.readableMapToMap(rawMap);
            }
            Double rotation = 0.0;
            if (rawData.hasKey("rotation")) {
                rotation = rawData.getDouble("rotation");
            }
            String graphicId = "";
            if (rawData.hasKey("graphicId")) {
                graphicId = rawData.getString("graphicId");
            }
            ReadableMap alert = null;
            if (rawData.hasKey("alert")) {
                alert = rawData.getMap("alert");
            }
            return new Point(rawData.getDouble("latitude"), rawData.getDouble("longitude"), rotation,
                    rawData.getString("referenceId"), map, graphicId, alert);
        }

        private Point(Double latitude, Double longitude, Double rotation, String referenceId,
                Map<String, Object> attributes, String graphicId, ReadableMap alert) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.rotation = rotation;
            this.referenceId = referenceId;
            this.attributes = attributes;
            this.graphicId = graphicId;
            this.alert = alert;
        }

        // MARK: Get/Set
        public void setRotation(Double rotation) {
            this.rotation = rotation;
        }

        public void setReferenceId(String referenceId) {
            this.referenceId = referenceId;
        }

        public void setLongitude(Double longitude) {
            this.longitude = longitude;
        }

        public void setLatitude(Double latitude) {
            this.latitude = latitude;
        }

        public void setGraphicId(String graphicId) {
            this.graphicId = graphicId;
        }

        public void setAlert(ReadableMap alert) {
            this.alert = alert;
        }

        public void setAttributes(Map<String, Object> attributes) {
            this.attributes = attributes;
        }

        public String getReferenceId() {
            return referenceId;
        }

        public String getGraphicId() {
            return graphicId;
        }

        public Map<String, Object> getAttributes() {
            return attributes;
        }

        public Double getRotation() {
            return rotation;
        }

        public double getLongitude() {
            return longitude;
        }

        public double getLatitude() {
            return latitude;
        }

        public ReadableMap getAlert() {
            return alert;
        }
    }
}

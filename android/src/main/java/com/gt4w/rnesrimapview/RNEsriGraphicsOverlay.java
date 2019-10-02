package com.gt4w.rnesrimapview;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
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

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class RNEsriGraphicsOverlay {
    private GraphicsOverlay graphicsOverlay;
    private String referenceId;

    public RNEsriGraphicsOverlay(String referenceId,GraphicsOverlay graphicsOverlay) {
        this.referenceId = referenceId;
        this.graphicsOverlay = graphicsOverlay;
    }


    // Getters
    public GraphicsOverlay getAGSGraphicsOverlay() {
        return graphicsOverlay;
    }

    public String getReferenceId() {
        return referenceId;
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
    public static Graphic rnPointToAGSGraphic(Point point, Map pointImageDictionary, Boolean isDebug) {
        com.esri.arcgisruntime.geometry.Point agsPoint = new com.esri.arcgisruntime.geometry.Point(point.getLongitude(),
                point.getLatitude(), SpatialReferences.getWgs84());
        Graphic result;
        if (point.getGraphicId() != null && pointImageDictionary.get(point.getGraphicId()) != null) {
            PictureMarkerSymbol symbol = null;

            if(isDebug == true){
                String image = (String) pointImageDictionary.get(point.getGraphicId());
                symbol = new PictureMarkerSymbol(image);
            }else{
                BitmapDrawable image = (BitmapDrawable) pointImageDictionary.get(point.getGraphicId());
                symbol = new PictureMarkerSymbol(image);
            }
            assert symbol != null;

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

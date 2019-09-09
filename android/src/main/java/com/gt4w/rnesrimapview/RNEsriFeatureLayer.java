package com.gt4w.rnesrimapview;

import android.graphics.Color;
import android.util.Log;

import com.esri.arcgisruntime.data.ServiceFeatureTable;
import com.esri.arcgisruntime.layers.FeatureLayer;
import com.esri.arcgisruntime.symbology.SimpleFillSymbol;
import com.esri.arcgisruntime.symbology.SimpleLineSymbol;
import com.esri.arcgisruntime.symbology.SimpleRenderer;
import com.facebook.react.bridge.ReadableMap;

public class RNEsriFeatureLayer {
    public RNEsriFeatureLayer() {
    }

    public FeatureLayer setFeatureLayer(ReadableMap args) {
        String layerUrl = args.getString("url");

        ServiceFeatureTable sft = new ServiceFeatureTable(layerUrl);

        SimpleLineSymbol initialLineSymbol = new SimpleLineSymbol(SimpleLineSymbol.Style.NULL, Color.BLACK, 1.0f);
        SimpleFillSymbol simpleFillSymbol = new SimpleFillSymbol(SimpleFillSymbol.Style.NULL, Color.BLACK, initialLineSymbol);

        // create the feature layer using the service feature table
        FeatureLayer featureLayer = new FeatureLayer(sft);

        // Setup outline of map to solid and the color that comes from the user
        if(args.hasKey("outlineColor")) {
            setupOutlineColor(args, initialLineSymbol);
        }

        // Setup filler of map to solid and the color that comes from the user
        if(args.hasKey("fillColor")) {
            setupFillColor(args, simpleFillSymbol);
        }

        // Set the style to the featureLayer
        SimpleRenderer sr = new SimpleRenderer(simpleFillSymbol);
        featureLayer.setRenderer(sr);

        return featureLayer;
    }

    private void setupFillColor(ReadableMap args, SimpleFillSymbol simpleFillSymbol) {

        // Get the fill color and parse
        String fillColor = args.getString("fillColor");
        Integer parsedFillColor = Color.parseColor(fillColor);

        // Set the style and color
        // Can be change, to another types of filler
        simpleFillSymbol.setStyle(SimpleFillSymbol.Style.SOLID);
        simpleFillSymbol.setColor(parsedFillColor);

    }

    private void setupOutlineColor(ReadableMap args, SimpleLineSymbol initialLineSymbol) {

        // Get the outline color and parse
        String outlineColor = args.getString("outlineColor");
        Integer parsedOutlineColor = Color.parseColor(outlineColor);

        // Set the style and color
        // Can be style the way you want
        initialLineSymbol.setStyle(SimpleLineSymbol.Style.SOLID);
        initialLineSymbol.setColor(parsedOutlineColor);

    }
}

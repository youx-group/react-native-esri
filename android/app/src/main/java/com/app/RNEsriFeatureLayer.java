package com.app;

import com.esri.arcgisruntime.data.ServiceFeatureTable;

public class RNEsriFeatureLayer {
    public RNEsriFeatureLayer(String layerUrl) {
       setFeatureTable(layerUrl);
    }

    public ServiceFeatureTable setFeatureTable(String layerUrl) {
        ServiceFeatureTable sft = new ServiceFeatureTable(layerUrl);
        return sft;
    }
}

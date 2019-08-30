import React from 'react';
import { View, Image, Button } from 'react-native';
import ArcGISMapView, { setLicenseKey } from './AGSMapView';
import { createStackNavigator, createAppContainer } from "react-navigation";

class MapView extends React.Component {
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

		point.latitude = -30.304790
		point.longitude = -53.286374
		point.graphicId = 'point'
		point.referenceId = '149';
		point.ocorrencia = "detalhes"
		points.push(point);

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
		const { navigate } = this.props.navigation;
		return (
			<View style={{ flex: 1 }}>
				<ArcGISMapView
					ref={mapView => this.mapView = mapView}
					style={{ flex: 1 }}
					initialMapCenter={[{ latitude: -30.304790, longitude: -53.286374, scale: 6 }]}
					recenterIfGraphicTapped={true}
					rotationEnabled={false}
					mapBasemap={{ type: 'normal' }}
					onTapPopupButton={() => navigate('Detalhes', { id: 149 })}
				/>
			</View>
		);
	}
};

const url = {
	url: 'http://sistemas.gt4w.com.br/arcgis/rest/services/rs/MunicipiosRS/MapServer/0/',
	outlineColor: '#000000',
}

let teste =
{
	point: {
		latitude: -45.000064,
		longitude: -21.2430804
	},
	title: 'oi',
	text: 'fala',
}

MapView.navigationOptions = {
	title: 'MapView',
}

export default MapView;


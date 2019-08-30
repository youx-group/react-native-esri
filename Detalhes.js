import React, { Component } from 'react';

import { View } from 'react-native';

export default class Detalhes extends Component {
	async componentDidMount() {
		const id = this.props.navigation.state.params.id
		const response = await fetch(`http://homologacao.grd.geotech4web.com.br/public/ocorrencia/findById/${id}`);
		const responseJson = await response.json();
		alert(JSON.stringify(responseJson))
	}

	render() {
		return <View />;
	}
}

Detalhes.navigationOptions = {
	title: 'Detalhes',
}
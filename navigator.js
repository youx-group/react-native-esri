import MapView from './MapView';
import Detalhes from './Detalhes';

import { createAppContainer, createStackNavigator } from 'react-navigation';

const Routes = createAppContainer(
	createStackNavigator({
		MapView: MapView,
		Detalhes: Detalhes,
	})
);

export default Routes;
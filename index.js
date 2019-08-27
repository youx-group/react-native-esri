/**
 * @format
 */

import { AppRegistry } from 'react-native';
import App from './App';
import { name as appName } from './app.json';
import { setLicenseKey } from './EsriMapView';

setLicenseKey('runtimelite,1000,rud1919843927,none,ZZ0RJAY3FLJ5EBZNR193');

AppRegistry.registerComponent(appName, () => App);

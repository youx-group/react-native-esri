require 'json'

package = JSON.parse(File.read(File.join(__dir__, '../package.json')))

Pod::Spec.new do |s|
  umbrella_header = "Project-Umbrella-Header.h"
  s.name         = "RNEsriMaps"
  s.version      = package['version']
  s.summary      = package['description']
  s.homepage     = package['homepage']
  s.description = "A React Native performance-focused map component for iOS and Android, built around Swift/Java native Esri's ArcGIS SDKs."
  s.license      = "MIT"
  s.author       = package['author']
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/gt4w-consultoria/react-native-esri.git", :tag => "#{s.version}" }
  s.source_files  = "app/*.{h,m,swift}", "*.{h,m,swift}"
  s.swift_version = '4.2'

  s.dependency 'React'
  s.dependency 'ArcGIS-Runtime-SDK-iOS', '100.6'
  s.dependency 'UIColor_Hex_Swift', '~> 5.1.0'
end
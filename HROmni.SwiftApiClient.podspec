Pod::Spec.new do |s|
  s.name = 'HROmni.SwiftApiClient'
  s.swift_version = '4.0'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.version = '0.1.5'
  s.source = { :git => 'https://github.com/hromni/SwiftAPIClient.git', :tag => '0.1.5' }
  s.authors =  { 'Panayot Panayotov' => 'panayot@hromni.com' }
  s.license = { :type => 'MIT' }
  s.homepage = 'https://www.hromni.com'
  s.summary = 'Light weight and simplistic API Client written in Swift using protocol oriented programming.'
  s.source_files = 'Sources/SwiftAPIClient/**/*.swift'
end

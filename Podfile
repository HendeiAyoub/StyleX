react_native_app_path = File.join(__dir__, 'ShoppingModuleRN')
react_native_node_modules = File.join(react_native_app_path, 'node_modules')
react_native_path = 'ShoppingModuleRN/node_modules/react-native'

require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', react_native_app_path]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
end

target 'ShoppingApp' do
  config = {
    :reactNativePath => react_native_path
  }

  use_react_native!(
    :path => config[:reactNativePath],
    :app_path => react_native_app_path
  )

  target 'ShoppingAppTests' do
    inherit! :complete
  end

  target 'ShoppingAppUITests' do
    inherit! :complete
  end

end

# Widget Extension as a standalone target (NOT nested), with explicit host
target 'ShoppingAppWidgetExtension' do
  inherit! :search_paths
end

post_install do |installer|
  react_native_post_install(
    installer,
    'ShoppingModuleRN/node_modules/react-native',
    :mac_catalyst_enabled => false,
  )
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |build_config|
      build_config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
end

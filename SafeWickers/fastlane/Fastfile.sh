# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
# https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
# https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update\_fastlane

# 导入插件
import 'cocoapods'
import 'gym'


lane :build do |options|
  scheme = options[:scheme]
  workspace = options[:workspace]
  export_options = options[:export_options]

  # 更新依赖库
  cocoapods

  # 构建应用
  gym(
    scheme: scheme,
    workspace: workspace,
    export_options: export_options
  )
end

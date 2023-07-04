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

default\_platform(:ios)

platform :ios do

 desc "利用Fastland实现自动化打包"
  # fastlane debug 命令打包 这样容易理解
 lane :debug do

 build\_app(

 # 每次打包之前clean一下
 clean: true,
 # 打包出ipa文件路径
      output\_directory: './fastlane/build',
 # 打包的名称
      output\_name: 'Shopmoods.ipa',
 # 项目的scheme
      scheme: 'Shopmoods',
 # 默认Release，Release or Debug
      configuration: 'Release',
 # 是否包含bitcode 根据自己项目的实际情况到buildsetting查看
 include\_bitcode:false,
 # 是否包含symbols
 include\_symbols: true,
 # 打包导出方式，包含app-store, validation, ad-hoc, package, enterprise, development, developer-id and mac-application
      # 我们这里是上传蒲公英 所以就选择ad-hoc
      export\_method: 'development',
 # 这个设置是为了设置xcode自动配置证书和配置文件，当然也可以手动配置
      export\_xcargs: '-allowProvisioningUpdates'
 )
 # mac上的通知弹窗，通知打包完毕
    notification(app\_icon: './fastlane/icon.png', title: 'manager', subtitle: '打包成功，已导出安装包', message: '准备上传中……')
 # 上传IPA到蒲公英
    #pgyer(api\_key: "****", user\_key: "****")

 end

 
 desc "钉钉群消息通知"
 lane :dingdingTalk do |options|

 msg = options[:message]
 curl = %Q{
 curl 'https://oapi.dingtalk.com/robot/send?access_token=744c0744db403fc7ab45da5150861118e5876735fc26dc0f61e8c195d1301963' \
 -H 'Content-Type:application/json' \
 -d '{
        "msgtype":"markdown",
 "markdown":{
 "title":"Shopmoods更新通知",
 "text":"#### 🚀 App更新成功（0.0.1）\n 更新说明：#{msg} \n###### 扫码安装↓↓↓\n)"
 },
 "at":{
 "isAtAll": true
 }
 }'
 }
 system curl
 end
end

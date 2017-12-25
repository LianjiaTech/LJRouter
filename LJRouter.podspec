Pod::Spec.new do |s|
    s.name             = 'LJRouter'
    s.version          = '0.7.0'
    s.summary          = '链家iOS路由方案'
    s.description      = <<-DESC
                    LJRouter是链家独立开发完成的ios客户端路由跳转模块,该模块在接入,安全性,易用性都有比较好的表现,一行代码即可支持h5交互,push跳转,url scheme跳转等功能并实时生成文档.
                       DESC
    s.homepage         = 'https://github.com/LianjiaTech/LJRouter'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'chenxi' => 'fover0@126.com' }
    s.source           = { :git => "https://github.com/LianjiaTech/LJRouter.git",:tag => "#{s.version}"}

    s.preserve_path = 'LJRouter/ExportTool','LJRouter/ExportDocument','build'
    s.platform = :ios
    s.ios.framework = 'UIKit'
    s.ios.deployment_target = '8.0'

    s.subspec 'Core' do |ss|
        ss.source_files = 'LJRouter/Core/**/*'
    end

    s.subspec 'Navigation' do |ss|
        ss.source_files = 'LJRouter/Navigation/**/*'
    end

    s.default_subspec = 'Core','Navigation'

end

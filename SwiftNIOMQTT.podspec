Pod::Spec.new do |spec|

  spec.name           = "SwiftNIOMQTT"
  spec.version        = "0.0.1"
  spec.summary        = "SwiftNIO-based MQTT v5.0 client."
  spec.module_name    = "NIOMQTT"
  spec.swift_versions = "5.0"

  spec.description  = <<-DESC
  SwiftNIOMQTT is a SwiftNIO-based MQTT v5.0 client.
                   DESC

  spec.homepage     = "https://github.com/bofeizhu/swift-nio-mqtt"
  spec.license      = "Apache License, Version 2.0"
  spec.author             = { "Bofei Zhu" => "zhu.bofei@gmail.com" }
  spec.platform     = :ios, "12.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.source       = { :git => "https://github.com/bofeizhu/swift-nio-mqtt.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/NIOMQTT/**/*.swift"

  spec.dependency "SwiftNIOTransportServices", "~> 1.0"

end

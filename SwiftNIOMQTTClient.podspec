Pod::Spec.new do |spec|

  spec.name           = "SwiftNIOMQTTClient"
  spec.version        = "0.1.1"
  spec.summary        = "SwiftNIO-based MQTT v5.0 client."
  spec.module_name    = "NIOMQTTClient"

  spec.description  = <<-DESC
  SwiftNIOMQTTClient is a SwiftNIO-based MQTT v5.0 client.
                   DESC

  spec.homepage     = "https://github.com/HealthTap/swift-nio-mqtt"
  spec.license      = "Apache License, Version 2.0"
  spec.author       = { "Bofei Zhu" => "zhu.bofei@gmail.com" }

  spec.swift_versions             = "5.0"
  spec.ios.deployment_target      = "12.0"
  spec.osx.deployment_target      = "10.14"
  spec.tvos.deployment_target     = "12.0"

  spec.source       = { :git => "https://github.com/HealthTap/swift-nio-mqtt.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/NIOMQTTClient/**/*.swift"

  spec.dependency "SwiftNIOTransportServices", "~> 1.0"
  spec.dependency "Logging", "~> 1.0"
  spec.dependency "MQTTCodec", "~> 0.1"

end

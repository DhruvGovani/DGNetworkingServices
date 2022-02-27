
Pod::Spec.new do |spec|

spec.name         = "DGNetworkingServices"
spec.version      = "1.0.2"
spec.summary      = "DGNetworkingServices allows you to Make REST API Calls with low effort of code writing."
spec.authors      = { 'Dhruv Govani' => 'dhruvgovani@icloud.com' }
spec.description  = <<-DESC

DGNetworkingServices Allows you to Make Complex REST API Calls with snap of fingers. It uses the Pure swift Apis to provide you to suppler the all kind of API Calls with more specified errors and Response in the way you wanted. DGNetworking service is Easy to use and understand.

DESC

spec.homepage     = "https://github.com/DhruvGovani/DGNetworkingServices"

spec.license      = { :type => "MIT", :file => "LICENSE" }
spec.ios.deployment_target = "12.0"
spec.swift_version = "5.2"
spec.source       = { :git => "https://github.com/DhruvGovani/DGNetworkingServices.git", :tag => "1.0.610" }
#spec.source_files = 'DGNetworkingServices', 'DGNetworkingServices/**/*.{h,m,swift}'

spec.subspec "Core" do |core|

core.name = "Core"

core.subspec "Utilities" do |utils|

utils.name = "Utilities"
utils.source_files = 'Utilities', 'DGNetworkingServices/Utilities/*.{h,m,swift}'

end

core.subspec "NetworkingServices" do |networking|

networking.name = "NetworkingServices"
networking.source_files = 'NetworkingServices', 'DGNetworkingServices/NetworkingServices/*.{h,m,swift,json}'

end

core.subspec "Dispatcher" do |dispatcher|

dispatcher.name = "Dispatcher"
dispatcher.source_files = 'Dispatcher', 'DGNetworkingServices/Dispatcher/*.{h,m,swift}'

end

core.subspec "LogService" do |logService|

logService.name = "LogService"
logService.source_files = 'LogService', 'DGNetworkingServices/LogService/*.{h,m,swift}'

end

end

end

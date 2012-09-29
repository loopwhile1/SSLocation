Pod::Spec.new do |s|
  s.name         = "SSLocation"
  s.version      = "1.0.0"
  s.summary      = "A convenient block based interface to get the user's geo-coded location."
  s.homepage     = "https://github.com/loopwhile1/SSLocation"
  s.author       = { "Sanjit Saluja" => "loopwhile1@gmail.com" }
  s.source       = { :git => "https://github.com/loopwhile1/SSLocation.git", :tag => "1.0.0" }
  s.platform     = :ios, '4.3'
  s.source_files = 'SSLocation/**/*.{h,m}'
  s.frameworks = 'CoreLocation', 'MapKit'
  s.requires_arc = true
  s.license = 'MIT'
end

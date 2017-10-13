Pod::Spec.new do |s|

  s.name         = "SegmentedControl"
  s.version      = "0.1.0"
  s.summary      = "Scrollable segmented control with controllers container"
  s.homepage     = "https://github.com/elegion/ios-SegmentedControl"
  s.author       = { "Nibelungc" => "nibelungc@gmail.com" }
  s.license      = "MIT"

  s.platform     = :ios, '8.1'

  s.source       = { :git => "https://github.com/elegion/ios-SegmentedControl.git", :tag => "v#{s.version}" }
  s.source_files  = "Source/**/*"

end

Pod::Spec.new do |s|
  s.name         = "objc-couchdb"
  s.version      = "0.0.1"
  s.summary      = "Modern objective-c couchdb client based on MKNetworkKit."
  s.homepage     = "https://github.com/elwerene/objc-couchdb"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "René Rössler" => "rene@freshx.de", "Dominik Rössler" => "dominik@freshx.de" }
  s.source       = { :git => "https://github.com/elwerene/objc-couchdb.git", :tag => "0.0.1" }
  s.source_files = 'objc-couchdb'
  s.requires_arc = true
  s.dependency 'MKNetworkKit'
end

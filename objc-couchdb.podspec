Pod::Spec.new do |s|
  s.name         = "ObjC-CouchDB"
  s.version      = "0.0.1"
  s.summary      = "Modern objective-c couchdb client based on MKNetworkKit."
  s.homepage     = "https://github.com/elwerene/ObjC-CouchDB"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "René Rössler" => "rene@freshx.de", "Dominik Rössler" => "dominik@freshx.de" }
  s.source       = { :git => "https://github.com/elwerene/ObjC-CouchDB.git", :tag => "0.0.1" }
  s.source_files = 'Sources'
  s.requires_arc = true
  s.dependency 'MKNetworkKit'
  s.dependency 'CocoaLumberjack'
end

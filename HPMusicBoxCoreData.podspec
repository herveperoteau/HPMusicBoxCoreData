Pod::Spec.new do |s|
  s.name     = 'HPMusicBoxCoreData'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'MusicBox : CoreData'
  s.author   = { 'Herve Peroteau' => 'herve.peroteau@gmail.com' }
  s.description = 'CoreData MusicBox'
  s.platform = :ios
  s.source = { :git => "https://github.com/herveperoteau/HPMusicBoxCoreData.git"}
  s.source_files = 'HPMusicBoxCoreData'
  s.requires_arc = true
end

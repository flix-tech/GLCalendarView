
Pod::Spec.new do |s|
  s.name         = "GLCalendarView-Square"
  s.version      = "1.0"
  s.summary      = "Somewhat customizable date range picker"
  s.homepage     = "https://github.com/gelosi/GLCalendarView"
  s.license      = "MIT"
  s.author       = { "leo" => "gelosi@gmail.com" }
  s.source       = { :git => "https://github.com/gelosi/GLCalendarView.git", :tag => 'v1.2.square'}
  s.source_files = "GLCalendarView/Sources/**/*.{h,m}"
  s.resources = [
    "GLCalendarView/Sources/**/*.{png}",
    "GLCalendarView/Sources/**/*.{storyboard,xib}",
  ]
  s.requires_arc = true
  s.platform     = :ios, '7.0'

end

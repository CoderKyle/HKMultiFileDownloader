Pod::Spec.new do |s|
    s.name         = 'HKMultiFileDownloader'
    s.version      = '0.0.1'
    s.summary      = '使用多线程下载文件'
    s.homepage     = 'https://github.com/CoderKyle/HKMultiFileDownloader'
    s.license      = 'MIT'
    s.authors      = {'CoderKyle' => 'huangkai525@qq.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/CoderKyle/HKMultiFileDownloader.git', :tag => s.version}
    s.source_files = "HKMultiFileDownloader"
    s.requires_arc = true
end


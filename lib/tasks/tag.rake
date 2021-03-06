js_dir = 'vendor/assets/javascripts/'

desc 'Tag the default file versions for asset helpers'
task :tag_default do |t|
  Rake::Task["tag"].invoke
end

desc 'Tag the unstable file versions for asset helpers'
task :tag_unstable do |t|
  ENV['UNSTABLE_TAG'] = "-unstable"
  Rake::Task["tag"].invoke
end

task :tag do |t|
  version = ENV['VERSION']
  version ||= 'latest'
  additional_components = ENV['COMPONENTS'].split(",") unless ENV['COMPONENTS'].nil?
  additional_components ||= ['resource', 'sanitize']
  components = ['angular.js'].concat additional_components.map{|entry| "angular-#{entry}.js"}

  unstable_tag = ENV['UNSTABLE_TAG'] || ''

  puts "Target version: #{version.chomp('/')}"

  Dir.chdir(js_dir) do
    version_directories = Dir.glob("*").select { |fn| File.directory?(fn) }.sort.reverse
    if !(version_directories.include? version)
      puts "WARN: Specified version='#{version}' not found, setting to latest version: '#{version_directories.first}'"
      version = version_directories.first
    end
    new_files = Hash[*Dir.glob("#{version}/*.js").map {|longfn| [longfn.split(version+'/', 2)[1].chomp("-#{version}.js")+'.js', longfn]}.flatten]
    # Make sure all the components we want are there before overwriting.
    if !(new_files.keys & components == components)
      puts "ERROR: Target version directory does not contain all the components for updating: #{components}"
      exit
    end

    new_files.keys.each do |file|
      FileUtils.cp new_files[file], file.chomp('.js')+unstable_tag+'.js', {verbose: true}
    end
  end
end
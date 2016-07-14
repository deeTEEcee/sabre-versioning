require 'thor'
require 'colorize'
require_relative 'versioning'
require_relative 'constants'


def get_local_file_version(file_path)
  file_list = Dir["#{file_path}/*"]
  file_version = {}
  file_list.select! { |i| i[/#{FILE_SUFFIX}/] }
  file_list.each do |filename|
    matcher = filename.match(%r{.*/(?<name>.*)(?<version>\d+\.\d+\.\d+)#{FILE_SUFFIX}})
    if matcher
      file_version["#{matcher[:name]}#{FILE_SUFFIX}"] = matcher[:version]
    end
  end
  file_version
end

class MyCLI < Thor
  desc "version", "checks version"
  option :update

  def version
    Versioning.scrape(RESULT_FILE_PATH) if options[:update] or !File.exist?(RESULT_FILE_PATH)
    file_version = Versioning.load(RESULT_FILE_PATH)
    local_file_version = get_local_file_version(SABRE_FOLDER_PATH)
    local_file_version.each do |file, version|
      if file_version[file] == version
        puts "#{file}: #{version}"
      else
        puts "#{file}:" + " #{version} -> #{file_version[file]}".colorize(:green)
      end
    end
  end
end

MyCLI.start(ARGV)

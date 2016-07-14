require_relative 'constants'
require 'mechanize'

class Versioning

  def self.load(file_path)
    file_version = {}
    File.open(file_path).each do |line|
      title, version, name, link = line.split(',')
      if title
        file_version["#{name}#{FILE_SUFFIX}"] = version
      end
    end
    file_version
  end

  def self.scrape(file_path)
    agent = Mechanize.new
    page = agent.get(SABRE_API_BASE_URL + SOAP_RELATIVE_PATH)
    endpoint_links = page.links_with(:href => %r{resources})
    File.open(file_path, 'w') do |file|
      endpoint_links.each do |endpoint_link|
        link = endpoint_link.href
        puts "link #{link}"
        resources_page = agent.get(link)
        soap_item = resources_page.links_with(:href => %r{#{FILE_SUFFIX}}).first
        matcher = soap_item.href.match(%r{.*/(?<name>.*)(?<version>\d+\.\d+\.\d+)#{FILE_SUFFIX}})

        title = resources_page.search('div#main h1').first.text
        title.slice!(" Resources")
        if matcher
          name = matcher[:name]
          version = matcher[:version]
          file.puts "#{title},#{version},#{name},#{link}"
          # file.printf "%-20s %-20s #{link}\n" % ["#{title} :", "#{version} (#{name}) -"]
        else
          file.puts ",,,"
          # file.printf "#{soap_item.href} did not match\n"
        end
      end
    end
  end
end

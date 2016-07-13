require 'mechanize'

SABRE_API_BASE_URL = "https://developer.sabre.com"
SOAP_RELATIVE_PATH = "/docs/read/SOAP_APIs"

agent = Mechanize.new
page = agent.get(SABRE_API_BASE_URL + SOAP_RELATIVE_PATH)
endpoint_links = page.links_with(:href => %r{resources})

File.open("sabre-api.txt", 'w') do |file|
  endpoint_links.each do |endpoint_link|
    link = endpoint_link.href
    puts "link #{link}"
    resources_page = agent.get(link)
    soap_item = resources_page.links_with(:href => %r{RQ.xsd}).first
    matcher = soap_item.href.match(%r{.*/(?<name>.*)(?<version>\d+\.\d+\.\d+)RQ.xsd})

    title = resources_page.search('div#main h1').first.text
    title.slice!(" Resources")
    if matcher
      name = matcher[:name]
      version = matcher[:version]
      file.printf "%-20s %-20s #{link}\n" % ["#{title} :", "#{version} (#{name}) -"]
    else
      file.printf "#{soap_item.href} did not match\n"
    end
  end
end

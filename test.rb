require 'selenium-webdriver'
require 'open-uri'
require 'yaml'
require 'gmail'
require 'crack/xml'

# Provide a help page for cli arg -h and exit
if ARGV.length == 1 && ARGV[0] == '-h'
  puts <<-EOS
  Usage:   ruby test.rb [location] [platforms]
  Example: ruby test.rb "Singapore (10, Chrome, Firefox)" Firefox,Chrome
  Args:
    location:  location selection from the webpagetest.org site
    platforms: comma separated list of platforms (browsers) to be tested on
  EOS
  exit 0
end

test_site = 'https://www.webpagetest.org'

# gather the stuff for the email
config_file = YAML.load_file('config.yaml')
to_addr = config_file['to_addr']
to_name = config_file['to_name']
username = config_file['username']
password = config_file['password']
m_subject = config_file['m_subject']
greeting = config_file['greeting']
intro = config_file['intro']
message = %(#{greeting} #{to_name},

#{intro}
)
results_body = ''

# get location and platforms from config file if command line args are not set
location = ARGV.length == 2 ? ARGV[0] : config_file['location']
platform = ARGV.length == 2 ? ARGV[1].split(',') : config_file['platform']

puts "Using Location: #{location}, Test browser: #{platform}"

# open a firefox browser
driver = Selenium::WebDriver.for :firefox

# more than 1 URL - use each url in urls.txt
File.foreach('urls.txt') do |test_url|
  # skip the line if it's a malformed URL TODO: gather these and report them
  next if test_url !~ /^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

  # navigate to page testing site
  driver.navigate.to test_site

  # enter a URL
  driver.find_element(:id, 'url').send_keys test_url

  # select and click the location option in the dropdown
  location_list = driver.find_element(:id, 'location')
  l_options = location_list.find_elements(tag_name: 'option')
  l_options.each { |option| option.click if option.text.start_with?(location) }

  # select and click the test browser option in the dropdown
  browser_list = driver.find_element(:id, 'browser')
  b_options = browser_list.find_elements(tag_name: 'option')
  b_options.each { |option| option.click if option.text.start_with?(platform) }

  # TODO: click :id 'advanced_settings', change :id 'number_of_tests'

  # press the start button
  driver.find_element(:class, 'start_test').click

  # store the URLs of results page and XML API
  results_url = driver.current_url
  xml_url = results_url.gsub('result', 'xmlResult')

  # wait for the results page to load and the load time to show
  begin
    element = driver.find_element(:id, 'LoadTime')
  rescue
    retry if element.nil?
  end

  # now that the results page has loaded, the XML output exists; read and parse
  xml = open(xml_url).read
  doc = Crack::XML.parse(xml)['response']['data']['average']['firstView']

  # use XML API to scrape the load time and other data
  load_time = doc['loadTime']
  speed_index = doc['SpeedIndex']
  t_doc_complete = doc['docTime']
  t_fully_loaded = doc['fullyLoaded']
  t_first_byte = doc['TTFB']
  t_visual_complete = doc['visualComplete']
  t_last_interactive = doc['LastInteractive']

  results_body += %(
  [#{test_url.chomp}]
  Result URL:             #{results_url}
  Speed Index:            #{speed_index}
  Load Time:              #{load_time} ms
  Doc Complete Time:      #{t_doc_complete} ms
  Fully Loaded Time:      #{t_fully_loaded} ms
  Time to First Byte:     #{t_first_byte} ms
  Visual Complete Time:   #{t_visual_complete} ms
  Last Interactive Time:  #{t_last_interactive} ms
  )

  puts "[DONE] #{test_url}"
end

message += results_body

# connect to Gmail and send the message
gmail = Gmail.connect(username, password)
email = gmail.compose do
  to to_addr
  subject m_subject
  body message
end
gmail.deliver(email)
gmail.logout

require 'selenium-webdriver'
require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'gmail'
require 'crack/xml'

test_site = 'https://www.webpagetest.org'

# gather the stuff for the email
config_file = YAML.load_file('config.yaml')
to_addr = config_file['to_addr']
username = config_file['username']
password = config_file['password']
m_subject = 'Results of selenium page testing'
message = %(Hey josh,

Here are the URLs that I just tested along with relevant data:
)
results_body = ''

# open a firefox browser
driver = Selenium::WebDriver.for :firefox

# bonus: more than 1 URL - open 3 URLs from a file
File.foreach('urls.txt') do |test_url|
  # navigate to page testing site
  driver.navigate.to test_site

  # enter a URL and press the start test button
  driver.find_element(:id, 'url').send_keys test_url
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

  results_body += %(
  [#{test_url.chomp}]
  Result URL:        #{results_url}
  Speed Index:       #{speed_index}
  Load Time:         #{load_time} ms
  Doc Complete Time: #{t_doc_complete} ms
  Fully Loaded Time: #{t_fully_loaded} ms
  )
end

puts results_body
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

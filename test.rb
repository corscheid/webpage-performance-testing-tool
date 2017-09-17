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

  # store the URL of results page
  results_url = driver.current_url

  # wait for the results page to load and the load time to show
  begin
    element = driver.find_element(:id, 'LoadTime')
  rescue
    retry if element.nil?
  end

  # bonus: use XML API
  results_url.gsub!('result', 'xmlResult')

  # nokogiri scrape 1st run load time value from results page
  # doc = Nokogiri::HTML(open(results_url))
  # bonus: use XML API / read the XML in
  doc = Crack::XML.parse(open(results_url).read)['response']['data']['average']['firstView']
  # load_time = doc.at_css('td#LoadTime').text
  # bonus: use XML API / scrape the load time
  load_time = doc['loadTime']
  # bonus: more data
  # speed_index = doc.at_css('td#SpeedIndex').text
  # t_doc_complete = doc.at_css('td#DocComplete').text
  # t_fully_loaded = doc.at_css('td#FullyLoaded').text
  # bonus: use XML API / grab the same stuff as before
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

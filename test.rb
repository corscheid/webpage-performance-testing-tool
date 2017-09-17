require 'selenium-webdriver'
require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'gmail'

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

  # nokogiri scrape 1st run load time value from results page
  doc = Nokogiri::HTML(open(results_url))
  load_time = doc.at_css('td#LoadTime').text
  # bonus: more data
  speed_index = doc.at_css('td#SpeedIndex').text
  t_doc_complete = doc.at_css('td#DocComplete').text
  t_fully_loaded = doc.at_css('td#FullyLoaded').text
  results_body += %(
  [#{test_url.chomp}]
  Result URL: #{results_url}
  Load Time: #{load_time}
  Speed Index: #{speed_index}
  Doc Complete Time: #{t_doc_complete}
  Fully Loaded Time: #{t_fully_loaded}
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

require 'selenium-webdriver'
require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'gmail'

test_site = 'https://www.webpagetest.org'
test_url = 'https://google.com'

# open a firefox browser and navigate to page testing site
driver = Selenium::WebDriver.for :firefox
driver.navigate.to test_site

# enter a URL and press the start test button
driver.find_element(:id, 'url').send_keys test_url
driver.find_element(:class, 'start_test').click

# store the URL of results page
results_url = driver.current_url
puts results_url

# wait for the results page to load and the load time to show
begin
  element = driver.find_element(:id, 'LoadTime')
rescue
  retry if element.nil?
end

# nokogiri scrape 1st run load time value from results page
doc = Nokogiri::HTML(open(results_url))
load_time = doc.at_css('td#LoadTime').text
puts load_time

# gather the stuff for the email
config_file = YAML.load_file('config.yaml')
to_addr = config_file['to_addr']
username = config_file['username']
password = config_file['password']
m_subject = 'Results of selenium page testing'
message = <<-EOF
  Hey josh,
      Here's the URL that I just tested:

  #{results_url}

  And here is its LoadTime:   #{load_time}
  EOF

# connect to Gmail and send the message
gmail = Gmail.connect(username, password)
email = gmail.compose do
  to to_addr
  subject m_subject
  body message
end
gmail.deliver(email)
gmail.logout

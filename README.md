# webpage-performance-testing-tool

What this program *currently* does is open a Firefox window, load a list of URLS from a file, test the performance of each URL and then email the results according to the config file, all automatically using one command in a terminal.

## Dependencies

`selenium-webdriver` (`gem install selenium-webdriver`, also requires a [webdriver binary for firefox](https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver))

`gmail` (`gem install gmail`)

`crack` (`gem install crack`)

## Usage

edit `config.yaml` and `urls.txt` to your liking

`$ ruby test.rb`

### Command Line Arguments

`location` : location selection from the webpagetest.org site

`platforms` : comma separated list of platforms (browsers) to be tested on

#### Examples:

```
# will test with default values set in config.yaml file
$ ruby test.rb
```

```
# will test in Denver, CO using Firefox
$ ruby test.rb Denver Firefox
```

## Configuration file

`config.yaml` contains relevant values used by the program. They are all fairly self-explanatory:

`to_addr`: the email address to send the results to

`m_subject`: subject line of the results email

`to_name`: the name of the recipient, as desired in the beginning of the email (e.g., John, John Smith, Mr. Smith, etc.)

`greeting`: the greeting of the email (e.g., Hi, Good morning, Hello, etc.)

`intro`: the text of the email which precedes/introduces the actual test results

`username`: your gmail username (your gmail address or Gsuite address)

`password`: your gmail/Gsuite password

`location`: the location selection from the webpagetest.org site.

`platforms`: the list of platforms (browsers) to be tested on

## URLS file

List URLs to be tested in a plain text file one url per line and each will be tested sequentially.

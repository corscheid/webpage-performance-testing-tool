# webpage-performance-testing-tool

What this program *currently* does is open a Firefox window, load a list of URLS from a file, test the performance of each URL and then email the results according to the config file, all automatically using one command in a terminal.

## Dependencies

`selenium-webdriver` (`gem install selenium-webdriver`, also requires a webdriver binary for firefox: https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver)

`gmail` (`gem install gmail`)

`crack` (`gem install crack`)

## Usage

edit `config.yaml` and `urls.txt` to your liking

`$ ruby test.rb`

### Command Line Arguments

`location` : location selection from the webpagetest.org site

`platforms` : comma separated list of platforms (browsers) to be tested on

#### Examples:

`# will test on Firefox and Chrome in Singapore`
`$ ruby test.rb Singapore (10, Chrome, Firefox) Firefox,Chrome`

## Configuration file

`config.yaml` contains relevant values used by the program. They are all fairly self-explanatory:

`to_addr`: the email address to send the results to

`username`: your gmail username (your gmail address or Gsuite address)

`password`: your gmail/Gsuite password

`location`: the location selection from the webpagetest.org site.

`platforms`: the list of platforms (browsers) to be tested on

## URLS file

List URLs to be tested in a plain text file one url per line and each will be tested sequentially.

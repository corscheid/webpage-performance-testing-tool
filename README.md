# webpage-performance-testing-tool

What this program *currently* does is open a Firefox window, load a list of URLS from a file, test the performance of each URL and then email the results according to the config file, all automatically using one command in a terminal.

## Usage

`$ ruby test.rb`

## Configuration file

`config.yaml` contains relevant values used by the program. They are all fairly self-explanatory:

`to_addr`: the email address to send the results to

`username`: your gmail username (your gmail address or Gsuite address)

`password`: your gmail/Gsuite password

## URLS file

List URLs to be tested in a plain text file one url per line and each will be tested sequentially.

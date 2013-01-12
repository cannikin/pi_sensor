# PiSensor

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'pi_sensor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pi_sensor

## A note about pin numbering

Raspberry Pi pin numbering can be confusing. The pin numbers used in this
library are the wiringPi pin numbers: https://projects.drogon.net/raspberry-pi/wiringpi/pins

## Usage

Here's an example using the [SHT15](https://www.sparkfun.com/products/8257) temperture/humidty sensor.
Note that you need to run this code as root or with `sudo`:

    require 'wiringpi'

    # Connects Pi physical pin 11 to SCK and Pi physical pin 12 to DATA
    sensor = PiSensor::SHT15.new :clock => 0, :data => 1

    # And then simply query for the temperature and humidity
    puts " Temperature: #{sensor.temperature}°C"
    puts "    Humidity: #{sensor.humidity}%"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

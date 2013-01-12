require 'wiringpi'

module PiSensor
  class SHT15

    HIGH = 1
    LOW  = 0
    COMMANDS = { :temperature  => 0x03,
                 :humidity     => 0x05,
                 :read_status  => 0x07,
                 :write_status => 0x06,
                 :reset        => 0x1E }

    attr_reader :clock, :data

    def initialize(pins)
      @clock = pins[:clock]
      @data = pins[:data]
      raise StandardError, "You must assign both data and clock pins. Ex: `sensor = SHT15.new :clock => 0, :data => 1`" unless @clock and @data
    end


    # Reads the current temperature from the sensor, defaulting to celcius.
    # Pass in an :f to return fahrenheit instead:
    #
    #   sensor = SHT15.new :clock => 0, :data => 1
    #   sensor.temperature(:f)
    #
    def temperature(scale=:c)
      send_command(COMMANDS[:temperature])
      temp = read_result

      if temp.nil?
        return nil
      else
        converted_temp = -39.65 + (0.01 * temp)
        if scale == :f
          return celcius_to_fahrenheit(converted_temp)
        else
          return converted_temp
        end
      end
    end


    # Returns the current relative humidity (from 0.0 to 100.0)
    def humidity
      send_command(COMMANDS[:humidity])
      humid = read_result

      if humid.nil?
        return nil
      else
        return -2.0468 + (0.0367 * humid) + (-1.5955E-6 * humid)
      end
    end


    def celcius_to_fahrenheit(temp)
      return temp * 9.0 / 5.0 + 32.0
    end


    def fahrenheit_to_celcius(temp)
      return (temp - 32.0) * 5.0 / 9.0
    end

  private

    # Keeps an instance of WiringPi::GPIO around so we can talk to our pins
    def io
      @io ||= WiringPi::GPIO.new
    end


    # Warms the chip up and sends in a command, then waits until a response is
    # ready before returning
    def send_command(command)
      io.mode(@data, OUTPUT)
      io.mode(@clock, OUTPUT)

      # Wake up sensor
      io.write @data, HIGH
      io.write @clock, HIGH
      io.write @data, LOW
      io.write @clock, LOW
      io.write @clock, HIGH
      io.write @data, HIGH
      io.write @clock, LOW

      # Send command
      7.downto(0) do |i|
        binary = (command & (1 << i))
        bit = binary >= 1 ? HIGH : LOW
        io.write(@data, bit)
        io.write(@clock, HIGH)
        io.write(@clock, LOW)
      end

      # Make sure the sensor got our request
      io.write(@clock, HIGH)

      io.mode(@data, INPUT)
      if io.read(@data) != LOW
        raise SensorError, "Sensor should be LOW but isn't"
      end

      io.write(@clock, LOW)
      if io.read(@data) != HIGH
        raise SensorError, "Sensor should be HIGH but isn't"
      end

    end


    def read_result
      result = 0

      io.mode(@clock, OUTPUT)
      io.mode(@data, INPUT)

      # Wait for measurement
      puts "Waiting for sensor to take measurement..."
      1.upto(10) do |i|
        sleep(0.1)
        if io.read(@data) == LOW
          break
        end
      end
      puts "Data pin LOW, ready to read measurement."

      # If pin is still high at this point, we've got a problem
      if io.read(@data) == HIGH
        puts "!! Ack Error 3"
        exit 0
      end

      # Read first 8 bits
      0.upto(7) do |i|
        io.write(@clock, HIGH)
        result = (result << 1) | io.read(@data)
        io.write(@clock, LOW)
      end

      # Acknowledge first 8 bits
      io.mode(@data, OUTPUT)
      io.write(@data, HIGH)
      io.write(@data, LOW)
      io.write(@clock, HIGH)
      io.write(@clock, LOW)

      # Read second 8 bits
      io.mode(@data, INPUT)
      0.upto(7) do |i|
        io.write(@clock, HIGH)
        result = (result << 1) | io.read(@data)
        io.write(@clock, LOW)
      end

      # Skip CRC check
      io.mode(@data, OUTPUT)
      io.write(@data, HIGH)
      io.write(@clock, HIGH)
      io.write(@clock, LOW)

      return result
    end


  end
end

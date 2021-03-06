require 'optparse'
require 'fileutils'

module SpeedDemon
  # Handle all command line parsing
  class CLI
    def self.parse(args)
      @options = ScriptOptions.new
      OptionParser.new do |parser|
        @options.define_options(parser)
        parser.parse!(args)
      end
      @options
    end

    # Define each parser as a method object
    class ScriptOptions
      attr_accessor :setup, :measure, :output, :log, :frequency

      def initialize
        self.setup = false
        self.measure = false
      end

      def define_options(parser)
        parser.banner = 'Usage: speed_demon [options]'
        display_help(parser)
        # CLI parse options
        measure_speed(parser)
        setup_default(parser)
        custom_output_path(parser)
        custom_log_path(parser)
        custom_frequency(parser)
      end

      def display_help(parser)
        parser.on('-h', '--help', 'Display this screen') do
          puts parser
          exit
        end
      end

      def measure_speed(parser)
        parser.on('-m', '--measure-speed', 'Measure internet speed and save it') do
          self.measure = true
        end
      end

      def setup_default(parser)
        parser.on('-s', '--setup-default', 'Setup speedtest directories using defaults') do
          self.setup = true
        end
      end

      def custom_output_path(parser)
        parser.on('-o', '--custom-output PATH', String, 'Override the default output directory with a custom') do |path|
          self.output = path
          self.setup = true
        end
      end

      def custom_log_path(parser)
        parser.on('-l', '--custom-log PATH', String, 'Override the default log directory with a custom') do |path|
          self.log = path
          self.setup = true
        end
      end

      def custom_frequency(parser)
        parser.on('-f', '--custom-frequency TIME', String, 'Override the default measuring frequency with a custom') do |time|
          self.frequency = time
          self.setup = true
        end
      end
    end
  end
end

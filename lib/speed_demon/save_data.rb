require 'fileutils'
require 'csv'

module SpeedDemon
  # Saves measured speed data to a csv file
  class SaveData
    def self.execute(args)
      save = new(args)
      save.csv
    end

    def initialize(args)
      full_output_path = File.expand_path(args[:output_path])
      @file_name = File.join(full_output_path, '/data.csv')
      @time = args[:data].time
      @ping = args[:data].ping
      @download = args[:data].download
      @upload = args[:data].upload
      @wireless = args[:wireless]
      create_csv unless csv_exist?
    end

    def create_csv
      CSV.open(@file_name, 'a+', headers: true) do |line|
        # Write headers only if the file is new (empty)
        if line.eof?
          headers = ['Time',
                     'Ping (ms)',
                     'Download Speed (Mbit/s)',
                     'Upload Speed (Mbit/s)',
                     'wireless connection?']
          line << headers
        end
      end
    end

    def csv
      CSV.open(@file_name, 'a+', headers: true) do |line|
        line << [@time, @ping, @download, @upload, @wireless]
      end
    end

    private

    def csv_exist?
      File.exist?(@file_name)
    end
  end
end

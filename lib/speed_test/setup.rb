require 'fileutils'
require 'yaml'

module SpeedTest
  class Setup
    def self.execute(cli)
      setup = new(cli)
      setup.directories
      setup.settings
      setup.timestamp_generator
      setup.cron
      setup.cron_start
    end

    def initialize(cli)
      @output = File.expand_path(cli.output || "~/.local/share/speedtest")
      @log = File.expand_path(cli.log || "~/.speedtest")
      @config = File.expand_path("~/.config/speedtest")
      @frequency = cli.frequency || '15.minutes'
      @path = `echo $PATH`
    end

    def directories
      dirs.each do |dir|
        if Dir.exist?(dir)
          warn "#{dir} exists, not created"
        else
          puts "[add] `#{dir}'"
          FileUtils.mkdir_p(dir)
        end
      end
    end

    def settings
      File.open(settings_file_name, "w") do |file|
        file.write(settings_file_contents).to_yaml
        file.close
      end
    end

    def cron
      File.open(cron_schedule_file, "w") do |file|
        file.write(cron_schedule_file_contents)
        file.close
      end
    end

    def cron_start
      system("whenever --update-crontab --load-file  #{cron_schedule_file}")
    end

    def timestamp_generator
      File.open(timestamp_generator_file, "w") do |file|
        file.write(timestamp_generator_file_contents)
        file.close
      end
      FileUtils.chmod(0755, timestamp_generator_file)
    end

    private

    def dirs
      [] << @output << @log << @config
    end

    def cron_schedule_file
      File.expand_path("#{@config}/cron.rb")
    end

    def cron_log_file
      File.expand_path("#{@log}/cron.log")
    end

    def cron_schedule_file_contents
<<FILE
# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever
#

job_type :call_executable, 'export PATH=#{@path} && :task'

every #{@frequency} do
call_executable 'speedtest_init -m | #{timestamp_generator_file} >> #{cron_log_file} 2>&1'
end
FILE
    end

    def timestamp_generator_file_contents
<<FILE
#!/bin/bash

while read x; do
    echo -n `date '+%Y-%m-%dT%T%z'`;
    echo -n " ";
    echo $x;
done
FILE
    end

    def timestamp_generator_file
      File.expand_path("#{@config}/timestamp_generator.sh")
    end

    def settings_file_name
      File.expand_path("#{@config}/settings.yaml")
    end

    def settings_file_contents
<<FILE
---
output: #{@output}
log: #{@log}
frequency: #{@frequency}
FILE
    end
  end
end

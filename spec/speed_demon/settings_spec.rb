require 'spec_helper'

RSpec.describe SpeedDemon::Settings do
  describe 'Save & load settings to/from yaml file,' do
    let(:output) { '/tmp/output' }
    let(:log) { '/tmp/log' }
    let(:frequency) { '2.minutes' }
    let(:config) { '/tmp/config' }
    let(:create_settings_yaml) do
      described_class.create(config: config, output: output, log: log, frequency: frequency)
    end

    let(:settings_file_contents) do
      Hash[output: output,
           log: log,
           frequency: frequency ].to_yaml
    end

    before do
      # make directory as this is usually done in SpeedDemon::Setup
      FileUtils.mkdir_p(config)
      create_settings_yaml
    end

    after do
      FileUtils.rm_rf(config) if File.directory?(config) # cleanup
    end

    it 'creates a settings.yaml file assuming Setup creates the config path' do
      expect(File.exist?("#{config}/settings.yaml")).to be true
    end

    it 'creates a settings.yaml file with the correct contents' do
      expect(File.read("#{config}/settings.yaml")).to eq(settings_file_contents)
    end

    it 'loads output settings given correct path' do
      expect(described_class.load(config).output).to eq(output)
    end

    it 'loads log settings given correct path' do
      expect(described_class.load(config).log).to eq(log)
    end

    it 'loads frequency settings given correct path' do
      expect(described_class.load(config).frequency).to eq(frequency)
    end

    it 'raises an error if there is not a saved settings.yaml file' do
      # purposely remove config
      FileUtils.rm_rf(config) if File.directory?(config)
      expect { described_class.load(config) }.to raise_error(LoadError, 'settings.yaml does not exist. Run setup')
    end
  end
end

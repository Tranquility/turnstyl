require 'spec_helper'
require_relative '../../../lib/turnstyl/client'

module Turnstyl
  describe Client do
    let(:dummy_home) { base_path+'/spec/dummy_home_folder' }
    let(:key_file) { dummy_home+'/.ssh/authorized_keys' }
    let(:config_file) { dummy_home+'/.turnstylrc' }
    let(:turnstyl_client) {Client.new}

    before do
      Client.any_instance.stub(:config_file_missing?).and_return(false)
      FileUtils.mkdir_p base_path+"/spec/dummy_home_folder/.ssh"
      Client.stub(:home_folder).and_return(dummy_home)
      turnstyl_client.stub(:puts)
      turnstyl_client.stub(:print)
    end

    after do
      FileUtils.rm_rf dummy_home
    end

    describe '#initialize' do
      it 'raises exception if config file is missing' do
        Client.any_instance.stub(:config_file_missing?).and_return(true)
        expect { Client.new.run nil }.to raise_error(SystemExit)
      end
    end

    describe '#run' do
      it 'does not overwrite the authorized_keys file' do
        turnstyl_client.should_receive(:update_authorized_keys_carefully)

        turnstyl_client.run(false)
      end

      it 'overwrites the authorized_keys file if forced' do
        turnstyl_client.should_receive(:update_authorized_keys)

        turnstyl_client.run(false)
      end
    end

    describe '#update_authorized_keys' do
      it 'creates authorized_keys file' do
        turnstyl_client.should_receive(:load_settings).and_return("userlist" => [])

        File.exist?(key_file).should be_false
        turnstyl_client.update_authorized_keys
        File.exist?(key_file).should be_true
      end

      it 'adds a comment when there are no authorized keys file' do
        turnstyl_client.should_receive(:load_settings).and_return("userlist" => [])
        turnstyl_client.update_authorized_keys

        File.read(key_file).should eq "# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN\n"
      end

      it 'obtains key and writes them into the authorized_keys file' do
        Communicator.any_instance.stub(:get_keys_from).and_return(['12345', '67890'])
        turnstyl_client.should_receive(:load_settings).and_return("userlist" => ['flooose'])
        turnstyl_client.update_authorized_keys
        File.read(key_file).should eq "12345\n67890\n"
      end
    end

    describe '#update_authorized_keys_carefully' do
      let(:some_time) { Time.now }
      before do
        turnstyl_client.stub(:authorized_key_missing?).and_return(false)
      end

      it 'updates the keys if the authoized keys file is missing' do
        turnstyl_client.stub(:authorized_key_missing?).and_return(true)
        turnstyl_client.should_receive(:update_authorized_keys)

        turnstyl_client.update_authorized_keys_carefully
      end

      it 'does not overwrite authorized_keys file if configuration not changed' do
        STDIN.stub(:gets).and_return('y')
        File.should_receive(:mtime).with(config_file).and_return(some_time)
        File.should_receive(:mtime).with(key_file).and_return(some_time + 2)

        turnstyl_client.should_not_receive(:update_authorized_keys)
        turnstyl_client.run nil
      end

      it 'overwrites authorized_keys file if configuration changed' do
        STDIN.stub(:gets).and_return('y')
        File.should_receive(:mtime).with(config_file).and_return(some_time + 2)
        File.should_receive(:mtime).with(key_file).and_return(some_time)

        turnstyl_client.should_receive(:update_authorized_keys)
        turnstyl_client.run nil
      end

      it 'asks the user for feedback when the authorized_keys file exists' do
        turnstyl_client.stub(:authorized_key_missing?).and_return(true)
        turnstyl_client.stub(:update_authorized_keys)

        turnstyl_client.run nil
      end

      context 'user gives feedback' do
        before do
          turnstyl_client.stub(:config_file_missing?).and_return(false)
          turnstyl_client.stub(:config_changed?).and_return(true)
          turnstyl_client.stub(:authorized_key_missing?).and_return(false)
        end

        it 'updates authorized_keys file if user inputs "y"' do
          STDIN.stub(:gets).and_return('y')
          turnstyl_client.should_receive(:update_authorized_keys)

          turnstyl_client.run nil
        end

        it 'updates authorized_keys file and creates backup first if user inputs "b"' do
          STDIN.stub(:gets).and_return('b')

          turnstyl_client.should_receive(:create_backup)
          turnstyl_client.should_receive(:update_authorized_keys)

          turnstyl_client.run nil
        end

        it 'displays help if user inputs "?"' do
          STDIN.stub(:gets).and_return('?', 'n')

          turnstyl_client.should_receive(:display_help)
          turnstyl_client.should_not_receive(:update_authorized_keys)

          turnstyl_client.run nil
        end

        it 'it does not update authorized_keys file if user inputs "n"' do
          STDIN.stub(:gets).and_return('n')

          turnstyl_client.should_not_receive(:update_authorized_keys)

          turnstyl_client.run nil
        end
      end

      describe '#create_backup' do
        it 'renames the current authorized_keys file' do
          FileUtils.touch key_file
          FileUtils.touch key_file+".bak1"
          File.exist?(key_file).should be_true

          turnstyl_client.create_backup

          File.exist?(key_file).should be_false
          File.exist?(key_file+".bak2").should be_true
        end
      end
    end
  end
end

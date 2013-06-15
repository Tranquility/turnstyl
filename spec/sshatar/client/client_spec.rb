require 'spec_helper'
require_relative '../../../lib/sshatar/client'

module Sshatar
  describe Client do
    let(:dummy_home) { base_path+'/spec/dummy_home_folder' }
    let(:key_file) { dummy_home+'/.ssh/authorized_keys' }
    let(:config_file) { dummy_home+'/.sshatar_config' }
    let(:sshatar_client) {Client.new}

    before do
      Client.any_instance.stub(:config_file_missing?).and_return(false)
      FileUtils.mkdir_p base_path+"/spec/dummy_home_folder/.ssh"
      Client.stub(:home_folder).and_return(dummy_home)
      sshatar_client.stub(:puts)
    end

    after do
      FileUtils.rm_rf dummy_home
    end

    describe '#update_authorized_keys' do
      it 'creates authorized_keys file' do
        sshatar_client.should_receive(:load_settings).and_return("userlist" => [])

        File.exist?(key_file).should be_false
        sshatar_client.update_authorized_keys
        File.exist?(key_file).should be_true
      end


      it 'adds a comment when there are no authorized keys' do
        sshatar_client.should_receive(:load_settings).and_return("userlist" => [])
        sshatar_client.update_authorized_keys

        File.read(key_file).should eq "# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN\n"
      end

      it 'starts downloading the keys if there are user in the config file' do
        Communicator.any_instance.stub(:get_keys_from).and_return(['12345', '67890'])
        sshatar_client.should_receive(:load_settings).and_return("userlist" => ['flooose'])
        sshatar_client.update_authorized_keys
        File.read(key_file).should eq "12345\n67890\n"
      end
    end

    describe '#run' do
      let(:some_time) { Time.now }
      before do
        sshatar_client.stub(:authorized_key_missing?).and_return(false)
      end

      it 'does not overwrite authorized_keys file if configuration not changed' do
        STDIN.stub(:getch).and_return('y')
        File.should_receive(:mtime).with(config_file).and_return(some_time)
        File.should_receive(:mtime).with(key_file).and_return(some_time + 2)

        sshatar_client.should_not_receive(:update_authorized_keys)
        sshatar_client.run
      end

      it 'overwrites authorized_keys file if configuration changed' do
        STDIN.stub(:getch).and_return('y')
        File.should_receive(:mtime).with(config_file).and_return(some_time + 2)
        File.should_receive(:mtime).with(key_file).and_return(some_time)

        sshatar_client.should_receive(:update_authorized_keys)
        sshatar_client.run
      end

      it 'raises exception if config file is missing' do
        Client.any_instance.stub(:config_file_missing?).and_return(true)
        expect { Client.new.run }.to raise_error(Sshatar::ConfigMissing)
      end

      it 'asks the user for feedback when the authorized_keys file exists' do
        sshatar_client.stub(:config_changed?).and_return(true)
        sshatar_client.stub(:update_authorized_keys)

        STDIN.should_receive(:getch).and_return('y')

        sshatar_client.run
      end

      context 'user gives feedback' do
        before do
          sshatar_client.stub(:config_file_missing?).and_return(false)
          sshatar_client.stub(:config_changed?).and_return(true)
          sshatar_client.stub(:authorized_key_missing?).and_return(false)
        end

        it 'updates authorized_keys file if user inputs "y"' do
          STDIN.stub(:getch).and_return('y')
          sshatar_client.should_receive(:update_authorized_keys)

          sshatar_client.run
        end

        it 'updates authorized_keys file and creates backup first if user inputs "b"' do
          STDIN.stub(:getch).and_return('b')

          sshatar_client.should_receive(:create_backup)
          sshatar_client.should_receive(:update_authorized_keys)

          sshatar_client.run
        end

        it 'displays help if user inputs "?"' do
          STDIN.stub(:getch).and_return('?', 'n')

          sshatar_client.should_receive(:display_help)
          sshatar_client.should_not_receive(:update_authorized_keys)

          sshatar_client.run
        end

        it 'it does not update authorized_keys file if user inputs "n"' do
          STDIN.stub(:getch).and_return('n')

          sshatar_client.should_not_receive(:update_authorized_keys)

          sshatar_client.run
        end
      end
    end
  end
end

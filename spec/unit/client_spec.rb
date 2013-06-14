require 'spec_helper'
require_relative '../../lib/sshatar/client'

module Sshatar
  describe Client do
    let(:dummy_home) { base_path+'/spec/dummy_home_folder/' }
    let(:key_file) { dummy_home+'.ssh/authorized_keys' }
    let(:config_file) { dummy_home+'.sshatar_config' }
    let(:sshatar_client) {Client.new}

    before do
      FileUtils.mkdir_p base_path+"/spec/dummy_home_folder/.ssh"
      Client.stub(:home_folder).and_return(dummy_home)
    end

    after do
      FileUtils.rm_rf dummy_home
    end

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

    describe '#run' do
      it 'does not overwrite authorized_keys file if configuration not changed' do
        some_time = Time.now
        File.stub(:mtime).and_return(some_time)

        sshatar_client.should_not_receive(:update_authorized_keys)
        sshatar_client.run
      end

      it 'overwrites authorized_keys file if configuration changed' do
        some_time = Time.now
        File.should_receive(:mtime).with(key_file).and_return(some_time)
        File.should_receive(:mtime).with(config_file).and_return(some_time + 2)

        sshatar_client.should_receive(:update_authorized_keys)
        sshatar_client.run
      end
    end
  end
end

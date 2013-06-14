require 'spec_helper'
require_relative '../../lib/sshatar/client'

module Sshatar
  describe Client do
    let(:dummy_home) { base_path+'/spec/dummy_home_folder/' }
    let(:file) { dummy_home+'/.ssh/authorized_keys' }
    let(:sshatar_client) {Client.new}

    before do
      FileUtils.mkdir_p base_path+"/spec/dummy_home_folder/.ssh"
      Client.stub(:home_folder).and_return(dummy_home)
    end

    after do
      FileUtils.rm_rf dummy_home
    end

    it 'creates authorized_keys file' do
      File.exist?(file).should be_false

      sshatar_client.update_authorized_keys

      File.exist?(file).should be_true
    end

    it 'overwrites last authorized_keys file' do
      sshatar_client.update_authorized_keys
      last_time = File.mtime(file)

      sleep 0.0002
      sshatar_client.update_authorized_keys
      File.mtime(file).should_not eq last_time
    end

    it 'adds a comment when there are no authorized keys' do
      sshatar_client.update_authorized_keys

      File.read(file).should eq "# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN\n"
    end

    it 'starts downloading the keys if there are user in the config file' do
      Communicator.any_instance.stub(:get_keys_from).and_return(['12345', '67890'])
      sshatar_client.update_authorized_keys ['flooose']
      File.read(file).should eq "12345\n67890\n"
    end

  end
end

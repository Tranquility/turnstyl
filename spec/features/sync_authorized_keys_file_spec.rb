require 'spec_helper'
require_relative '../../lib/communicator'

describe 'Sync authorized_keys file' do
  let(:file) { File.expand_path('../../../testfile', __FILE__) }

  after do
    system("rm #{File.expand_path('../../../testfile', __FILE__)}")
  end

  it 'creates authorized_keys file' do
    File.exist?(file).should be_false

    Communicator.new.sync

    File.exist?(file).should be_true
  end

  it 'overwrites last authorized_keys file' do
    Communicator.new.sync
    last_time = File.mtime(file)

    Communicator.new.sync
    File.mtime(file).should_not eq last_time
  end

  it 'adds a comment when there are no authorized keys' do
    Communicator.new.sync

    File.read(file).should eq "# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN\n"
  end


end

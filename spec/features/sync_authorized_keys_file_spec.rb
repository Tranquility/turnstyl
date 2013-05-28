require 'spec_helper'
require_relative '../../lib/communicator'

describe 'Sync authorized_keys file' do
  after do
    puts "afterblock"
    system("rm #{File.expand_path('../../../testfile', __FILE__)}")
  end

  it 'creates authorized_keys file' do
    file = File.expand_path('../../../testfile', __FILE__)
    File.exist?(file).should be_false

    Communicator.new.sync

    File.exist?(file).should be_true
 end
end

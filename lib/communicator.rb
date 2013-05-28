class Communicator
  def sync
    system("echo '# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN'> #{File.expand_path('../../testfile', __FILE__)}")
  end
end

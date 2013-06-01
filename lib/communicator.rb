class Communicator
  def sync
    authorized_keys = shatarclient.people_with_access
    system("echo '# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN'> #{File.expand_path('../../testfile', __FILE__)}")

  end
end

class SshatarClient
  def new(config)

  end
end

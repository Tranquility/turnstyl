class Communicator
  def sync
    system("touch #{File.expand_path('../../testfile', __FILE__)}")
  end
end

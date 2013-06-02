require_relative 'communicator'

class SshatarClient
  def update_authorized_keys people=[]
    keys = []
    if people.empty?
      keys << '# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN'
    else
      people.each do |person|
        keys = keys + Communicator.new.get_keys_from(person)
      end
    end
    system("echo '#{keys.join("\n")}' > #{File.expand_path('../../testfile', __FILE__)}")
  end
end



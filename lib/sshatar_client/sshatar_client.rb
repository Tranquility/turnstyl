class SshatarClient
  def self.home_folder
    "~/"
  end

  def update_authorized_keys people=[]
    keys = []
    if people.empty?
      keys << '# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN'
    else
      people.each do |person|
        keys = keys + Communicator.new.get_keys_from(person)
      end
    end
    File.open(SshatarClient.home_folder+'.ssh/authorized_keys', 'w+') do |file|
      file.write(keys.join("\n") << "\n")
    end
  end
end



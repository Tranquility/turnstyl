require 'toml'

module Sshatar
  class Client
    def self.home_folder
      File.expand_path("~/")
    end

    def initialize
      @config_path = File.expand_path(Client.home_folder+".sshatar_config")
    end


    def run
      if File.mtime(@config_path) > File.mtime(Client.home_folder+".ssh/authorized_keys")
        update_authorized_keys
      end
    end

    def load_settings
      TOML.load_file(@config_path)
    end

    def update_authorized_keys
      settings = load_settings
      authorized_users = settings["userlist"]
      keys = []
      if authorized_users.empty?
        keys << '# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN'
      else
        authorized_users.each do |person|
          keys = keys + Communicator.new.get_keys_from(person)
        end
      end
      File.open(Client.home_folder+'/.ssh/authorized_keys', 'w+') do |file|
        file.write(keys.join("\n") << "\n")
      end
    end
  end
end

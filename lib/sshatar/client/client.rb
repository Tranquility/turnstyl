require 'toml'

module Sshatar
  class Client
    def self.home_folder
      File.expand_path("~/")
    end

    def initialize
      @config_path = File.expand_path(Client.home_folder+"/.sshatar_config")
    end

    def run
      if authorized_key_missing? || config_changed?
        update_authorized_keys
      end
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

    private

    def authorized_key_missing?
      !File.exist? Client.home_folder+"/.ssh/authorized_keys"
    end

    def config_changed?
      File.mtime(@config_path) > File.mtime(Client.home_folder+"/.ssh/authorized_keys")
    end

    def load_settings
      TOML.load_file(@config_path)
    end
  end
end

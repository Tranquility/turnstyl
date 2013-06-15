require 'toml'
require 'io/console'

module Sshatar
  class ConfigMissing < Exception; end
  class Client
    def self.home_folder
      File.expand_path("~/")
    end

    def initialize
      @config_path = File.expand_path(Client.home_folder+"/.sshatar_config")
      if config_file_missing?
        raise ConfigMissing, "Unable to run without a config file. RTFM"
      end
    end

    def run
      if authorized_key_missing? || config_changed?
        puts "Authorized keys file exists. Overwrite? [y/N/b/?]"
        input = STDIN.getch
        case input
        when "y"
          update_authorized_keys
        when "b"
          create_backup
          update_authorized_keys
        when "?"
          display_help
          run
        else
          puts "Doing nothing ..."
        end
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

    def config_file_missing?
      !File.exist? Client.home_folder+"/.sshatar_config"
    end

    def config_changed?
      File.mtime(@config_path) > File.mtime(Client.home_folder+"/.ssh/authorized_keys")
    end

    def load_settings
      TOML.load_file(@config_path)
    end

    def create_backup
      puts "Making a backup ..."
    end

    def display_help
      puts "I am helping you ..."
    end
  end
end

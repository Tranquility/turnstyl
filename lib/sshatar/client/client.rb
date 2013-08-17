require 'toml'
require 'io/console'

module Sshatar
  class ConfigMissing < Exception; end
  class Client
    def self.home_folder
      Dir.home
    end

    def initialize
      @config_path = File.expand_path(Client.home_folder+"/.sshatar_config")
      if config_file_missing?
        raise ConfigMissing, "Unable to run without a config file. RTFM"
      end
    end

    def run(force)
      if force
        update_authorized_keys
      else
        update_authorized_keys_carefully
      end
    end

    def update_authorized_keys_carefully
      if authorized_key_missing?
        update_authorized_keys
      elsif config_changed?
        print "Authorized keys file exists. Overwrite? [y/N/b/?]? "
        input = STDIN.gets.chomp
        case input
        when "y"
          update_authorized_keys
        when "b"
          create_backup
          update_authorized_keys
        when "?"
          display_help
          update_authorized_keys_carefully
        else
          puts "\nDoing nothing ..."
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
      puts "\nkeys updated..."
    end

    def authorized_key_missing?
      !File.exist? Client.home_folder+"/.ssh/authorized_keys"
    end

    def config_file_missing?
      !File.exist? Client.home_folder+"/.sshatar_config"
    end

    def config_changed?
      File.mtime(@config_path) > File.mtime(Client.home_folder+"/.ssh/authorized_keys")
    end

    def update_necessary?
      authorized_key_missing? || config_changed?
    end

    def create_backup
      puts "\nMaking a backup ..."
      number = Dir.glob(Client.home_folder+'/.ssh/authorized_keys*').count
      puts number
      FileUtils.mv(Client.home_folder+"/.ssh/authorized_keys", Client.home_folder+"/.ssh/authorized_keys.bak"+number.to_s)
    end

    private

    def load_settings
      TOML.load_file(@config_path)
    end

    def display_help
      puts <<-HERE

You tried to let sshatar manage your authorized_keys file, but there is an
existing authorized_keys file and you have to decide what you want to do with
it.

If you're sure you want to overwrite it choose "y" if you want to backup your
existing file choose "b"

HERE
    end
  end
end

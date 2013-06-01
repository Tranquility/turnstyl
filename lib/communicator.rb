require 'rest_client'
require 'json'

class Communicator
  def sync people=[]
    keys = []
    if people.empty?
      keys << '# YOU HAVE NOT AUTHORIZED ANYONE TO LOGIN'
    else
      people.each do |person|
        keys = keys + get_keys_from(person)
      end
    end
    system("echo '#{keys.join("\n")}' > #{File.expand_path('../../testfile', __FILE__)}")
  end

  def get_keys_from person
    keys = []
    response = RestClient.get "https://api.github.com/users/#{person}/keys"
    JSON.parse(response).each do |hash|
      keys << hash['key']
    end
    keys
  end
end

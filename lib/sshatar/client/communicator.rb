require 'rest_client'
require 'json'

class Communicator

  def get_keys_from person
    keys = []
    response = RestClient.get "https://api.github.com/users/#{person}/keys"
    JSON.parse(response).each do |hash|
      keys << hash['key']
    end
    keys
  end
end

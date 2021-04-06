require './lib/api_client.rb'
require "./require_files.rb"


class SlackClient < ApiClient
  attr_accessor :token

  def initialize(token)
    super(url: 'https://slack.com/api')
    connection.headers['Authorization'] = token
  end
end

class SlackClient < ApiClient
  attr_accessor :token

  def initialize(token)
    super(url: 'https://slack.com/api')
    connection.headers['Authorization'] = token
  end

  def get_lunch_users

  end
end

class ConnectSlack
  attr_accessor :connection, :token

  def initialize
    self.connection = Faraday.new(url: 'https://slack.com/api')
    self.token = SLACK_APP_TOKEN = ENV["SLACK_APP_TOKEN"]
  end

  def self.do_request(method, path, params)
    response = connection.public_send(
      method,
      path,
      params
    )

    parse_response(response.body)
  end

  def parse_response(body)
    JSON.parse(body, {symbolize_names: true})
  end
end

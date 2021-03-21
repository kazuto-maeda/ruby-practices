# puts 'スタンプを押して回ります！'

require 'json'
require 'time'
require 'date'
require 'faraday'
require 'dotenv'

Dotenv.load

time = Time.parse(Date.today.to_s).to_i
token = ENV["SLACK_APP_TOKEN"]
channel = "CHC3PJYMD"
my_user_id = "USG987S1Y"

connection = Faraday.new(url: 'https://slack.com/api')
response = connection.get(
  "conversations.history",
  {
    "channel": channel,
    "oldest": time,
    "pretty": 1,
    "token": token
  }
)

response_body =  JSON.parse(response.body, {symbolize_names: true})

messages = response_body[:messages]

messages.each do |message|
  next if message[:user] == my_user_id
  reactions = message.dig(:reactions)
  timestamp = message.dig(:ts)
  next if reactions.nil?
  sorted_reactions = reactions.sort {|a,b| a[:count] <=> b[:count]}
  reaction_name = sorted_reactions.last[:name]

  response = connection.post(
    "reactions.add",
    {
      "channel": channel,
      "name": "#{reaction_name}",
      "timestamp": "#{timestamp}",
      "pretty": 1,
      "token": token
    }
  )
  response_body =  JSON.parse(response.body, {symbolize_names: true})

  puts response_body
end

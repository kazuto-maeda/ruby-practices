# puts 'スタンプを押して回ります！'

require "./require_files.rb"
require "./slack/slack_client.rb"

Dotenv.load

time = Time.parse(Date.today.to_s).to_i
channel = "CHC3PJYMD"
my_user_id = "USG987S1Y"

slack_client = SlackClient.new(ENV["SLACK_APP_TOKEN"])

response_body = slack_client.get(
  "conversations.history",
  {
    "channel": channel,
    "oldest": time,
    "pretty": 1,
  }
)


messages = response_body[:messages]

messages.each do |message|
  next if message[:user] == my_user_id
  reactions = message.dig(:reactions)
  timestamp = message.dig(:ts)
  next if reactions.nil?
  sorted_reactions = reactions.sort {|a,b| a[:count] <=> b[:count]}
  reaction_name = sorted_reactions.last[:name]

  response_body = slack_client.post(
    "reactions.add",
    {
      "channel": channel,
      "name": "#{reaction_name}",
      "timestamp": "#{timestamp}",
      "pretty": 1,
    }
  )

  puts response_body
end

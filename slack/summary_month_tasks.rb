
require './require_files.rb'


Dotenv.load

current_month = Date.today.prev_month(1).beginning_of_month

channel = "CHC3PJYMD"
my_user_id = "USG987S1Y"

client = SlackClient.new(ENV["SLACK_APP_TOKEN"])

(current_month..current_month.end_of_month).each do |date|

  start_time = Time.parse(date.beginning_of_day.to_s).to_i
  end_time = Time.parse(date.end_of_day.to_s).to_i

  response = client.get(
    "conversations.history",
    {
      "channel": channel,
      "oldest": start_time,
      "latest": end_time,
      "pretty": 1,
    }
  )

  my_post = response[:messages].find { |message| message[:user] == my_user_id }

  next if my_post.blank?

  my_tasks = my_post[:text].split('```').last.split('【今日】').last

  puts my_tasks
end

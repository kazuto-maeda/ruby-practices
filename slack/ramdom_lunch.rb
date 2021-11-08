
puts 'ランダムランチ！'

require 'json'
require 'time'
require 'date'
require 'faraday'
require 'dotenv'

Dotenv.load

DEFAULT_MEMBER_COUNT = 4
FOOD_STAMPS = ["stew", "pancakes", "pizza", "hotdog", "hamburger", "shallow_pan_of_food", "sushi", "curry", "spaghetti", "dumpling",  "meat_on_bone", "taco"]
SPECIAL_FOOD_STAMPS = ["beer"]
OFFICE_CHANNELS = ["C980YRQM9"]
POST_TARGET_CHANNEL = "DSV2XCR9N"
SLACK_APP_TOKEN = ENV["SLACK_APP_TOKEN"]
LUNCHE_TRAIN_ID = "BUUKXRMN1"

class ConnectSlack
  attr_accessor :connection

  def initialize
    self.connection = Faraday.new(url: 'https://slack.com/api')
    # connection.post('posts', {post: {context: 'Hellow'}})
  end


  def get_users(time)
    users_array = OFFICE_CHANNELS.map do |channel|
      get_channel_users(channel, time)
    end

    puts users_array

    users_array.flatten.uniq
  end

  def get_channel_users(channel, time)
    
    response_body = do_request("get", "conversations.history", create_params_to_get_users(channel, time))


    messages = response_body[:messages].select {|message| message[:bot_id] == LUNCHE_TRAIN_ID}

    text = messages.first[:attachments].first[:text]

    extract_users(text)
  end

  def post_result(text)
    do_request("post", "chat.postMessage", create_params_to_post_result(POST_TARGET_CHANNEL, text))
  end

  def extract_users(text)

    got_users = text.scan(/<@(\w+)>/)

    mentions = got_users.flatten.map { |user| "<@#{user}>"}

    mentions.shuffle
  end

  def create_params_to_post_result(channel, text)
    {
      "channel": channel,
      "text": text,
      "token": SLACK_APP_TOKEN
    }
  end

  def create_params_to_get_users(channel, time)
    {
      "channel": channel,
      "oldest": time,
      "latest": time + 60 * 60 * 24,
      "pretty": 1,
      "token": SLACK_APP_TOKEN
    }
  end

  def do_request(method, path, params)
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

class LunchGroup
  attr_accessor :number_of_groups, :groups, :users_array

  def initialize(users_count)
    self.number_of_groups = calc_number_of_groups(users_count)
    self.groups = []
    self.number_of_groups.times { create_group }
  end

  def calc_number_of_groups(users_count)
    result = users_count.divmod(DEFAULT_MEMBER_COUNT)
    result[0] += 1 if result[0] < result[1]

    result[0]
  end

  def create_groups(users)
    users.each_with_index do |member, i|
      number = i % self.number_of_groups
      group = self.groups[number]
      group << member
    end
    self.groups
  end

  def create_group
    empty_group = []
    self.groups << empty_group
  end

  def create_text
    base_text = "▼ 今週のランランメンバーはこちらです ▼\n"

    group_texts = []
    stamps = shuffle_stamps

    self.groups.each.with_index(1) do |group, i|
      group_texts << " :#{stamps[i]}: チーム :#{stamps[i]}: ： #{group.join(", ")}"
    end
    base_text + group_texts.join("\n")
  end

  def shuffle_stamps
    int = rand(2)
    FOOD_STAMPS <<  SPECIAL_FOOD_STAMPS if int.zero?

    FOOD_STAMPS.flatten.shuffle
  end
end


time = Time.parse((Date.today).to_s).to_i

connect_slack = ConnectSlack.new

users = connect_slack.get_users(time)

lunch_groupe = LunchGroup.new(users.size)

lunch_groupe.create_groups(users)

text = lunch_groupe.create_text

puts text

connect_slack.post_result(text)

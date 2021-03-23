
puts 'ランダムランチ！'

require "./require_files.rb"
require "./slack/slack_client.rb"

Dotenv.load

DEFAULT_MEMBER_COUNT = 4
LUNCHE_TRAIN_ID = "BUUKXRMN1"
FOOD_STAMPS = ["stew", "pancakes", "pizza", "hotdog", "hamburger", "shallow_pan_of_food", "sushi", "curry", "spaghetti", "dumpling",  "meat_on_bone", "taco"]
SPECIAL_FOOD_STAMPS = ["beer"]
OFFICE_CHANNELS = ["C014JELF1T7", "C01052HE21K"]
POST_TARGET_CHANNEL = "DSV2XCR9N"

class RandomLunch
  attr_accessor :slack_client, :users, :groups, :group_num, :text

  def initialize
    self.slack_client = SlackClient.new(ENV["SLACK_APP_TOKEN"])
  end

  def create_groups
    self.users = get_users
    grouping_users
  end

  def post_message
    slack_client.post("chat.postMessage", create_params_to_post_result(POST_TARGET_CHANNEL, create_text))
  end

  private

  def grouping_users
    calc_group
    allocate_users
  end

  def calc_group
    result = self.users.size.divmod(DEFAULT_MEMBER_COUNT)
    result[0] += 1 if result[0] < result[1]

    self.group_num = result[0]

    self.groups = []
    self.group_num.times { self.groups << [] }
  end

  def allocate_users
    self.users.each_with_index do |member, i|
      number = i % self.group_num
      group = self.groups[number]
      group << member
    end
    self.groups
  end

  def get_users
    users_array = OFFICE_CHANNELS.map do |channel|
      get_lunch_users(channel)
    end

    users_array.flatten.uniq
  end

  def get_lunch_users(channel)
    # timestamp = Time.parse(Time.now.beginning_of_day.to_s).to_i

    response_body = slack_client.get("conversations.history", create_params_to_get_users(channel))

    messages = response_body[:messages].find {|message| message[:bot_id] == LUNCHE_TRAIN_ID}
    text = messages[:attachments].first[:text]

    extract_users(text)
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

  def extract_users(text)
    text.scan(/<@\w+>/).shuffle
  end

  def create_params_to_post_result(channel, text)
    {
      "channel": channel,
      "text": text,
    }
  end

  def create_params_to_get_users(channel)
    time = "2020/08/05"
    start = Time.parse(time).to_i
    today = Time.now.beginning_of_day
    {
      "channel": channel,
      "oldest": start,
      "latest": start + 60 * 60 * 24,
      "pretty": 1,
    }
  end
end

random_lunch = RandomLunch.new

random_lunch.create_groups

# random_lunch.post_message

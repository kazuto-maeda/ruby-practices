require './slack/random_lunch_creator.rb'

puts 'ランダムランチ！'

Dotenv.load

DEFAULT_MEMBER_COUNT = 4
LUNCHE_TRAIN_ID = "BUUKXRMN1"
FOOD_STAMPS = ["stew", "pancakes", "pizza", "hotdog", "hamburger", "shallow_pan_of_food", "sushi", "curry", "spaghetti", "dumpling",  "meat_on_bone", "taco"]
SPECIAL_FOOD_STAMPS = ["beer"]
OFFICE_CHANNELS = ["C014JELF1T7", "C01052HE21K"]
POST_TARGET_CHANNEL = "DSV2XCR9N"

random_lunch = RandomLunch.new

random_lunch.create_groups

random_lunch.post_message

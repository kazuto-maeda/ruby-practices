require 'selenium-webdriver'
require 'dotenv'

Dotenv.load

@wait_time = 3
@timeout = 4

# Seleniumの初期化
# class ref: https://www.rubydoc.info/gems/selenium-webdriver/Selenium/WebDriver/Chrome
Selenium::WebDriver.logger.output = File.join(ENV['ROOT_PATH'], "log", "selenium.log")

Selenium::WebDriver.logger.level = :warn
driver = Selenium::WebDriver.for :chrome
driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

# Yahooを開く
driver.get('https://mysys.work/')

# ちゃんと開けているか確認するため、sleepを入れる
sleep 2

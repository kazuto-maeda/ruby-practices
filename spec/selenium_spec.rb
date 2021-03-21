# 使用するライブラリを指定
require 'spec_helper'

# seleniumでchoromeを使用する
Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

# テストケース
RSpec.feature "Seleniumでテストサンプル", type: :feature  do
    scenario '入力フォームの確認' do

        # サンプルサイト(http://example.selenium.jp/reserveApp/)へアクセス
        visit 'http://example.selenium.jp/reserveApp/'
        sleep(3)
        # フォームへ入力（htmlタグのid指定）
        fill_in('reserve_year', with: '2018')
        fill_in('reserve_month', with: '4')
        fill_in('reserve_day', with: '1')
        fill_in('reserve_term', with: '3')
        fill_in('headcount', with: '5')
        fill_in('guestname', with: 'Selenium テスト')

        # ラジオボタンを選択（htmlタグのid指定）
        choose('breakfast_off')

        # チェックボックスを選択（htmlタグのid指定）
        check('plan_a')

        # ボタン押下
        click_on '次へ'

    end
end

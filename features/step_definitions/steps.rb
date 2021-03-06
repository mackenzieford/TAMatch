require 'uri'
require 'cgi'

Given(/^that I am an? (.*?)$/) do |role|
    @role = role
end

When(/^I login as "(.*?)"$/) do |email|
    begin
        @user = User.find_by(email: email)
        token = @user.generate_login_token
        visit '/auth?' + token
      rescue
        puts "##Did you seed the test db? THANKS AND GIG'EM!##"
        raise "##Make sure to seed the test db: 'rails db:seed RAILS_ENV=test'##"
    end
end

Then(/^I should( not)? see "(.*?)"$/) do |not_visible, text|
    begin
        expect(page.has_content?(text)).to eq !not_visible
    rescue
        raise "Did you seed the test db? 'rails db:migrate RAILS_ENV=test'"
    end
end

When(/^I login through google$/) do
    visit '/auth/google'
end

When(/^I am on the "(.*?)" page$/) do |targ_page|
    case targ_page
    when 'Dashboard'
        visit dashboard_path
    when 'Register'
        visit register_path
    when 'TA Application'
        visit ta_application_index_path
    when 'Instructor Preferences'
        visit prof_ranking_index_path
    end
end

And(/^I select "(.*?)" from "(.*?)"$/) do |item, form|
    select(item, :from => form)
end

And(/^I check "(.*?)"$/) do |item|
    check(item)
end

When(/^I input "(.*?)" to "(.*?)"$/) do |text, field|
    fill_in(field, :with => text)
end

And(/^I click "(.*?)"$/) do |button|
    click_button button
end

And(/^I click the link "(.*?)"$/) do |link_text|
    click_link link_text
end

Then(/^I can submit my information$/) do
    click_button "submit"
end

And(/^I want to register with "(.*?)" and "(.*?)"$/) do |email, username|
    user = User.find_by(email: email)
    if user
        user.destroy
    end
    user = User.find_by(username: username)
    if user
        user.destroy
    end
end
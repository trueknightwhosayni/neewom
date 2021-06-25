require 'rails_helper'

RSpec.describe "users tests", type: :feature do
  describe 'show users list' do
    before do
      User.create!(email: 'batman@test.com', data: { name: 'Bruce', role: 'Admin' })
      User.create!(email: 'ironman@test.com', data: { name: 'Tony', role: 'User' })
    end

    it 'should display users with virtual fields' do
      visit root_path

      expect(page).to have_content 'batman@test.com'
      expect(page).to have_content 'Bruce'
      expect(page).to have_content 'Admin'

      expect(page).to have_content 'ironman@test.com'
      expect(page).to have_content 'Tony'
      expect(page).to have_content 'User'
    end
  end

  describe 'create new user' do
    let!(:user_1) { User.create data: { name: 'Inviter 1' } }
    let!(:user_2) { User.create data: { name: 'Inviter 2' } }
    let!(:user_3) { User.create data: { name: 'Inviter 3' } }

    it 'should create new user' do
      visit root_path
      click_on "New User"

      within '#new_user' do
        fill_in "Name",	with: "Bruce"
        select 'Inviter 2', from: 'Inviter'
        select 'EN Cur Usser SomeHelper Cur Usser', from: 'Manager'
        fill_in "Email",	with: 'batman@test.com'
        fill_in "Password",	with: '11111111'
        fill_in "Password confirmation",	with: '11111111'
      end
      click_button 'Save'

      expect(page).to have_content "Bruce"
      expect(page).to have_content 'batman@test.com'

      user = User.last.neewom_view(:inviter, :manager)
      expect(user.inviter).to eq(user_2.id.to_s)
      expect(user.manager).to eq('1')
    end
  end

  describe 'edit existing user' do
    let!(:user) { User.create email: 'batman@test.com', data: { name: 'Bruce' } }

    it 'should update user' do
      visit root_path

      expect(page).to have_content "Bruce"
      expect(page).to have_content 'batman@test.com'

      click_on "Edit"

      within '.edit_user' do
        fill_in "Name",	with: "Tony"
        select 'EN Cur Usser SomeHelper Cur Usser', from: 'Manager'
        fill_in "Email",	with: 'ironman@test.com'
        fill_in "Password",	with: '11111111'
        fill_in "Password confirmation",	with: '11111111'
      end
      click_button 'Save'

      expect(page).to have_content "Tony"
      expect(page).to have_content 'ironman@test.com'
    end
  end
end

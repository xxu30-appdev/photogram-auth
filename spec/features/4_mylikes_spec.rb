require "rails_helper"

feature "My_likes:" do

  scenario "RCAV set for /my_likes", points: 1 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/my_likes"

    expect(page.status_code).to be(200) # 200 is "OK"
  end

  context "my likes" do
    scenario "shows photos a user has liked", points: 1 do
      user_1, user_2, user_3 = create_list(:user_with_photos, 3)

      like_1 = FactoryBot.create(:like, :user_id => user_1.id, :photo_id => user_1.photos.first.id)
      like_2 = FactoryBot.create(:like, :user_id => user_3.id, :photo_id => user_3.photos.first.id)
      login_as(user_2, :scope => :user)
      visit "/my_likes"

      user_2.likes.each do |like|
        expect(page).to have_content(like.photo.caption)
        expect(page).to have_css("img[src*='#{like.photo.image}']")
      end
    end

    scenario "does not show photos a user hasn't liked", points: 1 do
      user_1, user_2, user_3 = create_list(:user_with_photos, 3)

      like_1 = FactoryBot.create(:like, :user_id => user_1.id, :photo_id => user_1.photos.first.id)
      like_2 = FactoryBot.create(:like, :user_id => user_3.id, :photo_id => user_3.photos.first.id)

      login_as(user_2, :scope => :user)
      visit "/my_likes"

      user_1.likes.each do |like|
        expect(page).not_to have_content(like.photo.caption)
        expect(page).not_to have_css("img[src*='#{like.photo.image}']")
      end 
    end
  end

  scenario "header has link to /my_likes", points: 1 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within('nav') do
      expect(page).to have_link(nil, href: '/my_likes')
    end
  end

end

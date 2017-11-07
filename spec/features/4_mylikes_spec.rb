require "rails_helper"

feature "My_likes:" do

  scenario "RCAV set for /my_likes", points: 1 do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit "/my_likes"

    expect(page.status_code).to be(200) # 200 is "OK"
  end

  context "my likes" do
    before(:each) do
      @user_1 = FactoryGirl.create(:user, :username => "1", :email => "1@m.com")
      @user_2 = FactoryGirl.create(:user, :username => "2", :email => "2@m.com")
      @photo_1 = FactoryGirl.create(:photo, :user_id => @user_1.id)
      @photo_2 = FactoryGirl.create(:photo, :user_id => @user_1.id)
      @photo_3 = FactoryGirl.create(:photo, :user_id => @user_2.id)
      @like_1 = FactoryGirl.create(:like, :user_id => @user_2.id, :photo_id => @photo_1.id)
      @like_2 = FactoryGirl.create(:like, :user_id => @user_2.id, :photo_id => @photo_3.id)
      login_as(@user_2, :scope => :user)
      visit "/my_likes"
    end

    scenario "shows photos current user liked", points: 1 do
      @user_2.likes.each do |like|
        expect(page).to have_content(like.photo.caption)
        expect(page).to have_css("img[src*='#{like.photo.image}']")
      end
    end

    scenario "not shows photos current user liked", points: 1 do
      @user_1.likes.each do |like|
        expect(page).not_to have_content(like.photo.caption)
        expect(page).not_to have_css("img[src*='#{like.photo.image}']")
      end 
    end
  end

  scenario "header has link to /my_likes", points: 1 do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within('nav') do
      expect(page).to have_link(nil, href: '/my_likes')
    end
  end

end

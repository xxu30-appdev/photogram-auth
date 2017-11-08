require "rails_helper"

feature "Photos:" do

  context "index page" do
    before(:each) do
      @user_1 = FactoryBot.create(:user, :username => "1", :email => "1@m.com")
      @user_2 = FactoryBot.create(:user, :username => "2", :email => "2@m.com")
      @user_3 = FactoryBot.create(:user, :username => "Three", :email => "three@m.com")
      @photo_1 = FactoryBot.create(:photo, :user_id => @user_1.id)
      @photo_2 = FactoryBot.create(:photo, :user_id => @user_2.id)
      @photo_3 = FactoryBot.create(:photo, :user_id => @user_3.id)
    end

    scenario "only show edit link for signed-in user's photos", points: 1 do
      login_as(@user_2, :scope => :user)
      visit "/photos"

      @user_2.photos.each do |photo|
        expect(page).to have_link(nil, href: "/photos/#{photo.id}/edit")
      end

      @user_1.photos.each do |photo|
        expect(page).not_to have_link(nil, href: "/photos/#{photo.id}/edit")
      end
    end

    scenario "only show delete link for signed-in user's photos", points: 1 do
      login_as(@user_2, :scope => :user)
      visit "/photos"

      @user_2.photos.each do |photo|
        expect(page).to have_link(nil, href: "/delete_photo/#{photo.id}")
      end

      @user_1.photos.each do |photo|
        expect(page).not_to have_link(nil, href: "/delete_photo/#{photo.id}")
      end
    end

    scenario "in /photos, Bootstrap panels used", points: 1 do
      user = FactoryBot.create(:user)
      photo = FactoryBot.create(:photo, :user_id => user.id)
      login_as(user, :scope => :user)

      visit "/photos"

      expect(page).to have_css(".panel")
    end

    scenario "in /photos, Font Awesome fa-plus icon used (and 'Photos' h1 tag isn't)", points: 1 do
      user = FactoryBot.create(:user)
      photo = FactoryBot.create(:photo, :user_id => user.id)
      login_as(user, :scope => :user)

      visit "/photos"

      expect(page).to have_css(".fa-plus")
      expect(page).not_to have_selector("h1", text: "Photos")
    end

    scenario "/photos displays per-photo username, photo, and time elapsed", points: 1, hint: h("time_in_words") do
      login_as(@user_3, :scope => :user)

      visit "/photos"
      photos = Photo.all

      photos.each do |photo|
        expect(page).to have_content("#{photo.user.username}")
        expect(page).to have_css("img[src*='#{photo.image}']")
        expect(page).to have_content(ApplicationController.helpers.time_ago_in_words(photo.created_at))
      end
    end

    scenario "header uses Font Awesome fa-sign-out icon", points: 1 do
      user = FactoryBot.create(:user)
      login_as(user, :scope => :user)

      visit "/photos"

      within('nav') do
        expect(page).to have_css('.fa-sign-out')
      end
    end

    scenario "/photos lists comments with authors", points: 1 do
      comment_1 = FactoryBot.create(:comment, :user_id => @user_1.id, :body => "comment_1", :photo_id => @photo_1.id)
      comment_2 = FactoryBot.create(:comment, :user_id => @user_2.id, :body => "comment_two", :photo_id => @photo_3.id)
      login_as(@user_3, :scope => :user)

      visit "/photos"

      photos = Photo.all
      photos.each do |photo|
        photo.comments.each do |comment|
          expect(page).to have_content(comment.body)
          expect(page).to have_content(comment.user.username)
        end
      end
    end

    scenario "/photos shows Font Awesome heart icons to add/delete likes", points: 1, hint: h("font_awesome_css_must_match") do
      like_1 = FactoryBot.create(:like, :user_id => @user_1.id, :photo_id => @photo_1.id)
      like_2 = FactoryBot.create(:like, :user_id => @user_2.id, :photo_id => @photo_2.id)
      login_as(@user_1, :scope => :user)

      visit "/photos"

      expect(page).to have_css(".fa-heart")
      expect(page).to have_css(".fa-heart-o")
    end

    scenario "/photos includes form field with placeholder 'Add a comment...'", points: 1 do
      login_as(@user_1, :scope => :user)

      visit "/photos"

      expect(page).to have_selector("input[placeholder='Add a comment...']")
    end
  end
end

feature "Photos:" do

  scenario "quick-add a comment works and leads back to /photos", points: 2 do
    user_1 = FactoryBot.create(:user, :username => "1", :email => "1@m.com")
    user_2 = FactoryBot.create(:user, :username => "user_2", :email => "two@m.com")
    photo = FactoryBot.create(:photo, :user_id => user_1.id)
    login_as(user_2, :scope => :user)

    visit "/photos"
    new_comment = "Just added a comment at #{Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find(".fa-commenting-o").find(:xpath,".//..").click

    expect(page).to have_content(new_comment)
    expect(page).to have_current_path("/photos")
  end

  scenario "quick-add a comment sets the author correctly", points: 1, hint: h("display_id_or_username")  do
    user_1 = FactoryBot.create(:user, :username => "1", :email => "1@m.com")
    user_2 = FactoryBot.create(:user, :username => "user_2", :email => "two@m.com", :id => "#{Time.now.to_i}")
    photo = FactoryBot.create(:photo, :user_id => user_1.id)
    login_as(user_2, :scope => :user)

    visit "/photos"
    new_comment = "Just added a comment at #{Time.now.to_f + Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find(".fa-commenting-o").find(:xpath,".//..").click
    visit "/comments"

    expect(page).to have_content(new_comment)
    within('tr', text: new_comment) do
      if page.has_content?(user_2.id)
        expect(page).to have_content(user_2.id)
      else
        expect(page).to have_content(user_2.username)
      end
    end
  end

  scenario "quick-add a like works in /photos", points: 2 do
    user = FactoryBot.create(:user, :username => "1", :email => "1@m.com")
    photo = FactoryBot.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"
    find(".fa-heart-o").find(:xpath,".//..").click

    expect(page).to have_css(".fa-heart")
  end

  scenario "quick-delete a like works in /photos", points: 1 do
    user = FactoryBot.create(:user, :username => "1", :email => "1@m.com")
    photo = FactoryBot.create(:photo, :user_id => user.id)
    like = FactoryBot.create(:like, :user_id => user.id, :photo_id => photo.id)
    login_as(user, :scope => :user)

    visit "/photos"

    if page.has_link?(nil, href: "/delete_like/#{like.id}")
      expect(page).to have_css(".fa-heart")
      expect(page).to have_link(nil, href: "/delete_like/#{like.id}")
    else
      find(".fa-heart").click
      expect(page).to have_css(".fa-heart-o")
    end
  end

end

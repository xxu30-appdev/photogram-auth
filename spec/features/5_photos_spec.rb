require "rails_helper"

feature "Photos:" do

  context "index page" do

    scenario "only show edit link for signed-in user's photos", points: 1 do
      owner = create(:user)
      non_owner = create(:user)

      login_as(owner, :scope => :user)
      visit "/photos"

      owner.photos.each do |photo|
        expect(page).to have_link(nil, href: "/photos/#{photo.id}/edit")
      end

      non_owner.photos.each do |photo|
        expect(page).not_to have_link(nil, href: "/photos/#{photo.id}/edit")
      end
    end

    scenario "only show delete link for signed-in user's photos", points: 1 do
      owner = create(:user)
      non_owner = create(:user)

      login_as(owner, :scope => :user)
      visit "/photos"

      owner.photos.each do |photo|
        expect(page).to have_link(nil, href: "/delete_photo/#{photo.id}")
      end

      non_owner.photos.each do |photo|
        expect(page).not_to have_link(nil, href: "/delete_photo/#{photo.id}")
      end
    end

    scenario "in /photos, ADD PHOTO link should present (and 'Photos' h1 tag isn't)", points: 1 do
      user = create(:user)
      photo = create(:photo, :user_id => user.id)
      login_as(user, :scope => :user)

      visit "/photos"

      expect(page).to have_link("Add Photo", href: "/photos/new")
      expect(page).not_to have_selector("h1", text: "Photos")
    end

    scenario "/photos displays per-photo username", points: 1 do
      user = create(:user)
      login_as(user, :scope => :user)

      visit "/photos"
      photos = Photo.all

      photos.each do |photo|
        expect(page).to have_content("#{photo.user.username}")
      end
    end

    scenario "/photos displays photo", points: 1 do
      user = create(:user)
      login_as(user, :scope => :user)

      visit "/photos"
      photos = Photo.all

      photos.each do |photo|
        expect(page).to have_css("img[src*='#{photo.image}']")
      end
    end

    scenario "/photos displays per-photo time elapsed", points: 1, hint: h("time_in_words") do
      user = create(:user)
      login_as(user, :scope => :user)

      visit "/photos"
      photos = Photo.all

      photos.each do |photo|
        expect(page).to have_content(ApplicationController.helpers.time_ago_in_words(photo.created_at))
      end
    end

    scenario "header have Sign Out link", points: 1 do
      user = create(:user)
      login_as(user, :scope => :user)

      visit "/photos"

      within('nav') do
        expect(page).to have_link("Sign Out", href: "/users/sign_out")
      end
    end

    scenario "/photos lists comments with authors", points: 1 do
      user_1, user_2, user_3 = create_list(:user_with_photos, 3)

      comment_1 = FactoryBot.create(:comment, :user_id => user_1.id, :body => "comment_1", :photo_id => user_1.photos.first.id)
      comment_2 = FactoryBot.create(:comment, :user_id => user_2.id, :body => "comment_two", :photo_id => user_2.photos.first.id)
      login_as(user_3, :scope => :user)

      visit "/photos"

      photos = Photo.all
      photos.each do |photo|
        photo.comments.each do |comment|
          expect(page).to have_content(comment.body)
          expect(page).to have_content(comment.user.username)
        end
      end
    end

    scenario "/photos shows LIKE/UNLIKE button", points: 1 do
      user_1 = create(:user_with_photos)
      user_2 = create(:user_with_photos)

      like_1 = FactoryBot.create(:like, :user_id => user_1.id, :photo_id => user_1.photos.first.id)
      like_2 = FactoryBot.create(:like, :user_id => user_2.id, :photo_id => user_2.photos.first.id)
      login_as(user_1, :scope => :user)

      visit "/photos"

      expect(page).to have_css("button", text: 'Like')
      
      expect(page).to have_link("Unlike", href: "/delete_like/#{like_1.id}")
    end

    scenario "/photos includes form field with placeholder 'Add a comment...'", points: 1 do
      user = create(:user)
      login_as(user, :scope => :user)
      photo = FactoryBot.create(:photo, :user_id => user.id)

      visit "/photos"

      expect(page).to have_selector("input[placeholder='Add a comment...']")
    end
  end
end

feature "Photos:" do

  scenario "quick-add a comment works and leads back to /photos", points: 2 do
    user_1 = create(:user)
    user_2 = create(:user)
    photo = create(:photo, :user_id => user_1.id)
    login_as(user_2, :scope => :user)

    visit "/photos"
    new_comment = "Just added a comment at #{Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find(".fa-commenting-o").find(:xpath,".//..").click

    expect(page).to have_content(new_comment)
    expect(page).to have_current_path("/photos")
  end

  scenario "quick-add a comment sets the author correctly", points: 1, hint: h("display_id_or_username")  do
    user_1 = create(:user_with_photos)
    user_2 = create(:user)
    
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
    user = create(:user)
    photo = FactoryBot.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"
    find("button", text: 'Like').click

    expect(page).to have_link("Unlike", href: "/delete_like/#{photo.likes.first.id}")
  end

  scenario "quick-delete a like works in /photos", points: 1 do
    user = create(:user_with_photos)
    
    like = FactoryBot.create(:like, :user_id => user.id, :photo_id => user.photos.first.id)
    login_as(user, :scope => :user)

    visit "/photos"

    find(:xpath, "//a[@href='/delete_like/#{like.id}']").click

    expect(page).to have_css("button", text: 'Like')
  end

end

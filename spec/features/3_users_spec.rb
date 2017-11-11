require "rails_helper"

feature "Users:" do
  scenario "in routes.rb, 'get /users/:id' below 'devise_for :users'", points: 1 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/users/sign_in"

    expect(page.current_path).to eq "/"
  end

  scenario "user_id pre-populated in new photo form", points: 2 do
    user = create(:user)

    login_as(user, :scope => :user)
    visit "/photos/new"

    expect(page).to have_selector("input[value='#{user.id}']", visible: false)
  end

  scenario "RCAV dots connected for /users", points: 1 do
    user = create(:user)

    login_as(user, :scope => :user)
    visit "/users"

    expect(page.status_code).to be(200) # 200 is "OK"
  end

  scenario "/users lists all users", points: 3 do
    users = create_list(:user, 2)

    login_as(users.first, :scope => :user)
    visit "/users"

    users.each do |user|
      expect(page).to have_content(user.username)
    end
  end

  scenario "navbar includes link to /users", points: 1 do
    user = create(:user)

    login_as(user, :scope => :user)
    visit "/"

    within("nav") do
      expect(page).to have_link(nil, href: "/users")
    end
  end

  scenario "RCAV dots connected for /users/:id", points: 1 do
    user = create(:user)

    login_as(user, :scope => :user)
    visit "/users/#{user.id}"

    expect(page.status_code).to be(200) # 200 is "OK"
  end

  scenario "/users/:id lists user's details", points: 2 do
    user = create(:user)

    login_as(user, :scope => :user)
    visit "/users/#{user.id}"

    expect(page).to have_content(user.username)
  end

  scenario "/users/:id lists user's photos captions", points: 3 do
    user = create(:user)
    photo_1 = create(:photo, :user_id => user.id)
    photo_2 = create(:photo, :user_id => user.id)

    login_as(user, :scope => :user)
    visit "/users/#{user.id}"

    photos = Photo.all
    photos.each do |photo|
      expect(page).to have_content(photo.caption)
    end
  end

  scenario "/users/:id lists user's photos", points: 2 do
    user = create(:user)
    photo_1 = create(:photo, :user_id => user.id)
    photo_2 = create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/users/#{user.id}"

    photos = Photo.all
    photos.each do |photo|
      expect(page).to have_css("img[src*='#{photo.image}']")
    end
  end

  scenario "when signed in navbar has link to /users/:id", points: 2 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within("nav") do
      expect(page).to have_link(nil, href: "/users/#{user.id}")
    end
  end

  scenario "unless signed in, no link to /users/:id", points: 1 do
    user = create(:user)

    visit "/"

    within("nav") do
      expect(page).not_to have_link(nil, href: "/users/#{user.id}")
    end
  end
end

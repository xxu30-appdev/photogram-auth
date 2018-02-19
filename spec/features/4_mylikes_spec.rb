require "rails_helper"

describe "homepage" do
  it "navbar has link to /my_likes", points: 1 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within('nav') do
      expect(page).to have_link(nil, href: '/my_likes')
    end
  end
end

describe "/my_likes" do
  it "RCAV dots connected for /my_likes", points: 1 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/my_likes"

    expect(page.status_code).to be(200) # 200 is "OK"
  end
end

describe "/my_likes" do
  it "shows the captions of photos a user has liked", points: 3 do
    alice = create(:user_with_photos)
    bob = create(:user_with_photos)
    carol = create(:user_with_photos)

    create(:like, :user => alice, :photo => bob.photos.first)
    create(:like, :user => alice, :photo => carol.photos.first)

    login_as(alice, :scope => :user)
    visit "/my_likes"

    alice.likes.each do |like|
      expect(page).to have_content(like.photo.caption)
    end
  end
end

describe "/my_likes" do
  it "shows the images a user has liked", points: 2 do
    alice = create(:user_with_photos)
    bob = create(:user_with_photos)
    carol = create(:user_with_photos)

    create(:like, :user => alice, :photo => bob.photos.first)
    create(:like, :user => alice, :photo => carol.photos.first)

    login_as(alice, :scope => :user)
    visit "/my_likes"

    alice.likes.each do |like|
      expect(page).to have_css("img[src*='#{like.photo.image}']")
    end
  end
end

describe "/my_likes" do
  it "does not show the captions of photos a user hasn't liked", points: 3 do
    alice = create(:user_with_photos)
    bob = create(:user_with_photos)
    carol = create(:user_with_photos)

    create(:like, :user => alice, :photo => bob.photos.first)
    create(:like, :user => alice, :photo => carol.photos.first)

    login_as(alice, :scope => :user)
    visit "/my_likes"

    expect(page).not_to have_content(alice.photos.first.caption)
  end
end

describe "/my_likes" do
  it "does not show images a user hasn't liked", points: 2 do
    alice = create(:user_with_photos)
    bob = create(:user_with_photos)
    carol = create(:user_with_photos)

    create(:like, :user => alice, :photo => bob.photos.first)
    create(:like, :user => alice, :photo => carol.photos.first)

    login_as(alice, :scope => :user)
    visit "/my_likes"

    expect(page).not_to have_css("img[src*='#{alice.photos.first.image}']")
  end
end

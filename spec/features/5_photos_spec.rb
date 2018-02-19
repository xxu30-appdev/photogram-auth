require "rails_helper"

describe "/photos" do
  it "only shows edit link for signed-in user's photos", points: 3 do
    owner = create(:user_with_photos)
    non_owner = create(:user_with_photos)

    login_as(owner, :scope => :user)
    visit "/photos"

    owner.photos.each do |photo|
      expect(page).to have_link(nil, href: "/photos/#{photo.id}/edit")
    end

    non_owner.photos.each do |photo|
      expect(page).not_to have_link(nil, href: "/photos/#{photo.id}/edit")
    end
  end
end

describe "/photos" do
  it "only shows delete link for signed-in user's photos", points: 2 do
    owner = create(:user_with_photos)
    non_owner = create(:user_with_photos)

    login_as(owner, :scope => :user)
    visit "/photos"

    owner.photos.each do |photo|
      expect(page).to have_link(nil, href: "/delete_photo/#{photo.id}")
    end

    non_owner.photos.each do |photo|
      expect(page).not_to have_link(nil, href: "/delete_photo/#{photo.id}")
    end
  end
end

describe "/photos" do
  it "has 'Add Photo' link", points: 1 do
    user = create(:user)

    login_as(user, :scope => :user)
    visit "/photos"

    expect(page).to have_link("Add Photo", href: "/photos/new")
  end
end

describe "/photos" do
  it "'Photos' h1 element should not present", points: 1 do
    user = create(:user)

    login_as(user, :scope => :user)
    visit "/photos"

    expect(page).not_to have_selector("h1", text: "Photos")
  end
end

describe "/photos" do
  it "displays photos", points: 2 do
    users = create_list(:user_with_photos, 3)
    photos = Photo.all

    login_as(users.first, :scope => :user)
    visit "/photos"

    photos.each do |photo|
      expect(page).to have_css("img[src*='#{photo.image}']")
    end
  end
end

describe "/photos" do
  it "displays submitters' usernames", points: 3 do
    users = create_list(:user_with_photos, 3)
    photos = Photo.all

    login_as(users.first, :scope => :user)
    visit "/photos"

    photos.each do |photo|
      expect(page).to have_content("#{photo.user.username}")
    end
  end
end

describe "/photos" do
  it "displays time elapsed since posting photos", points: 1, hint: h("time_in_words") do
    users = create_list(:user_with_photos, 3)
    photos = Photo.all

    login_as(users.first, :scope => :user)
    visit "/photos"

    photos.each do |photo|
      expect(page).to have_content(ApplicationController.helpers.time_ago_in_words(photo.created_at))
    end
  end
end

describe "/photos" do
  it "lists comments in each photo", points: 1 do
    user_1, user_2, user_3 = create_list(:user_with_photos, 3)

    comment_1 = create(:comment, :user_id => user_1.id, :body => "comment_1", :photo_id => user_1.photos.first.id)
    comment_2 = create(:comment, :user_id => user_2.id, :body => "comment_two", :photo_id => user_2.photos.first.id)
    login_as(user_3, :scope => :user)

    visit "/photos"

    photos = Photo.all
    photos.each do |photo|
      photo.comments.each do |comment|
        expect(page).to have_content(comment.body)
      end
    end
  end
end

describe "/photos" do
  it "lists comments with authors", points: 1 do
    user_1, user_2, user_3 = create_list(:user_with_photos, 3)

    comment_1 = create(:comment, :user_id => user_1.id, :body => "comment_1", :photo_id => user_1.photos.first.id)
    comment_2 = create(:comment, :user_id => user_2.id, :body => "comment_two", :photo_id => user_2.photos.first.id)
    login_as(user_3, :scope => :user)

    visit "/photos"

    photos = Photo.all
    photos.each do |photo|
      photo.comments.each do |comment|
        expect(page).to have_content(comment.user.username)
      end
    end
  end
end

describe "/photos" do
  it "includes form field with placeholder 'Add a comment...'", points: 1 do
    user = create(:user)
    login_as(user, :scope => :user)
    photo = create(:photo, :user_id => user.id)

    visit "/photos"

    expect(page).to have_selector("input[placeholder='Add a comment...']")
  end
end

describe "/photos" do
  it "quick-add a comment should add comment", points: 2 do
    user_1 = create(:user_with_photos)
    user_2 = create(:user)
    login_as(user_2, :scope => :user)

    visit "/photos"

    new_comment = "Just added a comment at #{Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find("button", text: 'Add Comment').click

    expect(page).to have_content(new_comment)
  end
end

describe "/photos" do
  it "after adding a comment page it should leads back to /photos", points: 2 do
    user_1 = create(:user_with_photos)
    user_2 = create(:user)
    login_as(user_2, :scope => :user)

    visit "/photos"

    new_comment = "Just added a comment at #{Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find("button", text: 'Add Comment').click

    expect(page).to have_current_path("/photos")
  end
end

describe "/photos" do
  it "quick-add a comment sets the author correctly", points: 1, hint: h("display_id_or_username")  do
    user_1 = create(:user_with_photos)
    user_2 = create(:user)

    login_as(user_2, :scope => :user)

    visit "/photos"
    new_comment = "Just added a comment at #{Time.now.to_f + Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find("button", text: 'Add Comment').click
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
end

describe "/photos" do
  it "shows Like/Unlike buttons", points: 1 do
    user_1 = create(:user_with_photos)
    user_2 = create(:user_with_photos)

    like_1 = create(:like, :user_id => user_1.id, :photo_id => user_1.photos.first.id)
    like_2 = create(:like, :user_id => user_2.id, :photo_id => user_2.photos.first.id)
    login_as(user_1, :scope => :user)

    visit "/photos"

    expect(page).to have_css("button", text: 'Like')

    expect(page).to have_link("Unlike", href: "/delete_like/#{like_1.id}")
  end
end

describe "/photos" do
  it "displays a link to unlike a photo after liking a photo", points: 2 do
    user = create(:user)
    photo = create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"
    find("button", text: 'Like').click

    expect(page).to have_link("Unlike", href: "/delete_like/#{photo.likes.first.id}")
  end
end

describe "/photos" do
  it "displays a link to like a photo after unliking a photo", points: 1 do
    user = create(:user_with_photos)

    like = create(:like, :user_id => user.id, :photo_id => user.photos.first.id)
    login_as(user, :scope => :user)

    visit "/photos"

    find(:xpath, "//a[@href='/delete_like/#{like.id}']").click

    expect(page).to have_css("button", text: 'Like')
  end
end

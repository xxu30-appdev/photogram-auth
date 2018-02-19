require "rails_helper"


describe "homepage" do
  it "edit profile link's text is username", points: 3 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within("nav") do
      expect(page).to have_link(user.username, href: "/users/edit")
    end
  end
end

describe "homepage" do
  it "no 'dummy' text in sign out link", points: 1 do
    user = create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within("nav") do
      expect(find(:xpath, "//a[@href='/users/sign_out']").text).not_to eq("Dummy Sign Out Link")
    end
  end
end

describe "homepage" do
  it "shows sign-up link if signed out", points: 2 do
    visit "/"

    within("nav") do
      expect(page).to have_link(nil, href: "/users/sign_up")
    end
  end
end

describe "homepage" do
  it "shows sign-in link if signed out", points: 2 do
    visit "/"

    within("nav") do
      expect(page).to have_link(nil, href: "/users/sign_in")
    end
  end
end

describe "homepage" do
  it "does not show sign-out link if signed out", points: 2 do
    visit "/"

    within("nav") do
      expect(page).not_to have_link(nil, href: "/users/sign_out")
    end
  end
end

describe "homepage" do
  it "does not show edit link if signed out", points: 1 do
    visit "/"

    within("nav") do
      expect(page).not_to have_link(nil, href: "/users/edit")
    end
  end
end 

require "rails_helper"

feature "Header:" do

  scenario "edit profile link is just username", points: 2 do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within("nav") {
      expect(page).to have_link(user.username, href: "/users/edit")
    }
  end

  scenario "no 'dummy' text in sign-out link", points: 1 do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit "/"

    within("nav") {
      expect(find(:xpath, "//a[@href='/users/sign_out']").text).not_to eq("Dummy Sign Out Link")
    }
  end

  scenario "if logged out, sign-up/sign-in should present", points: 1 do
    visit "/"

    within("nav") {
      expect(page).to have_link(nil, href: "/users/sign_up")
      expect(page).to have_link(nil, href: "/users/sign_in")
    }
  end

  scenario "if logged out, sign-out/edit should not present", points: 1 do
    visit "/"

    within("nav") {
      expect(page).not_to have_link(nil, href: "/users/sign_out")
      expect(page).not_to have_link(nil, href: "/users/edit")
    }
  end

end

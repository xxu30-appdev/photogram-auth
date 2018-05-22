require "rails_helper"

describe "homepage" do
  it "root url set to photos index", points: 1 do
    user = create(:user)

    visit "/"

    if page.has_selector?("label", text: "Email")
      fill_in("Email", :with => user.email)
      fill_in("Password", :with => user.password)
      click_on("Sign in")
    end

    expect(page).to have_link(nil, href: "/photos/new")
  end
end

describe "homepage" do
  it "user authentication required for home page", points: 2 do
    visit "/"

    expect(page.current_path).to eq("/users/sign_in")
  end
end

describe "/users/sign_in" do
  it "login form works", points: 1 do
    user = create(:user)

    visit "/"
    fill_in("Email", :with => user.email)
    fill_in("Password", :with => user.password)
    click_on("Sign in")

    expect(page).to have_content("Signed in successfully.")
  end
end

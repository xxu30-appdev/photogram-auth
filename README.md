# Photogram / Auth

In this project, we'll practice tailoring the experience for users by allowing them to sign in so that we know who they are. We'll use the Devise gem to make authentication a snap.

We'll be building a simple clone of Instagram.

### [Here is your target for the required parts of the assignment](https://photogram-auth-target.herokuapp.com/) (associations, authentication).

Later, optionally, you will add image uploading and social networking.

## Domain Model

Suppose we design the following domain model for our application:

                                   +---------------------+
                                   |                     |
                                   |Comment              |
                                  /|=======              |\
                   +---------------|- body:text          |---------------+
                   |              \|- photo_id:integer   |/              |
                   |               |- user_id:integer    |               |
                   |               |                     |               |
                   |               +---------------------+               |
                   |                                                     |
                   |                                                     |
                   -                                                     -
                   |                                                     |
        +---------------------+                               +---------------------+
        |                     |                               |User                 |
        |Photo                |                               |====                 |
        |=====                |\                              |- username:string    |
        |- caption:string     |-----------------------------|-|- Devise columns     |
        |- image:string       |/                              |(email, password,    |
        |- user_id:integer    |                               |etc)                 |
        |                     |                               |                     |
        +---------------------+                               +---------------------+
                   |                                                     |
                   -                                                     -
                   |                                                     |
                   |                                                     |
                   |               +---------------------+               |
                   |               |                     |               |
                   |               |Like                 |               |
                   |              /|====                 |\              |
                   +---------------|- photo_id:integer   |---------------+
                                  \|- user_id:integer    |/
                                   |                     |
                                   |                     |
                                   +---------------------+

  - Associations
     - Users have many photos, a photo belongs to a user
     - Photos have many comments, a comment belongs to a photo
     - Users have many comments, a comment belongs to a user
     - Users have many likes, a like belongs to a user
     - Photos have many likes, a like belongs to a photo
     - Users have many `liked_photos` through likes. Since this breaks naming conventions (the method name, `.liked_photos`, does not exactly match the class name, `Photo`), we'll have to write out the full form of the has_many/through:

        ```ruby
        has_many :liked_photos, :through => :likes, :source => :photo
        ```

     - Similarly, Photos have many fans through likes (source: user):

        ```ruby
        has_many :fans, :through => :likes, :source => :user
        ```

  - Validations
     - User
         - username: presence, uniqueness
     - Photo
         - user_id: presence
     - Like
         - user_id: presence, uniqueness in combination with photo
         - photo_id: presence
     - Comment
         - user_id: presence
         - photo_id: presence
         - body: presence

Right now, this is a brand new application with nothing at all in it. Your job is to make it function and look like the target.

Below I suggest a plan of attack. Try to imagine, as you go through it, how each step would apply to your own app idea.

## Steps

 1. Download the code to your Cloud9 workspace as usual.
 1. `bin/setup`
 1. Click the Run Project button.
 1. Navigate to the app preview in Chrome and verify that it works.
 1. I've already added [draft_generators](https://guides.firstdraft.com/draftgenerators.html) and [Devise](https://guides.firstdraft.com/authentication-and-authorization-with-devise.html) to the Gemfile. You might want to pull up those cheatsheets and have them handy.
 1. You can navigate to `[YOUR APP PREVIEW URL]/git` in Chrome to access the visual Git interface; remember to commit and branch often so that you can always get back to a good state if an experiment goes wrong.
 1. Generate the User table [with Devise](https://guides.firstdraft.com/authentication-and-authorization-with-devise.html#generate-a-new-model-with-devise):

    ```bash
    rails generate draft:devise user username:string
    ```

    Devise will automatically add email, password, and all the other columns that it needs to secure accounts. You just specify any additional columns you want besides those (in this case, we only want username additionally).

 1. Generate the rest of your CRUD resources [with draft_generators](https://guides.firstdraft.com/draftgenerators.html#resources):

    ```bash
    rails generate draft:resource photo caption:text image:string user_id:integer
    rails generate draft:resource like user_id:integer photo_id:integer
    rails generate draft:resource comment photo_id:integer body:text user_id:integer
    ```

 1. Now that you have generated your model files, **add all of the associations and validations listed above immediately**.
 1. Set the root URL to the photos index page:

    ```ruby
    # In config/routes.rb
    root "photos#index"
    ```

 1. Finally, click through your app preview to see your work so far. If you haven't `rails db:migrate`d yet, it will ask you to now.
 1. Generate [a better application layout](https://guides.firstdraft.com/draftgenerators.html#application-layout), including Bootstrap:

    ```bash
    rails generate draft:layout
    ```

 1. I've included some random starter data for you to use while developing:

    ```bash
    rails dev:prime
    ```

    Now click around the app and see what we've got. (If you're curious, I used the [faker gem](https://github.com/stympy/faker) to create the silly random seed comments. It's very useful for quickly generating random names, addresses, etc.)

 1. Let's require that someone be signed in before they can do anything else. In `application_controller.rb`, add the line

    ```ruby
    before_action :authenticate_user!
    ```

    Now try and navigate around the app. It should demand that you sign in before allowing you to visit any page.

 1. Sign in with one of the seeded users; you can use `alice@example.com`, `bob@example.com`, or `carol@example.com`. All of the passwords are `password`.

 1. Add edit profile and sign-out links to the navbar.
    - If there is currently a signed-in user,
       - The link to edit profile should display the signed-in user's username instead.
       - Don't forget the `data-method="delete"` attribute on the "Sign Out" link.
    - If not, display links to sign-in (`/users/sign_in`) and sign-up (`/users/sign_up`) instead.

 1. On the new photo form, the user should not have to provide their ID number. Fix it using Devise's `current_user` helper method to pre-populate that input.

 1. Create an RCAV: When I visit `/users`, I should see an index of all users. This RCAV does not exist right now, since we used Devise to generate the User resource rather than starter_generators. Devise only builds the RCAVs required for sign-up/sign-in/sign-out/etc; it doesn't build the standard Golden Seven. But that's okay, because we can easily add the ones that we want ourselves (if any). Once done, add a link to the navbar.

 1. Create an RCAV: When I visit `/users/1`), I should see the details of user #1 along with all of his or her photos. Once done, add a link to the navbar that leads to the current user's show page. (This may lead to a problem when no one is signed in -- how can you fix it? Also, be careful where you add this route in `routes.rb` -- it needs to be below the line `devise_for :users`, otherwise it will conflict with `/users/sign_in` and `/users/sign_up`.)

 1. Create an RCAV: When I visit `/my_likes`, I should see only the photos that I have liked.  Once done, add a link to the navbar.

 1. On the photo show and index pages, I should only see the "Edit" and "Delete" buttons if it is my own photo.

 1. Optionally: Improve the styling.

 1. **Make the form to quick-add a comment directly below a photo work.**
 1. **Make the heart to quick-add/delete a like directly below a photo work.**

 1. Optional: On Canvas under "Additional Topics" there is a video and written guide to using the CarrierWave gem to enable image uploads (rather than pasting in existing URLs). Give it a try.
 1. Optional: Follow [the Tweeter example project](https://github.com/firstdraft/tweeter) to enable followers/timeline. You'll find an accompanying video titled "Social Network" under "Additional Topics" in Canvas.

[Here is a target for the optional parts of the assignment](https://photogram-final-target.herokuapp.com/) (file uploads, social network).

## The skills covered in this assignment are essential in 99% of apps. Ask lots of questions and book office hours! Good luck!

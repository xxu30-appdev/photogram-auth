namespace :dev do
  desc "Hydrate the database with some dummy data to make it easier to develop"
  task :prime => :environment do
    usernames = ["alice", "bob", "carol"]

    users = []

    usernames.each do |username|
      user = User.find_or_initialize_by(email: "#{username}@example.com")

      user.username = username
      user.password = "password"
      user.save

      users << user
    end

    puts "There are now #{User.count} users in the database."

    photo_info = [
      {
        :image => "http://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Lake_Bondhus_Norway_2862.jpg/1280px-Lake_Bondhus_Norway_2862.jpg",
        :caption => "Lake Bondhus"
      },
      {
        :image => "http://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Lanzarote_5_Luc_Viatour.jpg/1280px-Lanzarote_5_Luc_Viatour.jpg",
        :caption => "Cueva de los Verdes"
      },
      {
        :image => "http://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Fire_breathing_2_Luc_Viatour.jpg/1280px-Fire_breathing_2_Luc_Viatour.jpg",
        :caption => "Jaipur"
      },
      {
        :image => "http://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Ніжний_ранковий_світло.jpg/1280px-Ніжний_ранковий_світло.jpg",
        :caption => "Sviati Hory"
      },
      {
        :image => "http://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Mostar_Old_Town_Panorama_2007.jpg/1280px-Mostar_Old_Town_Panorama_2007.jpg",
        :caption => "Mostar"
      },
      {
        :image => "http://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Elakala_Waterfalls_Swirling_Pool_Mossy_Rocks.jpg/1280px-Elakala_Waterfalls_Swirling_Pool_Mossy_Rocks.jpg",
        :caption => "Elakala"
      },
      {
        :image => "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Biandintz_eta_zaldiak_-_modified2.jpg/1280px-Biandintz_eta_zaldiak_-_modified2.jpg",
        :caption => "Biandintz"
      }
    ]

    photos = []

    users.each do |user|
      photo_info.each do |photo_hash|
        p = Photo.new
        p.user_id = user.id
        p.image = photo_hash.fetch(:image)
        p.caption = photo_hash.fetch(:caption)
        p.save

        photos << p
      end
    end

    puts "There are now #{Photo.count} photos in the database."

    photos.each do |photo|
      if Comment.where(:photo_id => photo.id).count < 1
        rand(6).times do
          comment = Comment.new
          comment.photo_id = photo.id
          comment.user_id = users.sample.id
          comment.body = Faker::Hacker.say_something_smart
          comment.save
        end
      end
    end

    puts "There are now #{Comment.count} comments in the database."

    photos.each do |photo|
      users.sample(rand(users.count)).each do |user|
        like = Like.new
        like.photo_id = photo.id
        like.user_id = user.id
        like.save
      end
    end

    puts "There are now #{Like.count} likes in the database."

  end
end

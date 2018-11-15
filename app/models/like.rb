# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  photo_id   :integer
#  user_id    :integer
#

class Like < ApplicationRecord
    validates :photo_id, :presence => true
    validates :user_id, :presence => true

    validates :user_id, uniqueness: {
        scope: :photo_id,
        message: "Don't be so greedy and like a photo more than once!"
    }
    belongs_to :photos
    belongs_to :users
end

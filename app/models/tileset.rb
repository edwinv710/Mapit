class Tileset < ActiveRecord::Base
  attr_accessible :source
  has_many :layers
  validates :source, presence: true

end

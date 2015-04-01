class Ship < ActiveRecord::Base
    has_many :cells
    belongs_to :ocean
end
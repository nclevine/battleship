class Cell < ActiveRecord::Base
    belongs_to :ocean
    belongs_to :ship
end
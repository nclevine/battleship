class Ocean < ActiveRecord::Base
    has_many :cells, dependent: :destroy
    has_many :ships, dependent: :destroy
    belongs_to :game
end
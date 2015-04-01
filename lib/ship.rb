class Ship < ActiveRecord::Base
    has_many :cells
    belongs_to :ocean

    def insert_into_empty_cells(empty_cells)
        empty_cells.each do |cell| 
            cell.ship = self
            cell.save
        end
    end
end
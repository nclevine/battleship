class Ship < ActiveRecord::Base
    has_many :cells
    belongs_to :ocean

    def to_str
        name
    end

    def to_s
        to_str
    end

    def insert_into_empty_cells(empty_cells)
        empty_cells.each do |cell| 
            cell.ship = self
            cell.save
        end
    end

    def determine_if_sunk
        hit_cells = 0
        cells.each { |cell| hit_cells += 1 if cell.hit }
        sunk = true if hit_cells == self.length
        return sunk
    end
end
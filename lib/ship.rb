class Ship < ActiveRecord::Base
    has_many :cells
    belongs_to :ocean


    # I'd define a method like
    # def sunk?
    #   cells.where(hit: true) == self.length
    # end

    # in other words, there's no need to save the 'sunk' status to the DB, since
    # all the data is already there in the cells.
    # if performance were an issue, you might cache this value, but the method
    # above could reduce complexity in your ocean / game classes.

    def to_str
        name
    end

    def to_s
        to_str
    end

    def insert_into_empty_cells empty_cells
        empty_cells.each do |cell|
            cell.ship = self
            cell.save
        end
    end

    def update_sunk_status
        hit_cells = cells.where(hit: true)
        self.update(sunk: true) if hit_cells.length == self.length
        return sunk
    end
end

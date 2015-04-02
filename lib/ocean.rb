class Ocean < ActiveRecord::Base
    has_many :cells, dependent: :destroy
    has_many :ships, dependent: :destroy
    belongs_to :game

    def to_str
        name
    end

    def to_s
        to_str
    end

    def populate_with_cells
        height.times do |y_coord|
            width.times do |x_coord|
                cells.create(x_coord: x_coord + 1, y_coord: y_coord + 1, hit: false)
            end
        end
    end

    def get_unoccupied_cell
        x_coord, y_coord = rand(width) + 1, rand(height) + 1
        unoccupied_cell = cells.where(x_coord: x_coord, y_coord: y_coord).first
        until unoccupied_cell.ship == nil
            x_coord, y_coord = rand(width) + 1, rand(height) + 1
            unoccupied_cell = cells.where(x_coord: x_coord, y_coord: y_coord).first
        end
        return unoccupied_cell
    end

    def get_ship_orientation
        cardinal_direction = rand(4)
        case cardinal_direction
        when 0 # north
            then orientation = Proc.new { |cell| cells.where(x_coord: cell.x_coord, y_coord: cell.y_coord - 1).first }
        when 1 # east
            then orientation = Proc.new { |cell| cells.where(x_coord: cell.x_coord + 1, y_coord: cell.y_coord).first }
        when 2 # south
            then orientation = Proc.new { |cell| cells.where(x_coord: cell.x_coord, y_coord: cell.y_coord + 1).first }
        when 3 # west
            then orientation = Proc.new { |cell| cells.where(x_coord: cell.x_coord - 1, y_coord: cell.y_coord).first }        
        end
        return orientation
    end

    def find_empty_cells_for_ship ship
        fully_placed = false
        until fully_placed
            ship_cells = [get_unoccupied_cell]
            orientation = get_ship_orientation
            (ship.length - 1).times do |ship_cells_index|
                next_cell = orientation.call(ship_cells[ship_cells_index])
                next_cell ? (ship_cells << next_cell if next_cell.ship == nil) : break
            end
            fully_placed = true if ship_cells.length == ship.length
        end
        return ship_cells
    end

    def arrange_ships
        ships.each do |ship|
            empty_cells = find_empty_cells_for_ship(ship)
            ship.insert_into_empty_cells(empty_cells)
        end
    end
end
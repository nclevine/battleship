class Ocean < ActiveRecord::Base
    has_many :cells, dependent: :destroy
    has_many :ships, dependent: :destroy
    belongs_to :game
    # you could add an after_create here to populate with cells

    def to_str
        x_axis = '     '
        width.times do |x_coord|
            if (x_coord + 1) < 10
                x_axis += "  #{x_coord + 1} "
            else
                x_axis += " #{x_coord + 1} "
            end
        end
        horizontal_border = '    +' + ('---+' * width) + " \n"
        complete_ocean = x_axis + "\n" + horizontal_border
        height.times do |y_coord|
            current_row = ''
            if (y_coord + 1) < 10
                current_row += " #{y_coord + 1}  | "
            else
                current_row += "#{y_coord + 1}  | "
            end
            width.times do |x_coord|
                current_row += cells.where(x_coord: x_coord + 1, y_coord: y_coord + 1).first.to_s + ' | '
            end
            complete_ocean += current_row + "\n" + horizontal_border
        end
        return complete_ocean
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


    # I'd rename this method something like `random_unoccupied_cell` to indicate
    # that it's random.
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

    # this is certainly a clever way to do find empty cells for a ship, but I
    # think you've introduced more complexity than needed. I think it'd be
    # worthwhile talking about this one in person with you to see if we can find
    # a better way. part of leveling up as a developer is finding ways to reduce
    # a problem to the simplest solution, so that our code is easy to understand
    # and maintain / modify.
    def find_empty_cells_for_ship ship
        fully_placed = false
        until fully_placed
            ship_cells = [get_unoccupied_cell]
            orientation = get_ship_orientation
            (ship.length - 1).times do |ship_cells_index|
                # to further my comment above, I really had to think hard
                # to understand why this worked. the code isn't really telling
                # me what's happening here. i.e. ship_cells_index is only greater
                # than ship_cells.length in the case where we skiped a cell
                # below due to it not existing or having a ship placed already
                break if ship_cells_index >= ship_cells.length
                next_cell = orientation.call(ship_cells[ship_cells_index])
                ship_cells << next_cell if (next_cell && next_cell.ship == nil)
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

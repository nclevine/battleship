require_relative 'db/connection'
require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/ocean'
require_relative 'lib/ship'
require_relative 'lib/cell'
require 'pry'

milton_bradley_ships = {
    aircraft_carrier: {name: 'aircraft carrier', length: 5, sunk: false},
    battleship: {name: 'battleship', length: 4, sunk: false},
    submarine: {name: 'submarine', length: 3, sunk: false},
    cruiser: {name: 'cruiser', length: 3, sunk: false},
    destroyer: {name: 'destroyer', length: 2, sunk: false}
}

oceans_of_the_world = {
    pacific: {name: 'Pacific Ocean', width: 35, height: 30},
    atlantic: {name: 'Atlantic Ocean', width: 25, height: 20},
    indian: {name: 'Indian Ocean', width: 20, height: 15},
    southern: {name: 'Southern Ocean', width: 15, height: 10},
    arctic: {name: 'Arctic Ocean', width: 10, height: 10}
}

def populate_ocean_with_cells(ocean)
    ocean.height.times do |y_coord|
        ocean.width.times do |x_coord|
            ocean.cells.create(x_coord: x_coord + 1, y_coord: y_coord + 1, hit: false)
        end
    end
end

def get_unoccupied_cell(ocean)
    x_coord, y_coord = rand(ocean.width) + 1, rand(ocean.height) + 1
    unoccupied_cell = ocean.cells.where(x_coord: x_coord, y_coord: y_coord).first
    until unoccupied_cell.ship_id == nil
        x_coord, y_coord = rand(ocean.width) + 1, rand(ocean.height) + 1
        unoccupied_cell = ocean.cells.where(x_coord: x_coord, y_coord: y_coord).first
    end
    return unoccupied_cell
end

def get_ship_orientation(ocean)
    cardinal_direction = rand(4)
    case cardinal_direction
    when 0 then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord, y_coord: cell.y_coord - 1).first }
    when 1 then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord + 1, y_coord: cell.y_coord).first }
    when 2 then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord, y_coord: cell.y_coord + 1).first }
    when 3 then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord - 1, y_coord: cell.y_coord).first }        
    end
    return orientation
end

def place_ships_in_ocean(ocean, *ships)
    ships.each do |ship|
        bow_cell = get_unoccupied_cell(ocean)
        # direction = rand(4)
        
    end
end

binding.pry
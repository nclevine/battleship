require_relative 'db/connection'
require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/ocean'
require_relative 'lib/ship'
require_relative 'lib/cell'
require 'pry'

# milton_bradley_ships = {
#     aircraft_carrier: {name: 'aircraft carrier', length: 5, sunk: false},
#     battleship: {name: 'battleship', length: 4, sunk: false},
#     submarine: {name: 'submarine', length: 3, sunk: false},
#     cruiser: {name: 'cruiser', length: 3, sunk: false},
#     destroyer: {name: 'destroyer', length: 2, sunk: false}
# }

# oceans_of_the_world = {
#     pacific: {name: 'Pacific Ocean', width: 15, height: 15},
#     atlantic: {name: 'Atlantic Ocean', width: 13, height: 12},
#     indian: {name: 'Indian Ocean', width: 10, height: 10},
#     southern: {name: 'Southern Ocean', width: 8, height: 7},
#     arctic: {name: 'Arctic Ocean', width: 6, height: 6}
# }

# difficulty_settings = {
#     impossible: {region: :pacific, ship_array: [:aircraft_carrier, :aircraft_carrier, :aircraft_carrier, :battleship, :battleship, :battleship, :battleship, :submarine, :submarine, :cruiser, :cruiser, :destroyer]},
#     hard: {region: :atlantic, ship_array: [:aircraft_carrier, :aircraft_carrier, :battleship, :battleship, :submarine, :submarine, :cruiser, :destroyer, :destroyer]},
#     normal: {region: :indian, ship_array: [:aircraft_carrier, :battleship, :submarine, :cruiser, :cruiser, :destroyer]},
#     easy: {region: :southern, ship_array: [:battleship, :submarine, :cruiser, :destroyer]},
#     baby: {region: :arctic, ship_array: [:aircraft_carrier, :aircraft_carrier]}
# }

# def populate_ocean_with_cells(ocean)
#     ocean.height.times do |y_coord|
#         ocean.width.times do |x_coord|
#             ocean.cells.create(x_coord: x_coord + 1, y_coord: y_coord + 1, hit: false)
#         end
#     end
# end

# def get_unoccupied_cell(ocean)
#     x_coord, y_coord = rand(ocean.width) + 1, rand(ocean.height) + 1
#     unoccupied_cell = ocean.cells.where(x_coord: x_coord, y_coord: y_coord).first
#     until unoccupied_cell.ship == nil
#         x_coord, y_coord = rand(ocean.width) + 1, rand(ocean.height) + 1
#         unoccupied_cell = ocean.cells.where(x_coord: x_coord, y_coord: y_coord).first
#     end
#     return unoccupied_cell
# end

# def get_ship_orientation(ocean)
#     cardinal_direction = rand(4)
#     case cardinal_direction
#     when 0 # north
#         then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord, y_coord: cell.y_coord - 1).first }
#     when 1 # east
#         then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord + 1, y_coord: cell.y_coord).first }
#     when 2 # south
#         then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord, y_coord: cell.y_coord + 1).first }
#     when 3 # west
#         then orientation = Proc.new { |cell| ocean.cells.where(x_coord: cell.x_coord - 1, y_coord: cell.y_coord).first }        
#     end
#     return orientation
# end

# def find_empty_cells_for_ship(ocean, ship)
#     fully_placed = false
#     until fully_placed
#         ship_cells = [get_unoccupied_cell(ocean)]
#         orientation = get_ship_orientation(ocean)
#         (ship.length - 1).times do |ship_cells_index|
#             next_cell = orientation.call(ship_cells[ship_cells_index])
#             next_cell ? (ship_cells << next_cell if next_cell.ship == nil) : break
#         end
#         fully_placed = true if ship_cells.length == ship.length
#     end
#     return ship_cells
# end

# def place_ship_in_empty_cells(ship_cells, ship)
#     ship_cells.each do |cell| 
#         cell.ship = ship
#         cell.save
#     end
# end


# def place_ships_in_ocean(ocean, array_of_ships)
#     array_of_ships.each do |ship|
#         ship.ocean = ocean
#         ship.save
#     end
#     ocean.ships.each do |ship|
#         empty_cells = find_empty_cells_for_ship(ocean, ship)
#         place_ship_in_empty_cells(empty_cells, ship)
#     end
# end

def get_valid_menu_choice(num_choices)
  user_input = gets.strip.to_i
  until (1..num_choices).include?(user_input)
    puts "Select an available option."
    user_input = gets.strip.to_i
  end
  return user_input
end

def make_new_player
    puts 'What is your name?'
    name = gets.strip
    new_player = Player.new(name: name, num_torpedoes: 0, games_won: 0)
    until new_player.valid?
        puts 'Enter a name at least two letters long.'
        name = gets.strip
        new_player.name = name
    end
    new_player.save
end

def load_existing_player
    if Player.all.any?
        puts 'Please select a player:'
        Player.all.each_with_index { |player, index| puts "#{index + 1}. " + player }
    else
        puts 'There are no existing players.'
    end
end

# def build_ships_by_difficulty(difficulty)
#     built_ships = []
#     ship_names = difficulty_settings[difficulty][:ship_array]
#     ship_names.each { |ship_name| built_ships << Ship.new(milton_bradley_ships[ship_name]) }
#     return built_ships
# end

# def build_ocean_by_difficulty(difficulty)
#     ocean = Ocean.new(oceans_of_the_world[difficulty_settings[difficulty][:region]])
#     ocean.populate_ocean_with_cells
#     ocean.ships.create(build_ships_by_difficulty(difficulty))
#     ocean.arrange_ships
# end

# def create_new_game(difficulty)
#     new_game = Game.create(complete: false)
#     new_ocean = new_game.oceans.create(oceans_of_the_world[difficulty_settings[difficulty][:region]])
#     populate_ocean_with_cells(new_ocean)
# end

# def start_new_single_player_game(player)
    
#     player.games.create()
# end

# def load_existing_single_player_game(player)
    
# end

pacific = Ocean.new(oceans_of_the_world[:pacific])
pacific.game_id = 1
pacific.save
populate_ocean_with_cells(pacific)
pacific.ships.create([
    milton_bradley_ships[:aircraft_carrier],
    milton_bradley_ships[:battleship],
    milton_bradley_ships[:submarine],
    milton_bradley_ships[:cruiser],
    milton_bradley_ships[:destroyer],
    milton_bradley_ships[:aircraft_carrier]
])
place_ships_in_ocean(pacific)

binding.pry
require_relative 'db/connection'
require_relative 'lib/cell'
require_relative 'lib/ship'
require_relative 'lib/ocean'
require_relative 'lib/constants'
require_relative 'lib/game'
require_relative 'lib/player'
require 'pry'

def display_main_menu
    puts 'Battleship'
    puts '1. Choose Player'
    puts '2. New Player'
    puts '3. Delete Player'
    puts '4. Exit'
end

def get_valid_menu_choice num_choices
  user_input = gets.strip.to_i
  until (1..num_choices).include?(user_input)
    puts 'Select an available option.'
    user_input = gets.strip.to_i
  end
  return user_input
end

def display_existing_players
    if Player.all.any?
        puts 'Select a player:'
        Player.all.each_with_index { |player, index| puts "#{index + 1}. " + player }
    else
        puts 'There are no existing players.'
    end
    puts "#{Player.all.length + 1}. Cancel"
end

def make_new_player
    puts 'What is your name?'
    name = gets.strip
    new_player = Player.new(name: name, games_won: 0)
    until new_player.valid?
        puts 'Enter a name at least two letters long.'
        name = gets.strip
        new_player.name = name
    end
    new_player.save
    return new_player
end

# def display_delete_player_menu
#     puts 'Are you sure you want to delete ' + player_to_delete + '?'
#     puts 'Y / N'
#     user_input = gets.strip.downcase
#     until ['y', 'n'].include?(user_input)
#         puts 'Select \'Y\' or \'N\'.'
#         user_input = gets.strip.downcase
#     end
#     return user_input
# end

# def display_games_menu
#     puts 'Welcome ' + player
#     puts '1. New Game'
#     puts '2. Saved Games'
#     puts '3. Completed Games'
#     puts '4. Cancel'
# end

def display_new_game_menu
    puts 'Choose a difficulty:'
    puts '1. Baby (Arctic)'
    puts '2. Easy (Southern)'
    puts '3. Normal (Indian)'
    puts '4. Hard (Atlantic)'
    puts '5. Impossible (Pacific)'
end

difficulties = {1 => :baby, 2 => :easy, 3 => :normal, 4 => :hard, 5 => :impossible}

# def display_saved_games
#     incomplete_games = player.games.where(complete: false)
#     if incomplete_games.any?
#         puts 'Continue Playing:'
#         incomplete_games.each_with_index { |game, index| puts "#{index + 1}. " + game }
#     else
#         puts 'No games in progress.'
#     end
#     puts "#{incomplete_games.length + 1}. Cancel"
#     return incomplete_games
# end

# def display_completed_games
#     completed_games = player.games.where(complete: true)
#     if completed_games.any?
#         puts 'View Completed Game:'
#         completed_games.each_with_index { |game, index| puts "#{index + 1}. " + game }
#     else
#         puts 'No completed games.'
#     end
#     puts "#{completed_games.length + 1}. Cancel"
#     return completed_games
# end

# begin UI
system ('clear')
loop do
    display_main_menu
    user_input = get_valid_menu_choice(4)
    if user_input == 1 # Choose Player
        display_existing_players
        user_input = get_valid_menu_choice(Player.all.length + 1)
        # if user_input == Player.all.length + 1
        #     break
        # else
        if (1..Player.all.length).include?(user_input)
            player = Player.all[user_input - 1]
            player.display_games_menu
            user_input = get_valid_menu_choice(4)
            if user_input == 1 # New Game
                display_new_game_menu
                user_input = get_valid_menu_choice(5)
                game = player.start_new_single_player_game(difficulties[user_input])
                game.play
                game.results
            elsif user_input == 2 # Load Save Game
                incomplete_games = player.display_saved_games
                user_input = get_valid_menu_choice(incomplete_games.length + 1)
                # if user_input == incomplete_games.length + 1
                #     break
                # else
                if (1..incomplete_games.length).include?(user_input)
                    game = incomplete_games[user_input - 1]
                    game.play
                    game.results
                end
            elsif user_input == 3 # View Past Games
                completed_games = player.display_completed_games
                user_input = get_valid_menu_choice(completed_games.length + 1)
                # if user_input == completed_games.length + 1
                #     break
                # else
                if (1..completed_games.length).include?(user_input)
                    game = completed_games[user_input - 1]
                    game.display_board
                end
            # else
            #     break
            end
        end
    elsif user_input == 2 # New Player
        new_player = make_new_player
        puts("#{new_player} created!")
    elsif user_input == 3 # Delete Player
        display_existing_players
        user_input = get_valid_menu_choice(Player.all.length + 1)
        # if user_input == Player.all.length + 1
        #     break
        # else 
        if (1..Player.all.length).include?(user_input)
            player_to_delete = Player.all[user_input - 1]
            user_input = player_to_delete.display_delete_player_menu
            if user_input == 'y'
                puts("#{player_to_delete} deleted!")
                player_to_delete.destroy
            # else
            #     break
            end
        end
    else
        exit
    end
end

# binding.pry

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

# pacific = Ocean.new(oceans_of_the_world[:pacific])
# pacific.game_id = 1
# pacific.save
# populate_ocean_with_cells(pacific)
# pacific.ships.create([
#     milton_bradley_ships[:aircraft_carrier],
#     milton_bradley_ships[:battleship],
#     milton_bradley_ships[:submarine],
#     milton_bradley_ships[:cruiser],
#     milton_bradley_ships[:destroyer],
#     milton_bradley_ships[:aircraft_carrier]
# ])
# place_ships_in_ocean(pacific)

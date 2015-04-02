class Game < ActiveRecord::Base
    has_and_belongs_to_many :players
    has_one :ocean

    def to_str
        if !complete
            complete_string = "#{num_torpedoes} torpedoes left"
        else
            complete_string = "completed #{completed_at.strftime("%D %R")}"
        end
        "Game ##{id}, #{ocean.name}, begun #{created_at.strftime("%D %R")}, #{complete_string}"
    end

    def to_s
        to_str
    end

    difficulty_settings = {
        impossible: {region: :pacific, torpedoes: 55, ship_array: [:aircraft_carrier, :aircraft_carrier, :aircraft_carrier, :battleship, :battleship, :battleship, :battleship, :submarine, :submarine, :cruiser, :cruiser, :destroyer]},
        hard: {region: :atlantic, torpedoes: 41, ship_array: [:aircraft_carrier, :aircraft_carrier, :battleship, :battleship, :submarine, :submarine, :cruiser, :destroyer, :destroyer]},
        normal: {region: :indian, torpedoes: 30, ship_array: [:aircraft_carrier, :battleship, :submarine, :cruiser, :cruiser, :destroyer]},
        easy: {region: :southern, torpedoes: 21, ship_array: [:battleship, :submarine, :cruiser, :destroyer]},
        baby: {region: :arctic, torpedoes: 17, ship_array: [:aircraft_carrier, :aircraft_carrier]}
    }

    milton_bradley_ships = {
        aircraft_carrier: {name: 'aircraft carrier', length: 5, sunk: false},
        battleship: {name: 'battleship', length: 4, sunk: false},
        submarine: {name: 'submarine', length: 3, sunk: false},
        cruiser: {name: 'cruiser', length: 3, sunk: false},
        destroyer: {name: 'destroyer', length: 2, sunk: false}
    }

    oceans_of_the_world = {
        pacific: {name: 'Pacific Ocean', width: 15, height: 15},
        atlantic: {name: 'Atlantic Ocean', width: 13, height: 12},
        indian: {name: 'Indian Ocean', width: 10, height: 10},
        southern: {name: 'Southern Ocean', width: 8, height: 7},
        arctic: {name: 'Arctic Ocean', width: 6, height: 6}
    }

    def build_ships difficulty
        built_ships = []
        ship_names = difficulty_settings[difficulty][:ship_array]
        ship_names.each { |ship_name| built_ships << Ship.new(milton_bradley_ships[ship_name]) }
        return built_ships
    end

    def build_ocean difficulty
        ocean = ocean.create(oceans_of_the_world[difficulty_settings[difficulty][:region]])
        ocean.populate_with_cells
        ocean.ships.create(build_ships(difficulty))
        ocean.arrange_ships
        num_torpedoes = difficulty_settings[difficulty][torpedoes]
    end

    def play_or_quit
        puts '(A)im torpedo | (Q)uit'
        user_input = gets.strip.downcase
        until ['a', 'q'].include?(user_input)
            puts 'Select an available option.'
            user_input = gets.strip.downcase
        end
        return user_input
    end

    def fire_torpedo target_cell
        target_cell.hit = true
        target_cell.save
        num_torpedoes -= 1
        self.save
        return target_cell.ship_id != nil
    end

    def aim_and_fire_torpedo
        hit_a_cell = false
        until hit_a_cell
            puts 'Aim torpedo at which cell? (format "row#,column#")'
            user_input = gets.strip
            until user_input.include?(',')
                puts 'Enter the coordinates in the proper format.'
                user_input = gets.strip
            end
            coords = user_input.split(',').map(&:to_i)
            target_cell = ocean.cells.where(x_coord: coords.first, y_coord: coords.last).first
            if target_cell == nil
                puts 'Invalid coordinates. Re-enter.'
            elsif target_cell.hit
                puts 'You have already hit that sector. Re-enter.'
            else
                hit_ship = fire_torpedo(target_cell)
                puts "You shot (#{coords.first}, #{coords.last})..."
                hit_ship ? puts 'You hit a ship!' : puts 'sploosh.'
                hit_a_cell = true
            end
        end
    end

    def update_number_of_ships_sunk
        sunk_ships = 0
        ocean.ships.each { |ship| sunk_ships += 1 if ship.determine_if_sunk }
        return sunk_ships
    end

    def check_if_game_completed
        if num_torpedoes == 0 || update_number_of_ships_sunk == ocean.ships.length
            complete = true
            completed_at = Time.now
        end
        self.save
        return complete
    end

    def check_if_player_won
        if update_number_of_ships_sunk == ocean.ships.length
            player.games_won += 1
            player.save
            return true
        else
            return false
        end
    end

    def display_board
        puts ocean
    end

    def play
        until complete
            display_board
            user_input = play_or_quit
            user_input == 'a' ? aim_and_fire_torpedo : break
            check_if_game_completed
        end
        return complete
    end
end
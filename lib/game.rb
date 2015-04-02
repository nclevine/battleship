require_relative 'constants'

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

    # DIFFICULTY_SETTINGS = {
    #     impossible: {region: :pacific, torpedoes: 55, ship_array: [:aircraft_carrier, :aircraft_carrier, :aircraft_carrier, :battleship, :battleship, :battleship, :battleship, :submarine, :submarine, :cruiser, :cruiser, :destroyer]},
    #     hard: {region: :atlantic, torpedoes: 41, ship_array: [:aircraft_carrier, :aircraft_carrier, :battleship, :battleship, :submarine, :submarine, :cruiser, :destroyer, :destroyer]},
    #     normal: {region: :indian, torpedoes: 30, ship_array: [:aircraft_carrier, :battleship, :submarine, :cruiser, :cruiser, :destroyer]},
    #     easy: {region: :southern, torpedoes: 21, ship_array: [:battleship, :submarine, :cruiser, :destroyer]},
    #     baby: {region: :arctic, torpedoes: 17, ship_array: [:aircraft_carrier, :aircraft_carrier]}
    # }

    # MILTON_BRADLEY_SHIPS = {
    #     aircraft_carrier: {name: 'aircraft carrier', length: 5, sunk: false},
    #     battleship: {name: 'battleship', length: 4, sunk: false},
    #     submarine: {name: 'submarine', length: 3, sunk: false},
    #     cruiser: {name: 'cruiser', length: 3, sunk: false},
    #     destroyer: {name: 'destroyer', length: 2, sunk: false}
    # }

    # OCEANS_OF_THE_WORLD = {
    #     pacific: {name: 'Pacific Ocean', width: 15, height: 15},
    #     atlantic: {name: 'Atlantic Ocean', width: 13, height: 12},
    #     indian: {name: 'Indian Ocean', width: 10, height: 10},
    #     southern: {name: 'Southern Ocean', width: 8, height: 7},
    #     arctic: {name: 'Arctic Ocean', width: 6, height: 6}
    # }

    def build_ships difficulty
        built_ships = []
        ship_names = DIFFICULTY_SETTINGS[difficulty][:ship_array]
        ship_attrs = []
        ship_names.each { |ship_name| ship_attrs << MILTON_BRADLEY_SHIPS[ship_name] }
        ship_attrs.each { |ship_attr| built_ships << Ship.new(ship_attr) }
        return built_ships
    end

    def build_ocean difficulty
        ocean_attrs = OCEANS_OF_THE_WORLD[DIFFICULTY_SETTINGS[difficulty][:region]]
        new_ocean = Ocean.new(ocean_attrs)
        new_ocean.game = self
        new_ocean.save
        new_ocean.populate_with_cells
        built_ships = build_ships(difficulty)
        built_ships.each do |ship|
            ship.ocean = new_ocean
            ship.save
        end
        new_ocean.arrange_ships
        self.num_torpedoes = DIFFICULTY_SETTINGS[difficulty][:torpedoes]
        self.save
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
        self.num_torpedoes -= 1
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
                hit_ship ? puts('You hit a ship!') : puts('sploosh.')
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
        puts ocean.to_s
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

    def results
        if complete
            check_if_player_won ? puts('You won!') : puts('You lost.')
        else
            puts 'You quit the game'
        end
    end
end
class Game < ActiveRecord::Base
    has_and_belongs_to_many :players
    has_one :ocean

    def to_str
        if !complete
            complete_string = "incomplete"
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

    def build_ships(difficulty)
        built_ships = []
        ship_names = difficulty_settings[difficulty][:ship_array]
        ship_names.each { |ship_name| built_ships << Ship.new(milton_bradley_ships[ship_name]) }
        return built_ships
    end

    def build_ocean(difficulty)
        ocean = ocean.create(oceans_of_the_world[difficulty_settings[difficulty][:region]])
        ocean.populate_with_cells
        ocean.ships.create(build_ships(difficulty))
        ocean.arrange_ships
        num_torpedoes = difficulty_settings[difficulty][torpedoes]
    end

    def fire_torpedo(x_coord, y_coord)
        target_cell = ocean.cells.where(x_coord: x_coord, y_coord: y_coord).first
        target_cell.hit = true
        num_torpedoes -= 1
        return target_cell.ship_id != nil
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
        return complete
    end

    def check_if_player_won
        if update_number_of_ships_sunk == ocean.ships.length
            player.games_won += 1
            return true
        else
            return false
        end
    end

    def display_board
        puts ocean
    end
end
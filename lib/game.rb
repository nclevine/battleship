class Game < ActiveRecord::Base
    has_and_belongs_to_many :players
    has_one :ocean

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
    end
end
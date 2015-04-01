require_relative 'connection'
require_relative '../lib/player'
require_relative '../lib/game'
require_relative '../lib/ocean'
require_relative '../lib/ship'
require_relative '../lib/cell'

Player.destroy_all
Game.destroy_all
Ocean.destroy_all
Ship.destroy_all
Cell.destroy_all

Player.create(name: 'Noah', games_won: 0)

Player.first.games.create(complete: false)

Game.first.create_ocean(name: 'Indian Ocean', width: 10, height: 10)

Ocean.first.ships.create([
    {name: 'battleship', length: 4, sunk: false},
    {name: 'aircraft carrier', length: 5, sunk: false}
])

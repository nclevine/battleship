# player class
def start_new_two_player_game difficulty, player2
    new_game = games.create(num_torpedoes: 0, complete: false)
    ocean1 = new_game.build_ocean(difficulty)
    ocean2 = new_game.build_ocean(difficulty)
    new_game.players += player2
    new_game.save
    ocean1.player = self
    ocean1.save
    ocean2.player = player2
    ocean2.save
    return new_game
end

# game class
def fire_torpedo2 player_ocean, target_cell
    target_cell.update(hit: true)
    self.save
    return target_cell.ship
end

def aim_and_fire_torpedo2 player_ocean
    hit_a_cell = false
    until hit_a_cell
        puts 'Aim torpedo at which cell? (format "column#,row#")'
        user_input = gets.strip
        until user_input.include?(',')
            puts 'Enter the coordinates in the proper format.'
            user_input = gets.strip
        end
        coords = user_input.split(',').map(&:to_i)
        target_cell = player_ocean.cells.where(x_coord: coords.first, y_coord: coords.last).first
        if target_cell == nil
            puts 'Invalid coordinates. Re-enter.'
        elsif target_cell.hit
            puts 'You have already hit that sector. Re-enter.'
        else
            hit_ship = fire_torpedo2(player_ocean, target_cell)
            hit_a_cell = true
        end
    end
    result_string = "You shot (#{coords.first}, #{coords.last})...\n"
    if hit_ship
        result_string += 'You hit a ship!'
        hit_ship.update_sunk_status
        result_string += "\nThe ship sunk!!" if hit_ship.sunk
    else
        result_string += 'sploosh.'
    end
    result_string += "\n#{self.num_torpedoes} torpedoes left"
    return result_string
end

def update_ships_sunk_status2 player_ocean
    player_ocean.ships.each { |ship| ship.update_sunk_status }
    sunk_ships = player_ocean.ships.where(sunk: true)
    return sunk_ships.length
end

def update_completed_status2
    sunk_ships1 = update_ships_sunk_status2(oceans.first)
    sunk_ships2 = update_ships_sunk_status2(oceans.last)
    if self.num_torpedoes == 0 || sunk_ships1 == oceans.first.ships.length || sunk_ships2 == oceans.first.ships.length
        self.update(complete: true, completed_at: Time.now)
    end
    self.save
    return complete
end

def check_which_players_won player1, player2
    winning_players = []
    sunk_ships1 = update_ships_sunk_status2(player1.ocean)
    sunk_ships2 = update_ships_sunk_status2(player2.ocean)
    if sunk_ships1 == oceans.first.ships.length
        player_wins = player1.games_won + 1
        player1.update(games_won: player_wins)
        winning_players << player1
    end
    if sunk_ships2 == oceans.first.ships.length
        player_wins = player2.games_won + 1
        player2.update(games_won: player_wins)
        winning_players << player2
    end
    return winning_players
end

def display_board2 player
    system ('clear')
    puts player.ocean.to_s
end

def results2
    if complete
        winning_players = check_which_players_won
        if winning_players.length == 0
            puts 'Both players lost.'
        elsif winning_players.length == 1
            puts "#{winning_players.first} WON!!"
        else
            puts "#{winning_players.first} and #{winning_players.last} tied!"
        end
        puts "\nPress any key to continue."
        gets
    end
end

def player_turn player
    display_board2(player)
    puts result_of_turn
    user_input = play_or_quit
    user_input == 'a' ? (result_of_turn = aim_and_fire_torpedo2(player.ocean)) : break
end

def play_two_player
    player1 = players.first
    player2 = players.last
    until self.complete
        player_turn(player1)
        player_turn(player2)
        self.num_torpedoes -= 1
        self.save
        update_completed_status2
    end
    results2
end
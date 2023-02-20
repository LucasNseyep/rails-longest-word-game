require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    # raise
    @results = run_game(params[:attempt], params[:letters], params[:start_time], Time.now )
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    count = 0
    alphabet = ('A'..'Z').to_a
    while count < grid_size
      grid.append(alphabet.sample)
      count += 1
    end
    grid
  end

  def run_game(attempt, grid, start_time, end_time)
    time = end_time - start_time.to_datetime
    url = "https://wagon-dictionary.herokuapp.com/#{attempt.downcase}"
    check = JSON.parse(URI.open(url).read)
    if check["found"] && (attempt.upcase.chars.tally.all? { |letter, count| count <= grid.count(letter) })
      breakdown =  { time: time, score: (check["length"] + ((0.5 / time) * 10)).round(), message: "well done" }
      return results = "Congratulations, #{attempt.upcase} is an english word! \nYou took: #{breakdown[:time].round()}s to answer. \nYou scored: #{breakdown[:score]} points!\n"
    elsif check["found"] == false
      breakdown = { time: time, score: 0, message: "not an english word" }
      return results = "Sorry but #{attempt.downcase} isn't an english word... \nYou scored: #{breakdown[:score]} points :("
    elsif attempt.upcase.chars.tally.all? { |letter, count| count <= grid.count(letter) } == false
      breakdown = { time: time, score: 0, message: "not in the grid" }
      return results = "Sorry but #{attempt.upcase} isn't in the grid. \nYou scored: #{breakdown[:score]} points :("
    end
  end
end

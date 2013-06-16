require './lib/myanimelist'

begin
  ## TEST CLASSES
  class RunTests < Exception; end
  class TestFailed < Exception; end

  raise RunTests if ARGV[0] == 'test'

  #puts "ARGV = #{ARGV.inspect}    \nARGV[0] = #{ARGV[0]}"
  search_term = ARGV[0] || 'bakuman'

  results = MyAnimeList.search_anime(search_term, MyAnimeList.account)
  y results

  results = MyAnimeList.search_manga(search_term, MyAnimeList.account)
  y results

  # working
  #results = MyAnimeList.search_anime(search_term)
  #results = MyAnimeList.add_anime(10030,'watching')
  #results = MyAnimeList.update_anime(7674,'completed')
  #results = MyAnimeList.delete_anime(7674)

  #puts [results.class, HTTParty::Parser.new(results, :xml).parse]
  #y results

  mal = MyAnimeList.new 'config.yml'
  y mal
  y mal.config

rescue RunTests

  ## TESTS
  mal = MyAnimeList.new 'config.yml'

  raise TestFailed unless mal.config.username == 'jearsh'
  raise TestFailed unless mal.config.password == MyAnimeList.config_file.password

  puts "Tests pass!"
end

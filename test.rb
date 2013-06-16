require './lib/myanimelist'

begin
  ## TEST CLASSES
  class RunTests < Exception; end
  class TestFailed < Exception; end

  raise RunTests if ARGV[0] == 'test'

  #puts "ARGV = #{ARGV.inspect}    \nARGV[0] = #{ARGV[0]}"
  search_term = ARGV[0] || 'bakuman'

  # results = MyAnimeList.search_anime(search_term, MyAnimeList.account)
  # y results

  # results = MyAnimeList.search_manga(search_term, MyAnimeList.account)
  # y results

  # working
  #results = MyAnimeList.search_anime(search_term)
  #results = MyAnimeList.add_anime(10030,'watching')
  #results = MyAnimeList.update_anime(7674,'completed')
  #results = MyAnimeList.delete_anime(7674)

  #puts [results.class, HTTParty::Parser.new(results, :xml).parse]
  #y results

  y '                                                                           '
  y '---------------------------------------------------------------------------'
  y '---------------------------------------------------------------------------'
  y '                                                                           '

  mal = MyAnimeList.new 'config.yml'

  y mal.config.account

  y '                                                                           '
  y '---------------------------------------------------------------------------'
  y '---------------------------------------------------------------------------'
  y '                                                                           '

  y mal.search_anime search_term

rescue RunTests

  begin
    ## TESTS
    mal = MyAnimeList.new 'config.yml'

    raise TestFailed unless mal.config.username == 'jearsh'
    raise TestFailed unless mal.config.password == MyAnimeList.config_file.password

    results = mal.search_anime('ore+no+gurren')['anime']['entry']
    raise TestFailed, mal.last_message unless results['id'] == '10622'
    raise TestFailed, mal.last_message unless mal.add_anime(results['id'], 'watching') =~ /201.*created/i
    raise TestFailed, mal.last_message unless mal.update_anime(results['id'], 'completed') =~ /updated/i
    raise TestFailed, mal.last_message unless mal.delete_anime(results['id']) =~ /deleted/i

    results = mal.search_manga('tengen+toppa')['manga']['entry']
    raise TestFailed, mal.last_message unless results[0]['id'] == '1648'
    raise TestFailed, mal.last_message unless mal.add_manga(results[2]['id'], 'started') =~ /^\d\d*$/
    raise TestFailed, mal.last_message unless mal.update_manga(results[2]['id'], 'completed') =~ /updated/i
    raise TestFailed, mal.last_message unless mal.delete_manga(results[2]['id']) =~ /deleted/i

    puts "Tests pass!"

  rescue TestFailed => e
    puts "TEST FAILED"
    puts "-----------"
    puts e.message
    puts e.backtrace
  end
end

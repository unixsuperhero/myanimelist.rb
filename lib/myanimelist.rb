require 'httparty'

class MyAnimeList

  class << self
    def config
      Class.new do
        attr_accessor :username, :password
        def initialize
          vars=YAML.load(File.open('config.yml')).inject({}) {|p,(key,value)| p.merge key.to_sym => value }
          vars.each{|k,v| instance_variable_set "@#{k}".to_sym, v }
        end
      end.new
    end

    def account
      { username: config.username, password: config.password }
    end

    def search_anime(term)
      Anime.search(term)
    end

    def add_anime(id,data)
    end

    def update_anime(id,data)
    end

    def delete_anime(id,data)
    end

    def search_manga(term)
      Manga.search(term)
    end

    def add_manga(id,data)
    end

    def update_manga(id,data)
    end

    def delete_manga(id,data)
    end
  end

  class Parser
    def self.parse(data)
      HTTParty::Parser.new(data, :xml).parse
    end
  end

  class Anime
    class << self
      def search(term)
        response = HTTParty.get('http://myanimelist.net/api/anime/search.xml?q=' + term, basic_auth: MyAnimeList.account)
        Parser.parse(response)
      end
      def add(id,data)
      end
      def update(id,data)
      end
      def delete(id,data)
      end
    end
  end

  class Manga
    class << self
      def search(term)
        response = HTTParty.get('http://myanimelist.net/api/manga/search.xml?q=' + term, basic_auth: MyAnimeList.account)
        Parser.parse(response)
      end
      def add(id,data)
      end
      def update(id,data)
      end
      def delete(id,data)
      end
    end
  end
end

#puts "ARGV = #{ARGV.inspect}    \nARGV[0] = #{ARGV[0]}"
search_term = ARGV[0] || 'bakuman'
results = MyAnimeList.search_manga(search_term)
#puts [results.class, HTTParty::Parser.new(results, :xml).parse]
puts results

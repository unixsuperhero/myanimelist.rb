require 'httparty'

class MyAnimeList
  attr_accessor :config, :anime, :manga

  def initialize(options={})
    @config = Config.new options
    @anime = Anime
    @manga = Manga
  end

  def configure(options)
    @config.update options
    #return @config.merge! Config.new(options) if options.class.to_s =~ /^hash/i
    #@config.merge! Config.file(options) if options.is_a?(String)
  end

  class << self
    def config_file
      Class.new do
        attr_accessor :username, :password
        def initialize
          vars=YAML.load(File.open('config.yml')).inject({}) {|p,(key,value)| p.merge key.to_sym => value }
          vars.each{|k,v| instance_variable_set "@#{k}".to_sym, v }
        end
      end.new
    end

    def account
      { username: config_file.username, password: config_file.password }
    end

    def search_anime(term)
      Anime.search(term, MyAnimeList.account)
    end

    def add_anime(id,status='completed')
      Anime.add(id,status, MyAnimeList.account)
    end

    def update_anime(id,status)
      Anime.update(id,status, MyAnimeList.account)
    end

    def delete_anime(id)
      Anime.delete(id, MyAnimeList.account)
    end

    def search_manga(term)
      Manga.search(term, MyAnimeList.account)
    end

    def add_manga(id, status)
      Manga.add(id, status, MyAnimeList.account)
    end

    def update_manga(id, status)
      Manga.update(id, status, MyAnimeList.account)
    end

    def delete_manga(id)
      Manga.delete(id, MyAnimeList.account)
    end
  end

  class Config
    attr_accessor :options

    def initialize(opts={})
      @options = prepare opts
    end

    def update(opts={})
      @options.merge! prepare(opts)
    end

    def prepare(opts)
      Config.prepare(opts)
    end

    def username
      @options[:username]
    end

    def password
      @options[:password]
    end

    class << self
      def defaults
        {username: 'username', password: 'password'}
      end

      def prepare(opts)
        {}.tap{|o|
          opts = opts.options if opts.is_a? MyAnimeList::Config
          opts = load_file(opts) if opts.is_a? String
          o.merge! opts
        }
      end

      def load_file(name)
        YAML.load(File.open(name)).inject({}) {|p,(key,value)| p.merge key.to_sym => value }
      end

      def file(name)
        new load_file(name)
      end

      def options
        defaults.keys
      end
    end
  end

  class Parser
    def self.parse(data)
      HTTParty::Parser.new(data, :xml).parse
    end
  end

  class Anime
    class << self
      def search(term, options)
        response = HTTParty.get('http://myanimelist.net/api/anime/search.xml?q=' + term, basic_auth: options)
        Parser.parse(response)
      end
      def add(id,status='completed', options)
        puts "xml(status) = #{xml(status)}"
        response = HTTParty.post "http://myanimelist.net/api/animelist/add/#{id}.xml",
          basic_auth: options,
          body: {
            id: id,
            data: xml(status)
          }
      end
      def update(id,status='completed', options)
        puts "xml(status) = #{xml(status)}"
        response = HTTParty.post "http://myanimelist.net/api/animelist/update/#{id}.xml",
          basic_auth: options,
          body: {
            id: id,
            data: xml(status)
          }
      end
      def delete(id, options)
        response = HTTParty.post "http://myanimelist.net/api/animelist/delete/#{id}.xml",
          basic_auth: options
      end

      def xml(status)
        %~<?xml version="1.0" encoding="UTF-8"?>
          <entry>
            <status>#{status}</status>
          </entry>~
      end
    end
  end

  class API
    def search(type, query, options)
      options = Config.new(options)
      response = HTTParty.get("http://myanimelist.net/api/#{type}/search.xml?q=" + query, basic_auth: options)
      Parser.parse(response)
    end
    def add(type, id, data, options)
      options = Config.new(options)
      iface = MyAnimeList.new.send type.to_sym
      response = HTTParty.post "http://myanimelist.net/api/animelist/add/#{id}.xml",
        basic_auth: options,
        body: {
          id: id,
          data: iface.xml(data) # xml(status)
        }
    end
    def update(type, id, data, options)
      options = Config.new(options)
    end
    def delete(type, id, options)
      options = Config.new(options)
      response = HTTParty.post "http://myanimelist.net/api/animelist/delete/#{id}.xml",
        basic_auth: options
    end
  end

  class Manga
    class << self
      def search(term, options)
        response = HTTParty.get('http://myanimelist.net/api/manga/search.xml?q=' + term, basic_auth: options)
        Parser.parse(response)
      end
      def add(id,status='completed', options)
        response = HTTParty.post("http://myanimelist.net/api/mangalist/add/#{id}.xml", basic_auth: options, body: <<-BODY)
<?xml version="1.0" encoding="UTF-8"?>
<entry>
  <status>#{status}</status>
</entry>
        BODY
      end
      def update(id,data, options)
      end
      def delete(id,data, options)
      end
    end
  end
end

begin
  ## TEST CLASSES
  class RunTests < Exception; end
  class TestFailed < Exception; end

  raise RunTests if ARGV[0] == 'test'

  #puts "ARGV = #{ARGV.inspect}    \nARGV[0] = #{ARGV[0]}"
  search_term = ARGV[0] || 'bakuman'
  results = MyAnimeList.search_manga(search_term)

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
  y results

rescue RunTests

  ## TESTS
  mal = MyAnimeList.new 'config.yml'

  raise TestFailed unless mal.config.username == 'jearsh'
  raise TestFailed unless mal.config.password == MyAnimeList.config_file.password

  puts "Tests pass!"
end

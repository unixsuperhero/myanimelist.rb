require 'httparty'

class MyAnimeList
  attr_accessor :config, :anime, :manga, :last_message

  def initialize(options={})
    @config = Config.new options
    @anime = Anime
    @manga = Manga
  end

  def configure(options)
    @config.update options
  end

  def search_anime(term)                     @last_message = Anime.search(term, config)         end
  def add_anime(id, status='completed')      @last_message = Anime.add(id, status, config)      end
  def update_anime(id, status='completed')   @last_message = Anime.update(id, status, config)   end
  def delete_anime(id)                       @last_message = Anime.delete(id, config)           end

  def search_manga(term)                     @last_message = Manga.search(term, config)         end
  def add_manga(id, status='completed')      @last_message = Manga.add(id, status, config)      end
  def update_manga(id, status='completed')   @last_message = Manga.update(id, status, config)   end
  def delete_manga(id)                       @last_message = Manga.delete(id, config)           end

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

    def anime
      Anime
    end
    def manga
      Manga
    end
    def search_anime(term, config)
      Anime.search(term, config)
    end

    def add_anime(id,status='completed', config)
      Anime.add(id,status, config)
    end

    def update_anime(id,status, config)
      Anime.update(id,status, config)
    end

    def delete_anime(id, config)
      Anime.delete(id, config)
    end

    def search_manga(term, config)
      Manga.search(term, config)
    end

    def add_manga(id,data, config)
      Manga.add(id,data, config)
    end

    def update_manga(id,data, config)
      Manga.update(id,data, config)
    end

    def delete_manga(id, config)
      Manga.delete(id,config)
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

    def account
      [:username, :password].inject({}){|p,key| p.merge key => @options[key]}
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
      def type; 'anime' end
      def search(query, config) API.search(type, query, config); end
      def add(id, data, config) API.add(type, id, xml(data), config); end
      def update(id, data, config) API.update(type, id, xml(data), config); end
      def delete(id, config) API.delete(type, id, config); end

      def xml(data)
        <<-BODY.sub(/\s\s*/, '')
          <?xml version="1.0" encoding="UTF-8"?>
          <entry>
            <status>#{data}</status>
          </entry>
        BODY
      end
    end
  end

  class Manga
    class << self
      def type; 'manga' end
      def search(query, config) API.search(type, query, config); end
      def add(id, data, config) API.add(type, id, xml(data), config); end
      def update(id, data, config) API.update(type, id, xml(data), config); end
      def delete(id, config) API.delete(type, id, config); end
      def xml(data)
        <<-BODY.sub(/\s\s*/, '')
          <?xml version="1.0" encoding="UTF-8"?>
          <entry>
            <status>#{data}</status>
          </entry>
        BODY
      end
    end
  end

  class API
    class << self
      def search(type, query, config)
        config = Config.new(config)
        response = HTTParty.get "http://myanimelist.net/api/#{type}/search.xml?q=" + query,
                                basic_auth: config.account
        Parser.parse(response)
      end
      def add(type, id, data, config)
        #puts [type, id, data, config.account]
        config = Config.new(config)
        iface = MyAnimeList.new.send type.to_sym
        response = HTTParty.post "http://myanimelist.net/api/#{type}list/add/#{id}.xml",
          basic_auth: config.account,
          body: {
            id: id,
            data: data #iface.xml(data) # xml(status)
          }
      end
      def update(type, id, data, config)
        config = Config.new(config)
        iface = MyAnimeList.new.send type.to_sym
        response = HTTParty.post "http://myanimelist.net/api/#{type}list/update/#{id}.xml",
          basic_auth: config.account,
          body: {
            id: id,
            data: data #iface.xml(data) #xml(status)
          }
      end
      def delete(type, id, config)
        config = Config.new(config)
        response = HTTParty.post "http://myanimelist.net/api/#{type}list/delete/#{id}.xml",
          basic_auth: config.account
      end
    end
  end
end


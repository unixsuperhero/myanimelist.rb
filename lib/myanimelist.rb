class MyAnimeList

  class << self
    def search(term)
    end

    def add_anime(id,data)
    end

    def update_anime(id,data)
    end

    def delete_anime(id,data)
    end

    def add_manga(id,data)
    end

    def update_manga(id,data)
    end

    def delete_manga(id,data)
    end
  end

  class Search
    def search(term)
    end
  end

  class Anime
    def add(id,data)
    end
    def update(id,data)
    end
    def delete(id,data)
    end
  end

  class Manga
    def add(id,data)
    end
    def update(id,data)
    end
    def delete(id,data)
    end
  end
end


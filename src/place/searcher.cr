module Place
  class Searcher
    getter current_dir

    def self.search(dir)
      new(dir).tap {|s| s.search}
    end

    def initialize(@base_dir : String)
      @current_dir = Dir.new @base_dir
    end

    def search
      search_in
      puts "Finished at #{@current_dir.path}"
    end

    private def search_in
      descendants = @current_dir.children
        .select do |path|
          File.info( File.join @current_dir.path, path ).directory?
        end

      menu = Menu.new("Searching in #{@current_dir.path}...", descendants.sort)
      choice = menu.run

      puts "found choice: #{choice}"

      if choice
        @current_dir = Dir.new(File.join @current_dir.path, choice)
        search_in
      end
    end
  end
end

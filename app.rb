require 'reverse_markdown'
require 'securerandom'
require 'edn'
require 'pry'
require 'json'
require 'fileutils'
require 'action_view'
require 'zip'

class MochiCard
  attr_accessor :name, :id, :sort, :deck_id, :content, :new, :reviews

  def initialize(details = {})
    @name    = details[:name]    || 'Mochi Card'
    @content = details[:content] || ''
    @id      = details[:id]      || SecureRandom.uuid
    @new     = details[:new]     || false
    @sort    = details[:sort]    || 1
    @reviews = details[:reviews] || []
    @deck_id = details[:deck_id] || nil
  end

  def to_edn
    {
      content: convert_to_markdown(content),
      name: convert_to_markdown(name),
      reviews: reviews,
      id: EDN.symbol(':' + id),
      sort: EDN.symbol(sort.to_s),
      new?: new,
      deck_id: deck_id
    }.to_edn
  end

  def convert_to_markdown(html)
    html = ReverseMarkdown.convert(html, github_flavored: true)
    ActionView::Base.full_sanitizer.sanitize(html) 
  end
end

# WIP
# class AnkiCard
# end

# WIP
# class AnkiDeck
#   attr_accessor :name, :id, :contents
#   def initialize
#     @name = options[:name] ||
#     @id = nil
#     @cards = []
#   end
# end

class MochiDeck
  attr_accessor :name, :id, :cards, :version

  def initialize(details = {})
    @name     = details[:name]     || 'New Deck'
    @id       = details[:id]       || SecureRandom.uuid
    @cards    = details[:cards]    || []
    @version  = details[:version]  || 1
  end

  def to_edn
    self.instance_variables.each {|var| var.to_edn}
  end

  def create_file(anki_file_path, mochi_file_path)
    anki_deck  = JSON.parse(File.read(anki_file_path))
    anki_deck = anki_deck["notes"]
    anki_deck.each_with_index do |card, index|
      question = card["fields"][0]
      answer = card["fields"][1]
      @cards << MochiCard.new(
                name: card["fields"][0],
                content: "#{question} #{'<div></div>---<div></div>'} #{answer}",
                sort: EDN.symbol((@cards.size).to_s),
                deck_id: id
      )
      @cards << EDN.symbol(",") unless index + 1 == anki_deck.size
    end

    File.write(mochi_file_path, self.to_edn)
  end

  def to_edn
    {
      name: EDN.symbol(name).to_s,
      id: EDN.symbol(':' + id),
      cards: EDN.symbol(cards.to_edn),
      version: EDN.symbol(version.to_s)
    }.to_edn
  end

  def delete_exsiting_directory(dir_path)
    FileUtils.rm_rf(dir_path) if File.directory?(dir_path) 
  end

  def create_directory(dir_path)
    FileUtils.mkdir dir_path
  end

  def delete_and_create_directory(dir_path)
    delete_exsiting_directory(dir_path)
    create_directory(dir_path)
  end

  def create_and_clean_zip(new_dir_path, new_file_path)
    create_zip("#{new_dir_path}/data.mochi", new_file_path)
    delete_file(new_file_path)
  end

  def create_zip(dir_path, file_path)
    Zip::File.open("#{dir_path}", Zip::File::CREATE) {
      |zipfile|
      zipfile.get_output_stream("data.edn") do |f| 
        f.puts File.read("#{file_path}")
      end
    }
  end

  def delete_file(file)
    FileUtils.rm_rf(file)
  end
end

class AmConverter
  attr_accessor :anki_location, :mochi_location

  def initialize(details = {})
    @anki_location = details[:anki_location] || "anki_decks"
    @mochi_location = details[:mochi_location] || "mochi_decks"
  end

  def convert(deck_name = 'Anki')
    if deck_name == 'Anki'
      convert_anki_deck
    elsif deck_name == 'Mochi'
      # converts mochi_deck(deck)
      # @location = "mochi"
    end
  end

  def convert_anki_deck
    Dir.foreach(@anki_location) do |file_name|
      next unless File.extname(file_name) == ".json"

      file_base_name  = File.basename(file_name, File.extname(file_name))
      mochi_deck      = MochiDeck.new(name: file_base_name)
      mochi_dir_path  = "#{@mochi_location}/#{file_name}"
      mochi_file_path = "#{mochi_dir_path}/data.edn"
      anki_file_path  = "#{@anki_location}/#{file_name}"

      mochi_deck.delete_and_create_directory(mochi_dir_path)
      mochi_deck.create_file(anki_file_path, mochi_file_path)
      mochi_deck.create_and_clean_zip(mochi_dir_path, mochi_file_path)
    end
  end

  # WIP
  # def convert_mochi_deck 
  # end
end

am_converter = AmConverter.new

am_converter.convert('Anki')
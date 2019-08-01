require 'reverse_markdown'
require 'securerandom'
require 'edn'
require 'pry'
require 'json'
require 'fileutils'
require 'action_view'
require 'zip'

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

def replace_content_separator!(new_file_path)
  contents = File.read(new_file_path)
  contents.gsub!(/newline---newline/, "\\n---\\n")
  File.write(new_file_path, contents)
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


def create_mochi_deck_info(file_name, new_file_path, index_counter)
  anki_deck  = JSON.parse(File.read("anki/#{file_name}"))

  deck_name  = EDN.symbol("New Deck#{index_counter}").to_s
  deck_id    = EDN.symbol(':' + SecureRandom.uuid)
  mochi_deck = {name: deck_name, 
                id: deck_id, 
                cards: [], 
                version: EDN.symbol((1).to_s)}

  anki_deck.each_with_index do |card, index|
    card_id      = SecureRandom.uuid

    card_title = ReverseMarkdown.convert(card["sfld"], github_flavored: true)
    card_title = ActionView::Base.full_sanitizer.sanitize(card_title)

    card_content = card["flds"].gsub!(/\u001f/i, "newline---newline")
    card_content = ReverseMarkdown.convert(card_content, github_flavored: true)
    card_content = ActionView::Base.full_sanitizer.sanitize(card_content)

    mochi_deck[:cards] << { content: card_content,
                            name: card_title,
                            reviews: [],
                            new?: false,
                            sort: EDN.symbol((index + 1).to_s),
                            'deck-id': deck_id,
                            id: EDN.symbol(':' + card_id)
    }
    mochi_deck[:cards] << EDN.symbol(",") unless index + 1 == anki_deck.size
  end
  File.write(new_file_path, mochi_deck.to_edn)
end

def create_and_clean_zip(new_dir_path, new_file_path)
  create_zip("#{new_dir_path}/data.mochi", new_file_path)
  delete_file(new_file_path)
end

def start_app
  index_counter = 0

  Dir.foreach('anki') do |file_name|
    next unless File.extname(file_name) == ".json"
    index_counter += 1
    new_dir_path  = "mochi/new-deck-#{index_counter}"
    new_file_path = new_dir_path + '/data.edn'

    delete_and_create_directory(new_dir_path)
    create_mochi_deck_info(file_name, new_file_path, index_counter)
    replace_content_separator!(new_file_path)
    create_and_clean_zip(new_dir_path, new_file_path)
  end
end

start_app

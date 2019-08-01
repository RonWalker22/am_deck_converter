# Convert anki notes into mochi notes


## Use
* set up repo
  * `git clone repo` 
  * `cd repo`
  * `bundle install`
* Get Anki Json file
  * File > Export  > Save (From Anki Desktop)
    * File format = Anki Deck Package
    * Include = Deck Name(don’t use “ALL Decks”)
  * Unzip the `.apkg` file that has been generated
    * may need to change file extension to `.zip`
  * Open the `collection.anki2` with SQLiteBrowser
  * File > Export > Table to Json > Save (From SQLiteBrowser)
    * Table(s) = notes
    *  the json file must be saved or move to the `am_deck_converter/anki` directory
    * when saving, use a descriptive name such as the title of the deck to prevent naming conflicts when converting multiple decks
  * repeat for each deck
* Convert the decks
  * `ruby app.rb`
    * converted decks will be inside `am_deck_converter/moch` directory
    * each deck will have its own directory
* Import newly created mochi decks
    * Add Deck > Import Deck (From Mochi Desktop)
      * select the `data.mochi` file
  * repeat for each deck 

## Limitations
* Decks must be exported and imported one by one
  * Mochi(at the time of this tool's creation) doesn’t supports deck collection
    exports or imports
  * Anki does support deck collection exports, but because of Mochi’s limitation, you will need to export one by one. 
* Conversion
  * Due to the limitations of the converter gem I'm using not all html is converted into markdown. Most **should** get converted, the lingering HTML is stripped out.
  * all content(excluding media files and tags) **should** be transfered

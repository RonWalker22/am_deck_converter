# Convert anki notes into mochi notes


## Use
* set up repo
  * `git clone repo` 
  * `cd repo`
  * `bundle install`
* Export Anki deck as Json file
  * [Download CrowdAnki Addon](https://ankiweb.net/shared/info/1788670778)
  * File > Export  > Save (From Anki Desktop)
    * File format = CrowdAnki Json representation
    * Include = Deck Name(don’t use “ALL Decks”)
  * the json file should be saved or move to the `am_deck_converter/anki_decks` directory
  * repeat for each deck
* Convert the decks
  * `ruby app.rb`
    * converted decks will be inside `am_deck_converter/moch_decks` directory
    * each deck will have its own directory
* Import newly created mochi decks
    * Add Deck > Import Deck (From Mochi Desktop)
      * select the `.mochi` file from the `moch_decks` directory
  * repeat for each deck 

## Limitations
* Decks must be exported and imported one by one
  * Mochi(at the time of this tool's creation) doesn’t supports deck collection exports or imports
  * Anki does support deck collection exports, but because of Mochi’s limitation, you will need to export one by one. 
* Conversion
  * Due to the limitations of the converter gem I'm using not all html is converted into markdown. Most **should** get converted, the lingering HTML is stripped out.
  * all content(excluding media files and tags) **should** be transfered

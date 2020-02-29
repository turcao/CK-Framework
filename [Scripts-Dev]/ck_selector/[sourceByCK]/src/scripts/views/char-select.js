import Vue from 'vue/dist/vue.common';

class CharSelect {
  constructor() {
    if(window.location.href.indexOf('select-character') > -1) {
      this.initScript();
    }
  }

  initScript() {
    window.vm = new Vue({
      el: "#char_selection",
      data: {
        showCharList: false,
        characters: [],
	    },
      methods: {
        deleteChar: function(charid) {
          console.log(charid)
        },
        selectChar: function(charid) {
          console.log(charid)
        },
        emitCharacters: function(listcharacters) {
          this.showCharList = true;
          this.characters = listcharacters;
        },
        clearCharacters: function(){
          this.showCharList = false;
          this.characters = null;
        },
        createCharacter: function(){
          this.clearCharacters();
          $.post("http://ck_selector/CreateCharacter", JSON.stringify({}));
        }
      },
      mounted() {
      },
      created() {
      }
    });
  }
}

window.addEventListener('message', function(event) {
  switch(event.data.action) {
    case "listCharacters":
      window.vm.emitCharacters(event.data.listcharacters);
      break;
    case "closeCharacters":
      window.vm.clearCharacters();
      break;
  }
});

export default CharSelect;
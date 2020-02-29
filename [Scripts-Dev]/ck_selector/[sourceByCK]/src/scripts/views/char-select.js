import Vue from 'vue/dist/vue.common';

class CharSelect {
  constructor() {
    if (window.location.href.indexOf('select-character') > -1) {
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
        deleteChar: function (charid) {
          $.post("http://ck_selector/DeleteCharacter", JSON.stringify({charid}));
        },
        selectChar: function (charid) {
          $.post("http://ck_selector/SelectCharacter", JSON.stringify({charid}));
        },
        emitCharacters: function (listcharacters) {
          this.characters = null;
          this.showCharList = true;
          this.characters = listcharacters;
        },
        clearCharacters: function () {
          this.showCharList = false;
        },
        createCharacter: function () {
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

window.addEventListener('message', function (event) {
  switch (event.data.action) {
    case "listchar":
      if (event.data.characters) {
        window.vm.emitCharacters(event.data.characters);
      } else {
        window.vm.emitCharacters([]);
      }
      break;
    case "closeCharacters":
      window.vm.clearCharacters();
      break;
  }
});

export default CharSelect;
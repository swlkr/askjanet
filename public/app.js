var api = function(url, options) {
  var options = options || {};
  options.headers = options.headers || {};
  if(options.method.toLowerCase() !== 'get') {
    options['headers']['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content;
  }

  return window.fetch(url, options);
}

function signupForm() {
  return {
    email: '',

    disabled: function() {
      return this.email.indexOf('@') === -1;
    }
  }
}

function toggleDarkMode() {
  return api('/api/toggle-dark-mode', {
            method: 'post',
            headers: {
              'Content-Type': 'application/json'
            }
          })
          .then(function(response) {
            return response.json();
          })
          .then(function(response) {
            console.log(response);
          });
};

function app() {
  var startTheme = document.getElementsByTagName('html')[0].dataset.startTheme;
  var initialScheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  var colorScheme = startTheme || initialScheme;
  var darkMode = colorScheme === 'dark';

  return {
    modalOpen: false,
    action: '',
    colorScheme: colorScheme,
    darkMode: darkMode,

    toggleColorScheme: function() {
      this.darkMode = !this.darkMode;
      window.toggleDarkMode();
    }
  };
}

function voter(url, voted, votes) {
  return {
    voted: voted,
    votes: votes,

    vote: function() {
      var self = this;

      return api(url, {
                method: 'post',
                headers: {
                  'Content-Type': 'application/json'
                }
              })
              .then(function(response) {
                return response.json()
              })
              .then(function(response) {
                if (response.url) {
                  window.location.href = response.url;
                } else if (response.voted) {
                  self.voted = true;
                  self.votes = self.votes + 1;
                }
              })
              .catch(function(err) {
                console.log(err);
              })
    }
  }
}

window.matchMedia("(prefers-color-scheme: dark)").addListener(toggleTheme);

function toggleTheme(e) {
  if(e.matches) {
    // dark mode
    document.body.classList.remove('light-mode');
    document.body.classList.add('dark-mode');
  } else {
    // light mode
    document.body.classList.remove('dark-mode');
    document.body.classList.add('light-mode');
  }
}

function api(url, options) {
  var options = options || {};
  options.headers = options.headers || {};
  if(options.method.toLowerCase() !== 'get') {
    options['headers']['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content;
  }

  return fetch(url, options);
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
          })
          .catch(function(err) {
            console.log(err);
          })
};

function app(savedColorScheme) {
  var colorScheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark-mode' : 'light-mode';
  if(savedColorScheme !== "") {
    colorScheme = savedColorScheme;
  }

  return {
    modalOpen: false,
    action: '',
    colorScheme: colorScheme,

    toggleColorScheme: function() {
      this.colorScheme = (this.colorScheme === 'dark-mode' ? 'light-mode' : 'dark-mode');

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
                } else if (response.downvoted) {
                  self.voted = false;
                  self.votes = self.votes - 1;
                }
              })
              .catch(function(err) {
                console.log(err);
              })
    }
  }
}

function settings(url, initDailySummary) {
  return {
    dailySummary: initDailySummary,
    error: '',

    update: function() {
      self = this;
      this.dailySummary = this.dailySummary ? 0 : 1;

      return api(url, {
        method: 'post',
        headers: {
          'Content-Type': 'application/json'
        },
        body:  JSON.stringify({
          _method: "patch",
          "daily-summary": self.dailySummary.toString()
        })
      })
      .then(function(response) {
        return response.json()
      })
      .then(function(response) {})
      .catch(function(err) {
        self.dailySummary = initDailySummary;
        self.error = "Something went wrong :(";
      })
    }
  }
}

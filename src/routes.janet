(import joy :prefix "")

(defroutes app
  [:get "/" :home/index]
  [:get "/check-your-email" :auth-code/success]
  [:get "/sign-in" :auth-code/new]
  [:post "/auth-codes" :auth-code/create]
  [:get "/auth-codes/:auth-code" :session/create]
  [:get "/join" :account/new]
  [:post "/accounts" :account/create]

  [:get "/questions" :question/index]
  [:get "/questions/new" :question/new]
  [:post "/questions" :question/create]
  [:get "/questions/:id" :question/show]
  [:get "/questions/:id/edit" :question/edit]
  [:patch "/questions/:id" :question/patch]
  [:delete "/questions/:id" :question/destroy])

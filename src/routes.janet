(import joy :prefix "")

(defroutes app
  [:get "/" :home/index]
  [:get "/check-your-email" :auth-code/success]
  [:get "/sign-in" :auth-code/new]
  [:post "/auth-codes" :auth-code/create]
  [:get "/auth-codes/:auth-code" :session/create]
  [:get "/join" :account/new]
  [:post "/accounts" :account/create]
  [:delete "/sessions" :session/destroy]

  [:get "/questions/new" :question/new]
  [:post "/questions" :question/create]
  [:get "/questions/:id" :question/show]
  [:get "/questions/:id/edit" :question/edit]
  [:patch "/questions/:id" :question/patch]
  [:delete "/questions/:id" :question/destroy]

  [:get "/questions/:question-id/answers/new" :answer/new]
  [:post "/questions/:question-id/answers" :answer/create]
  [:get "/questions/:question-id/answers/:id/edit" :answer/edit]
  [:patch "/questions/:question-id/answers/:id" :answer/patch]
  [:delete "/questions/:question-id/answers/:id" :answer/destroy])

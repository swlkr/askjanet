(import joy :prefix "")

(defroutes app
  [:get "/" :home/index]
  [:get "/check-your-email" :auth-code/success]
  [:get "/sign-in" :auth-code/new]
  [:post "/auth-codes" :auth-code/create])
  # [:get "/join" :account/new]
  # [:post "/accounts" :account/create])

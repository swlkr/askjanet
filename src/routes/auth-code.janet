(use joy)
(import cipher)
(import ../helpers :prefix "")
(import ../mailgun)


(defn new [request]
  [:vstack {:spacing "l" :stretch "" :align-x "center" :align-y "center"}
   [:spacer]
   [:div {:style "width: 300px"}
    [:img {:src "camping_flatline.svg"}]]
   (form-with request {:method "POST" :id "form" :action "/auth-codes" :x-data "signupForm()" :style "width: 100%; max-width: 450px"}
    [:vstack {:spacing "m"}
     [:vstack {:spacing "l"}
      [:center
       [:h1 "Welcome back!"]]]

     [:vstack
      [:label {:for "email"} "enter your email for your auth link"]
      [:input {:type "email" :name "email" :id "email" :x-model "email"}]]

     [:center
      [:button {:type "submit" :style "width: 100%" :x-bind:disabled "disabled()"}
       "Sign in"]]])
   [:spacer]
   [:spacer]])


(defn- emails/sign-in [{:code code :email email}]
  (let [link (url "auth-codes" code)
        text (string/replace-all "__link__" link (slurp "emails/login.txt"))]
    (mailgun/send-message {:from from-email
                           :to email
                           :subject "Sign back in to askjanet"
                           :text text})))


(defn- auth-code []
  (string (cipher/bin2hex (os/cryptorand 8))))


(defn- auth-code-params []
  {:code (auth-code)
   :code-expires-at (+ 600 (os/time))})


(defn create [request]
  (when-let [email (get-in request [:body :email])
             account (db/find-by :account :where {:email email :deleted-at 'null})
             account (db/update :account account (auth-code-params))]
    (emails/sign-in account))

  (redirect-to :auth-code/success))


(defn success [request]
  [:center
   [:h1 "Check your email for your login link"]])

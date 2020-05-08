(use joy)
(use ../helpers)

(import ../mailgun)
(import cipher)


(defn new [request]
  [:vstack {:spacing "l" :align-x "center"}
    [:spacer]
    [:div {:style "width: 300px"}
     (svg "start_up")]
    [:div {:id "form" :x-data "signupForm()" :style "width: 100%; max-width: 450px"}
     (form-for [request :account/create]
      [:vstack {:spacing "m"}
       [:vstack {:spacing "l"}
        [:center
         [:h1 "Join ask janet!"]]

        [:vstack {:spacing "xs"}
         [:label "your new username"]
         [:input {:type "text" :name "name" :value (get-in request [:body :name])}]
         [:div {:class "red"} (get-in request [:errors :name])]]

        [:vstack {:spacing "xs"}
         [:label "your email"]
         [:input {:type "email" :name "email" :id "email" :x-model "email" :value (get-in request [:body :email])}]
         [:div {:class "red"} (get-in request [:errors :email])]]]

       [:button {:type "submit" :id "submit" :x-bind:disabled "disabled()"}
        "Join"]])]])


(defn username? [str]
  (def p '(<- (any (+ (range "az" "AZ" "09") (set "-_")))))

  (= str (first (peg/match p str))))


(defn emails/join [{:code code :email email}]
  (let [link (url "auth-codes" code)
        text (string/replace-all "__link__" link (slurp "emails/join.txt"))]
    (mailgun/send-message {:from from-email
                           :to email
                           :subject "Welcome to askjanet!"
                           :text text})))


(defn create [request]
  (def email (get-in request [:body :email]))
  (def name (get-in request [:body :name]))

  (when (blank? name)
    (put-in request [:errors :name] "Name can't be blank"))

  (when (blank? email)
    (put-in request [:errors :email] "Email is invalid"))

  (unless (username? name)
    (put-in request [:errors :name] "Name can only have letters, numbers, dashes and underscores"))

  (if (request :errors)
    (new request)
    (try
      (do
        (def account (db/insert :account (merge {:email email :name name :dark-mode 1} (auth-code-params))))
        (emails/join account)
        (redirect-to :auth-code/success))
      ([err fib]
       (cond
         (= "UNIQUE constraint failed: account.email" err)
         (new (put-in request [:errors :email] "Email is invalid"))

         (= "UNIQUE constraint failed: account.name" err)
         (new (put-in request [:errors :name] "Name is invalid"))

         :else (propagate err fib))))))


(defn rando []
  (cipher/bin2hex (os/cryptorand 5)))


(defn show [request]
  (when-let [account (request :account)
             questions (db/fetch-all [:account account :question])
             answers (db/fetch-all [:account account :answer])
             votes (db/fetch-all [:account account :vote])
             answer-votes (db/fetch-all [:account account :answer-vote])]
     [:vstack {:spacing "l"}

      [:h2 "Stats"]
      [:hstack {:spacing "m"}
       [:vstack
        [:h2 (length answers)]
        [:div "Answers"]]

       [:vstack
        [:h2 (length questions)]
        [:div "Questions"]]

       [:vstack
        [:h2 (+ (length votes) (length answer-votes))]
        [:div "Votes"]]]

      [:h2 "Settings"]
      [:div {:x-data (string/format "settings('%s', %d)" (url-for :account/patch) (account :daily-summary))}
       (form-for [request :account/patch account]
         [:vstack {:spacing "m"}
          [:hstack
           [:input (merge {:type "checkbox" :name "daily-summary" :value 1
                           :x-on:click.debounce "update()"
                           :x-bind:checked "dailySummary"}
                          (if (one? (account :daily-summary))
                            {:checked ""}
                            {}))]
           [:label {:for "daily-summary" :style "margin-left: 5px"} "Send me a daily summary email of my answered questions"]]

          [:noscript
           [:button {:type "submit"}
            "Save settings"]]])]

      [:h2 "Delete your account"]
      [:div "Deleting your account does not delete any questions, answers or votes you have made."]
      [:div "Instead, it changes your username to \"deleted user\""]
      [:div "After deleting you will NOT be able to recover any questions, answers or votes you made in the past."]
      [:a {:href "#" :@click.prevent "action = '/accounts'; modalOpen = true"}
       "Delete"]]))


(defn patch [request]
  (when-let [account (request :account)
             body (request :body)]
    (db/update :account account {:daily-summary (scan-number (or (body :daily-summary) "0"))})
    (if (json? request)
      (application/json {:status "ok"})
      (redirect-to :account/show account))))


(defn destroy [request]
  (when-let [account (request :account)
             deleted-username (string "deleted user " (rando))]
    (db/update :account account {:email (string deleted-username "@example.com") :deleted-at (os/time) :name deleted-username})
    (-> (redirect-to :home/index)
        (put :session @{}))))


(defn toggle-dark-mode [request]
  (def account (request :account))

  (if (nil? account)
    (application/json {:status 404 :message "Join to save your dark mode preferences!"})

    (let [new-dark-mode (if (one? (account :dark-mode)) 0 1)]
      (db/update :account account {:dark-mode new-dark-mode})
      (application/json {:status "success"}))))

(use joy)
(use ../helpers)

(import ../mailgun)


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
         [:input {:type "text" :name "name"}]
         [:div (get-in request [:errors :name])]]

        [:vstack {:spacing "xs"}
         [:label "your email"]
         [:input {:type "email" :name "email" :id "email" :x-model "email"}]
         [:div (get-in request [:errors :email])]]]

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
    (put-in request [:errors :email] "Email can't be blank"))

  (unless (username? name)
    (put-in request [:errors :name] "Name can only have letters, numbers, dashes and underscores"))

  (if (request :errors)
    (new request)
    (do
      (def account (db/insert :account (merge {:email email :name name :dark-mode 1} (auth-code-params))))
      (emails/join account)
      (redirect-to :auth-code/success))))

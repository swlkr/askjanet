(use joy)
(use ../helpers)

(import moondown)


(defn show [request]
  (let [params (request :params)
        question (db/find :question (params :id))
        account (request :account)
        asker (db/find :account (question :account-id))
        answers (db/fetch-all [:question question :answer])
        votes (db/fetch-all [:question question :vote])
        acct (db/find :account (question :account-id))]
    [:vstack {:spacing "l"}
     [:hstack {:spacing "m"
               :x-data (string/format "voter('/api/questions/%d/votes', %s, %d)" (question :id) (if (empty? votes) "false" "true") (length votes))}
      [:vstack {:align-x "center" :align-y "top"}
       [:a {:href "#"
            :@click.prevent "vote()"
            :tabindex "0"
            :role "button"
            :aria-label "upvote"}
         [:span {:x-show "!voted"}
          (svg "caret-up")]
         [:span {:x-show "voted"}
          (svg "caret-up-fill")]]
       [:div {:x-text "votes"}]]
      [:aside
       [:vstack {:spacing "l"}
        [:h2 {:style "margin-top: 0" :responsive ""}
          (question :title)]
        (when (question :body)
          [:div (raw (moondown/render (markdown/escape (question :body))))])
        [:vstack {:align-y "bottom" :spacing "m"}
         [:hstack {:spacing "l"}
          [:hstack {:spacing "xs"}
           [:div (length answers)]
           [:strong "answers"]]
          [:hstack {:spacing "xs"}
           [:div {:x-text "votes"} (length votes)]
           [:strong "upvotes"]]]
         [:hstack
          [:hstack {:spacing "xs"}
           [:span (datestring (question :created-at))]
           [:span (asker :name)]]
          [:spacer]
          (when (= (get account :id) (question :account-id))
            [:a {:href (url-for :question/edit question)}
             "Edit question"])]]]]]

     [:h2 "Answers"]

     (when (empty? answers)
       [:div "None so far. Be the first!"])

     (foreach [answer answers]
       (let [answerer (db/find :account (answer :account-id))]
         [:aside
          [:vstack {:spacing "m"}
           [:div (raw (moondown/render (markdown/escape (answer :body))))]
           [:vstack {:align-y "bottom"}
            [:hstack {:spacing "xs" :stretch ""}
             [:hstack {:spacing "xs"}
              [:div (datestring (answer :created-at))]
              [:div (answerer :name)]]
             [:spacer]
             (when (= (get account :id) (answer :account-id))
               [:hstack {:spacing "m"}
                [:a {:href (string/format "/questions/%d/answers/%d/edit" (question :id) (answer :id))}
                  "Edit"]
                [:a {:href "#" :@click (string/format "action = '/questions/%d/answers/%d'; modalOpen = true" (question :id) (answer :id))}
                  "Delete"]])]]]]))


     [:hstack
      [:a {:href (string "/questions/" (question :id) "/answers/new")}
       [:button "Answer"]]]]))


(defn form [request route &opt question]
  (if (nil? (request :account))
    (redirect "/join")

    [:vstack {:spacing "l"}
     (form-for [request route question]
       [:vstack {:spacing "l"}
        [:vstack {:spacing "xs"}
         [:label {:for "title"} "title"]
         [:input {:type "text" :name "title" :value (question :title)}]
         [:div (get-in request [:errors :title])]]

        [:vstack {:spacing "xs"}
         [:label {:for "body"} "body"]
         [:textarea {:rows 10 :name "body"}
          (question :body)]]

        [:button {:type "submit"}
         "Ask"]])]))


(defn new [request]
  (if (request :account)
    (form request :question/create)
    (redirect-to :account/new)))


(defn create [request]
  (when-let [account (request :account)
             body (request :body)]

    (when (blank? (body :title))
      (put-in request [:errors :title] "Needs a title"))

    (if (request :errors)
      (new request)
      (do
        (db/insert :question {:account-id (account :id)
                              :title (body :title)
                              :body (body :body)})
        (redirect-to :home/index)))))


(defn edit [request]
  (when-let [account (request :account)
             question (db/fetch [:account account :question (request :params)])]
    (form request :question/patch question)))


(defn patch [request]
  (when-let [account (request :account)
             params (request :params)
             question (db/fetch [:account account :question (params :id)])
             body (request :body)]

    (when (blank? (body :title))
      (put-in request [:errors :title] "Needs a title"))

    (if (request :errors)
      (edit request)
      (do
        (db/update :question question {:title (body :title) :body (body :body)})
        (redirect-to :question/show {:id (question :id)})))))


(defn destroy [request]
  (when-let [account (request :account)
             question (db/fetch [:account account :question (request :params)])]
     (db/delete :question question)
     (redirect-to :question/index)))

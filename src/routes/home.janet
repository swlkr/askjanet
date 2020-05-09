(use joy)
(use ../helpers)
(import json)


(defn index [request]
  (let [account (request :account)
        questions (db/fetch-all [:question] :order "created_at desc")
        all-accounts (group-by :id (db/fetch-all [:account]))
        all-votes (group-by :question-id (db/fetch-all [:vote]))
        all-answers (group-by :question-id (db/fetch-all [:answer]))]
    [:vstack {:spacing "l"}
     [:hstack {:stretch ""}
      [:spacer]
      [:a {:href "/questions/new"}
       [:button "Ask a question"]]]
     (foreach [q questions]
       (let [votes (get all-votes (q :id) [])
             answers (get all-answers (q :id) [])]
         [:hstack {:spacing "m"
                   :x-data (string/format "voter('%s', %s, %d)"
                                          (url-for :vote/toggle q)
                                          (if (empty? (filter |(= (get account :id)  (get $ :account-id)) votes))
                                            "false"
                                            "true")
                                          (length votes))}
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
          [:aside {:stretch ""}
           [:vstack {:spacing "s" :stretch ""}
            [:h2 {:style "margin-top: 0" :responsive ""}
             [:a {:href (string "/questions/" (q :id))}
              (q :title)]]
            [:vstack {:align-y "bottom" :spacing "xs"}
             [:hstack {:spacing "l"}
              [:hstack {:spacing "xs"}
               [:div (length answers)]
               [:strong "answers"]]
              [:hstack {:spacing "xs"}
               [:div {:x-text "votes"} (length votes)]
               [:strong "upvotes"]]]
             [:hstack {:spacing "xs"}
              [:div (datestring (q :created-at))]
              [:div (get-in all-accounts [(q :account-id) 0 :name])]]]]]]))]))


(defn open [request]
  (let [questions (first (db/query "select count(id) as questions from question"))
        answers (first (db/query "select count(id) as answers from answer"))
        accounts (first (db/query "select count(id) as accounts from account"))
        votes (first (db/query "select count(id) as votes from vote"))
        answer-votes (first (db/query "select count(id) as votes from answer_vote"))
        votes {:votes (+ (or (get answer-votes :votes) 0) (or (get votes :votes) 0))}
        counts (merge questions answers accounts votes)]
    [:vstack
     [:div
      [:h2 "/open"]
      [:p "askjanet is an open project which means I share all the stats with everyone!"]]

     [:hstack {:spacing "m" :responsive ""}
      [:vstack
       [:h2 (get counts :accounts)]
       [:div "Accounts"]]

      [:vstack
       [:h2 (get counts :questions)]
       [:div "Questions"]]

      [:vstack
       [:h2 (get counts :answers)]
       [:div "Answers"]]

      [:vstack
       [:h2 (get counts :votes)]
       [:div "Votes"]]

      [:vstack
       [:h2 "Not tracked yet :("]
       [:div "Pageviews"]]]]))

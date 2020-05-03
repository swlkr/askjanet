(import joy :prefix "")
(import ../helpers :prefix "")


(defn index [request]
  (let [account (request :account)
        questions (db/fetch-all [:question])
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
                   :x-data (string/format "voter('/api/questions/%d/votes', %s, %d)" (q :id) (if (empty? votes) "false" "true") (length votes))}
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
              [:div (get-in all-accounts [(q :account-id) :name])]]]]]]))]))

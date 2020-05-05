(use joy)
(use ../helpers)


(defn up [question account]
  (try
    (do
      (db/insert :vote {:question-id (question :id)
                        :account-id (account :id)})
      (application/json {:status "voted" :voted true}))
    ([err]
     (if (= "UNIQUE constraint failed: vote.account_id, vote.question_id" err)
       (application/json {:status "already voted"})
       (-> (application/json {:error "something went wrong"})
           (put :status 500))))))


(defn down [vote]
  (try
    (do
      (db/delete :vote (vote :id))
      (application/json {:status "downvoted" :downvoted true}))
    ([err]
     (-> (application/json {:error "something went wrong"})
         (put :status 500)))))


(defn toggle [request]
  (when-let [account (request :account)
             params (request :params)
             question (db/find :question (params :question-id))]

    (def vote (db/find-by :vote :where {:question-id (question :id) :account-id (account :id)}))

    (if (nil? account)
      (-> (application/json {:url "/join"})
          (put :status 401))

      (if (not vote)
        (up question account)
        (down vote)))))

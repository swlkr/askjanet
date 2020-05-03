(use joy)


(defn create [request]
  (when-let [code (get-in request [:params :auth-code])
             account (db/find-by :account :where {:code code})
             account (when (< (- (os/time) (account :code-expires-at)) 600)
                       account)
             {:email email :id id} (db/update :account account {:code ""})]
    (-> (redirect-to :home/index)
        (put :session @{:account {:id id :email email}}))))



(defn destroy [request]
  (-> (redirect-to :home/index)
      (put :session @{})))

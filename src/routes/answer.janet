(use joy)
(use ../helpers)


(defn params [request]
  (request :params))


(defn question-id [request]
  (get-in request [:params :question-id]))


(defn form [request route &opt question answer]
  [:vstack {:spacing "l"}
   (form-for [request route {:question-id (get question :id) :id (get answer :id)}]
     [:vstack {:spacing "l"}
      [:vstack {:spacing "xs"}]

      [:vstack {:spacing "xs"}
       [:textarea {:rows 10 :name "body"}
        (get answer :body)]
       [:div (get-in request [:errors :title])]]

      [:button {:type "submit"}
       "Answer"]])])


(defn new [request]
  (if (nil? (request :account))
    (redirect-to :account/new)

    (let [question (db/fetch [:question (question-id request)])]
      (form request :answer/create question))))


(defn create [request]
  (when-let [{:account account :body body :params params} request
             question (db/find :question (params :question-id))]

    (when (blank? (body :body))
      (put-in request [:errors :body] "Answer is blank"))

    (unless (request :errors)
      (db/insert :answer {:body (body :body)
                          :question-id (question :id)
                          :account-id (account :id)}))

    (if (nil? (request :errors))
      (redirect-to :question/show question)
      (new request))))


(defn edit [request]
  (if (nil? (request :account))
    (redirect-to :account/new)

    (when-let [account (request :account)
               params (request :params)
               question (db/fetch [:question (params :question-id)])
               answer (db/fetch [:account account :answer (params :id)])]
      (form request :answer/patch question answer))))


(defn patch [request]
  (when-let [{:account account :params params :body body} request
             answer (db/fetch [:account account :answer (params :id)])
             question (db/fetch [:question (params :question-id)])]

    (when (blank? (body :body))
      (put-in request [:errors :body] "Answer can't be blank"))

    (unless (request :errors)
      (db/update :answer answer {:body (body :body)}))

    (if (nil? (request :errors))
      (redirect-to :question/show question)
      (edit request))))


(defn destroy [request]
  (when-let [{:account account :params params} request
             answer (db/fetch [:account account :answer (params :id)])
             question (db/fetch [:question (params :question-id)])]
    (db/delete :answer answer)
    (redirect-to :question/show question)))

(import joy :prefix "")
(import ./layout :as layout)
(import ./routes :as routes)


(defn current-account [handler]
  (fn [request]
    (def id (get-in request [:session :account :id] 0))
    (def account (db/find :account id))
    (handler (put request :account account))))


(defn not-found-fn [request]
  (layout/layout {:request request
                  :body [:center
                         [:h1 "Oops! 404!"]]}))


(def app (as-> routes/app ?
               (handler ?)
               (layout ? layout/layout)
               (not-found ? not-found-fn)
               (current-account ?)
               (csrf-token ?)
               (session ?)
               (extra-methods ?)
               (query-string ?)
               (body-parser ?)
               (json-body-parser ?)
               (server-error ?)
               (x-headers ?)
               (logger ?)
               (static-files ?)))


(defn start [port]
  (let [port (scan-number
              (or port
                  (env :port)
                  "8000"))]
    (db/connect (env :database-url))
    (server app port) # stops listening on SIGINT
    (db/disconnect)))

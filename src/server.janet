(import joy :prefix "")
(import ./layout :as layout)
(import ./routes :as routes)


(defn current-account [handler]
  (fn [request]
    (def id (get-in request [:session :account :id]))
    (def account (db/find :account id))
    (handler (put request :account account))))


(def app (as-> routes/app ?
               (handler ?)
               (layout ? layout/layout)
               (not-found ?)
               (current-account ?)
               (csrf-token ?)
               (session ?)
               (extra-methods ?)
               (query-string ?)
               (body-parser ?)
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

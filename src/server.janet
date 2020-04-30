(import joy :prefix "")
(import ./layout :as layout)
(import ./routes :as routes)


(def app (as-> routes/app ?
               (handler ?)
               (layout ? layout/layout)
               (not-found ?)
               (csrf-token ?)
               (session ?)
               (extra-methods ?)
               (query-string ?)
               (body-parser ?)
               (server-error ?)
               (x-headers ?)
               (static-files ?)
               (logger ?)))


(defn start [port]
  (let [port (scan-number
              (or port
                  (env :port)
                  "8000"))]
    (db/connect (env :database-url))
    (server app port) # stops listening on SIGINT
    (db/disconnect)))

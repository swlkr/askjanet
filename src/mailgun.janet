(import http)
(import codec)
(import uri)
(import json)
(import dotenv)


(def base-url (dotenv/env :mailgun-base-url))
(def mailgun-domain (dotenv/env :mailgun-domain))
(def headers {"Authorization" (string "Basic " (codec/encode (string "api:" (dotenv/env :mailgun-api-key))))})


(defn contains? [arr val]
  (find (fn [x] (= x val)) arr))


(defn table/slice [dict ks]
  (as-> dict ?
        (pairs ?)
        (filter (fn [[k v]] (contains? ks k)) ?)
        (mapcat identity ?)
        (table ;?)))


(defn body [dict]
  (as-> (pairs dict) ?
        (map (fn [[k v]] (string k "=" (if (indexed? v)
                                         (string/join (map uri/escape v) ",")
                                         (uri/escape v))))
             ?)
        (string/join ? "&")))


(defn url [& str]
  (string base-url
    (string/join str "/")))


(defn send-message [dict]
  (def body (body (table/slice dict [:to :from :text :subject])))
  (http/post (url mailgun-domain "messages") body :headers headers))


(defn domains []
  (http/get (url "domains") :headers headers))


(defn domain [str]
  (http/get (url "domains" str) :headers headers))


(defn domains/create [dict]
  (http/post (url "domains") (body dict) :headers headers))


(defn domains/verify [domain]
  (http/put (url "domains" domain "verify") "" :headers headers))

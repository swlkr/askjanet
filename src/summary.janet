(use joy)
(use ./helpers)
(import ./mailgun)
(import ./routes)
(import dotenv)
(dotenv/load)


(def domain (if development? "http://localhost:8000" "https://askjanet.xyz"))


(defn midnight []
  (def now (os/time))
  (- now (% now 86400)))


(defn emails/summary [dict]
  (let [summary (slurp "emails/summary.txt")
        text (->> (string/replace "__questions__" (get dict :questions) summary)
                  (string/replace "__question-links__" (get dict :question-links)))]
    (mailgun/send-message {:from "Sean <sean@askjanet.xyz>"
                           :to (get dict :to)
                           :subject "[askjanet.xyz] Daily summary"
                           :text text})))


(defn send-emails []
  (let [midnight (midnight)
        questions-by-account (group-by :email (db/query (slurp "db/sql/daily-answered-questions.sql") [midnight]))]
    (loop [[email questions] :pairs questions-by-account]
      (emails/summary {:to email
                       :questions (string/join (map |(string "- " ($ :title)) questions)
                                    "\n")
                       :question-links (string/join (map |(string "- " domain (url-for :question/show $))
                                                         questions)
                                         "\n")}))))

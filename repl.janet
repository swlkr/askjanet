(use joy)
(import json)
(import ./src/mailgun)

(db/connect)

(repl nil
      (fn [_ y] (printf "%Q" y))
      (fiber/getenv (fiber/current)))

(db/disconnect)

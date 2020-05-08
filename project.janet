(declare-project
  :name "askjanet"
  :description "A q&a site for janet"
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/joy-framework/http"
                 "https://github.com/joy-framework/dotenv"
                 "https://github.com/joy-framework/moondown"]
  :author "swlkr"
  :license "MIT"
  :url "https://askjanet.xyz"
  :repo "https://github.com/swlkr/askjanet")

(declare-executable
  :name "askjanet"
  :entry "main.janet")

(phony "server" []
  (do
    (os/shell "pkill -xf 'janet main.janet'")
    (os/shell "janet main.janet")))

(phony "watch" []
  (do
    (os/shell "pkill -xf 'janet main.janet'")
    (os/shell "janet main.janet &")
    (os/shell "fswatch -o src | xargs -n1 -I{} ./watch")))

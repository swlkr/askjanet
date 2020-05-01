(declare-project
  :name "askjanet"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/joy-framework/http"
                 "https://github.com/joy-framework/tester"]
  :author ""
  :license ""
  :url ""
  :repo "")

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
    (os/shell "fswatch -m poll_monitor -o src | xargs -n1 -I{} ./watch")))

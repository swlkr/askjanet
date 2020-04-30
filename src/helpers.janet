(use joy)


(def domain "askjanet.xyz")
(def from-email "askjanet <sean@askjanet.xyz>")
(def base-url (if development? "http://localhost:8080/" "https://askjanet.xyz/"))


(defn url [& str]
  (string base-url
    (string/join str "/")))


(defn svg [src]
  (raw (slurp (string "public/" src ".svg"))))


(defmacro foreach [binding & body]
  ~(map (fn [val]
          (let [,(first binding) val]
            ,;body))
        ,(get binding 1)))


(defn blank? [str]
  (or (nil? str)
      (empty? str)))


(defn present? [val]
  (not (blank? val)))


(defn datestring
  "Format the date"
  [timestamp]
  (let [date (os/date timestamp)
        M (+ 1 (date :month))
        D (+ 1 (date :month-day))
        Y (date :year)
        HH (date :hours)
        MM (date :minutes)]
    (string/format "%d/%.2d/%.2d at %.2d:%.2d"
                   M D Y HH MM)))


(defn group-by [key dicts]
  (var output @{})
  (loop [dict :in dicts]
    (when (nil? (get output (get dict key)))
      (put output (get dict key) @[]))
    (update output (get dict key) array/push dict))
  output)


(defn pluck [k dicts]
  (map |(get $ k) dicts))

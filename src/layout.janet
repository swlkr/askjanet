(import joy :prefix "")
(import ./helpers :prefix "")


(defn menu [request]
  [:vstack {:spacing "l"}
   [:hstack {:stretch ""}
    [:a {:href "/"}
     "ask janet"]
    [:spacer]
    (if (request :account)
      [:hstack {:spacing "m"}
       [:a {:href "/profile"
            :role "button"}
        "Profile"]
       (form-with request {:method "POST" :action "/logout"}
         [:input {:type "submit" :value "Sign out"}])
       [:a {:href "javascript://" :@click "toggleColorScheme()"
            :role "button"}
        [:div {:x-show "darkMode"}
         (svg "moon")]
        [:div {:x-show "!darkMode" :style "color: #ff8a00"}
         (svg "brightness-high-fill")]]]

      [:hstack {:spacing "m"}
       [:a {:href "/sign-in"
            :role "button"}
        "Sign in"]
       [:a {:href "/join"
            :role "button"}
        "Join"]
       [:a {:href "javascript://" :@click "toggleColorScheme()"
            :role "button"}
        [:div {:x-show "darkMode"}
         (svg "moon")]
        [:div {:x-show "!darkMode" :style "color: #ff8a00"}
         (svg "brightness-high-fill")]]])]
   [:spacer]])


(defn confirm-modal [request]
  [:div {:class "md-modal" ::class "{'md-show': modalOpen}" :x-show "modalOpen" :@click.away "modalOpen = false"}
   [:div {:class "md-content"}
    [:vstack {:align-x "center"}
     [:h3 "Are you sure?"]
     [:hstack {:spacing "l" :align-x "center"}
      (form-with request {:method "POST" :x-bind:action "action"}
        [:input {:type "hidden" :name "_method" :value "DELETE"}]
        [:button {:type "submit"}
         "Yes, do it"])
      [:a {:href "#" :@click.prevent "modalOpen = false"}
       "No"]]]]])


(defn layout [{:request request :body body}]
  (let [dark-mode (get-in request [:account :dark-mode])
        start-theme (cond
                      (nil? dark-mode) nil
                      (one? dark-mode) "dark"
                      :else "light")]
   (text/html
     (doctype :html5)
     [:html {:lang "en" :data-start-theme start-theme :data-theme "light" :x-bind:data-theme "darkMode ? 'dark' : 'light'" :x-data "app()"}
      [:head
       [:title "ask janet"]
       [:meta {:name "csrf-token" :content (authenticity-token request)}]
       [:meta {:charset "utf-8"}]
       [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
       [:link {:href "/pylon.css" :rel "stylesheet"}]
       [:link {:href "/app.css" :rel "stylesheet"}]
       [:script {:src "/alpine.js"}]]
      [:body {:@keydown.escape.prevent "modalOpen = false"}
        (menu request)
        body
       (confirm-modal request)
       [:div {:class "md-overlay" ::class "{'md-show': modalOpen}"}]
       [:script {:src "/app.js"}]]])))

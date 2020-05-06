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
       (form-for [request :session/destroy]
         [:input {:type "submit" :value "Sign out"}])
       [:a {:href "javascript://" :@click "toggleColorScheme()"
            :role "button"}
        [:div {:x-show "colorScheme === 'dark-mode'"}
         (svg "moon")]
        [:div {:x-show "colorScheme === 'light-mode'" :style "color: #ff8a00"}
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
        [:div {:x-show "colorScheme === 'dark-mode'"}
         (svg "moon")]
        [:div {:x-show "colorScheme === 'light-mode'" :style "color: #ff8a00"}
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
        color-scheme (cond
                       (nil? dark-mode) ""
                       (one? dark-mode) "dark-mode"
                       :else "light-mode")]
   (text/html
     (doctype :html5)
     [:html {:lang "en" :x-data (string "app('" color-scheme "')")}
      [:head
       [:title "ask janet"]
       [:meta {:name "csrf-token" :content (authenticity-token request)}]
       [:meta {:charset "utf-8"}]
       [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
       [:link {:rel "stylesheet" :href "/dark.css" :media "(prefers-color-scheme: no-preference), (prefers-color-scheme: dark)"}]
       [:link {:rel "stylesheet" :href "/light.css" :media "(prefers-color-scheme: light)"}]
       (css "/pylon.css" "/app.css")]
      [:body {:@keydown.escape.prevent "modalOpen = false" :x-bind:class "colorScheme"}
        (menu request)
        body
       (confirm-modal request)
       [:div {:class "md-overlay" ::class "{'md-show': modalOpen}"}]
       (js "/alpine.js" "/app.js")]])))

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/activestorage", to: "activestorage.esm.js"

# three.js 0.187.0, loaded only on pages with a 3D box viewer.
pin "three", preload: false
pin "three/core", to: "three.core.js", preload: false
pin "three/addons/controls/OrbitControls.js", to: "three--orbit-controls.js", preload: false

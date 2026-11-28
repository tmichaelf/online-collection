import { Controller } from "@hotwired/stimulus"

const VIEW_DIRECTIONS = {
  front:  [ 0, 0, 1 ],
  back:   [ 0, 0, -1 ],
  left:   [ -1, 0, 0 ],
  right:  [ 1, 0, 0 ],
  top:    [ 0, 1, 0.0001 ],
  bottom: [ 0, -1, 0.0001 ]
}

// The default three-quarter view: mostly front, a little of the right side and top.
const HOME_DIRECTION = [ 0.45, 0.25, 1 ]

// BoxGeometry orders its faces +x, -x, +y, -y, +z, -z.
const FACE_ORDER = [ "right", "left", "top", "bottom", "front", "back" ]

const BLANK_FACE_COLOR = 0x3a3632

// Renders a title's box in 3D with three.js. Three is only loaded on pages that have a viewer.
export default class extends Controller {
  static targets = [ "stage", "status", "toolbar", "spinButton", "fullscreenButton" ]
  static values = { textures: Object, dimensions: Object }

  async connect() {
    try {
      this.THREE = await import("three")
      const { OrbitControls } = await import("three/addons/controls/OrbitControls.js")
      if (!this.element.isConnected) return

      this.#buildScene(OrbitControls)
      this.toolbarTarget.hidden = false
      await this.#applyTextures()
    } catch (error) {
      console.error("Box viewer could not start", error)
      this.#teardown()
      this.#showStatus("The 3D view isn't available in this browser, so here's the front of the box.")
    }
  }

  disconnect() {
    this.#teardown()
  }

  zoomIn() {
    this.#dolly(0.8)
  }

  zoomOut() {
    this.#dolly(1.25)
  }

  reset() {
    this.#moveCamera(HOME_DIRECTION, this.homeDistance)
  }

  show({ params: { face } }) {
    this.#setSpin(false)
    this.#moveCamera(VIEW_DIRECTIONS[face], this.homeDistance)
  }

  toggleSpin() {
    this.#setSpin(!this.controls?.autoRotate)
  }

  toggleFullscreen() {
    if (document.fullscreenElement) {
      document.exitFullscreen()
    } else {
      this.element.requestFullscreen?.()
    }
  }

  fullscreenChanged() {
    const fullscreen = document.fullscreenElement === this.element
    this.fullscreenButtonTarget.textContent = fullscreen ? "Exit full screen" : "Full screen"
    this.#resize()
  }

  keydown(event) {
    if (!this.controls || event.target.closest("input, textarea, select")) return

    switch (event.key) {
      case "+": case "=": this.zoomIn(); break
      case "-": case "_": this.zoomOut(); break
      case "r": case "R": this.reset(); break
      case "f": case "F": this.toggleFullscreen(); break
      default: return
    }
    event.preventDefault()
  }

  // Scene

  #buildScene(OrbitControls) {
    const THREE = this.THREE
    const { width, height, depth } = this.dimensionsValue
    const scale = 2 / Math.max(width, height, depth)
    const size = new THREE.Vector3(width * scale, height * scale, depth * scale)

    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    this.renderer.outputColorSpace = THREE.SRGBColorSpace
    this.renderer.domElement.classList.add("box-viewer__canvas")

    this.scene = new THREE.Scene()
    this.scene.add(new THREE.AmbientLight(0xffffff, 1.8))
    const keyLight = new THREE.DirectionalLight(0xffffff, 1.4)
    keyLight.position.set(2, 3, 4)
    this.scene.add(keyLight)

    this.materials = FACE_ORDER.map(() => new THREE.MeshStandardMaterial({ color: BLANK_FACE_COLOR, roughness: 0.85 }))
    this.geometry = new THREE.BoxGeometry(size.x, size.y, size.z)
    this.box = new THREE.Mesh(this.geometry, this.materials)
    this.scene.add(this.box)

    const radius = size.length() / 2
    this.homeDistance = radius * 3.2
    this.camera = new THREE.PerspectiveCamera(35, 1, 0.01, 100)

    this.controls = new OrbitControls(this.camera, this.renderer.domElement)
    this.controls.enableDamping = true
    this.controls.minDistance = radius * 1.1
    this.controls.maxDistance = radius * 8
    this.controls.autoRotateSpeed = 1.5
    this.controls.addEventListener("start", () => this.#setSpin(false))
    this.#placeCamera(HOME_DIRECTION, this.homeDistance)

    this.stageTarget.querySelector(".box-cover")?.setAttribute("hidden", "")
    this.stageTarget.prepend(this.renderer.domElement)

    this.resizeObserver = new ResizeObserver(() => this.#resize())
    this.resizeObserver.observe(this.stageTarget)
    this.#resize()

    this.#setSpin(!window.matchMedia("(prefers-reduced-motion: reduce)").matches)
    this.renderer.setAnimationLoop(() => this.#render())
  }

  async #applyTextures() {
    const THREE = this.THREE
    const loader = new THREE.TextureLoader()
    const anisotropy = this.renderer.capabilities.getMaxAnisotropy()

    await Promise.all(FACE_ORDER.map(async (face, index) => {
      const url = this.texturesValue[face]
      if (!url) return

      try {
        const texture = await loader.loadAsync(url)
        if (!this.materials) return texture.dispose()

        texture.colorSpace = THREE.SRGBColorSpace
        texture.anisotropy = anisotropy
        this.materials[index].map = texture
        this.materials[index].color.set(0xffffff)
        this.materials[index].needsUpdate = true
      } catch (error) {
        console.warn(`Box viewer could not load the ${face} photo`, error)
      }
    }))
  }

  #render() {
    if (this.animation) this.#stepAnimation()
    this.controls.update()
    this.renderer.render(this.scene, this.camera)
  }

  #resize() {
    if (!this.renderer) return

    const { clientWidth: width, clientHeight: height } = this.stageTarget
    if (!width || !height) return

    this.renderer.setSize(width, height, false)
    this.camera.aspect = width / height
    this.camera.updateProjectionMatrix()
  }

  // Camera

  #placeCamera(direction, distance) {
    const position = new this.THREE.Vector3(...direction).normalize().multiplyScalar(distance)
    this.camera.position.copy(position)
    this.controls.target.set(0, 0, 0)
    this.controls.update()
  }

  #moveCamera(direction, distance) {
    if (!this.camera) return

    const to = new this.THREE.Vector3(...direction).normalize().multiplyScalar(distance)
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.camera.position.copy(to)
      this.controls.target.set(0, 0, 0)
      return
    }

    this.animation = {
      fromPosition: this.camera.position.clone(),
      toPosition: to,
      fromTarget: this.controls.target.clone(),
      startedAt: performance.now(),
      duration: 450
    }
  }

  #stepAnimation() {
    const { fromPosition, toPosition, fromTarget, startedAt, duration } = this.animation
    const progress = Math.min((performance.now() - startedAt) / duration, 1)
    const eased = 1 - Math.pow(1 - progress, 3)

    // Swing around the box rather than through it.
    const length = fromPosition.length() + (toPosition.length() - fromPosition.length()) * eased
    this.camera.position.copy(fromPosition).lerp(toPosition, eased).setLength(length)
    this.controls.target.copy(fromTarget).lerp(new this.THREE.Vector3(), eased)

    if (progress === 1) this.animation = null
  }

  #dolly(factor) {
    if (!this.camera) return

    const offset = this.camera.position.clone().sub(this.controls.target)
    const distance = Math.min(Math.max(offset.length() * factor, this.controls.minDistance), this.controls.maxDistance)
    this.camera.position.copy(this.controls.target).add(offset.setLength(distance))
  }

  #setSpin(spinning) {
    if (!this.controls) return

    this.controls.autoRotate = spinning
    this.spinButtonTarget.setAttribute("aria-pressed", String(spinning))
  }

  // Lifecycle

  #showStatus(message) {
    this.statusTarget.textContent = message
    this.statusTarget.hidden = false
  }

  #teardown() {
    this.resizeObserver?.disconnect()
    this.renderer?.setAnimationLoop(null)
    this.controls?.dispose()
    this.materials?.forEach((material) => { material.map?.dispose(); material.dispose() })
    this.geometry?.dispose()
    this.renderer?.domElement.remove()
    this.renderer?.dispose()

    this.stageTarget.querySelector(".box-cover")?.removeAttribute("hidden")
    if (this.hasToolbarTarget) this.toolbarTarget.hidden = true
    this.renderer = this.controls = this.materials = this.geometry = this.camera = this.scene = null
  }
}

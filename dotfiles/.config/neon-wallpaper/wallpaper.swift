// Fondo de pantalla animado: muestra index.html en una ventana al nivel del escritorio
// de cada pantalla (por debajo de los iconos y de todas las ventanas). Es lo que hace
// Plash, que ya no es open source.
//
//   wallpaper [--external <modo>] [--builtin <modo>] [--keep-on-battery]
//       Fondo animado. Se rehace solo al conectar o quitar pantallas y se pausa (y se
//       oculta, dejando ver el fondo estático) con batería o en modo de bajo consumo.
//   wallpaper set-static [--external <modo>] [--builtin <modo>]
//       Saca un fotograma de cada escena a la resolución de cada pantalla, lo guarda en
//       static/ y lo pone como fondo de escritorio normal de macOS (pantalla de bloqueo,
//       Mission Control, o cuando el animado está en pausa).
//
// Modos de index.html: city, minimal, freefall, edge, window. Por defecto: window en
// monitores externos y edge en la pantalla del portátil.
import AppKit
import IOKit.ps
import WebKit

let dir = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath().deletingLastPathComponent()
let page = dir.appendingPathComponent("index.html")
let args = CommandLine.arguments

func option(_ name: String, _ fallback: String) -> String {
    if let i = args.firstIndex(of: name), i + 1 < args.count { return args[i + 1] }
    return fallback
}
let externalMode = option("--external", "window")
let builtinMode = option("--builtin", "edge")

func isBuiltin(_ screen: NSScreen) -> Bool {
    let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
    return CGDisplayIsBuiltin(id) != 0
}

func mode(for screen: NSScreen) -> String { isBuiltin(screen) ? builtinMode : externalMode }

func pageURL(mode: String, still: Bool = false) -> URL {
    var url = URLComponents(url: page, resolvingAgainstBaseURL: false)!
    url.queryItems = [URLQueryItem(name: "mode", value: mode)] + (still ? [URLQueryItem(name: "still", value: "1")] : [])
    return url.url!
}

func makeWebView(size: CGSize, url: URL) -> WKWebView {
    let web = WKWebView(frame: CGRect(origin: .zero, size: size))
    web.setValue(false, forKey: "drawsBackground")
    web.loadFileURL(url, allowingReadAccessTo: dir)
    return web
}

// MARK: - Fondo animado

func onBattery() -> Bool {
    let info = IOPSCopyPowerSourcesInfo().takeRetainedValue()
    let type = IOPSGetProvidingPowerSourceType(info)?.takeUnretainedValue() as String?
    return type == kIOPSBatteryPowerValue
}

final class Wallpaper: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var webViews: [WKWebView] = []
    let keepOnBattery = args.contains("--keep-on-battery")

    func applicationDidFinishLaunching(_ notification: Notification) {
        build()
        NotificationCenter.default.addObserver(self, selector: #selector(build),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyPower),
            name: .NSProcessInfoPowerStateDidChange, object: nil)
        // Aviso de IOKit cuando cambia la fuente de alimentación (enchufe / batería)
        let source = IOPSNotificationCreateRunLoopSource({ _ in
            DispatchQueue.main.async { (NSApp.delegate as? Wallpaper)?.applyPower() }
        }, nil).takeRetainedValue()
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
    }

    @objc func build() {
        windows.forEach { $0.close() }
        webViews = []
        windows = NSScreen.screens.map { screen in
            let window = NSWindow(contentRect: screen.frame, styleMask: .borderless,
                                  backing: .buffered, defer: false, screen: screen)
            window.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.ignoresMouseEvents = true
            window.isReleasedWhenClosed = false
            window.backgroundColor = NSColor(red: 0.043, green: 0.043, blue: 0.071, alpha: 1)
            let web = makeWebView(size: screen.frame.size, url: pageURL(mode: mode(for: screen)))
            webViews.append(web)
            window.contentView = web
            window.setFrame(screen.frame, display: true)
            return window
        }
        applyPower()
    }

    // Con batería o en bajo consumo: pausa la animación y oculta las ventanas, de
    // modo que se ve el fondo estático de macOS
    @objc func applyPower() {
        let pause = !keepOnBattery && (onBattery() || ProcessInfo.processInfo.isLowPowerModeEnabled)
        webViews.forEach { $0.evaluateJavaScript("window.setPaused && setPaused(\(pause))") }
        windows.forEach { pause ? $0.orderOut(nil) : $0.orderFront(nil) }
    }
}

// MARK: - Fondo estático

final class StaticWallpaper: NSObject, NSApplicationDelegate {
    var pending = 0
    var holders: [NSWindow] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        let out = dir.appendingPathComponent("static")
        try? FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        let screens = NSScreen.screens
        pending = screens.count
        for screen in screens {
            let size = screen.frame.size, m = mode(for: screen)
            let file = out.appendingPathComponent("\(m)-\(Int(size.width))x\(Int(size.height)).png")
            // WebKit solo pinta si la vista está en una ventana: una fuera de la pantalla
            let holder = NSWindow(contentRect: CGRect(x: -30000, y: -30000, width: size.width, height: size.height),
                                  styleMask: .borderless, backing: .buffered, defer: false)
            let web = makeWebView(size: size, url: pageURL(mode: m, still: true))
            holder.contentView = web
            holder.orderFront(nil)
            holders.append(holder)
            waitThenSnapshot(web, size: size, file: file, screen: screen, tries: 0)
        }
    }

    func waitThenSnapshot(_ web: WKWebView, size: CGSize, file: URL, screen: NSScreen, tries: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            web.evaluateJavaScript("window.stillReady === true") { ready, _ in
                guard (ready as? Bool) == true || tries > 20 else {
                    return self.waitThenSnapshot(web, size: size, file: file, screen: screen, tries: tries + 1)
                }
                let config = WKSnapshotConfiguration()
                config.rect = CGRect(origin: .zero, size: size)
                web.takeSnapshot(with: config) { image, _ in
                    if let image, let tiff = image.tiffRepresentation,
                       let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) {
                        try? png.write(to: file)
                        do {
                            try NSWorkspace.shared.setDesktopImageURL(file, for: screen, options: [:])
                            print("Fondo estático: \(file.lastPathComponent) en \(screen.localizedName)")
                        } catch {
                            print("No se pudo poner el fondo en \(screen.localizedName): \(error)")
                        }
                    }
                    self.pending -= 1
                    if self.pending == 0 { NSApp.terminate(nil) }
                }
            }
        }
    }
}

let app = NSApplication.shared
let delegate: NSApplicationDelegate = args.dropFirst().first == "set-static" ? StaticWallpaper() : Wallpaper()
app.delegate = delegate
app.setActivationPolicy(.prohibited)   // sin icono en el Dock ni menú
app.run()

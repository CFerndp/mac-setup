// Fondo de pantalla animado: muestra index.html en una ventana al nivel del escritorio
// de cada pantalla (por debajo de los iconos y de todas las ventanas). Es lo que hace
// Plash, que ya no es open source.
//
//   wallpaper [--external <modo>] [--builtin <modo>]
//
// Modos de index.html: city, minimal, freefall, edge. Por defecto: freefall en
// monitores externos y edge en la pantalla del portátil. Se rehace solo al conectar o quitar pantallas.
import AppKit
import WebKit

let dir = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath().deletingLastPathComponent()
let page = dir.appendingPathComponent("index.html")

func option(_ name: String, _ fallback: String) -> String {
    let args = CommandLine.arguments
    if let i = args.firstIndex(of: name), i + 1 < args.count { return args[i + 1] }
    return fallback
}
let externalMode = option("--external", "freefall")
let builtinMode = option("--builtin", "edge")

func isBuiltin(_ screen: NSScreen) -> Bool {
    let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
    return CGDisplayIsBuiltin(id) != 0
}

final class Wallpaper: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        build()
        NotificationCenter.default.addObserver(self, selector: #selector(build),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    @objc func build() {
        windows.forEach { $0.close() }
        windows = NSScreen.screens.map { screen in
            let window = NSWindow(contentRect: screen.frame, styleMask: .borderless,
                                  backing: .buffered, defer: false, screen: screen)
            window.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.ignoresMouseEvents = true
            window.isReleasedWhenClosed = false
            window.backgroundColor = NSColor(red: 0.043, green: 0.043, blue: 0.071, alpha: 1)

            let web = WKWebView(frame: CGRect(origin: .zero, size: screen.frame.size))
            web.setValue(false, forKey: "drawsBackground")
            var url = URLComponents(url: page, resolvingAgainstBaseURL: false)!
            url.queryItems = [URLQueryItem(name: "mode", value: isBuiltin(screen) ? builtinMode : externalMode)]
            web.loadFileURL(url.url!, allowingReadAccessTo: dir)

            window.contentView = web
            window.setFrame(screen.frame, display: true)
            window.orderFront(nil)
            return window
        }
    }
}

let app = NSApplication.shared
let delegate = Wallpaper()
app.delegate = delegate
app.setActivationPolicy(.prohibited)   // sin icono en el Dock ni menú
app.run()

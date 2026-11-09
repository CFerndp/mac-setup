// Globos de avisos sin leer del Dock (el número rojo sobre el icono).
// lsappinfo ya no expone StatusLabel en macOS 27, así que se leen del propio Dock.
//   badges          -> "App<TAB>globo" por cada app con globo, uno por línea
//   badges <App>    -> solo el globo de esa app (nada si no tiene)
// Necesita permiso de Accesibilidad para el proceso que lo lanza (SketchyBar).
import AppKit
import ApplicationServices

guard AXIsProcessTrusted(),
      let dock = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first
else { exit(1) }

func attr(_ el: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    return AXUIElementCopyAttributeValue(el, name as CFString, &value) == .success ? value : nil
}

let wanted = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil
let lists = attr(AXUIElementCreateApplication(dock.processIdentifier), kAXChildrenAttribute) as? [AXUIElement] ?? []

for list in lists {
    for item in attr(list, kAXChildrenAttribute) as? [AXUIElement] ?? [] {
        guard let title = attr(item, kAXTitleAttribute) as? String,
              let label = attr(item, "AXStatusLabel") as? String, !label.isEmpty
        else { continue }
        if let wanted {
            if title == wanted { print(label); exit(0) }
        } else {
            print("\(title)\t\(label)")
        }
    }
}

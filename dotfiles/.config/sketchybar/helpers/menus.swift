// Menús de la app activa (Archivo, Edición…) para mostrarlos en SketchyBar.
// Idea de FelixKratz/dotfiles (helpers/menus), reescrita con APIs públicas.
//   menus list        -> títulos de los menús, uno por línea (sin el menú Apple)
//   menus select <n>  -> abre el menú n (1 = el primero tras el menú Apple)
// Necesita permiso de Accesibilidad para el proceso que lo lanza (SketchyBar).
import AppKit
import ApplicationServices

let prompt = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
guard AXIsProcessTrustedWithOptions(prompt) else { exit(1) }

func menuItems() -> [AXUIElement] {
    guard let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier else { return [] }
    let app = AXUIElementCreateApplication(pid)
    var bar: CFTypeRef?
    var children: CFTypeRef?
    guard AXUIElementCopyAttributeValue(app, kAXMenuBarAttribute as CFString, &bar) == .success,
          AXUIElementCopyAttributeValue(bar as! AXUIElement, kAXVisibleChildrenAttribute as CFString, &children) == .success
    else { return [] }
    return children as? [AXUIElement] ?? []
}

let args = CommandLine.arguments
let items = menuItems()

switch args.count > 1 ? args[1] : "" {
case "list":
    for item in items.dropFirst() {
        var title: CFTypeRef?
        if AXUIElementCopyAttributeValue(item, kAXTitleAttribute as CFString, &title) == .success,
           let title = title as? String {
            print(title)
        }
    }
case "select" where args.count > 2:
    guard let n = Int(args[2]), n < items.count else { exit(1) }
    AXUIElementPerformAction(items[n], kAXCancelAction as CFString)
    usleep(150_000)
    AXUIElementPerformAction(items[n], kAXPressAction as CFString)
default:
    FileHandle.standardError.write("Uso: menus list | select <n>\n".data(using: .utf8)!)
    exit(1)
}

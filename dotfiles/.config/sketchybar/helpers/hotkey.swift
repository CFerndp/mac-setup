// Pulsa un atajo de teclado a nivel de sistema (como si viniera del teclado), para
// abrir apps que solo se invocan con su atajo global, p. ej. Maccy.
//   hotkey <keycode> [cmd,shift,alt,ctrl]
//   hotkey 8 cmd,shift   -> Shift+Cmd+C
// Necesita permiso de Accesibilidad para el proceso que lo lanza (SketchyBar).
import CoreGraphics
import Foundation

let args = CommandLine.arguments
guard args.count > 1, let code = CGKeyCode(args[1]) else {
    FileHandle.standardError.write("Uso: hotkey <keycode> [cmd,shift,alt,ctrl]\n".data(using: .utf8)!)
    exit(1)
}
let names: [String: CGEventFlags] = ["cmd": .maskCommand, "shift": .maskShift, "alt": .maskAlternate, "ctrl": .maskControl]
let flags = (args.count > 2 ? args[2].split(separator: ",") : []).reduce(CGEventFlags()) {
    $0.union(names[String($1)] ?? [])
}

let source = CGEventSource(stateID: .hidSystemState)
for down in [true, false] {
    let event = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: down)
    event?.flags = flags
    event?.post(tap: .cghidEventTap)
    usleep(20_000)
}

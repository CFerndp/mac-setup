// Pulsa una tecla multimedia del sistema, igual que las teclas F7/F8/F9 del Mac.
// Controla lo que esté sonando (Spotify, Música, navegador...).
//   mediakey play | next | previous
import AppKit

let keys: [String: Int] = ["play": 16, "next": 17, "previous": 18] // NX_KEYTYPE_*

guard CommandLine.arguments.count > 1, let key = keys[CommandLine.arguments[1]] else {
    FileHandle.standardError.write("Uso: mediakey play|next|previous\n".data(using: .utf8)!)
    exit(1)
}

for down in [true, false] {
    let state = down ? 0xa : 0xb
    let event = NSEvent.otherEvent(with: .systemDefined, location: .zero,
                                   modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(state << 8)),
                                   timestamp: 0, windowNumber: 0, context: nil, subtype: 8,
                                   data1: (key << 16) | (state << 8), data2: -1)
    event?.cgEvent?.post(tap: .cghidEventTap)
}

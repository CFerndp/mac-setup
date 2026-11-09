// Lista y cambia las distribuciones de teclado activas (Ajustes > Teclado > Fuentes de entrada).
//   inputsource list            -> id|nombre|1 si es la actual, una por línea
//   inputsource current         -> id|nombre de la actual
//   inputsource select <id>     -> cambia a esa distribución
import Carbon
import Foundation

func prop(_ src: TISInputSource, _ key: CFString) -> String {
    guard let ptr = TISGetInputSourceProperty(src, key) else { return "" }
    return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
}

func keyboards() -> [TISInputSource] {
    let filter = [kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource,
                  kTISPropertyInputSourceIsSelectCapable: true] as CFDictionary
    let list = TISCreateInputSourceList(filter, false).takeRetainedValue() as! [TISInputSource]
    return list.filter { prop($0, kTISPropertyInputSourceType) == (kTISTypeKeyboardLayout as String) ||
                         prop($0, kTISPropertyInputSourceType) == (kTISTypeKeyboardInputMode as String) }
}

let current = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
let currentID = prop(current, kTISPropertyInputSourceID)
let args = CommandLine.arguments

switch args.count > 1 ? args[1] : "current" {
case "list":
    for src in keyboards() {
        let id = prop(src, kTISPropertyInputSourceID)
        print("\(id)|\(prop(src, kTISPropertyLocalizedName))|\(id == currentID ? 1 : 0)")
    }
case "select" where args.count > 2:
    guard let src = keyboards().first(where: { prop($0, kTISPropertyInputSourceID) == args[2] }) else {
        FileHandle.standardError.write("No existe: \(args[2])\n".data(using: .utf8)!)
        exit(1)
    }
    exit(TISSelectInputSource(src) == noErr ? 0 : 1)
default:
    print("\(currentID)|\(prop(current, kTISPropertyLocalizedName))")
}

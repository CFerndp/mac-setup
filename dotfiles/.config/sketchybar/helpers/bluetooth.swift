// Bluetooth para SketchyBar, con la API pública de IOBluetooth.
//   bluetooth status         -> on | off
//   bluetooth list           -> "dirección|conectado (1/0)|tipo|nombre" por dispositivo emparejado
//                               (tipo: audio, input, phone, computer u other)
//   bluetooth toggle <dir>   -> conecta o desconecta ese dispositivo
// Encender/apagar el Bluetooth no tiene API pública: eso se hace desde Ajustes.
import IOBluetooth

func kind(_ d: IOBluetoothDevice) -> String {
    switch d.deviceClassMajor {
    case UInt32(kBluetoothDeviceClassMajorAudio): return "audio"
    case UInt32(kBluetoothDeviceClassMajorPeripheral): return "input"
    case UInt32(kBluetoothDeviceClassMajorPhone): return "phone"
    case UInt32(kBluetoothDeviceClassMajorComputer): return "computer"
    default: return "other"
    }
}

let paired = (IOBluetoothDevice.pairedDevices() ?? []).compactMap { $0 as? IOBluetoothDevice }
let args = CommandLine.arguments

switch args.count > 1 ? args[1] : "" {
case "status":
    print(IOBluetoothHostController.default()?.powerState == kBluetoothHCIPowerStateON ? "on" : "off")
case "list":
    for d in paired {
        print("\(d.addressString ?? "")|\(d.isConnected() ? 1 : 0)|\(kind(d))|\(d.name ?? "?")")
    }
case "toggle" where args.count > 2:
    guard let d = paired.first(where: { $0.addressString == args[2] }) else { exit(1) }
    let result = d.isConnected() ? d.closeConnection() : d.openConnection()
    exit(result == kIOReturnSuccess ? 0 : 1)
default:
    FileHandle.standardError.write("uso: bluetooth status | list | toggle <dirección>\n".data(using: .utf8)!)
    exit(2)
}

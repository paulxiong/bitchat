<img width="256" height="256" alt="icon_128x128@2x" src="https://github.com/user-attachments/assets/90133f83-b4f6-41c6-aab9-25d0859d2a47" />

## BitChat-photo

A decentralized peer-to-peer messaging app with photo sharing capabilities and dual transport architecture: local Bluetooth mesh networks for offline communication and internet-based Nostr protocol for global reach. No accounts, no phone numbers, no central servers. It's the side-groupchat with photo support.

[bitchat.free](http://bitchat.free)

📲 [App Store](https://apps.apple.com/us/app/bitchat-mesh/id6748219622)

> [!WARNING]
> Private messages have not received external security review and may contain vulnerabilities. Do not use for sensitive use cases, and do not rely on its security until it has been reviewed. Now uses the [Noise Protocol](http://www.noiseprotocol.org) for identity and encryption. Public local chat (the main feature) has no security concerns.

## License

This project is released into the public domain. See the [LICENSE](LICENSE) file for details.

## Features

- **Dual Transport Architecture**: Bluetooth mesh for offline + Nostr protocol for internet-based messaging
- **Location-Based Channels**: Geographic chat rooms using geohash coordinates over global Nostr relays
- **Intelligent Message Routing**: Automatically chooses best transport (Bluetooth → Nostr fallback)
- **Decentralized Mesh Network**: Automatic peer discovery and multi-hop message relay over Bluetooth LE
- **Photo Sharing**: Send and receive photos through the secure mesh network with automatic compression and chunking
- **Privacy First**: No accounts, no phone numbers, no persistent identifiers
- **Private Message End-to-End Encryption**: [Noise Protocol](http://noiseprotocol.org) for mesh, NIP-17 for Nostr
- **IRC-Style Commands**: Familiar `/slap`, `/msg`, `/who` style interface
- **Universal App**: Native support for iOS and macOS
- **Emergency Wipe**: Triple-tap to instantly clear all data
- **Performance Optimizations**: LZ4 message compression, adaptive battery modes, and optimized networking

## [Technical Architecture](https://deepwiki.com/permissionlesstech/bitchat)

BitChat-photo uses a **hybrid messaging architecture** with two complementary transport layers that support both text and photo sharing:

### Bluetooth Mesh Network (Offline)

- **Local Communication**: Direct peer-to-peer within Bluetooth range
- **Multi-hop Relay**: Messages route through nearby devices (max 7 hops)
- **No Internet Required**: Works completely offline in disaster scenarios
- **Noise Protocol Encryption**: End-to-end encryption with forward secrecy
- **Binary Protocol**: Compact packet format optimized for Bluetooth LE constraints
- **Automatic Discovery**: Peer discovery and connection management
- **Adaptive Power**: Battery-optimized duty cycling

### Nostr Protocol (Internet)

- **Global Reach**: Connect with users worldwide via internet relays
- **Location Channels**: Geographic chat rooms using geohash coordinates
- **290+ Relay Network**: Distributed across the globe for reliability
- **NIP-17 Encryption**: Gift-wrapped private messages for internet privacy
- **Ephemeral Keys**: Fresh cryptographic identity per geohash area

### Channel Types

#### `mesh #bluetooth`

- **Transport**: Bluetooth Low Energy mesh network
- **Scope**: Local devices within multi-hop range
- **Internet**: Not required
- **Use Case**: Offline communication, protests, disasters, remote areas

#### Location Channels (`block #dr5rsj7`, `neighborhood #dr5rs`, `country #dr`)

- **Transport**: Nostr protocol over internet
- **Scope**: Geographic areas defined by geohash precision
  - `block` (7 chars): City block level
  - `neighborhood` (6 chars): District/neighborhood
  - `city` (5 chars): City level
  - `province` (4 chars): State/province
  - `region` (2 chars): Country/large region
- **Internet**: Required (connects to Nostr relays)
- **Use Case**: Location-based community chat, local events, regional discussions

### Direct Message Routing

Private messages use **intelligent transport selection**:

1. **Bluetooth First** (preferred when available)

   - Direct connection with established Noise session
   - Fastest and most private option

2. **Nostr Fallback** (when Bluetooth unavailable)

   - Uses recipient's Nostr public key
   - NIP-17 gift-wrapping for privacy
   - Routes through global relay network

3. **Smart Queuing** (when neither available)
   - Messages queued until transport becomes available
   - Automatic delivery when connection established

For detailed protocol documentation, see the [Technical Whitepaper](WHITEPAPER.md).

## Photo Sharing

BitChat-photo includes advanced photo sharing capabilities that work seamlessly with the existing mesh network architecture:

### Photo Transfer Features

- **Secure Photo Sharing**: Photos are encrypted and transmitted through the same secure mesh network as text messages
- **Automatic Compression**: Photos are automatically compressed to optimize transfer speed and reduce bandwidth usage
- **Chunked Transfer**: Large photos are split into manageable chunks for reliable delivery over Bluetooth LE
- **Progress Tracking**: Real-time transfer progress with status updates for both sender and receiver
- **Error Recovery**: Automatic retry mechanisms and error handling for failed transfers
- **Local Storage**: Received photos are stored locally and accessible within the chat interface

### How Photo Sharing Works

1. **Photo Selection**: Tap the photo button in the chat interface to select from your photo library
2. **Compression & Chunking**: The app automatically compresses the photo and splits it into transferable chunks
3. **Mesh Network Transmission**: Photos are sent through the same secure Bluetooth mesh network as text messages
4. **Progressive Assembly**: Receiving devices assemble photo chunks and reconstruct the complete image
5. **Local Storage**: Completed photos are saved locally and displayed in the chat conversation

### Privacy & Security

- **End-to-End Encryption**: Photos are encrypted using the same Noise Protocol as text messages
- **No Cloud Storage**: Photos are never uploaded to external servers or cloud storage
- **Local Only**: All photo data remains on your device and is transmitted only through the secure mesh network
- **Automatic Cleanup**: Photos can be cleared with the emergency wipe feature (triple-tap)

### Supported Formats

- **Image Types**: JPEG, PNG, HEIC, and other common image formats
- **Size Limits**: Automatically optimized for mesh network constraints
- **Quality Preservation**: Smart compression maintains good visual quality while reducing file size

## Setup

### Option 1: Using XcodeGen (Recommended)

1. Install XcodeGen if you haven't already:

   ```bash
   brew install xcodegen
   ```

2. Generate the Xcode project:

   ```bash
   cd bitchat
   xcodegen generate
   ```

3. Open the generated project:
   ```bash
   open bitchat.xcodeproj
   ```

### Option 2: Using Swift Package Manager

1. Open the project in Xcode:

   ```bash
   cd bitchat
   open Package.swift
   ```

2. Select your target device and run

### Option 3: Manual Xcode Project

1. Open Xcode and create a new iOS/macOS App
2. Copy all Swift files from the `bitchat` directory into your project
3. Update Info.plist with Bluetooth permissions
4. Set deployment target to iOS 16.0 / macOS 13.0

### Option 4: just

Want to try this on macos: `just run` will set it up and run from source.
Run `just clean` afterwards to restore things to original state for mobile app building and development.

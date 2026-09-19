# AmneziaWG Dedicated UDP VPN Architecture

<p align="center">
  <img src="https://img.shields.io/badge/Made_by-Farzad_(@MusicOverdose)-indigo?style=for-the-badge" alt="Made by Farzad" />
  <img src="https://img.shields.io/badge/Linux-Universal-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
  <img src="https://img.shields.io/badge/Docker-Compatible-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
  <img src="https://img.shields.io/badge/Protocol-AmneziaWG_UDP_51820-blueviolet?style=for-the-badge" alt="AmneziaWG" />
  <img src="https://img.shields.io/badge/Timezone-Asia%2FTehran-red?style=for-the-badge" alt="Asia/Tehran" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

---

## 📖 Overview

A dedicated, ultra-low-latency **AmneziaWG (UDP)** VPN server engineered specifically to bypass aggressive Deep Packet Inspection (DPI) and protocol-specific throttling across restricted networks and restrictive ISPs in Iran.

- **Pure UDP on Port 51820**: Native kernel and userspace WireGuard performance optimized for gaming, VoIP, and video streaming.
- **Advanced DPI Obfuscation**: Uses packet junk padding (`Jc`, `Jmin`, `Jmax`), message shifts (`S1`, `S2`), and customized magic headers (`H1`, `H2`, `H3`, `H4`) to disguise traffic from carrier DPI.
- **WG Tunnel Compatible**: Pre-configured with single 32-bit integer headers for seamless 1-click import into **WG Tunnel** and **AmneziaWG** on Android.
- **Timezone**: Explicitly set to **`Asia/Tehran`** (Iran/Tehran).
- **Auto Keypair Generation**: Generates and manages matched Curve25519 cryptographic keys on first boot.
- **Direct Host Persistence**: All server and client configuration files are saved directly in `/opt/amneziawg/` on your VPS host hard drive.

---

## 🏛️ Architecture

```
                 CLIENT DEVICE (Android / PC)
                    [WG Tunnel / AmneziaWG]
                               |
                     Pure UDP (Port 51820)
        [Obfuscated Handshake: Jc + S1-S2 + H1-H4 | MTU 1280]
                               |
                 Restrictive ISP / DPI Gateway
                               |
+-------------------------------------------------------------+
|                          LINUX VPS                          |
|                  Timezone: Asia/Tehran                      |
|                                                             |
|  [Docker Container: amneziawg]                              |
|  - UDP: 51820 (Host Network Mode)                           |
|  - IP: 10.13.13.1/24 (wg0 interface)                        |
|  - NAT Masquerade: Host Default Interface                   |
|  - Host Storage: /opt/amneziawg/                            |
+-------------------------------------------------------------+
```

---

## 📁 Repository Structure

```text
├── docker-compose.yml           # 1-Click Docker Compose for Portainer Git Stacks
├── amneziawg-client.conf        # Ready-to-import client configuration for WG Tunnel
├── sysctl-anti-censorship.conf  # Linux kernel & network performance optimizations
├── audit-vps.sh                 # Read-only VPS networking diagnostic script
├── LICENSE                      # MIT License
└── .gitignore                   # Git ignore file
```

---

## 🚀 1-Click Deployment via Portainer (From GitHub)

Deploy directly through the Portainer web dashboard:

1. In Portainer, go to **Stacks** $ightarrow$ **Add stack** (or update your existing stack).
2. Select **Repository** as the build method.
3. Configure the fields:
   - **Name**: `amneziawg`
   - **Repository URL**: `https://github.com/musicOverdose/amneziawg-vps`
   - **Repository reference**: `refs/heads/main`
   - **Compose path**: `docker-compose.yml`
4. Click **Deploy the stack** (or **Pull and redeploy**).

### 📋 Retrieve Your WG Tunnel Client Config:
1. In Portainer, click **Containers** $ightarrow$ select **`amneziawg`** $ightarrow$ click **Logs**.
2. Copy the ready-to-use `client.conf` printed in the banner.
3. Or open it directly on your VPS terminal:
   ```bash
   cat /opt/amneziawg/client.conf
   ```
4. Paste it into **WG Tunnel** on Android and tap **Connect**!

---

## 💻 CLI / Terminal Deployment

If deploying via terminal SSH:

```bash
# Clone the repository
git clone https://github.com/musicOverdose/amneziawg-vps.git
cd amneziawg-vps

# Start the AmneziaWG stack
docker compose up -d

# View your generated client configuration
docker logs -f amneziawg
```

---

## 📱 WG Tunnel Client Configuration Template

> [!TIP]
> **Zero Manual Editing Required**: When you start the stack, your server automatically generates a unique Curve25519 keypair and auto-detects your server's public IP.
> You can simply copy your complete, ready-to-use config directly from your container logs (`docker logs amneziawg`) or from `/opt/amneziawg/client.conf` on your VPS!

```ini
[Interface]
Address = 10.13.13.2/24
DNS = 1.1.1.1, 8.8.8.8, 9.9.9.9
MTU = 1280
Jc = 8
Jmin = 75
Jmax = 101
S1 = 88
S2 = 119
H1 = 234186206
H2 = 969072416
H3 = 1204011079
H4 = 2067328887
PrivateKey = <YOUR_CLIENT_PRIVATE_KEY>

[Peer]
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PublicKey = <YOUR_SERVER_PUBLIC_KEY>
PersistentKeepalive = 25
```

### Mobile Optimization Notes:
1. **IPv4 Only (`AllowedIPs = 0.0.0.0/0`)**: Excludes `::/0` to prevent Android `VpnService` routing deadlocks on IPv4-only tunnels.
2. **MTU = 1280**: Guarantees zero IP packet fragmentation across cellular (LTE/5G) carrier-grade NATs (CGNAT).
3. **Private DNS Off**: On Android, set **Settings $\rightarrow$ Network $\rightarrow$ Private DNS $\rightarrow$ Off** to prevent DoT (port 853) handshake verification timeouts.

---

## ⚡ Linux Performance Tuning (sysctl)

Apply kernel tweaks for Linux BBR congestion control and enlarged UDP socket buffers:

```bash
sudo cp sysctl-anti-censorship.conf /etc/sysctl.d/99-anti-censorship.conf
sudo sysctl --system
```

Key optimizations:
- **`net.ipv4.tcp_congestion_control = bbr`**: Maintains maximum throughput even during high packet loss.
- **`net.core.rmem_max = 16777216`**: 16 MB socket buffers prevent packet drops during high-speed traffic bursts.
- **`net.netfilter.nf_conntrack_max = 262144`**: Ample conntrack headroom for high-concurrency connections.

---

## 🔍 Read-Only VPS Diagnostic Script

Run the included diagnostic script to verify active ports, TUN interfaces, MTUs, and sysctl settings:

```bash
chmod +x audit-vps.sh
./audit-vps.sh
```

To quickly verify that AmneziaWG is listening on UDP port 51820:
```bash
ss -ulpn | grep 51820
```

---

## 📱 Recommended Client Applications

- **[WG Tunnel for Android](https://github.com/wgtunnel/android/releases)** *(Recommended: full AmneziaWG 3.1 obfuscation support)*
- **[AmneziaVPN Official Client](https://amnezia.org)** *(Windows, macOS, iOS, Android, Linux)*

---

## 👤 Author

Maintained and built by **Farzad** ([@MusicOverdose](https://github.com/musicOverdose)).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

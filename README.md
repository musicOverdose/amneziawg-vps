# AmneziaWG Dedicated UDP VPN Architecture

<p align="center">
  <img src="https://img.shields.io/badge/Made_by-Farzad_(@MusicOverdose)-indigo?style=for-the-badge" alt="Made by Farzad" />
  <img src="https://img.shields.io/badge/Linux-Universal-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
  <img src="https://img.shields.io/badge/Docker-Compatible-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
  <img src="https://img.shields.io/badge/Protocol-AmneziaWG_UDP_443-blueviolet?style=for-the-badge" alt="AmneziaWG" />
  <img src="https://img.shields.io/badge/Timezone-Asia%2FTehran-red?style=for-the-badge" alt="Asia/Tehran" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

---

## 📖 Overview

A dedicated, ultra-low-latency **AmneziaWG (UDP)** VPN server engineered specifically to bypass aggressive Deep Packet Inspection (DPI) and protocol-specific throttling across restricted networks and restrictive ISPs in Iran.

- **QUIC / HTTP3 Masquerading on Port 443 (UDP)**: Runs on UDP 443 so traffic blends in with global QUIC/HTTP3 web traffic, bypassing carrier-level port-51820 throttling.
- **Multiport Redirection**: Automatically accepts and forwards connections from ports **443, 8443, 53, 2083, and 51820 / UDP**.
- **Zero Fragmentation (MTU 1200)**: Clamped to 1200 MTU with TCP MSS clamping to prevent mobile carrier packet fragmentation drops.
- **Tuned Anti-DPI Obfuscation**: Uses packet junk padding (`Jc=4`, `Jmin=40`, `Jmax=70`), message shifts (`S1=50`, `S2=50`), and customized magic headers (`H1-H4`) to disguise traffic from carrier DPI.
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
                      Pure UDP (Port 443 / QUIC)
         [Obfuscated Handshake: Jc=4 + S1/S2 + H1-H4 | MTU 1200]
                               |
                  Restrictive ISP / DPI Gateway
                               |
+-------------------------------------------------------------+
|                          LINUX VPS                          |
|                  Timezone: Asia/Tehran                      |
|                                                             |
|  [Docker Container: amneziawg]                              |
|  - UDP Primary: 443 (QUIC/HTTP3 Masquerade)                 |
|  - Multiport Redirect: 51820, 8443, 2083, 53 / UDP          |
|  - IP: 10.13.13.1/24 (wg0 interface)                        |
|  - NAT Masquerade: Host Subnet & Interface                  |
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
DNS = 8.8.8.8, 8.8.4.4, 1.1.1.1
MTU = 1200
Jc = 4
Jmin = 40
Jmax = 70
S1 = 50
S2 = 50
H1 = 234186206
H2 = 969072416
H3 = 1204011079
H4 = 2067328887
PrivateKey = <YOUR_CLIENT_PRIVATE_KEY>

[Peer]
# Port 443 (UDP) mimics HTTP/3 (QUIC) web traffic to bypass port 51820 throttling
# Alt ports supported on same server: 8443, 53, 51820
Endpoint = YOUR_SERVER_IP:443
AllowedIPs = 0.0.0.0/0
PublicKey = <YOUR_SERVER_PUBLIC_KEY>
PersistentKeepalive = 25
```

### Mobile Optimization Notes:
1. **QUIC / HTTP3 Port Masquerade (Port 443 / UDP)**: ISPs in Iran (MCI, Irancell, Rightel) throttle port 51820 to 0–1 KB/s. Using UDP 443 blends in with everyday HTTPS/QUIC traffic and eliminates port-based drops.
2. **MTU = 1200 (Zero Packet Fragmentation)**: Cellular carrier LTE encapsulation adds overhead. Setting MTU to 1200 prevents packet fragmentation, which Iranian DPI firewalls systematically discard.
3. **Private DNS Off**: On Android, set **Settings $\rightarrow$ Network $\rightarrow$ Private DNS $\rightarrow$ Off** to prevent DNS-over-TLS (port 853) handshake timeouts.
4. **"Fake TLS" vs AmneziaWG**: AmneziaWG is pure UDP with randomized packet header obfuscation. It does not use Fake TLS. If an ISP temporarily executes a 100% total UDP blackout across all ports, only TCP TLS protocols like VLESS REALITY will connect.

---

## 🛠️ Essential Host-Level Routing Command

To ensure the Linux host kernel instantly forwards all decrypted VPN packets to the internet:

```bash
# Enable IPv4 packet forwarding and NAT masquerade directly on the VPS host
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -P FORWARD ACCEPT
sudo iptables -t nat -I POSTROUTING 1 -s 10.13.13.0/24 -j MASQUERADE
```

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

To verify that AmneziaWG is listening on UDP port 443:
```bash
ss -ulpn | grep 443
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

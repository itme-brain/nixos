# Frigate Camera Setup

## Camera Models

| Camera | Model | MAC | IP |
|--------|-------|-----|-----|
| parking_lot | W461ASC | 00:1f:54:c2:d1:b1 | 192.168.1.194 |
| doorbell | B463AJ | | |
| living_room | W463AQ (ch1) | 00:1f:54:b2:9b:1d | 192.168.1.147 |
| kitchen | W463AQ (ch2) | 00:1f:54:b2:9b:1d | 192.168.1.147 |
| porch | SL300 | | | |

## Network Architecture

- Camera network: 192.168.1.0/24 (isolated, no internet)
- Server NIC: enp2s0f1 @ 192.168.1.1
- WiFi AP: TP-Link RE315 @ 192.168.1.254
- DHCP range: 192.168.1.100-200

## RTSP URL Format

```
rtsp://admin:ocu?u3Su@<IP>/cam/realmonitor?channel=<CH>&subtype=0
```

- channel=1 for single-camera devices
- channel=1,2 for dual-camera devices (W463AQ)
- subtype=0 for main stream, subtype=1 for sub stream

## Camera Reset Procedures

### W461ASC (parking_lot)
1. Keep camera powered on
2. Reset button is on the back of the camera
3. Press and hold reset button for 30-60 seconds until chime sounds

### B463AJ (doorbell)
1. Remove doorbell from mount
2. Locate reset button on the back
3. Press and hold until you hear chime reset sound
4. Reconnect via Lorex app as new device

### W463AQ (living_room/kitchen)
1. Keep camera powered on
2. Rotate the lens upwards to reveal hidden reset button
3. Press and hold reset button until you hear audio prompt
4. Flashing green Smart Security Lighting confirms reset
5. Solid green = not fully reset, repeat if needed

### SL300 (porch)
1. Keep camera powered on
2. Tilt camera lens upwards to reveal reset/microSD card cover
3. Remove the cover
4. Press and hold reset button until audio prompt
5. Replace cover quickly
6. Wait for green LED flash + audio confirmation

## Initial Setup

1. Temporarily enable internet for camera network:
   ```bash
   sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o enp2s0f0 -j MASQUERADE
   sudo sysctl -w net.ipv4.ip_forward=1
   ```

2. Connect camera to "cams" WiFi network

3. Use Lorex app to configure camera (requires cloud - CCP middleman)

4. Get camera MAC from DHCP leases:
   ```bash
   cat /var/lib/dnsmasq/dnsmasq.leases
   ```

5. Add DHCP reservation in `system.nix`:
   ```nix
   dhcp-host = [
     "aa:bb:cc:dd:ee:ff,192.168.1.XXX,camera_name"
   ];
   ```

6. Add MAC to firewall block list in `system.nix`:
   ```nix
   iptables -A FORWARD -m mac --mac-source aa:bb:cc:dd:ee:ff -j DROP
   ```

7. Update camera IP in `frigate/default.nix` and enable

8. Deploy and disable internet:
   ```bash
   nixos-rebuild switch --flake .#server --target-host server
   sudo iptables -t nat -D POSTROUTING -s 192.168.1.0/24 -o enp2s0f0 -j MASQUERADE
   sudo sysctl -w net.ipv4.ip_forward=0
   ```

## Storage

Frigate data is stored on /data to avoid filling root partition:

| Path | Bind Mount | Contents |
|------|------------|----------|
| /var/lib/frigate | /data/frigate/lib | Database, recordings, clips |
| /var/cache/frigate | /data/frigate/cache | Temporary cache |
| /var/cache/nginx/frigate | /data/frigate/nginx-cache | API response cache |

## Notes

- Lorex cameras are cloud-only for configuration (no local web UI responds)
- RTSP works locally without internet
- Cameras phone home aggressively when internet is available - keep isolated
- Haswell CPU cannot hardware decode HEVC - using CPU decode
- Consider T400 GPU for hardware acceleration if scaling to more cameras

## Port Scan Results (W461ASC)

- 80/tcp - HTTP (non-responsive, proprietary)
- 554/tcp - RTSP (working)
- 8086/tcp - Proprietary
- 35000/tcp - Proprietary

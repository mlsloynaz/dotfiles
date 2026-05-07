# start-serveDocs — GlobalSkew HTML hub (Projects / OneDrive)

Default: serve **static HTML** from the **`00-InventoryPrices`** project folder on port **9000** (not the Angular app). Browser opens **`/`** → **`index.html`**; the full hub remains **`InventoryPrices-GlobalSkew.html`**.

## Run from CMD (any folder, if `~\bin` is on PATH)

```bat
start-serveDocs
```

That runs the same `cd` + `npx http-server` as below.

## Run (PowerShell — copy both lines)

```powershell
cd "C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects\00-InventoryPrices"
npx --yes http-server . -p 9000 -a 0.0.0.0 -o /
```

Leave the terminal open. `cd` must be this folder so `./` fetches for `.md` / `.sql` / `PD-6109-hub-resources.js` work. **`-o /`** opens the browser at the site root, which serves **`index.html`** when present.

**`-a 0.0.0.0`** means the server listens on **every network interface**, including your LAN IPv4 (e.g. **`192.168.75.5`** from `ipconfig`). Other people on the **same LAN** should open **`http://192.168.75.5:9000/`** (replace with **your** IPv4; **include port `:9000`** — `http://192.168.75.5/` alone is **port 80**, which this command does not serve unless you add something else on 80).

**Optional — bind only your LAN IP and open that URL locally** (useful if you have several adapters or VPNs; set IP from `ipconfig`):

```powershell
cd "C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects\00-InventoryPrices"
npx --yes http-server . -p 9000 -a 192.168.75.5 -o http://192.168.75.5:9000/
```

Change **`192.168.75.5`** whenever your DHCP address changes.

## Stop

Use slash **`/stop-serveDocs`** or run **`stop-serveDocs`** from CMD (same PATH as `start-serveDocs`).

## Open in browser

- This PC: `http://localhost:9000/` (serves **`index.html`** at the project root; from there, open the full hub link if needed)
- **Same LAN (other users):** `http://<YOUR_IPV4>:9000/` — e.g. `http://192.168.75.5:9000/` if that is **this PC’s** IPv4 (`ipconfig` → your Wi‑Fi or Ethernet adapter). They must use **`:9000`**.
- Direct hub (optional): `http://localhost:9000/InventoryPrices-GlobalSkew.html`

## Tunnel (optional — share outside your network), second terminal

```powershell
npx --yes cloudflared tunnel --url http://localhost:9000
```

Share the printed `https://…` URL.

## Windows firewall (only if LAN cannot connect), elevated PowerShell

```powershell
New-NetFirewallRule -DisplayName "Dev server 9000" -Direction Inbound -LocalPort 9000 -Protocol TCP -Action Allow
```

---

**Other stacks** (Angular, .NET, another Projects subfolder): follow the project rule `@.cursor/rules/start-local-server.mdc` and swap the `cd` path or use `npm run` / `dotnet run` as documented there.

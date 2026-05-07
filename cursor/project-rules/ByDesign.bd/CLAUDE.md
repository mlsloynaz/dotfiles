# ByDesign.bd — AI Assistant Handbook

Canonical rules for this repository. Follow these as hard requirements, not suggestions.

---

## 1. Personal SQL snippets

The user's SQL snippets are stored at:
`C:\Users\malu.loynaz\Documents\sql-my-snippets.snippet`

This is a Visual Studio XML snippet file. When asked to add, view, or edit SQL snippets, read and write this file directly.

---

## 2. Where to put files (markdown, SQL, notes)

Determine the **card id** and **topic/client** from the conversation **before** choosing a folder.

### PD-style titles (e.g. `PD-5742: Promotion: Tropic:`)

| Segment | Meaning | Example |
|---------|---------|---------|
| First token | Jira card id / branch | `PD-5742` |
| Next segment | Topic (feature/area) | `Promotion` |
| Further segment | Client or environment | `Tropic` |

### UB-style titles (e.g. `UB-10217: AngularApp:`)

- `UB-xxxx` = Jira/branch id → **prefix every new doc** with `UB-xxxx_`
- App name maps to a repo path (see app paths below)

### File placement

| File type | Location |
|-----------|----------|
| Quick debug SQL, scratch scripts, short MD | `C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects\ToOrganize` |
| Longer docs/SQL tied to a PD Jira card | `...\Documents\Projects\PD\PD-xxxx\` (use real id) |
| Topic-level summary for PD process | `...\Documents\Projects\PD\00-Topic\` |
| Research / prior context | Search `...\Documents\Projects` by `PD-xxxx`/`UB-xxxx` prefix first |
| Product code or repo-owned SQL to commit | Normal paths inside `C:\Code\ByDesign.bd\` |

**Naming:** always start filenames with the Jira id, e.g. `PD-6191-Debug-orders.sql`, `UB-10217-investigation-notes.md`.

### App paths

| Chat label | Repo folder |
|------------|-------------|
| AngularApp | `SOA/Applications/Web/AngularApp` |
| WebAPI | `SOA/Applications/Web/ByDesign.SOA.Applications.WebAPI` |
| BO | `Websites/BackOffice` |
| BO2 | `SOA/Applications/Web/BackOffice2` |
| Angularjs | `SOA/Applications/Web/ByDesignAngularJSShoppingCart` |

---

## 2. Topic diagrams (Mermaid) and `media`

When creating ERDs, flow diagrams, or other diagrams for a topic:

1. **Format:** Prefer Mermaid (`.mmd` with a `mermaid` fenced block, or `.md` with fenced block)
2. **Location:**
   - PD handbook tree → `...\Documents\Projects\PD\00-Topic\media\`
   - Top-level topic folder → `...\Documents\Projects\00-<Name>\media\`
   - **Create `media/` if it does not exist**
3. **Single source:** one canonical file per diagram variant; link from elsewhere, never duplicate
4. **HTML dropdowns:** if HTML already has a diagram dropdown, render from the `media` file — do not embed the full Mermaid source again inline

---

## 3. Assistant behavior

- Run tools and commands in this real environment; do not stop at "you could run…". If something fails, diagnose and try again.
- Use full conversation context; short follow-ups usually refine the current task, not cancel it.
- Today's date is available in the chat context — use it when the year matters.

---

## 4. Communication and code edits

- **Code changes:** smallest change that solves the task; no unrelated refactors; do not remove unrelated comments or code.
- **PD/UB ticket ids in comments:** do **not** add `PD-xxxx` or `UB-xxxx` inside comments in application code (C#, TypeScript, etc.). Use commit messages, PRs, or docs under Projects for ticket traceability.
  - **Exception:** ticket ids may appear in **SQL description/revision headers** at the top of a SQL script (the usual block that documents the proc or change).
- **New markdown in the repo:** only when the user explicitly asked for it.
- **ESLint:** fix line length last when cleaning lint.
- **Paths and URLs:** give full strings.

---

## 5. ByDesign domain and technical defaults

### Inventory pricing

Price from inventory prices by **country** and **currency type**, only when `INVENTORYPRICES_COUNTRYAWARE = 1`. Related terms: **inventory prices country aware**, **global skew**, **IPCA**.

### SQL in the repo

- **Single-line separation:** separate statements or logical blocks with **one blank line** (not multiple). Match the file's current spacing when touching existing scripts — do not reformat unrelated SQL.
- **No `PRINT`** in SQL committed to the repo.
- **Do not reformat** SQL or code unless the task requires it.
- **Stored procedures:** `util_CreateEmptyProc` then `ALTER PROCEDURE`:

```sql
EXEC util_CreateEmptyProc 'aspx_CompRun'
GO

ALTER PROCEDURE [dbo].[aspx_CompRun] @BonusRunID INT = NULL OUTPUT,
```

- If the **same function or heavy expression runs more than once** in one batch, materialize into a temp table and reuse.

### .NET and Angular tests

- **.NET 4.5** where applicable.
- **Angular unit tests:** Jest; **do not** unit test private methods.

---

## 6. AngularApp coding standards

*Applies to files under `SOA/Applications/Web/AngularApp/`.*

Angular 14. Focus on clean code, proper component organization, and reactive patterns. Performance is paramount.

### General style

- 2 spaces for indentation; max line length 80 characters
- Newline at end of every file; dangling commas for multi-line lists
- Braces on same line; always use if-else when all paths return
- Initialize properties in declaration when possible

### TypeScript

- Always include type annotations (except arrow functions)
- Use enums instead of union types for fixed values; strict type checking
- Avoid `any`; use `unknown` when type is uncertain
- Always add TSDoc (except injection properties)
- Use `Maybe<T>` and `Nullable<T>` for optional/nullable; `MaybePromise<T>` for `T | Promise<T>`

### Angular

- Standalone components preferred for simpler organization
- `changeDetection: ChangeDetectionStrategy.OnPush` on every component
- Never use `public` access modifier (it's default); use `private` and `protected` appropriately
- Use `inject()` function instead of constructor injection
- Use BehaviorSubject/Observable pattern for reactive state; name observables with `$` suffix
- Prefer Reactive forms over Template-driven forms
- Use `trackBy` with `*ngFor`; always use async pipe with observables

### Imports

- Aliased imports (`@bydesign/*`) when importing from outside current project, outside current root, subdirectories, or sibling subdirectories
- Relative imports only for files in the same directory or directly above in the same root

### Component property order (with newlines between groups)

ViewChilds → Inputs → Outputs → Public (excluding injections) → Protected → Private → Public injections → Protected injections → Private injections

### Services

- Single responsibility; document public API with TSDoc
- Extensions: files suffixed `.extensions`, classes suffixed `Extensions`

---

## 7. Serve AngularApp project

**Trigger:** `start ng {project} {client-shorthand}`

Resolve `{client-shorthand}` using the DBName shorthands table in §8, then run:

```
cd C:\Code\ByDesign.bd\SOA\Applications\Web\AngularApp
ng serve {project} --configuration={DBName}
```

No confirmation needed — execute immediately.

If port 4200 is already in use, kill the process occupying it first (use PowerShell `Stop-Process`), then start on 4200.

Examples: `start ng shop truaura` → `ng serve shop --configuration=truaurabeauty`

**Trigger:** `stop ng` — kill all running `ng serve` processes. Find the PID on port 4200 and kill it with PowerShell `Stop-Process`. No confirmation needed.

**Trigger:** `ng {project} {client-shorthand}` (no server prefix) — generate a seamless checkout test URL for the current MCP DB connection:

1. Query `SELECT TOP 1 Guid FROM SeamlessAuthGUIDs ORDER BY ID DESC`
2. Query `SELECT TOP 1 ID FROM OnlineOrders ORDER BY ID DESC`
3. Return: `localhost:4200/checkout/seamless/customer/{Guid}/{ID}/1?cartConfigurationID=1&repDID=1`

No confirmation needed. The user is responsible for switching the MCP DB to the right client first (`db-{server}-{client}`).

---

## 8. Environment profiles — appsettings.json

When given a **Server** and **DBName**, update `appsettings.json` using these patterns:

| Key | Value |
|-----|-------|
| `API_ENDPOINT` | `https://{Server}-webapi.bydesign.com` |
| `EXTRANET_URL` | `https://{Server}-extranet.bydesign.com` |
| `REVOLUTION_URL` | `https://{Server}-tools.bydesign.com` |
| `JSCART_URL` | `https://{Server}-shop.bydesign.com` |
| `CLIENT_FOLDER` | `{DBName}` |
| `LEVEL` | `{Server}` uppercased |

**Triggers — two distinct commands:**

| Command form | Action |
|---|---|
| `ng {server}-{db}` | Update Angular `appsettings.json` only |
| `db-{server}-{db}` | Switch MCP DB connection only |

Both can be typed as a standalone message with no other words. Examples: `ng cs-tropic`, `ng stg-qa10`, `db-cs-tropic`, `db-stg-qa10`.

**Shorthands** — resolve before applying the pattern:

**Servers**

| Shorthand | Server |
|-----------|--------|
| `stg` | `staging` |
| `cs` | `cs` |

**Sandbox patterns (cover all numbers automatically)**

| Shorthand | DBName |
|-----------|--------|
| `qa{N}` | `QASandbox{N}` |
| `bdt{N}` | `BDTSandbox{N}` |

**Client databases**

| Shorthand | DBName |
|-----------|--------|
| `hh` | `HealthyHome` |
| `hh-old` | `839229_HealthyHome` |
| `adp-clean` | `AdaptureClean` |
| `adp-demo` | `AdaptureDemo` |
| `adp-shopify` | `AdaptureShopifyDemo` |
| `annuity` | `annuity` |
| `anovite` | `Anovite` |
| `arieyl` | `Arieyl` |
| `avere` | `averelife` |
| `avroy` | `avroyshlain` |
| `beacon` | `beaconofhope` |
| `beni` | `benivita` |
| `blen` | `blenusa` |
| `bodywise` | `BodyWise` |
| `bravenly` | `Bravenly` |
| `bd` | `ByDesign` |
| `bdrev` | `ByDesignRevolution` |
| `bduni` | `ByDesignUniversity` |
| `cili` | `Cili` |
| `crunchi` | `crunchi` |
| `ethos` | `ethoslending` |
| `faster` | `fasterway` |
| `fcd` | `FreedomCD` |
| `frc` | `FreedomRC` |
| `ght` | `GHTHealth` |
| `ghs` | `GlobalHealthSafety` |
| `gfp` | `goodfeelingproducts` |
| `heavenly` | `heavenlyenhanced` |
| `impax` | `ImpaxWorld` |
| `jbloom` | `jBloom` |
| `jh` | `JHilburn` |
| `joi` | `joiandblokes` |
| `jordan` | `JordanEssentials` |
| `kyani` | `KyaniSun_archive` |
| `lbri` | `Lbri` |
| `lemon` | `lemongrassspa` |
| `lumi` | `lumiceuticals` |
| `lmc` | `lunchmoneyclub` |
| `magnetu` | `MagnetudeJewelry` |
| `magnolia` | `magnoliadesignco` |
| `maquira` | `maquira` |
| `maysense` | `Maysense` |
| `nefful` | `Nefful` |
| `phoenix` | `newphoenixrising` |
| `newulife` | `NewULife` |
| `nuvi` | `NuviGlobalLife` |
| `nuvita` | `Nuvitacbd` |
| `oliveda` | `OlivedaNT-732` |
| `omg` | `omgcontigo` |
| `opena` | `opena` |
| `oqata` | `oqata` |
| `papa` | `Paparazzi` |
| `pharma` | `Pharmaziegasse` |
| `pixingo` | `Pixingo` |
| `pomi` | `Pomifera` |
| `purehaven` | `PureHaven` |
| `quantum` | `QuantumLifestyle` |
| `sendout` | `SendoutCards` |
| `sharelife` | `sharelife` |
| `shoppy` | `shoppyshop` |
| `shopme` | `shopwithme` |
| `somnvie` | `somnvie` |
| `syona` | `Syona` |
| `te` | `TeamEffort` |
| `movie` | `TheMovieBookClub` |
| `tropic` | `tropicskincare` |
| `truaura` | `truaurabeauty` |
| `vfinity` | `Vfinity` |
| `vista` | `VistaLife` |
| `voxx` | `VoxxLife` |
| `wayroo` | `wayroo1` |
| `wine` | `WineShop` |
| `youngevity` | `Youngevity` |
| `zilis` | `Zilis` |

---

## 8. Local dev server

**`/start-serveDocs`** — starts OneDrive `00-InventoryPrices` + `http-server` on port 9000.  
**`/stop-serveDocs`** — stops whatever owns port 9000.

- Bind dev server to `0.0.0.0` for LAN access
- Use a tunnel (cloudflared / ngrok) for outside-network access

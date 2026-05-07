# Cursor AI rules — handbook (readable)

**Canonical handbook for this repo.** Cursor loads it via the always-on **ByDesign-only** project rule `.cursor/rules/bd-handbook-consolidated.mdc` (present only in this workspace). Prefer updating **this file** (and Angular-specific `.mdc` when needed) instead of duplicating the same policies in **Cursor Settings → User Rules** — remove duplicated ByDesign bullets there.

This file explains **how Cursor applies rules** and **where to put files** (markdown, SQL, notes) so work stays easy to find. For Cursor’s own product behavior, see [Rules | Cursor Docs](https://www.cursor.com/docs/context/rules).

**AngularApp coding standards** are **not** duplicated here; they live only in `.cursor/rules/angular-copilot-instructions.mdc`.

---

## 1. How Cursor rules work (short)

| Kind | Where | Used by |
| --- | --- | --- |
| **Project rules** | `.cursor/rules/` (`.md`, `.mdc`) | Agent in this repo |
| **User rules** | **Cursor Settings → Rules** | Agent in **all** your projects |
| **Team rules** | Cursor dashboard (Team / Enterprise) | Your org (may be enforced) |
| **AGENTS.md** | Repo root or subfolders | Agent, plain markdown |

**What rules do:** when they apply, their text is added **near the start** of the model context so the assistant follows the same instructions each time.

**How a project rule is applied:** always / intelligent (uses **description**) / file **globs** / **@‑mention** manual. You can embed **`@path/to/file`** in a rule instead of pasting large code.

**If rules conflict:** **Team → Project → User** (earlier wins when merged).

**Limits:** **User rules do not apply to Inline Edit (Ctrl/Cmd+K)** — Agent Chat only. Rules are **not** the same as Cursor Tab behavior (see docs).

**Good habits:** short, imperative rules; split by topic; link to repo examples instead of copying whole style guides.

---

## 2. Where to put markdown and SQL (debug, help, investigation)

Use this when you create **markdown notes**, **debug SQL**, **one-off scripts**, or **writeups that are not meant to live in the git repo** unless the user explicitly wants them in the codebase.

**Read order matters:** figure out **card id** and **topic / client** from the chat **before** choosing a folder (sections **2.1 → 2.2**). That way paths like `...\PD\PD-xxxx\` use the correct `PD-xxxx`.

### 2.1 Read card id, topic, and client from the chat first

Do this **before** creating or naming files under Projects.

**PD-style titles** (example: `PD-5742: Promotion: Tropic:`):

| Segment (typical pattern) | Meaning | Example |
| --- | --- | --- |
| First token | **Jira card id** / branch when aligned | `PD-5742` |
| Next segment | **Topic** (feature, area, or workstream label) | `Promotion` |
| Further segment(s) | Often **client** or environment label | `Tropic` |

**From that, you know:**

- **`PD-xxxx`** = Jira card id → use it in **folder** `...\Documents\Projects\PD\PD-xxxx\` and as the **`PD-xxxx_`** prefix on **new `.md` / `.sql`** for that card.
- **Topic** (e.g. Promotion) → use when **searching** for prior docs and when placing **topic summaries** under **`...\Documents\Projects\PD\00-Topic\`** (or your team’s existing `00-Topic` location).
- **Client** (e.g. Tropic) → use for **HTML journal** and client-specific artifacts; same **card folder** and **filename prefix** unless the user gives a different client layout.

**UB-style titles** (example: `UB-10217: AngularApp:`):

- **`UB-xxxx`** = Jira / branch id → **prefix every new doc** with `UB-xxxx_`.
- The **app name** after the id maps to a **repo path** (see **2.3**).

**If the title does not include an id:** use the **git branch** name when it matches **`PD-xxxx`** or **`UB-xxxx`**, or ask once instead of guessing.

### 2.2 Where to put the file (after you know PD-xxxx / UB-xxxx)

| If the file is… | Put it here |
| --- | --- |
| **Quick debug SQL**, **scratch script**, **short MD** to help you or the team troubleshoot | `C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects\ToOrganize` |
| **Longer docs or SQL tied to a PD Jira card** (same card as the branch) | `C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects\PD\PD-xxxx\` (use the real id from **2.1**) |
| **A topic-level summary** for the PD process (not only one ticket’s folder) | `C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects\PD\00-Topic\` — **or** the `00-Topic` location your team already uses under Projects; stay consistent with existing folders |
| **Research / prior context** before inventing new docs | Under `C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects`: search by the same **PD-xxxx** or **UB-xxxx** **prefix in filenames**, **and** search by **similar topic or context** (topic label from the title, client name, feature name, error message, or table/SP names from the task) so you find related writeups even when the id differs or is missing from older files |
| **Product code or repo-owned SQL** the user asked to commit | Normal paths **inside** `C:\Code\ByDesign.bd\` (or the relevant repo) — **not** ToOrganize |

**Naming:** whenever you have a Jira id, **start the filename with it**, for example `PD-6191-Debug-orders.sql`, `UB-10217-investigation-notes.md`. That makes OneDrive and search predictable.

**Format:** documentation **outside** the codebase should be **Markdown** (`.md`) unless the user asks for something else.

### 2.3 UB card + app name (repo paths)

- **Reuse prior writeups:** search `...\Documents\Projects` for **`UB-xxxx`** and for **topic/context** keywords as in **2.2** before creating duplicates.
- **Code paths** when the chat names an app:

| Chat label | Repo folder |
| --- | --- |
| AngularApp | `C:\Code\ByDesign.bd\SOA\Applications\Web\AngularApp` |
| WebAPI | `C:\Code\ByDesign.bd\SOA\Applications\Web\ByDesign.SOA.Applications.WebAPI` |
| BO | `C:\Code\ByDesign.bd\Websites\BackOffice` |
| BO2 | `C:\Code\ByDesign.bd\SOA\Applications\Web\BackOffice2` |
| Angularjs | `C:\Code\ByDesign.bd\SOA\Applications\Web\ByDesignAngularJSShoppingCart` |

### 2.4 Tiny examples

- *“I need a quick query to list duplicate orders while debugging PD-6191.”*  
  → `...\ToOrganize\PD-6191-duplicate-orders.sql`

- *“Write a durable analysis doc for PD-5742 with screenshots in MD.”*  
  → `...\Projects\PD\PD-5742\PD-5742_analysis.md`

- *“User asked to add a migration script to the repo.”*  
  → Put it where the team keeps SQL in **git**, not ToOrganize.

### 2.5 Topic diagrams (ERD, flowcharts) — Mermaid and `media`

Use this when you produce **ERDs**, **process / flow diagrams**, or other **Mermaid** visuals tied to a **topic** (not a one-off scratch note).

**Where to put diagram files**

| Topic layout you are using | Put Mermaid / diagram files here |
| --- | --- |
| PD handbook tree (`...\Projects\PD\00-Topic\`) | `...\Documents\Projects\PD\00-Topic\media\` |
| Top-level topic folder under Projects (`00-<Name>`, same pattern as `tools/organize-00-topic-folders.ps1`) | `...\Documents\Projects\00-<Name>\media\` |

- **Create `media` if it does not exist** under that topic root before saving new diagram files.
- Prefer **clear filenames**, e.g. `promotion-order-flow.mmd`, `inventory-pricing-erd.mmd`, or `topic-flow.md` with a fenced `mermaid` block.
- Keep **one canonical file per diagram variant**; other docs should **link** to it or **load** it, not copy-paste the full definition in multiple places.

**HTML / journal and diagram dropdowns**

- If the **HTML already includes a diagram dropdown** (or tab/panel meant to host a diagram), **use that UI** to show the diagram by **loading content from the file under `media/`** (for example fetch the `.mmd` / `.md` asset and render with Mermaid.js, or equivalent). **Do not duplicate** the same Mermaid source inline in the HTML **and** in the file — **read from the file** so there is a single source of truth.
- If **no** such control exists, follow the user’s preference (link to `media/`, single embed, etc.) while still storing the canonical definition under **`media/`** when it is topic documentation.

---

## 3. How the assistant should behave

- Treat **user rules**, **tool descriptions**, **skills**, and **MCP** text as **hard requirements**, not suggestions.
- **Read and follow skills** when they match the task.
- **Run tools and commands** in this real environment; do not stop at “you could run…”. If something fails, **diagnose and try again** or another approach.
- **Today’s date:** use the **`Today's date:`** value from the chat user info when the year matters (do not assume the wrong year).
- Use **full conversation context**; short follow-ups usually **refine** the current task, not cancel it.

---

## 4. Communication and repo edits

- Prefer **code citations** (line range + path in the fence label). Put the **opening code fence on its own line** (not after a bullet on the same line). Do not use HTML escapes where literal characters are intended.
- **Paths and URLs:** give full strings.
- **Code changes:** smallest change that solves the task; no unrelated refactors; do not remove unrelated comments or code.
- **PD / UB ticket id in comments:** do **not** add **`PD-xxxx`** or **`UB-xxxx`** inside **comments in application code** (C#, TypeScript, etc.) as part of a change. Use the **commit message**, **PR**, or **docs under Projects** for ticket traceability. **Exception:** ticket ids **may** appear in an **SQL description / revision header** at the top of a SQL script or object (the usual block that describes the proc or change), when that matches your SQL header standard.
- **New markdown in the repo:** only when the user asked for that documentation (this handbook file is an explicit exception when you maintain it on purpose).
- **ESLint:** fix **line length last** when cleaning lint.

---

## 5. Personal SQL snippets

The user's SQL snippets are stored at:
`C:\Users\malu.loynaz\Documents\sql-my-snippets.snippet`

This is a Visual Studio XML snippet file. When asked to add, view, or edit SQL snippets, read and write this file directly.

---

## 6. ByDesign domain and technical defaults

### Inventory pricing (one feature family)

Price from **inventory prices** by **country** and **currency type**, only when **`Inventoryprices_CountryAware = 1`**. Related terms: **inventory prices country aware**, **global skew**, **IPCA**.

### SQL in the repo

- **Ticket id in comments:** same rule as **section 4** — **`PD-xxxx` / `UB-xxxx`** only in **SQL description / revision headers** where your team documents the object, not as ad hoc inline comments in the body unless the user asks.
- **Single-line separation:** in **SQL scripts** you add or materially extend, separate **statements or logical blocks** with **one blank line** (a single empty line between units—e.g. after `GO`, between `CREATE`/`ALTER` sections, or between unrelated batches). Do **not** stack multiple blank lines between the same two blocks; when touching existing scripts, **match the file’s current spacing** (do not reformat unrelated SQL).
- **Do not reformat** SQL or code unless the task requires it.
- **No `PRINT`** in SQL committed to the repo.
- **Stored procedures:** `util_CreateEmptyProc` then `ALTER PROCEDURE` (standard pattern), for example:

```sql
EXEC util_CreateEmptyProc 'aspx_CompRun'
GO

ALTER PROCEDURE [dbo].[aspx_CompRun] @BonusRunID INT = NULL OUTPUT,
```
- If the **same function or heavy expression runs more than once** in one batch, **materialize into a temp table** (or equivalent) and reuse.

### .NET and Angular tests

- **.NET 4.5** where applicable.
- **Angular unit tests:** **Jest**; **do not** unit test **private** methods.

---

## 6. What this file is not

- Not a replacement for **Cursor Settings** or the live docs.
- Not an automatic export of **Team Rules** from the dashboard.
- Not a dump of Cursor’s proprietary system prompts.

---

## 7. Local dev server — `start-serveDocs` / `stop-serveDocs` (Cursor)

**Slash commands:** **`/start-serveDocs`** loads **`.cursor/commands/start-serveDocs.md`** (OneDrive **`00-InventoryPrices`** + **`http-server`** on port **9000**). **`/stop-serveDocs`** loads **`.cursor/commands/stop-serveDocs.md`** (stops whatever owns **port 9000**).

In **Agent** chat you can also say **`start-serveDocs`**, **`stop-serveDocs`**, or attach **`@.cursor/rules/start-local-server.mdc`** for the full rule (Angular, .NET, tunnels, firewall). The **command** files are the short defaults for the **GlobalSkew HTML hub** start/stop; the **rule** file has all variants.

- bind the dev server to **all interfaces** (`0.0.0.0`) so **LAN** peers can open `http://YOUR_IP:PORT`, and  
- **publish** to people outside the network via a **tunnel** (e.g. cloudflared / ngrok).

Canonical instructions live in the project rule (Angular `ng serve` flags, `dotnet run --urls`, static `http-server`, Windows firewall, tunnels). Do not duplicate the full command list here.

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

## 9. Maintenance

- Re-read [Cursor Rules documentation](https://www.cursor.com/docs/context/rules) when Cursor ships changes.
- When **sections 3–5**, **§2.5** (topic diagrams / `media`), or **§7** (local server) of this handbook change, you usually **do not** need to touch `.cursor/rules/bd-handbook-consolidated.mdc` unless you rename this file or add another canonical doc — unless you add a **new** always-on rule file; then consider `@`-including it from `bd-handbook-consolidated.mdc` only if it must apply every chat.
- **AngularApp / component / RxJS / import rules:** edit **only** `.cursor/rules/angular-copilot-instructions.mdc`.

### 8.1 Cursor User Rules — delete duplicates (manual, one time)

**Cursor Settings → Rules → User Rules** cannot be edited from this repo. After `bd-handbook-consolidated.mdc` is in place, **remove** from User Rules any text that now lives in this handbook, for example:

- OneDrive / `ToOrganize` / `Projects` / `PD` / `UB` paths and naming
- Chat title patterns **PD-xxxx** / **UB-xxxx**, topic, client, `00-Topic`
- PD / UB in code comments (SQL header exception)
- SQL: `PRINT`, `CreateEmptyProc`, temp table reuse, formatting
- .NET 4.5, Jest / private methods, ESLint line length last
- Inventory country-aware pricing / IPCA / global skew
- “Execute commands yourself”, skills/MCP, prose standards — **if** you duplicated them only for ByDesign; keep them in User Rules **only** when you want the same behavior **in every repo**

**Keep in User Rules** short **global** items that are **not** ByDesign-specific (examples: default tone, secrets handling, tools you always want mentioned).

Optional replacement for User Rules after cleanup:

```text
For non-ByDesign repos, follow these global preferences: [your short global lines].
For the ByDesign.bd workspace, do not restate repo policy; follow .cursor/CURSOR-AI-RULES-CONSOLIDATED.md via project rules.
```

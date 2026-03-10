# Branding Skill — Standard, Premium & Angular (SOA)

**Reference:** Standard Branding Process, Premium Cart Branding & Angular Cart Branding (SOA), by Arianna Capasso.

Use this skill when setting up or updating client branding for the cart and Revolution.

- **Standard branding:** Logos, color schemes, fonts, favicons, template links → see [Standard Branding Process](#standard-branding-process-soa) below.
- **Premium cart branding (PCB):** Replicating the client’s marketing site header and footer in the cart with custom HTML and styles → see [Premium Cart Branding](#premium-cart-branding-soa) below. Do standard branding first if the client is new.
- **Angular cart branding:** New Angular cart client folder, SCSS variables, and build config → see [Angular Cart Branding](#angular-cart-branding) below.

---

## Standard Branding Process (SOA)

**Example ticket:** ClaroMD — PD-1366.

## Scope (standard)

- **Standard branding:** Logos, color schemes, and fonts in the cart and Revolution.
- **Premium branding:** See [Premium Cart Branding](#premium-cart-branding-soa) section; marketing header/footer replication and heavy custom styling.

**Note:** A PDF with client branding guidelines (colors, fonts, logo specs) should be attached to the work ticket. Use it for `variable.less`, `client.less`, and asset replacement.

---

## 1. Generate new client folders

Create the client folder in all three places (use the **client name from Intranet**):

| Location | Path |
|----------|------|
| **Cart** | `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/<ClientName>` |
| **Revolution** | `Revolution/WebSites/Revolution/Clients/<ClientName>` |
| **Extranet** | `\\extranet-cs-01\wwwroot\<ClientName>` |

Use an existing client (e.g. ClaroMD) as the template: copy the folder structure and then replace content per steps below.

---

## 2. Replace logos

### Extranet

- **Path:** `\\extranet-cs-01\wwwroot\<ClientName>\Personal\Header`
- Replace the **5 different .png files**, keeping the **same filenames**.
- The **Cart pulls its logos from `logo-cart.png`** in this folder.

### Revolution

- **Path:** `Revolution/WebSites/Revolution/Clients/<ClientName>/Content/Images`
- Replace **`logo.png`** with the new image.

---

## 3. Replace favicons

| Location | Path | File to replace |
|----------|------|------------------|
| **Revolution** | `Revolution/WebSites/Revolution/Clients/<ClientName>/Content/Images/icons` | `favicon.png` |
| **Cart** | `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/<ClientName>` | `favicon.png` |
| **Extranet** | `\\extranet-cs-01\wwwroot\<ClientName>\Personal\images` | `favicon.ico` |

Use **.png** for Revolution and Cart, **.ico** for Extranet.

---

## 4. Cart branding (styling)

Use the client’s branding PDF for colors, fonts, and any logo/size notes.

### 4.1 `variable.less`

- **Path:** `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/<ClientName>/less/client/variable.less`
- Update variables from the client’s branding guidelines. Typically:
  - All **color** variables
  - **Font**, **case**, **btn-radius**, **btn-case**, **btn-font**
- Leave structure the same; only change values to match the PDF.

### 4.2 `client.less`

- **Path:** `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/<ClientName>/less/client/client.less`
- **Fonts:** Match client font (use a **Google Font** when possible).
  - If using a Google font, add the **`@import`** at the **top** of this file.
  - Update all **`font-family`** values to the client’s font.
- **Buttons:** Align with what was set in `variable.less` (border-radius, text-transform, etc.).
- **Custom tweaks:** Logo size, top navbar, button styling, etc. can go here.

### 4.3 Header and footer templates

- **Path:** `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/<ClientName>/template`
- **`header-main.html`:** Set the logo **`href`** to the client’s **marketing site**. Use the correct **repDID** for redirects. Prefer **subdomain** URL structure for new clients (confirm it’s not subfolder).
- **`footer.html`:** Update the **copyright section** so the client name links to the same marketing site (same `href` behavior as header).
- **Note:** If the HTML differs a lot from the standard template, the site may have **premium branding**; standard process may not be enough.

---

## 5. Extranet styling

- **Path:** `\\extranet-cs-01\wwwroot\<ClientName>\Personal\Css`
- Edit **`styles.css`**:
  - Set **`border-top`** color to the client’s **primary color (hex)**.
  - Add any other Extranet-specific styles (e.g. logo **max-width** so large logos don’t overflow).

---

## 6. Revolution styling

- **Path:** `Revolution/WebSites/Revolution/Clients/<ClientName>/Content/CSS`
- Edit **`custom.css`**:
  - Adjust **button styles** (and add any **font `@import`** if needed).
  - Add any other generic Revolution custom styles here.
- Revolution can inherit some branding (e.g. colors, fonts) from the **Cart’s variable file**; for **overrides** that must only affect Revolution, put them in this **`custom.css`**. Overriding Revolution-only styles in the Cart’s `variable.less` will **not** work.

**Examples:**

- **PD-5537** — override in Revolution `custom.css`: [commit 358d495](https://hub.com/Retail-Success/ByDesign.bd/commit/358d495a40573bf6d3661afe8974a1c30bd21e5d).
- **PD-5102** — more extensive example: LuxeBeauty branding (ByDesign.bd repo).

---

## Checklist (quick reference)

- [ ] Client folders created in Cart, Revolution, Extranet
- [ ] Extranet Header: 5 logos replaced (names unchanged); Cart uses `logo-cart.png`
- [ ] Revolution: `Content/Images/logo.png` replaced
- [ ] Favicons: Revolution + Cart `.png`, Extranet `.ico`
- [ ] Cart: `variable.less` (colors, fonts, button vars)
- [ ] Cart: `client.less` (font-family, Google import, buttons, custom styles)
- [ ] Cart: `header-main.html` and `footer.html` — marketing site links + repDID
- [ ] Extranet: `styles.css` — border-top color, logo max-width if needed
- [ ] Revolution: `custom.css` — buttons, font import, overrides (not in Cart variable.less)

---

## Premium Cart Branding (SOA)

**Reference:** Premium Cart Branding (SOA), by Arianna Capasso.

Premium cart branding (PCB) is replicating the client’s **marketing site header and footer** inside the shopping cart with custom HTML and styles. **Standard branding must already be in place** for the client before starting PCB. See [Standard Branding Process](#standard-branding-process-soa) if you need to set up standard branding first.

### Main files to change

Most PCB work is in:

| File / folder | Path |
|---------------|------|
| Header template | `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/{{client}}/template/header-main.html` |
| Footer template | `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/{{client}}/template/footer.html` |
| Client styles | `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/{{client}}/less/client/client.less` |
| Other templates | `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/{{client}}/template/*.html` |
| Site links (header nav) | `SOA/Applications/Web/ByDesignAngularJSShoppingCart/clients/{{client}}/template/siteLinks.html` |

### Scope of work

- **In scope:** Replication of the client’s header and footer to be practically **one-for-one** with their marketing site. Refer to the official Premium Cart Branding guide for any defined exemptions.
- **Exemptions:**
  - **Header:** Does **not** include menu dropdowns.
  - **Footer:** Does **not** include forms (e.g. mail sign-ups).

**Workflow:** Update `header-main.html` and `footer.html` to match the marketing site; put custom styles in `client.less`; add header menu links in `siteLinks.html`. Use the **browser dev console** on the marketing site to inspect applied styles and replicate them in the cart.

### Pitfalls (common oversights)

- **Hover effects**
- **Mobile responsiveness** (layout and style changes)
- **Font weights and families** (you may need to import additional fonts beyond standard branding)
- **Animations and transitions**
- **Correct links** for email/phone (e.g. `mailto:`, `tel:`)

**Specificity:** Use **unique IDs/class names** (and proper CSS specificity) for any elements added to the HTML templates so they don’t override other cart styles.

### Images

Ensure you have **all images and logos** used in the header and footer. If anything is missing, request from the client or take them from the marketing site. Store and reference images here:

- **Path:** `Websites/Extranet Sites/{{client}}/Personal`

### Mobile view

- Marketing headers/footers usually **change layout** in responsive/mobile view; replicate those changes, typically with **media queries**.
- **Header links** must be added to **`siteLinks.html`** for the client. This file drives:
  - The replicated header in **desktop** view, and
  - The **hamburger menu** in the cart’s top bar in **mobile** view.
- **Hide the replicated header’s menu links** at mobile breakpoints (e.g. via CSS or conditional markup) so the cart’s hamburger menu is the single source of nav links on small screens.

### Premium PCB checklist

- [ ] Standard branding already done for client
- [ ] `header-main.html` and `footer.html` replicated from marketing site (one-for-one, within scope)
- [ ] Custom styles in `client.less`; unique classes/IDs to avoid cart overrides
- [ ] `siteLinks.html` updated with header menu links
- [ ] Hover, mobile, fonts, animations, and email/phone links checked
- [ ] All header/footer images in Extranet `{{client}}/Personal` and referenced correctly
- [ ] Mobile: media queries and menu links removed from replicated header so hamburger is used

---

## Angular Cart Branding

**Reference:** Angular Cart Branding (SOA), by Arianna Capasso.

Use the **same webfolder naming convention** as for new client setup in SOA.

### 1. Create client folder and files

- **Path:** `SOA/Applications/Web/AngularApp/clients/<ClientName>`

Create a **new folder** for the client, then add:

| File | Description |
|------|-------------|
| `favicon.png` | Favicon |
| `logo-cart.png` | Cart logo |
| `custom.scss` | Custom stylesheet (can be empty unless the client has custom styles) |
| `variables.scss` | CSS variables (copy from an existing client) |

### 2. Update `variables.scss`

- Update **`variables.scss`** with the client’s branding variables.
- **Note:** This is **SASS**, not LESS (unlike the SOA AngularJS cart). There are conventional differences and some variables that differ between the two. If you copy from the SOA/LESS version, adapt syntax and variable names accordingly.

### 3. Add client to Angular build config

- Edit **`angular.json`** and add configs for this client in **both** the **shop** and **revolution** projects.
- **Copy from a client that does NOT use `fileReplacements`.**  
  `fileReplacements` is used to override shared components with client-specific custom components; avoid it unless this client needs that.

### 4. Build and run locally

```bash
npm run init --client={{client-name}}
```

- Updates client settings (e.g. `appSettings.json`) and copies client styles for local build.

```bash
npm run start --client={{client-name}}
```

- Starts the Angular dev server for that client.

Confirm the client builds and runs locally with the CLI before considering Angular branding complete.

### Angular branding checklist

- [ ] New folder under `SOA/Applications/Web/AngularApp/clients/<ClientName>` (webfolder naming)
- [ ] `favicon.png`, `logo-cart.png`, `custom.scss`, `variables.scss` added
- [ ] `variables.scss` updated with client branding (SASS, not LESS)
- [ ] `angular.json` updated for **shop** and **revolution** (copy from client without `fileReplacements` unless needed)
- [ ] `npm run init --client={{client-name}}` runs successfully
- [ ] `npm run start --client={{client-name}}` runs and client loads locally

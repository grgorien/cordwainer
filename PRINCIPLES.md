# Principles for Building High‑Performance Shopify Theme (Personal Rulesets) (2.0)

This document is my checklist and mental model for building fast, robust Shopify theme that aligns with Shopify’s own best practices.

Core references I should re‑read periodically:

- [Performance best practices for Shopify themes](https://shopify.dev/docs/storefronts/themes/best-practices/performance)  
- [Best practices for building Shopify themes](https://shopify.dev/docs/storefronts/themes/best-practices)  
- [Shopify CLI for themes](https://shopify.dev/docs/storefronts/themes/tools/cli)  
- [File transformation best practices (Tailwind, build pipeline, etc.)](https://shopify.dev/docs/storefronts/themes/best-practices/file-transformation)  

---

## 1. Architecture & Mindset

### 1.1 Server‑Rendered First, JS as Enhancement

- Every page is fundamentally **server‑rendered HTML** via Liquid.  
- **Core flows must work without JavaScript**:
  - Navigation
  - Viewing products and collections
  - Adding to cart
  - Reaching checkout
- JavaScript is used **only** as progressive enhancement:
  - Make things nicer, faster, or smoother.
  - Never make critical flows JS‑only.

See: [Optimize your JavaScript](https://shopify.dev/docs/storefronts/themes/best-practices/performance#optimize-your-javascript).

**Rule of thumb:**  
“If JS fails to load, a customer can still browse, select a product, add to cart, and checkout.”

---

### 1.2 Declarative Over Imperative

- Express as much as possible in terms of **HTML, CSS, and data**:
  - Use HTML semantics (`<form>`, `<button>`, `<details>`, `<summary>`, `<nav>`, `<dialog>`).
  - Use CSS for visibility, layout, and transitions.
- Where JS is needed, prefer **declarative bindings** (e.g., Alpine attributes) over manual DOM manipulation.

**Bad (imperative global scripts):**

- “Find element A; toggle class; query element B; manually sync state.”

**Better (declarative):**

- “This button toggles `open`.”
- “This div is visible when `open === true`.”

---

### 1.3 Components Own Their Own State

- Theme architecture: **templates → sections → blocks**.  
- Each visual component manages its own state locally:
  - Use Alpine `x-data` or similar to scope state to a small DOM subtree.
- Avoid **global JS state** and massive `theme.js` files full of `document.querySelector` code.

See: [Templates, sections, and blocks best practices](https://shopify.dev/docs/storefronts/themes/best-practices#templates-sections-and-blocks).

**Rule:**  
“One section/component = one state boundary, not a global god‑object.”

---

## 2. JavaScript Rules

### 2.1 Minimize JS Bundle Size

- Aim for **≤ 16 KB minified total** core JS (Shopify’s guidance).  
- Keep dependencies extremely limited:
  - Alpine.js (or an equivalent tiny helper) is acceptable.
  - Avoid big frameworks (React, Vue, etc.) in themes.

See: [Optimize your JavaScript](https://shopify.dev/docs/storefronts/themes/best-practices/performance#optimize-your-javascript).

**Rule:**  
“If I add another library, the bundle must still stay lean. If it can be done with native browser APIs + a little Alpine, do that instead.”

---

### 2.2 JS is an Escape Hatch, Not the Foundation

- First ask:
  - Can this be done with **HTML** alone?  
  - Can this be done with **CSS** (e.g., `:checked`, `details/summary`, `:target`, `@media`)?  
- Use JS only when:
  - There is no reasonable HTML/CSS‑only solution, or
  - JS meaningfully improves UX without breaking core flow.

**Rule:**  
“Try HTML. If not, try CSS. If still not, then add a small, local JS enhancement.”

---

### 2.3 IntersectionObserver, Not Scroll Listeners

- For scroll‑based UI (e.g., back‑to‑top button, sticky headers):
  - Prefer **IntersectionObserver** with small sentinels.
- Avoid `window.addEventListener('scroll', ...)` unless absolutely necessary.

**Reason:** Scroll events are frequent and can cause main‑thread pressure; IntersectionObserver is optimized by the browser.

---

### 2.4 Scoped JS & Cleanup

- Scope JS to components:
  - Use Alpine `x-data` and `x-ref`, not `getElementById`/`querySelector` all over the page.
- If you create observers or timers, **clean them up** (e.g., disconnect on unload or component teardown).

**Rule:**  
“Think like manual memory management: whoever creates a long‑lived resource (observer, timer) is also responsible for disposing it.”

---

### 2.5 Don’t Break Core Forms with JS

- Cart forms should still `POST /cart/add` without JS.
- If using Ajax for nicer UX:
  - Use `@submit.prevent` or `fetch` as **enhancement**, not the only path.
- Same logic for other critical forms (contact, login, etc.).

See: [Forms in themes](https://shopify.dev/docs/storefronts/themes/architecture/templates/forms).

---

## 3. CSS & Tailwind Rules

### 3.1 Tailwind as a Build‑Time Tool Only

- Use Tailwind (e.g., v4) in the **source** code, but ship **compiled CSS** only:
  - Source: `src/styles/theme.css` with Tailwind directives.
  - Output: `assets/theme.css` included via `<link>` in `layout/theme.liquid`.
- Do **not** ship Tailwind’s dev build or unpurged CSS to the storefront.

See: [File transformation best practices](https://shopify.dev/docs/storefronts/themes/best-practices/file-transformation).

---

### 3.2 Keep CSS Small & Focused

- Purge unused classes using Tailwind’s `content` configuration.
- Avoid duplicating functionality:
  - Don’t use Tailwind **and** a big third‑party CSS framework.
- Organize design tokens (spacing, typography, color) in Tailwind config; keep utilities predictable.

**Rule:**  
“Make the final CSS as small as possible while preserving the design system.”

---

### 3.3 Tailwind + Alpine: Use Literal Class Strings

- When binding classes in Alpine, use **literal class strings** so Tailwind’s JIT can see them:

```html
:class="{ 'opacity-100 translate-y-0': active, 'opacity-0 translate-y-4 pointer-events-none': !active }"
```

- Avoid building class names dynamically (e.g., `` `opacity-${value}` ``) unless you safelist them **(be aware of tw4 complains)**.

---

## 4. HTML, Accessibility & i18n

### 4.1 Semantic First

- Use semantic HTML elements:
  - `<header>`, `<nav>`, `<main>`, `<footer>`
  - `<button>` for actions, `<a>` for navigation
  - `<details>` / `<summary>` for disclosures
  - `<dialog>` for modals (with proper polyfills if targeting older browsers)
- This improves accessibility, SEO, and reduces JS needed.

See: [Accessibility best practices](https://shopify.dev/docs/storefronts/themes/best-practices/accessibility).

---

### 4.2 ARIA & Labels

- Every interactive control must be accessible:
  - Use `aria-label` or visible text on icon‑only buttons.
  - Keep icons `aria-hidden="true"` when labels cover the semantics.
- For “back to top” and similar:
  - Use meaningful labels: `"Back to top"`, `"Open navigation"`, etc.

---

### 4.3 Internationalization (i18n)

- Never hardcode user‑facing text; always use translation keys:

```liquid
aria-label=""
```

- Maintain translation files in `locales/*.json` (e.g., `locales/en.default.json`):

```json
{ 
  "buttons": { 
    "back_to_top": "Back to top" 
  } 
}
```

See: [Theme internationalization](https://shopify.dev/docs/storefronts/themes/internationalization).

**Rule:**  
“Every string a customer can see must go through the translation system.”

---

## 5. Theme Structure, Version Control & CI

### 5.1 Respect Theme Folder Structure

Use the standard Shopify theme structure:

- `layout/` – top-level HTML (must include `{{ content_for_header }}` and `{{ content_for_layout }}`)
- `templates/` – per‑page templates (Liquid or JSON)
- `sections/` – major reusable blocks, each with `{% schema %}`  
- `snippets/` – small, reusable fragments
- `config/` – global settings (`settings_schema.json`, `settings_data.json`)
- `assets/` – compiled CSS, JS, images, fonts

See: [Theme architecture](https://shopify.dev/docs/storefronts/themes/architecture).

---

### 5.2 Version Control & Config Files

- Always track:
  - `config/settings_schema.json` (theme settings definition)
  - Important `templates/*.json` that define structure (home, product, collection)
- For `config/settings_data.json`:
  - For this **OSS theme**, it’s OK (and often good) to track this as “canonical demo settings.”
  - For merchant stores, consider keeping their `settings_data.json` store‑only and not overwriting via CI.

See: [Version control for Shopify themes](https://shopify.dev/docs/storefronts/themes/best-practices/version-control).

---

### 5.3 Deploy via Shopify CLI + CI (Not Directly Through GitHub App)

- Use Shopify CLI and Theme Access tokens in CI:
  - `SHOPIFY_FLAG_STORE` – store domain
  - `SHOPIFY_CLI_THEME_TOKEN` – Theme Access password
  - `THEME_ID` – specific theme ID for dev/demo/live
- Example deploy command:

```bash
shopify theme push \
  --store "$SHOPIFY_FLAG_STORE" \
  --token "$SHOPIFY_CLI_THEME_TOKEN" \
  --theme "$THEME_ID" \
  --allow-live
```

See: [Use Shopify CLI in a CI/CD pipeline](https://shopify.dev/docs/storefronts/themes/tools/cli/ci-cd).

**Rule:**  
“Git is the source of truth. CLI deploys that source to a specific theme ID.”

---

## 6. Performance & Testing

### 6.1 Lighthouse Monitoring

- Test Lighthouse scores for:
  - Home page
  - Product page
  - Collection page
- Aim for **≥ 60** performance score (Theme Store requirement baseline).

See: [Performance best practices](https://shopify.dev/docs/storefronts/themes/best-practices/performance).

---

### 6.2 Avoid Blocking & Heavy Scripts

- Use `defer`/`async` on `<script>` tags where order allows it.
- Avoid parser‑blocking scripts in the `<head>` unless absolutely required.
- Prefer small, focused scripts in `assets/` and load them at the bottom or with `defer`.

---

### 6.3 Measure Before and After

- Any time I:
  - Add a new library,
  - Introduce a heavy animation,
  - Change core CSS/JS bundles,

I should:

- Re‑run Lighthouse.
- Compare bundle sizes (CSS + JS).
- Back out changes if performance regresses significantly.

---

## 7. Personal “Guardrail” Questions

Before committing a new feature or pattern, ask:

1. **Does this work when JS is disabled or fails to load?**
2. **Is this expressed using HTML/CSS first, with JS only as needed?**
3. **Did I keep JS state local to the component instead of global?**
4. **Will Tailwind see these classes at build time, or am I hiding them behind dynamic strings?**
5. **Is all user‑facing text going through the translation system?**
6. **What does Lighthouse say about performance after this change?**
7. **If this was a luxury leather shoe brand’s main storefront, would I be comfortable relying on this at scale?**

If the answer to any of those is “no”, fix it before shipping.

---

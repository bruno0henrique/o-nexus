```markdown
# Design System Document: High-End Retail Management

## 1. Overview & Creative North Star: "The Synthetic Horizon"
This design system moves away from the "flat dashboard" trope, embracing a philosophy we call **The Synthetic Horizon**. It treats the retail management interface not as a spreadsheet, but as a high-precision flight deck. By leveraging the tension between deep, infinite voids and sharp, electric light, we create a sense of focused power.

**Breaking the Template:**
To achieve a premium editorial feel, avoid rigid symmetry. Use **Intentional Asymmetry**: offset your data visualizations or allow large typography to "break" the container edges. We are building a "Digital Curator" experience—where the interface recedes, leaving only the most critical retail insights illuminated by the Cyan glow.

---

## 2. Colors & Surface Philosophy
The palette is built on a foundation of tonal depth. We do not use "gray"; we use varying levels of charcoal and obsidian to simulate physical layers.

### Surface Hierarchy & Nesting
Instead of lines, we use **Tonal Nesting**. This creates a sense of "carved" or "floating" UI.
- **Base Environment:** `surface` (#131313) is your ground floor.
- **Secondary Workspaces:** Use `surface_container_low` (#1C1B1B) for sidebars or secondary navigation.
- **Primary Data Containers:** Use `surface_container` (#201F1F) for main dashboard cards.
- **Active Focus Elements:** Use `surface_container_high` (#2A2A2A) for elements that require immediate attention or hover states.

### The "No-Line" Rule
**Strict Prohibition:** 1px solid borders are forbidden for sectioning. 
*   **The Intent:** Traditional borders "trap" the eye. 
*   **The Solution:** Define boundaries through background shifts. A `surface_container_low` card sitting on a `surface` background creates a clean, sophisticated edge without the visual noise of a line.

### The "Glass & Gradient" Rule
To inject "soul" into the high-tech aesthetic:
- **Floating Overlays:** Use `surface_variant` with a 60% opacity and a `20px` backdrop-blur for modals and dropdowns. 
- **Signature Glow:** Apply a subtle linear gradient from `primary` (#C3F5FF) to `primary_container` (#00E5FF) on high-value CTAs or "Total Revenue" sparks to give them a luminous, electric energy.

---

## 3. Typography: Editorial Precision
We utilize a dual-font strategy to balance high-tech utility with editorial elegance.

*   **Display & Headlines (Manrope):** This is our "Editorial Voice." Use `display-lg` and `headline-md` for high-level retail metrics (e.g., Gross Margin). Manrope’s geometric clarity provides a custom, premium feel.
*   **Body & Labels (Inter):** Inter is our "Workhorse." Its high X-height ensures readability at small scales (`label-sm`) for SKU numbers and inventory timestamps.
*   **Hierarchy Tip:** Pair a `display-sm` metric with a `label-md` uppercase caption in `on_surface_variant` (#BAC9CC) for a sophisticated, data-dense look.

---

## 4. Elevation & Depth
In this system, depth is a function of light, not lines.

*   **The Layering Principle:** Stack `surface_container_lowest` (#0E0E0E) inside a `surface_container` to create "inset" areas for input fields, making them feel like they are etched into the dashboard.
*   **Ambient Shadows:** Use shadows sparingly. When an object must "float" (e.g., a notification toast), use a `48px` blur with 6% opacity using a tint of `surface_tint` (#00DAF3). This simulates the cyan accent light reflecting off the surface.
*   **The "Ghost Border" Fallback:** If accessibility requires a border, use `outline_variant` (#3B494C) at 15% opacity. It should be felt, not seen.

---

## 5. Components & Interface Elements

### Buttons
*   **Primary:** A high-contrast block using `primary` (#C3F5FF) with `on_primary` (#00363D) text. Use `rounded-md` (0.375rem) for a sharp, modern corner.
*   **Secondary:** No fill. Use a "Ghost Border" and `on_surface` text. On hover, transition the background to `surface_container_high`.

### Cards & Lists
*   **Forbid Dividers:** Do not use lines between list items. Use 16px of vertical white space or alternate background tones between `surface_container` and `surface_container_low`.
*   **Data Visualization:** Use `primary` for growth and `error` (#FFB4AB) for declines. Always accompany color with a trend icon for accessibility.

### Input Fields
*   **Surface:** Use `surface_container_lowest` for the field background to create an "etched" look.
*   **Focus State:** Do not change the border color alone; add a subtle outer glow using `primary` at 10% opacity to simulate the screen "powering up" the input.

### Additional Signature Component: The "Nexus HUD"
A sticky header/footer bar using **Glassmorphism** (`surface` at 70% + blur). This keeps the retail management tools available while allowing the rich data cards to scroll underneath, maintaining the "High-Tech" sleekness.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use extreme contrast in typography—large display numbers next to tiny labels.
*   **Do** use "Negative Space" as a structural element. Let the deep charcoal background breathe.
*   **Do** use the `secondary` (#98D0DA) tone for secondary data points to keep the `primary` Cyan reserved for critical actions.

### Don’t:
*   **Don’t** use pure white (#FFFFFF). Use `on_surface` (#E5E2E1) to prevent eye strain in dark mode.
*   **Don’t** use standard shadows. If it looks like a generic "Material" shadow, it’s too heavy.
*   **Don’t** use 100% opaque borders. They break the illusion of a seamless, high-tech obsidian surface.

---

**Director's Final Note:** This system is about the *absence* of clutter. Every pixel of Electric Blue must feel earned. If a screen feels "busy," increase the padding and move a container one level down in the `surface-container` hierarchy. Control the light, and you control the user's focus.
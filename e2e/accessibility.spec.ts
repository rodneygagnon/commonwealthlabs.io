/**
 * WCAG 2.2 AA Accessibility E2E Tests
 *
 * These tests use @axe-core/playwright to verify that pages meet WCAG 2.2 Level AA standards.
 * Run with: npm run e2e:a11y
 */

import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

// Helper to check accessibility and report violations
async function checkAccessibility(
  page: import("@playwright/test").Page,
  options?: { includedImpacts?: string[] }
) {
  const accessibilityScanResults = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
    .analyze();

  // Filter by impact if specified
  let violations = accessibilityScanResults.violations;
  if (options?.includedImpacts) {
    violations = violations.filter((v) =>
      options.includedImpacts!.includes(v.impact || "")
    );
  }

  // Create detailed error message if there are violations
  if (violations.length > 0) {
    const violationMessages = violations.map((v) => {
      const nodes = v.nodes
        .map((n) => `  - ${n.html}\n    Fix: ${n.failureSummary}`)
        .join("\n");
      return `${v.id} (${v.impact}): ${v.help}\n${nodes}`;
    });

    console.error(
      "Accessibility violations found:\n" + violationMessages.join("\n\n")
    );
  }

  return violations;
}

const pages = [
  { name: "Home", path: "/" },
  { name: "Platform", path: "/platform" },
  { name: "About", path: "/about" },
  { name: "Why", path: "/why" },
  { name: "Network", path: "/network" },
  { name: "Open Source", path: "/open-source" },
  { name: "Get Involved", path: "/get-involved" },
  { name: "Privacy", path: "/privacy" },
];

test.describe("Accessibility - All Pages", () => {
  for (const p of pages) {
    test(`${p.name} page should have no WCAG 2.2 AA violations`, async ({ page }) => {
      await page.goto(p.path);
      const violations = await checkAccessibility(page);
      expect(violations).toEqual([]);
    });
  }
});

test.describe("Accessibility - HTML Lang Attribute", () => {
  test("should have valid lang attribute on html element", async ({ page }) => {
    await page.goto("/");
    const htmlLang = await page.getAttribute("html", "lang");
    expect(htmlLang).toBeTruthy();
    expect(htmlLang).toBe("en");
  });
});

test.describe("Accessibility - Keyboard Navigation", () => {
  test("should be able to navigate with keyboard", async ({ page }) => {
    await page.goto("/");

    // Tab through the page elements
    await page.keyboard.press("Tab");

    // Should be able to focus on interactive elements
    const activeElement = await page.evaluate(
      () => document.activeElement?.tagName
    );
    expect(activeElement).toBeTruthy();
  });

  test("focus should be visible on interactive elements", async ({ page }) => {
    await page.goto("/");

    // Tab to first focusable element
    await page.keyboard.press("Tab");

    // Check that there's a visible focus indicator
    const focusedElement = await page.evaluate(() => {
      const el = document.activeElement;
      if (!el) return null;
      const styles = window.getComputedStyle(el);
      return {
        outline: styles.outline,
        outlineWidth: styles.outlineWidth,
        boxShadow: styles.boxShadow,
      };
    });

    // Element should have some focus styling (outline or box-shadow)
    expect(
      focusedElement?.outline !== "none" ||
        focusedElement?.outlineWidth !== "0px" ||
        focusedElement?.boxShadow !== "none"
    ).toBeTruthy();
  });
});

test.describe("Accessibility - Images and Icons", () => {
  test("decorative SVGs should have aria-hidden", async ({ page }) => {
    await page.goto("/");

    // Check SVGs in main content area (exclude Astro dev tools)
    const mainContent = page.locator("main");
    const svgElements = await mainContent.locator("svg").all();

    for (const svg of svgElements) {
      const ariaHidden = await svg.getAttribute("aria-hidden");
      const ariaLabel = await svg.getAttribute("aria-label");
      const role = await svg.getAttribute("role");

      // SVG should either be hidden from AT or have an accessible name
      expect(
        ariaHidden === "true" || ariaLabel || role === "img"
      ).toBeTruthy();
    }
  });
});

test.describe("Accessibility - Color Contrast", () => {
  for (const p of pages) {
    test(`${p.name} page should pass color contrast requirements`, async ({ page }) => {
      await page.goto(p.path);

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2aa"])
        .options({ runOnly: ["color-contrast"] })
        .analyze();

      expect(accessibilityScanResults.violations).toEqual([]);
    });
  }
});

test.describe("Accessibility - Headings", () => {
  test("should have proper heading hierarchy", async ({ page }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .options({ runOnly: ["heading-order"] })
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });
});

test.describe("Accessibility - Links", () => {
  test("links should have discernible text", async ({ page }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .options({ runOnly: ["link-name"] })
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });
});

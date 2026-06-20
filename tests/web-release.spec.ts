import { expect, test } from "@playwright/test";

const repoUrl = process.env["REPO_URL"] ?? "https://github.com/AndyHong-Productmanager/apk-2d-rpg";
const releaseUrl = process.env["RELEASE_URL"] ?? "https://github.com/AndyHong-Productmanager/apk-2d-rpg/releases/tag/v0.1.0";

test("local HTML5 export boots to the Godot canvas", async ({ page }) => {
  await page.goto("/");

  await expect(page).toHaveTitle(/APK 2D RPG/u);
  const canvas = page.locator("canvas#canvas");
  await expect(canvas).toBeVisible();
  await page.screenshot({ path: ".omo/evidence/playwright-release/local-web-export.png", fullPage: true });
});

test("GitHub README exposes screenshots and install context", async ({ page }) => {
  await page.goto(repoUrl);

  await expect(page.getByText("Lazycodex 딸깍으로 만든 RPG게임")).toBeVisible();
  await expect(page.getByText("com.lazycodex.apk2drpg")).toBeVisible();
  await expect(page.getByAltText("Combat")).toBeVisible();
  await page.screenshot({ path: ".omo/evidence/playwright-release/github-readme.png", fullPage: true });
});

test("GitHub release exposes APK and screenshot assets", async ({ page }) => {
  await page.goto(releaseUrl);

  await expect(page.getByRole("heading", { name: "v0.1.0" })).toBeVisible();
  await expect(page.getByText("apk-2d-rpg-debug.apk")).toBeVisible();
  await expect(page.getByText("combat.png")).toBeVisible();
  await page.screenshot({ path: ".omo/evidence/playwright-release/github-release.png", fullPage: true });
});

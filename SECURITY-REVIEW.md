# Security Review

**Date:** 2026-04-15
**Branch:** `claude/scan-security-vulnerabilities-cRWXZ`
**Scope:** Full repository scan

---

## Summary

This repository is a personal resume builder with a GitHub Actions CI/CD pipeline. No critical vulnerabilities were found. The findings below are primarily supply-chain and CI hygiene concerns.

---

## Findings

### 1. Unpinned GitHub Actions (Medium)

**File:** `.github/workflows/build-all.yml` — lines 19, 22, 26

```yaml
uses: actions/checkout@v4
uses: actions/setup-node@v4
uses: actions/setup-python@v5
```

**Risk:** Mutable version tags (`@v4`, `@v5`) mean a compromised upstream action repository could push malicious code under the same tag and have it execute in CI with full repository write access (`GITHUB_TOKEN`).

**Recommendation:** Pin each action to a specific commit SHA:

```yaml
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683      # v4.2.2
uses: actions/setup-node@39370e3970a6d050c480ffad4ff0ed4d3fdee5af    # v4.1.0
uses: actions/setup-python@0b93645e9fea7318ecaed2b359559ac225c90a2   # v5.3.0
```

---

### 2. Mutable Package Dependency (Medium)

**File:** `package.json` — line 3

```json
"jsonresume-theme-relaxed": "github:AndrewGrossman/jsonresume-theme-relaxed"
```

**Risk:** This installs the package from the default branch of a GitHub repository without a commit SHA or tag. Any future push to that repository's default branch will be picked up at the next `npm install`, making builds non-reproducible and opening a supply-chain vector if that repository is ever compromised.

**Recommendation:** Pin to a specific commit SHA or tag:

```json
"jsonresume-theme-relaxed": "github:AndrewGrossman/jsonresume-theme-relaxed#<commit-sha-or-tag>"
```

---

### 3. `npm install` Instead of `npm ci` in CI (Low)

**File:** `.github/workflows/build-all.yml` — line 32

```yaml
run: npm install
```

**Risk:** `npm install` can update `package-lock.json` and install versions outside what is locked, making CI builds non-deterministic. `npm ci` strictly installs from `package-lock.json` and fails if it doesn't match `package.json`, which is the safer choice for CI.

**Recommendation:**

```yaml
run: npm ci
```

---

### 4. Runtime Patching of `node_modules` (Low)

**File:** `.github/workflows/build-all.yml` — lines 35–46

The workflow patches `node_modules/jsonresume-theme-relaxed/index.js` in-place at build time to swap a CDN URL. While this happens inside a throwaway CI runner and is not persisted, modifying third-party code at runtime is fragile and non-transparent.

**Recommendation:** Apply the fix as a proper patch in the `jsonresume-theme-relaxed` fork (since that repo is already owned) and remove the inline patching step from the workflow.

---

### 5. `--no-sandbox` Chrome Flag (Informational)

**File:** `.github/workflows/build-all.yml` — line 50

```bash
exec google-chrome-stable --no-sandbox "$@"
```

**Risk:** Disabling Chrome's sandbox is standard practice for headless Chrome in Linux CI containers (where the user namespace sandbox is unavailable), so this is expected and not exploitable in this context.

**Note:** This is acceptable as-is for GitHub-hosted runners.

---

### 6. PII Committed to Repository (Informational)

**File:** `base-resume.json` — lines 9–16

The file contains a personal email address and phone number. For a public resume repository this is intentional, but worth acknowledging: these values are permanently in git history and cannot be easily scrubbed if the repository is public.

If this repository is or ever becomes public, consider whether the contact information should remain in the default branch history or be handled differently (e.g., injected at build time from secrets).

---

## No Issues Found

- No hardcoded secrets, API keys, or credentials.
- No command injection vulnerabilities in the Python script or Makefile.
- No SQL injection, XSS, or other OWASP Top 10 concerns (no web application code present).
- `git push` in CI uses `GITHUB_TOKEN` (scoped to the repository) rather than a long-lived personal access token.

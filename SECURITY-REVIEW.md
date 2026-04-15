# Security Review

**Date:** 2026-04-15
**Branch:** `claude/scan-security-vulnerabilities-cRWXZ`
**Scope:** Full repository scan

---

## Summary

This repository is a personal resume builder with a GitHub Actions CI/CD pipeline. `npm audit` reports **34 known vulnerabilities in npm dependencies** (3 critical, 17 high, 12 moderate, 2 low), most of which can be fixed by running `npm audit fix`. Additional CI hygiene and supply-chain findings are documented below.

---

## Findings

### 1. Vulnerable npm Dependencies (Critical/High/Moderate/Low)

**File:** `package.json` / `package-lock.json`

`npm audit` reports **34 vulnerabilities** across transitive dependencies of `resume-cli` and `jsonresume-theme-relaxed`. The majority are inherited from `resume-cli`'s dependencies (`browser-sync`, `localtunnel`, `axios`, `puppeteer`, etc.).

**Critical (3):**
| Package | Issue |
|---|---|
| `axios <=1.14.0` | CSRF, SSRF/credential leak via absolute URL, DoS via `__proto__`, NO_PROXY bypass, cloud metadata exfiltration |
| `form-data 3.0.0–3.0.3` | Unsafe random function for multipart boundary |
| `handlebars` | JavaScript injection via AST type confusion |

**High (17, selected):**
| Package | Issue |
|---|---|
| `tar-fs` | Symlink validation bypass / path traversal extraction |
| `ws 8.0.0–8.17.0` | DoS via many HTTP headers |
| `dset <=3.1.3` | Prototype pollution |
| `lodash` | Prototype pollution; code injection via `_.template` |
| `validator` | URL validation bypass |
| `pug` (via `jsonresume-theme-elegant`) | Remote code execution via `pretty` option |

**Note:** These dependencies are only used at **build time** (CI PDF/HTML generation) and are never deployed or served to end users. The exploitability of most findings requires an attacker to influence the build environment. That said, several are fixable at no cost.

**Remediation:**

```bash
# Fix non-breaking issues immediately (fixes ~20 vulnerabilities)
npm audit fix

# Review the breaking change before applying:
# Downgrades resume-cli to 3.0.0 (from 3.1.2) — test PDF generation first
npm audit fix --force
```

After `npm audit fix`, commit the updated `package-lock.json`. Evaluate whether `resume-cli@3.0.0` is functional before forcing the downgrade.

Dependabot is now configured (`.github/dependabot.yml`) to open weekly PRs for npm dependency updates, which will surface these and future vulnerable packages automatically.

---

### 2. Unpinned GitHub Actions (Medium)

**File:** `.github/workflows/build-all.yml` — lines 19, 22, 26

```yaml
uses: actions/checkout@v4
uses: actions/setup-node@v4
uses: actions/setup-python@v5
```

**Risk:** Mutable version tags (`@v4`, `@v5`) mean a compromised upstream action repository could push malicious code under the same tag and have it execute in CI with full repository write access (`GITHUB_TOKEN`).

**Recommendation:** Pin each action to a specific commit SHA. Dependabot (now configured) will open weekly PRs to keep pinned versions current. To get initial SHAs, run locally:

```bash
git ls-remote https://github.com/actions/checkout 'refs/tags/v4.*' | grep '\^{}' | sort -V | tail -1
git ls-remote https://github.com/actions/setup-node 'refs/tags/v4.*' | grep '\^{}' | sort -V | tail -1
git ls-remote https://github.com/actions/setup-python 'refs/tags/v5.*' | grep '\^{}' | sort -V | tail -1
```

Then update the workflow:

```yaml
uses: actions/checkout@<SHA>      # v4.x.x
uses: actions/setup-node@<SHA>    # v4.x.x
uses: actions/setup-python@<SHA>  # v5.x.x
```

---

### 3. Mutable Package Dependency — `jsonresume-theme-relaxed` (Medium)

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

### 4. Unpinned GitHub Actions (Medium)

**File:** `.github/workflows/build-all.yml` — lines 19, 22, 26

```yaml
uses: actions/checkout@v4
uses: actions/setup-node@v4
uses: actions/setup-python@v5
```

**Risk:** Mutable version tags mean a compromised upstream action repository could push malicious code under the same tag and have it execute in CI with full repository write access (`GITHUB_TOKEN`).

**Recommendation:** Pin each action to a specific commit SHA:

```yaml
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683      # v4.2.2
uses: actions/setup-node@39370e3970a6d050c480ffad4ff0ed4d3fdee5af    # v4.1.0
uses: actions/setup-python@0b93645e9fea7318ecaed2b359559ac225c90a2   # v5.3.0
```

---

### 5. `npm install` Instead of `npm ci` in CI (Low)

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

### 6. Runtime Patching of `node_modules` (Low)

**File:** `.github/workflows/build-all.yml` — lines 35–46

The workflow patches `node_modules/jsonresume-theme-relaxed/index.js` in-place at build time to swap a CDN URL. While this happens inside a throwaway CI runner and is not persisted, modifying third-party code at runtime is fragile and non-transparent.

**Recommendation:** Since `jsonresume-theme-relaxed` is an owned fork, apply the fix directly there. In the fork's `index.js`, find the icon URL template:

```js
// Change this:
`https://cdn.simpleicons.org/${name.toLowerCase().replace(' ', '')}`
// To this:
`https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/${name.toLowerCase().replace(' ', '')}.svg`
```

Once that commit is in the fork, delete the entire "Patch theme icon CDN" step from this workflow and pin `jsonresume-theme-relaxed` in `package.json` to that commit SHA.

---

### 7. `--no-sandbox` Chrome Flag (Informational)

**File:** `.github/workflows/build-all.yml` — line 50

```bash
exec google-chrome-stable --no-sandbox "$@"
```

Disabling Chrome's sandbox is standard practice for headless Chrome in Linux CI containers (where the user namespace sandbox is unavailable). This is acceptable as-is for GitHub-hosted runners.

---

### 8. PII Committed to Repository (Informational)

**File:** `base-resume.json` — lines 9–16

The file contains a personal email address and phone number. For a public resume repository this is intentional, but worth acknowledging: these values are permanently in git history and cannot be easily scrubbed if the repository is public.

If this repository is or ever becomes public, consider whether the contact information should remain in the default branch history or be handled differently (e.g., injected at build time from secrets).

---

## No Issues Found

- No hardcoded secrets, API keys, or credentials.
- No command injection vulnerabilities in the Python script or Makefile.
- No SQL injection, XSS, or other OWASP Top 10 concerns (no web application code present).
- `git push` in CI uses `GITHUB_TOKEN` (scoped to the repository) rather than a long-lived personal access token.

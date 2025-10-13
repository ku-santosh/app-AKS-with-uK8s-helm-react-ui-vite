# ✅ Fix strategy (what to change)

#### 1. Make the test command exit 0 on success; fix failing tests. (If you want to continue even when tests fail, you can || true — not recommended.)
#### 2. Make Vitest produce the coverage files you expect (cobertura, lcov, junit).
#### 3. Ensure coverage/junit files are created in a relative path (e.g. coverage/) inside the project workspace.
#### 4. Update .gitlab-ci.yml test job artifact paths to use relative paths (no leading slash).
#### 5. Optionally, use artifacts:reports for junit and coverage so GitLab UI can show the reports.


## 📌 Example fixes (copy/paste)
### 1) Vitest coverage + reporters config (e.g. vitest.config.ts or package.json)
#### If you use Vitest, add coverage reporters and junit reporter:
```bash
// vitest.config.ts (example)
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    // reporters: default + junit
    reporters: [
      'default',
      ['junit', { outputFile: 'coverage/junit-report.xml' }]
    ],
    // coverage configuration (c8/istanbul)
    coverage: {
      provider: 'c8',               // or 'istanbul' depending on your setup
      reportsDirectory: 'coverage',
      reporter: ['text', 'lcov', 'cobertura'], // produce cobertura and lcov
      all: true,
      include: ['src/**/*.ts', 'src/**/*.tsx', 'src/**/*.js', 'src/**/*.jsx']
    }
  }
})
```
#### If you configure Vitest in package.json:
```bash
"vitest": {
  "reporters": [
    "default",
    ["junit", { "outputFile": "coverage/junit-report.xml" }]
  ],
  "coverage": {
    "provider": "c8",
    "reportsDirectory": "coverage",
    "reporter": ["text", "lcov", "cobertura"],
    "all": true
  }
}

```
#### Why: these settings tell Vitest to write coverage/cobertura-coverage.xml (or similar) and coverage/junit-report.xml under the repo directory.
### 2) Update your test npm script if needed (in package.json)
```bash
"scripts": {
  "test": "vitest",
  "coverage": "vitest run --coverage"
}
```
#### Run npm run coverage locally to confirm it creates coverage/ files:

```bash
npm ci
npm run coverage
ls -la coverage
# expect: junit-report.xml, cobertura-coverage.xml (or cobertura-*.xml), lcov.info

```

### 3) Update .gitlab-ci.yml — test job artifact configuration
#### Replace your existing test job in .gitlab-ci.yml with this updated snippet (note relative paths, reports settings):
```bash
test:
  stage: test
  image: node:18
  script:
    - echo "🧪 Installing dependencies..."
    - npm ci
    - echo "🧪 Running lint..."
    - npm run lint || true
    - echo "🧪 Running tests with coverage..."
    - npm run coverage   # ensure this generates coverage/ and coverage/junit-report.xml
  artifacts:
    # paths must be relative to project root and exist when job finishes
    paths:
      - coverage/
      - coverage/junit-report.xml
      - coverage/cobertura-coverage.xml
    expire_in: 1 week
    when: always                 # upload even when job fails (useful to debug)
    reports:
      junit: coverage/junit-report.xml
      # Optional: GitLab can show code coverage summary with coverage_report (GitLab Premium)
      # coverage_report:
      #   coverage_format: cobertura
      #   path: coverage/cobertura-coverage.xml
  only:
    - merge_requests

```
### Key points:

- paths are relative (no leading /).
- when: always will upload artifacts even if tests fail; useful for debugging failing tests.
- reports: junit points GitLab at the junit XML so it can show test results.
- Optionally enable coverage_report if your GitLab edition supports it.

### 4) If using a monorepo or workspace (common pitfall)

Your error indicates the pipeline may be running from a subdirectory or the artifacts point to /coverage (absolute). If tests run inside a subfolder (e.g., client/), set the correct working dir or change artifact paths accordingly:

#### Option A — change working directory before running tests:
```bash
test:
  stage: test
  image: node:18
  script:
    - cd client               # move into package that runs tests
    - npm ci
    - npm run coverage
  artifacts:
    paths:
      - client/coverage/
      - client/coverage/junit-report.xml
    reports:
      junit: client/coverage/junit-report.xml
  only:
    - merge_requests

```
#### Option B — run from root but tell vitest where to write files (set reportsDirectory to client/coverage in vitest config).

## ✅ Quick local verification steps (before committing)
### 1. Run coverage locally:
```bash
npm ci
npm run coverage
ls -la coverage
# ensure files exist: coverage/junit-report.xml, coverage/cobertura-coverage.xml, coverage/lcov.info

```
### 2. If using a monorepo package:
```bash
cd client
npm ci
npm run coverage
ls -la coverage
```
### 3. Commit the updated vitest.config.ts / package.json and .gitlab-ci.yml, push, and create MR to verify CI.

### Extra suggestions / improvements

- Use when: always for artifacts to help debugging failing tests.
- Add allow_failure: true for non-blocking tests only if business allows — not recommended for critical suites.
- Use artifacts:reports:coverage_report (cobertura) to have GitLab UI show coverage if your GitLab tier supports it.
- Consider splitting unit tests and integration tests into separate jobs if coverage generation is slow.

### TL;DR — Action items for you (copy-paste)

- Add coverage reporters (cobertura, lcov, junit) to Vitest config (example above).
- Ensure coverage output path is coverage/ relative to project (not /coverage).
- Update .gitlab-ci.yml test job artifacts to use relative paths and reports.junit.
- If your tests run in subfolder, cd into it in CI or adjust paths.


## 📊 GitLab UI:
If you add this in .gitlab-ci.yml:

```bash
artifacts:
  reports:
    coverage_report:
      coverage_format: cobertura
      path: coverage/cobertura-coverage.xml
```

## 🧩 Overview
#### When you run:
```bash
npm run coverage
```
#### with a tool like Vitest, Jest, or Mocha using coverage reporters (like c8, istanbul), it generates 3 key report files in your coverage/ folder:

| File                              | Purpose                                             | Format            | Consumed by                          |
| --------------------------------- | --------------------------------------------------- | ----------------- | ------------------------------------ |
| `coverage/junit-report.xml`       | Test results (pass/fail per test)                   | **JUnit XML**     | GitLab CI, Jenkins, Azure DevOps     |
| `coverage/cobertura-coverage.xml` | Code coverage summary (lines, branches, statements) | **Cobertura XML** | GitLab coverage dashboard, SonarQube |
| `coverage/lcov.info`              | Raw detailed coverage for each file                 | **LCOV (text)**   | HTML report, IDE plugins, Codecov    |


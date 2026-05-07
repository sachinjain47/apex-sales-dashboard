# Oracle APEX Sales Dashboard

A full **Sales Dashboard** built on Oracle APEX + Autonomous Database (OCI).  
Features KPI cards, JET charts (line / bar / pie / donut), and drill-down navigation across 4 pages.

## Architecture

```
Page 1 — Dashboard    KPI cards + 4 charts
Page 2 — Orders       Filtered drill-down list
Page 3 — Order Detail Line items for a single order
Page 4 — Product Trend Monthly sales trend for a product
```

## Repository Layout

```
├── sql/
│   ├── 01_create_tables.sql   Tables + 4 views (DDL)
│   ├── 02_sample_data.sql     200 realistic orders
│   └── 03_apex_queries.sql    All SQL queries per page/chart
├── scripts/
│   └── deploy.sql             Master SQLcl deployment script
├── docs/
│   └── APEX_BUILD_GUIDE.md   Step-by-step APEX build guide
└── .github/
    └── workflows/
        └── deploy.yml         GitHub Actions CI/CD → OCI ADB
```

## Quick Start (Manual)

1. Open your APEX instance → **SQL Workshop → SQL Commands**
2. Run `sql/01_create_tables.sql`
3. Run `sql/02_sample_data.sql`
4. Follow `docs/APEX_BUILD_GUIDE.md` to build the 4 APEX pages

## CI/CD — GitHub Actions → OCI

See [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml).

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `OCI_DB_USERNAME` | ADB schema user (e.g. `ADMIN`) |
| `OCI_DB_PASSWORD` | ADB schema password |
| `OCI_DB_SERVICE`  | TNS alias (e.g. `myapextestdb_high`) |
| `OCI_WALLET_B64`  | Base64-encoded wallet.zip from OCI Console |

### How to encode the wallet

```bash
# Linux / macOS
base64 -w 0 wallet.zip

# PowerShell (Windows)
[Convert]::ToBase64String([IO.File]::ReadAllBytes('.\Wallet_myapextestdb.zip'))
```

Paste the output as the value of the `OCI_WALLET_B64` secret.

### Triggers

| Event | What runs |
|-------|-----------|
| Push to `main` (sql/** changed) | Schema DDL only |
| Manual dispatch | Choose whether to include sample data |

## License

MIT

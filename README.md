# SplitPay

A Ruby on Rails application to import merchant and orders data, calculate commissions, disburse payments, and apply monthly fees.

---

## Table of Contents
- [Ruby Version](#ruby-version)
- [Rails Version](#rails-version)
- [System Dependencies](#system-dependencies)
- [Database Design](#database-design)
- [Setup](#setup)
- [Execution](#execution)
- [Disbursement Report](#disbursement-report)
- [Technical Decisions](#technical-decisions)
- [Assumptions](#assumptions)

---

## Ruby version
```
ruby-3.3.6
```
## Rails version
```bash
Rails 8.0.2
```

## System Dependencies
- PostgreSQL
- Redis (for Sidekiq)
- Sidekiq (background jobs)

## Database design

### Schema
This application consists of four primary entities:

- `Merchant`: Represents a seller using the platform. Each merchant has a disbursement frequency (daily or weekly), a unique reference ID, and a minimum monthly fee requirement.

- `Order`: Represents a purchase made using the platform. It belongs to a merchant and may optionally be associated with a disbursement.

- `Disbursement`: Represents a payout to a merchant for a group of eligible orders on a given day. It includes total amounts and total fees.

- `MonthlyFee`: Captures a monthly fee charged to a merchant if their total commission for the previous month falls below the configured minimum.
  
### Schema Relationships

- A `Merchant` has many `Orders`, `Disbursements`, and `MonthlyFees`.

- An `Order` belongs to a `Merchant`, and optionally to a `Disbursement`.

- A `Disbursement` belongs to a `Merchant` and has many `Orders`.

- A `MonthlyFee` belongs to a `Merchant`.

### Indexes and Constraints
| Table           | Field(s)                                              | Reason                                                             |
| --------------- | ----------------------------------------------------- | ------------------------------------------------------------------ |
| `merchants`     | `reference (UNIQUE)`                                  | Prevents duplicate merchant records                                |
| `merchants`     | `source_id (UNIQUE)`                                  | Ensures idempotent CSV import and natural key tracking             |
| `orders`        | `source_id (UNIQUE)`                                  | Guarantees each order from CSV is imported only once               |
| `orders`        | `merchant_id`                                         | Foreign key for querying orders by merchant                        |
| `orders`        | `disbursement_id`                                     | Allows grouping of orders by disbursement                          |
| `orders`        | Composite: `merchant_id, disbursement_id, created_at` | Optimizes scoped lookups for processing disbursements              |
| `disbursements` | `merchant_id`                                         | Enables merchant-specific payout summaries                         |
| `disbursements` | `reference (UNIQUE)`                                  | Ensures every disbursement has a unique external-facing identifier |
| `monthly_fees`  | `merchant_id, month (UNIQUE)`                         | Prevents duplicate monthly fee entries for the same merchant+month |


## Setup

```bash
bundle install
rails db:create db:migrate
```
Start Sidekiq in a separate terminal tab/window:
```bash
bundle exec sidekiq
```

## Execution

### Import CSV Data

```bash
bundle exec rake data:import_csv
```
### Process Data

```bash
bundle exec rake backfill:commissions
bundle exec rake backfill:disbursements
bundle exec rake backfill:monthly_fees
```

## Disbursement report

| Year   | # Disbursements | Amount Disbursed to Merchants | Amount of Order Fees | # Monthly Fees Charged | Amount of Monthly Fees Charged |
| ------ | --------------- | ----------------------------- | -------------------- | ---------------------- | ------------------------------ |
| `2022` | `1,532`         | `€23,850,372.22`              | `€213,559.56`        | `92`                   | `€2,051.76`                    |
| `2023` | `10,247`        | `€1,295,843,771.10`           | `€1,166,998.71`      | `120`                  | `€2,048.25`                    |


## Technical Decisions

### Architecture
The app follows SOLID principles, with service classes encapsulating key responsibilities:

`Orders::CommissionCalculator` — calculates per-order commission fees

`DisburseMerchants` — handles daily/weekly disbursement logic

`CalculateMonthlyFees` — ensures minimum monthly fees are charged

`CSV importers` use a shared Importer::Base superclass and specialized subclasses:

- Importer::Merchants

- Importer::Orders

#### Performance via upsert_all
Used `ActiveRecord#upsert_all` for importing over 1.3 million orders efficiently.

- Ensures idempotency by using source_id as a natural unique constraint.

- Result: import time reduced from ~40 minutes to ~2 minutes.

#### Disbursement Logic
Merchants are disbursed once per day or once per week depending on their configuration.

A previously created disbursement is reused only if it has associated orders to prevent empty records.

Only eligible orders (undisbursed + with commission fees) are picked per merchant per day.

#### Commission Calculation
Tiered commission rates based on order amount:

`< €50 → 1%`

`€50 - €300 → 0.95%`

`> €300 → 0.85%`

Fees are calculated using BigDecimal and persisted on the commission_fee field.

#### Monthly Fee Enforcement
Monthly fees are enforced if a merchant's minimum monthly fee exceeds their earned commission.

No double-charging: existing fees are checked before calculation.


## Assumptions

| Area                         | Assumption                                                                                                                                                                                                                                                     |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **CSV Data**                 | CSV files provided by seQura are assumed to be structurally valid (UTF-8 encoded, headers present, no malformed rows), but the system still handles invalid rows gracefully—skipping and logging them without crashing.                                        |
| **Monetary Calculations**    | All monetary amounts are handled with `BigDecimal` and **rounded to two decimal places** using `.round(2)` to ensure financial accuracy and avoid floating point drift.                                                                                        |
| **Disbursement Frequency**   | Merchants with `DAILY` frequency are disbursed every day, merchants with `WEEKLY` frequency are disbursed **only on the weekday matching their `live_on` date**. This logic uses Ruby's `Date#cwday` to match weekdays reliably.                               |
| **Disbursement Eligibility** | Only orders **with a commission fee already calculated** are considered eligible for disbursement. This prevents processing incomplete or invalid orders.                                                                                                      |
| **Idempotency**              | Each disbursement is uniquely scoped by merchant and disbursement date. A disbursement will not be created more than once per merchant per day. If a disbursement exists but has no associated orders, it is treated as invalid.                               |
| **Monthly Fee Logic**        | Monthly fees are calculated **after the end of each month**, by checking if the merchant's **total commissions** meet their `minimum_monthly_fee`. Any shortfall is stored as a `MonthlyFee`, but **not deducted** from disbursements.                         |
| **Order Commission Bands**   | Commission rules strictly follow the spec: <br> - 1.00% for orders `< €50` <br> - 0.95% for orders between `€50 – €300` <br> - 0.85% for orders `> €300`                                                                                                       |
| **Timezones**                | All date comparisons (e.g., `created_at`) assume UTC and use `Date.current` or `created_at.to_date` to avoid time drift across boundaries.                                                                                                                     |
| **Skipped Orders**           | Orders that do not match the merchant's eligible disbursement date (especially for weekly merchants) are **not disbursed** and are intentionally skipped to comply with the business rules.                                                                    |
| **Commission Deduction**     | Commissions are calculated per order and stored on the order record. They are **not deducted** from monthly fees, both values are tracked independently.                                                                                                       |
| **Logging & Observability**  | Logging is minimal in the current implementation. Failures in disbursement creation or missing commission fees are silently skipped for stability, but can be enhanced with structured logging or exception tracking (e.g., Honeybadger/Sentry) in production. |

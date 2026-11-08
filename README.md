# FIRST STAR HOTEL & RESORT

Multi-branch, multi-country hotel reservation and property-management platform.

## Current Cloudflare resources

- Worker API: `first-star-hotel-api`
- D1 database: `first-star-hotel-management-db`
- Worker endpoint: `https://first-star-hotel-api.ponprachanban1.workers.dev`
- D1 binding: `DB`

## Repository structure

- `migrations/0001_core_schema.sql` — additive D1 schema for multi-branch room inventory, rates, booking items, inventory holds, payment events, payment slips and audit history.
- Existing Worker and database are retained; this migration does not drop or overwrite existing records.

## Important production gates

1. Configure a unique owner account and rotate the initial setup secret.
2. Add public booking endpoints with server-side rate calculation and transactional inventory holds.
3. Attach private R2 storage for payment slips and verify file access controls.
4. Select an approved Thai payment gateway/acquirer before enabling live payment verification. A PromptPay image upload alone is not an automated payment confirmation.
5. Add webhook signature verification, idempotency, reconciliation, backups, monitoring, rate limiting and security tests.
6. Configure branch-specific room inventory, rate plans, tax and service-charge policies before opening reservations.

No real payment is marked paid by a browser action or uploaded slip. Only verified provider events or an authorized finance review may change payment status.

# Upgrading Instructions

## From 0.2 to 0.3
* 0.3 introduced the Pay gem. You'll need to run migrations to delete/create the appropriate columns. The migrations in question are `create_pay_subscriptions.pay`, `create_pay_charges.pay`, `add_status_to_pay_subscriptions.pay`, and `add_pay_to_users`.

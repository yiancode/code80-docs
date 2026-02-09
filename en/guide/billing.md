# Billing & Subscriptions

## Billing Model

Code80 uses a pay-as-you-go billing model.

## Billing Rules

- Each API call is charged based on token usage
- Cost = Actual upstream consumption × Group multiplier
- Different groups may have different multiplier settings

## Subscription Plans

The platform may offer various subscription plans:

- **Daily quota**: Fixed daily allowance, resets next day
- **Weekly quota**: Fixed weekly allowance
- **Monthly quota**: Fixed monthly allowance

## Checking Balance

After logging in, visit the "My Subscriptions" page to view:
- Active subscriptions
- Used / Total quota
- Expiration date
- Quota reset countdown

## Getting Balance

- Purchase a subscription plan
- Online recharge
- Redeem with a code

## Cost Optimization Tips

- Use `/compact` and similar commands to compress context and reduce token usage
- Describe requirements precisely to minimize unnecessary back-and-forth
- Choose appropriate model and parameter settings

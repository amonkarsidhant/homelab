# JARVIS Home OS — Go-To-Market Strategy

**Author:** CRO (Chief Revenue Officer)  
**Date:** March 27, 2026  
**Version:** 0.1 (Sprint 0)

---

## Executive Summary

JARVIS Home OS uses a **Hybrid GTM motion** — Product-Led Growth (PLG) for the Free and Home+ tiers (bottom-up, community-driven), combined with Sales-Led motion for the Enterprise tier (top-down, partner-driven). The YouTube and home automation community becomes the primary awareness engine, following the proven playbook of n8n, Grafana, and Home Assistant.

---

## Launch Motion: PLG + Sales-Led Hybrid

### Why PLG Works for Free and Home+ Tiers

The smart home enthusiast community (Home Assistant forums, Reddit r/homeassistant, YouTube channels like The Hook Up, Lars & Friends) is a proven bottom-up distribution channel. These users self-select for technical curiosity, write tutorials, and create viral content. If JARVIS is genuinely better than Home Assistant for non-automators, this community will find it, test it, and promote it — at zero CAC.

**PLG motions that work in this space:**
- Open-source install image (Raspberry Pi flashable)
- Generous free tier (local-only, no subscription)
- YouTube tutorials and comparison videos
- Discord community with direct engineering access
- GitHub repos for skills and integrations

**Reference:** Grafana grew from 0 to 20M+ users with zero sales team by being genuinely better than incumbents and letting users evangelize. n8n did the same in the automation space. Home Assistant has 200K+ forum members, all earned through community quality.

### Why Sales-Led is Required for Enterprise Tier

Decor brands (IKEA, Wayfair) do not discover products on Discord. They need:
- Executive introductions
- Pilot program structuring
- Legal review of OEM agreements
- Quarterly business reviews and KPIs
- Dedicated support SLAs

The Enterprise tier requires a dedicated sales motion, even if it's a team of 2 (CRO + 1 SDR). This is not optional — a $500K OEM deal requires relationship-building that PLG cannot provide.

**Reference:** Home Assistant's commercial entity (Home Assistant Yellow) went through a traditional hardware retail sales motion (Arrow Electronics distribution). Their Enterprise offerings (Home Assistant Cloud by Nabu Casa) used a hybrid — community PLG for user adoption, direct sales for Enterprise contracts.

### The Hybrid Model

| Tier | Primary GTM | Secondary GTM | CAC Expectation |
|------|-------------|---------------|----------------|
| **Free** | Community / YouTube | App Store listing | ~$0 |
| **Home+ ($9.99/mo)** | Community → upgrade | Product Hunt launch | <$10 |
| **Enterprise** | Direct sales / events | Brand partner referral | $5K-$20K |
| **Developer** | Dev community / GitHub | Documentation | ~$0 |

---

## Pricing Strategy

### Pricing Philosophy

JARVIS should be free for local-only use (honors the privacy-first principle; no paywall for people who don't want cloud). The subscription is for people who want the cloud sync + premium features. Enterprise is priced to be accessible for SMB decor brands but valuable enough to fund the company.

### Tier Details

#### Free Tier — $0/mo
**Target:** Non-technical homeowners, privacy enthusiasts, home automation beginners

**Includes:**
- Local voice agent ("Hey JARVIS")
- Matter device bridge (up to 20 devices)
- Pattern learning engine (local storage)
- Mobile companion app (iOS + Android)
- Offline mode (100% local)
- Basic skills (timer, weather, lights, thermostat)
- Community support (Discord)

**Limits:**
- No cloud sync
- No backup / restore
- Max 1 household, 2 family members
- 5 automation rules

**Rationale:** This is the "try before you buy" tier. It must be genuinely useful so users experience the value before being asked to pay. No artificial limitations on core functionality.

---

#### Home+ Tier — $9.99/mo
**Target:** Power users, tech-savvy families, early adopters who want cloud sync

**Includes:**
- Everything in Free
- Cloud sync + backup
- Unlimited automation rules
- Up to 6 family members
- Advanced pattern learning (cross-room, presence-aware)
- Premium skills (energy dashboard, security monitoring basics, grocery list integration)
- Priority support (email + Discord)
- Multi-hub support (Phase 2)

**Rationale:** $9.99/mo is competitive with Nest Aware ($6.99-$29.99/mo), Amazon Alexa Guard ($4.99/mo), and Samsung SmartThings ($3.99/mo+). Those are all cloud-only with no local option. JARVIS Home+ is the premium privacy-first alternative.

**Pricing Anchoring:**
- Anchor against $15/mo Google Nest Aware (overkill for most)
- Anchor against $249/yr Home Assistant Yellow + Nabu Casa Cloud
- Position: "The smart home subscription that respects your privacy"

---

#### Enterprise Tier — Custom pricing (est. $2-5/household/month + setup fee)
**Target:** Decor brands (IKEA, Wayfair, Ashley) white-labeling JARVIS

**Includes:**
- White-label JARVIS OS (own brand name, voice, UX)
- Brand-specific skill pack
- OEM mobile app (App Store / Play Store listing under brand)
- API access for brand's internal tools
- Dedicated support SLA (99.9% uptime, <4hr response)
- Quarterly business review and analytics
- Custom Matter device certification testing
- Minimum 10,000 households (contract floor)

**Pricing Model:**
- Per-household/month license fee: ~$3-5/household
- Setup fee: ~$25K-100K (one-time, depends on customization)
- Optional: Revenue share on Home+ upsells originated through brand

**Rationale:** At $3/household/month x 50,000 brand households = $150K/mo revenue. A mid-size brand like Ashley (1,100 stores, assuming 1 demo unit + 1% attach rate = 11K households) generates $33K/mo. This is meaningful revenue at brand scale.

---

#### Developer Tier — Free (limited) / $29-99/mo (API + inference)
**Target:** Developers, researchers, home automation hackers, SI/SV companies

**Includes (Free):**
- Full JARVIS install (self-hosted)
- Local API access
- Community Discord

**Includes (Paid - $29/mo Developer Pro):**
- Cloud API access (for testing)
- Higher rate limits (1K vs 10K requests/day)
- Pre-trained model access (custom skill fine-tuning)
- Priority documentation support

**Includes (Paid - $99/mo Inference):**
- Cloud inference credits (GPU time for custom models)
- Model serving infrastructure
- Custom skill marketplace submission

**Rationale:** The developer tier seeds the ecosystem. Free tier gets developers hooked; paid developer tier funds the infrastructure. The goal is 1,000+ developers building skills — this creates a moat no competitor can replicate quickly.

---

## Channel Strategy

### Primary Channels

#### 1. YouTube (Primary Awareness Engine)

YouTube is the highest-leverage GTM channel for a hardware-adjacent software product like JARVIS. The home automation YouTube ecosystem is passionate, technically credible, and underserved by the products they cover.

**Content Strategy:**
- **Comparison Videos:** "JARVIS vs Home Assistant — which is right for you?" (target Lars & Friends, The Hook Up, DIY Perks)
- **Tutorial Series:** "Set up your smart home in 30 minutes with JARVIS" (step-by-step for non-technical users)
- **Privacy Deep Dives:** "Why local-first smart home matters" (target tech-literate but privacy-conscious audience)
- **Brand Partner Videos:** IKEA integration demo, Wayfair bundle reveal (brand co-marketing)
- **Developer Content:** API walkthrough, skill building tutorials (target developers)

**Channel Launch Plan:**
1. Seed with 6-8 tutorial + comparison videos before public launch
2. Offer early access to YouTubers with >50K subscribers (free hardware + 1-year Home+)
3. Create an affiliate program (10% recurring for referred Home+ subscriptions)
4. Encourage community to create content (Discord + GitHub contributors)

**Reference:** n8n's YouTube presence (200K+ subscribers) drove >50% of their sign-ups. Grafana's tutorials have 10M+ views. Home Assistant's Lars & Friends partnership created tens of thousands of household installs.

#### 2. App Store (Primary Distribution for Mobile)

**Apple App Store:**
- Free tier download as primary entry point
- QR code in retail boxes (IKEA, Ashley, etc.)
- App Store optimization: "smart home hub", "home automation", "privacy first", "Matter"
- Featured potential: Apple loves privacy-first stories; leverage this for editorial feature

**Google Play Store:**
- Android-first markets (where Raspberry Pi adoption is higher)
- APK sideloading for direct install (non-Google-play countries)
- Android TV / Google TV app (Phase 2 — smart TV hub control)

#### 3. Home Automation Community (Community-Led Growth)

**Forums and Communities to Penetrate:**
- r/homeassistant (200K+ members) — don't compete, complement ("JARVIS runs ON TOP of HA")
- r/smarthome (100K+ members) — target non-HA users
- Home Assistant Community Forums (200K+ posts)
- Matter protocol community (emerging, opportunity to own)
- Hacker News / Lobsters (developer audience)

**Community Motion:**
- CRO or Community Agent participates actively in these forums
- JARVIS is positioned as "the Home Assistant experience for people who don't want to write automations"
- Open-source JARVIS skills repo on GitHub (developer trust signal)
- Host a JARVIS Discord server with engineering transparency (weekly changelog, direct dev access)

**Reference:** Home Assistant's community is their moat. Grafana's community Slack has 50K+ members. Zulip, PostHog, and Mattermost all use community as their primary GTM channel.

#### 4. Brand Partnership Pipeline (Enterprise Revenue Driver)

**Partnership Motion (see BRAND-DECK.md for full list):**
1. **IKEA (Priority #1):** TRÅDFRI intelligence layer, white-label OEM pilot
2. **Wayfair (Priority #2):** "Wayfair Home" white-label, Matter device bundles
3. **Ashley (Priority #3):** "Ashley Home Intelligence," in-store demos

**Deal Structure for Brands:**
- Initial: 3-month pilot (50-200 households, no cost to brand except co-marketing)
- Pilot success metrics: activation rate >60%, WAU >40%, NPS >30
- Expansion: OEM license agreement (per-household/month pricing)
- Upsell: Premium skills, analytics dashboard, brand-specific features

#### 5. Events and Trade Shows (Enterprise + Community)

**Target Events:**
- **CES (Consumer Electronics Show):** JarvinOS demo, brand partner announcements
- **Salone del Mobile (Milan):** Design-focused brand partner event (Crate & Barrel, West Elm, RH)
- **IFA (Berlin):** European push (IKEA home market)
- **Home Automation Expo (CEDIA):** Pro installer channel (Best Buy Geek Squad angle)
- **Reddit r/homeassistant Meetup:** Community event to seed early adopters

---

## Community as GTM Engine: The n8n / Grafana / Home Assistant Playbook

### Why This Model Works

Products that commoditize infrastructure (smart home hubs, automation platforms) succeed or fail based on ecosystem trust. The companies that won in this space — Home Assistant (open source), Grafana (observability), n8n (automation) — did so by:

1. **Giving the product away free** to the most passionate users (developers, hobbyists)
2. **Building in public** — public roadmap, transparent changelogs, direct engineer access
3. **Enabling advocates** — great docs, easy onboarding, Discord/Slack where users feel heard
4. **Letting users tell the story** — comparison videos, tutorials, word of mouth
5. **Solving the hard problem** — being genuinely better at something incumbents can't match

### JARVIS's Community GTM Checklist

- [ ] Open-source JARVIS core (at minimum, the agent runtime)
- [ ] Public roadmap (GitHub Projects or Linear)
- [ ] Weekly YouTube changelog (like Home Assistant's 52-week release videos)
- [ ] Discord server with engineering office hours
- [ ] GitHub discussions for feature requests
- [ ] Affiliate program for YouTubers and community advocates
- [ ] Free hardware for top community contributors
- [ ] Clear migration path from Home Assistant (so HA users can try JARVIS without losing everything)

### The Key Insight: Don't Compete with Home Assistant — Complement It

Home Assistant is 10 years deep and has 200K+ community members. JARVIS should explicitly position as "runs on top of Home Assistant" or "the UX layer for Home Assistant for families." This:
- Gets Home Assistant community endorsement instead of tribal warfare
- Reduces the "why don't you just use HA?" objection
- Opens Home Assistant's ecosystem (HA already has 2,000+ integrations)
- Makes JARVIS adoption easier (HA users are the most likely power users to advocate for JARVIS)

---

## Channel Effectiveness Summary

| Channel | Timeline | Cost | Expected ROI | Primary Goal |
|---------|----------|------|-------------|--------------|
| YouTube (organic) | 3-6 months to traction | ~$0 | Very High | Awareness, trust |
| App Store | Launch day | $99/yr Apple | High | Distribution, installs |
| Community (Reddit/Discord) | 1-3 months | ~$0 | High | Early adopters, feedback |
| GitHub / Open Source | Launch day | ~$0 | High | Developer trust, skills |
| Brand Partnership (IKEA) | 6-18 months | $10K-50K (sales cycles) | Critical | Enterprise revenue |
| Trade Shows | 6-12 months | $20K-100K | Medium | Brand awareness, deals |
| Affiliate Program | 3-6 months | 10% revenue share | Medium | Word-of-mouth |

---

## Key GTM Risks and Mitigations

### Risk 1: Home Assistant Community Rejection
**Mitigation:** Position JARVIS as complementary, not competing. Explicitly support HA integration. Offer migration tooling.

### Risk 2: Brand Partnership Sales Cycles Are Long
**Mitigation:** Start IKEA conversation in Sprint 1. Use community metrics (WAU, NPS) as social proof during sales cycles.

### Risk 3: YouTube Algorithm Dependency
**Mitigation:** Diversify content distribution (blog, Twitter/X, podcast appearances). Seed multiple YouTubers so no single creator controls the narrative.

### Risk 4: App Store Rejection or Rating Damage
**Mitigation:** Pre-beta private program with trusted testers. Build App Store optimization from day 1. Never let rating fall below 4.0.

### Risk 5: PLG Is Too Slow for Revenue Targets
**Mitigation:** Hire first Enterprise AE in parallel with PLG launch. Target 2-3 brand pilots in Year 1 to fund PLG growth.

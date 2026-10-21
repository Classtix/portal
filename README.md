# ClassTix District Rewards Portal

The production portal for ClassTix: districts request tickets and gift cards with monthly points, and the ClassTix team approves, fulfils and reports. It runs at **portal.classtix.org**, and your Webflow site at classtix.org links to it.

ClassTix owns all of this code.

## What's inside

| Part | What it does | Service |
|---|---|---|
| Website | Every screen for ClassTix Admins and District Admins | Vercel (Next.js) |
| Database and sign-in | Districts, events, requests, points ledger, invite-only accounts | Supabase |
| Email | Invites, password resets, request decisions, monthly balances | Resend |
| Daily job | Starts each month on the 1st and retries failed emails | Vercel Cron |

**How the data is protected:**
- Districts can only see their own district, requests and points. The database enforces this, not the screens.
- Every points change runs as a single transaction, so balances can't drift and tickets can't be oversold.
- Internal notes are kept in a separate table that districts can't read.
- Invite and reset links work once, and they're removed from the email log after they're sent.

---

## Launch checklist (about an hour)

You'll create three free accounts and add three DNS records. Do the steps in order.

### 1. Put the code on GitHub (5 min)

1. Sign in at github.com and create a new **private** repository named `classtix-portal`. Don't add a README.
2. On the empty repository page, click **uploading an existing file**.
3. Unzip `classtix-portal.zip` on your computer. Drag everything inside the folder (not the folder itself) into the page.
4. Click **Commit changes**.

### 2. Set up the database on Supabase (15 min)

1. Sign in at supabase.com and create a new project:
   - **Name:** ClassTix
   - **Region:** West US
   - **Database password:** pick a strong one and save it.
2. Open **SQL Editor**. For each file below, open it from `supabase/migrations`, paste it into a new query, and click **Run**. Run them in this order:
   1. `0001_schema.sql`
   2. `0002_functions.sql`
   3. `0003_seed.sql`, which loads your 26-listing catalog, Tempe Union HSD and the retail gift card program.
   4. `0004_single_rate.sql`, which sets the single $2-per-student rate.
   5. `0005_full_rate.sql`, which makes it 1 point per student.
   6. `0006_merit_fields.sql`, which adds each district's school list and the "Merit awarded for" drop-downs.
   7. Catalog data in `supabase/data`: `asu-home-games.sql`, then `catalog-update-2026-10.sql` (Suns, Cardinals, concerts and always-available gift cards; removes dated retail drops and the old dining category).
3. Go to **Authentication → Sign In / Providers → Email**:
   - Turn **off** "Allow new users to sign up". Accounts are invite-only.
   - Leave "Confirm email" on.
4. Go to **Authentication → URL Configuration**:
   - Set **Site URL** to `https://portal.classtix.org`.
   - Under **Redirect URLs**, add `https://portal.classtix.org/**`.
5. Create your own admin account:
   1. Go to **Authentication → Users → Add user → Create new user**. Enter your email and a password, and tick **Auto Confirm User**.
   2. Open `supabase/bootstrap-admin.sql` and change the name and email to match.
   3. Run it in the SQL Editor.
6. Go to **Project Settings → API** and keep that tab open. Step 4 needs the **Project URL**, the **anon public** key and the **service_role** key.

### 3. Set up email on Resend (10 min, plus DNS time)

1. Sign in at resend.com. Go to **Domains → Add domain** and enter `classtix.org`.
2. Resend shows a few DNS records (MX, TXT and DKIM). Add them where classtix.org's DNS is managed:
   - **If Webflow hosts the domain's DNS:** the records go in Webflow.
   - **Otherwise:** they go at your registrar, such as GoDaddy, Namecheap or Squarespace.
3. Wait until Resend shows the domain as **Verified**. This usually takes minutes but can take a few hours.
4. Go to **API Keys → Create API key** with sending access, and copy it.

### 4. Deploy on Vercel (10 min)

1. Sign in at vercel.com with your GitHub account. Click **Add New → Project** and import `classtix-portal`.
2. Before deploying, open **Environment Variables** and add:

| Name | Value |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase Project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anon public key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service_role key (keep this secret) |
| `NEXT_PUBLIC_SITE_URL` | `https://portal.classtix.org` |
| `RESEND_API_KEY` | Resend API key |
| `EMAIL_FROM` | `ClassTix <hello@classtix.org>` |
| `EMAIL_REPLY_TO` | `hello@classtix.org` |
| `CRON_SECRET` | Any long random string, such as 40 letters and numbers |

3. Click **Deploy**. When it finishes, open the `.vercel.app` link it gives you and sign in to check it works.

### 5. Point portal.classtix.org at it (5 min, plus DNS time)

1. In Vercel, go to **Project → Settings → Domains**, add `portal.classtix.org`, and click **Add**.
2. Vercel shows one **CNAME** record: name `portal`, value something like `cname.vercel-dns.com`. Add it where you added the Resend records. Don't touch the records for `classtix.org` or `www`; your Webflow site keeps working as it is.
3. Vercel issues the security certificate itself. Once it shows **Valid Configuration**, https://portal.classtix.org is live.

### 6. Link it from Webflow (5 min)

1. In the Webflow Designer, add a button to your nav (and footer if you like). Label it **District login**.
2. Set its link to the URL `https://portal.classtix.org`. Leave "Open in new tab" off.
3. Click **Publish**.

### 7. Go live

1. Sign in at portal.classtix.org with the account from step 2.5.
2. Go to **Districts** and check Tempe Union HSD's monthly points. Add your other districts.
3. Go to **Users → Invite user** and invite each District Admin. They get an email, set a password and land on their dashboard.
4. Go to **Email log** and confirm the invites show **Sent**.

---

## How points are funded

Every district is funded at **$2 per student per month**. All of it becomes points at $2 each, so monthly points = number of students (4,500 students → 4,500 points). Editing a district's student count updates its monthly points; the new amount is credited at the next reset.

## How the monthly cycle runs

Every night at about 12:15 AM Arizona time, Vercel calls `/api/cron`. That job does three things:

1. **On the 1st, it starts the new month:**
   - Unused points expire, or roll over if you switch that on in Program settings.
   - Each district is credited its monthly points.
   - District Admins are emailed their new balance.
   - Pending requests keep their held points. If one is rejected later, the points return to the new month.
2. **It retries any email that failed to send.**

If a night is ever missed, the next run catches up.

## Costs

All three services have free plans that cover a pilot:

- **Supabase:** a free project pauses after a week with no activity. Once districts depend on the portal, move to the Pro plan for daily backups and no pausing.
- **Vercel:** the Hobby plan is for non-commercial use. Move to Pro when the portal is in regular use.
- **Resend:** the free plan sends 3,000 emails a month, 100 a day.

Check each provider's pricing page for current prices.

## Making changes

To change anything, edit the code and push to GitHub. Vercel redeploys automatically.

- **Database changes** go in a new file in `supabase/migrations`, which you run in the SQL Editor.
- **To run it on your own computer:** copy `.env.example` to `.env.local`, fill it in, then run `npm install` and `npm run dev`.
- **Tests:** `supabase/tests/run_tests.sql` checks the business rules (holds, partial approvals, overselling, resets, privacy between districts) against a plain Postgres database.

## Where things live

```
src/app/admin/*        ClassTix Admin screens
src/app/district/*     District Admin screens
src/app/actions.ts     Every button that changes data
src/app/api/cron       The nightly job
src/lib/email.ts       Email sending (Resend)
supabase/migrations    Database tables, security rules and business logic
```

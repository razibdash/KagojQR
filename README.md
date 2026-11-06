# KagojQR

Flutter + Supabase app. An owner uploads vehicle/ID documents and gets a QR
sticker for the car. A traffic officer scans it, enters their name, police ID and
the owner's PIN, and sees the documents in a short-lived, watermarked viewer.
The owner can revoke the QR at any time. See [PROJECT.md](PROJECT.md) for the brief.

> **Honest limitation:** screenshots and photos of a screen cannot be 100%
> prevented. Android FLAG_SECURE blocks screenshots/recording in the app, but
> the web viewer has no equivalent, and anyone can photograph a screen with
> another device. The watermark, 60-second expiry, PIN, access log and instant
> revocation *reduce* risk; they do not eliminate it.

## Status

- [x] Phase 1: project setup, SQL migrations, RLS, private storage bucket
- [ ] Phase 2+: see PROJECT.md

## Setup

### 1. Supabase project
1. Create a project at https://supabase.com.
2. Apply the migrations in `supabase/migrations/` in order — either
   `supabase link --project-ref <ref> && supabase db push`, or paste each file
   into the dashboard SQL editor (0001, 0002, 0003).
3. Confirm in Storage that bucket `documents` exists and is **private**.

### 2. Google OAuth (used from Phase 2)
1. Google Cloud Console → create OAuth clients: **Web**, **Android**
   (package `com.kagojqr.app` + your SHA-1).
2. Supabase → Authentication → Providers → Google: enable, paste the Web
   client ID and secret.
3. Add redirect URL `com.kagojqr.app://login-callback` under Auth → URL config.

### 3. App config
```
copy .env.example .env      # then fill in values
flutter pub get
flutter run --dart-define-from-file=.env
```
Only the **anon** key goes in `.env`. Never put the service-role key in the app.

### 4. Edge Functions (Phase 5)
Secrets are set with `supabase secrets set`, never committed.

## Security notes (Phase 1)
- RLS is enabled on every table; owners only touch their own rows.
- `access_logs` is readable by the owner only; inserts are service-role only.
- `qr_tokens.pin_hash` is hidden from and not writable by the client; PINs are
  hashed in the Edge Function.
- `pin_attempts` has no policies, so it is service-role only (rate limiting).
- Storage is private; objects are limited to `{owner_id}/{doc_type}/…`.

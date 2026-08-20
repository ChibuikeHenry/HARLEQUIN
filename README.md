# HARLEQUIN

Web-first Flutter workspace for collecting complaints, feedback and compliments.

## Firestore layout

```
users/{userId}
  firstName, lastName, email, role, businessId, createdAt, updatedAt

businesses/{businessId}
  ownerId, name, email, phone, uniqueLink, slug, createdAt, updatedAt

businesses/{businessId}/submissions/{submissionId}
  type          → complaint | feedback | compliment
  customerName
  subject
  status        → in_progress | resolved | open
  channel
  createdAt, updatedAt
```

Each business owner only reads and writes their own documents (see `firestore.rules`).

## Run locally

```bash
flutter run -d chrome
```

## Deploy

```bash
flutter build web --no-wasm-dry-run
firebase deploy --only hosting,firestore:rules
```

Live site: https://harlequin-30a7b.web.app

**Note:** Enable Cloud Firestore in the Firebase console (test mode or deploy the rules above) before sign-up.

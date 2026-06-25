# Integration front/back - auth admin

## Scope courant

L'image Docker et le backend actuellement connectes au front ne couvrent pour le moment que le flux d'auth admin suivant:

- login avec email et mot de passe
- restauration de session au chargement
- logout

Les fonctionnalites suivantes ne sont pas encore branchees dans cette version:

- inscription
- reset de mot de passe
- auth Discord

## Vue d'ensemble

La page admin `Users` centralise maintenant deux vues:

- `Users` pour les end users
- `Staff users` pour les comptes internes

Les endpoints backend restent separes, mais l'interface front les expose dans une seule page avec un toggle.

La route `/admin/staff-users` reste disponible comme alias technique et redirige vers `Users` avec la vue staff.

La page `Drive Settings` a ete deplacee sous la navigation `Multi`:

- nouvelle route: `/multi/drive-settings`
- ancienne route admin: `/admin/drive-settings` reste un alias de redirection

```mermaid
flowchart LR
  subgraph Client[Front]
    Login[Login page]
    Provider[AuthProvider]
    ClientAPI[api-client]
  end

  API[Backend admin API]
  Cookie[(httpOnly session cookie)]

  Login --> Provider
  Provider --> ClientAPI
  ClientAPI --> API
  API --> ClientAPI
  API --> Cookie
  Cookie --> ClientAPI
  ClientAPI --> Provider
  Provider --> Login
```

## Auth flow

### 1. Login

```mermaid
sequenceDiagram
  participant User
  participant UI as Login page
  participant Auth as AuthProvider
  participant API as Backend

  User->>UI: submit email/password
  UI->>Auth: login()
  Auth->>API: POST /admin/auth/login
  API-->>Auth: access_token, user_id, role
  API-->>Browser: set httpOnly session cookie
  Auth->>API: GET /admin/auth/me
  API-->>Auth: admin profile
  Auth-->>UI: session ready
  UI-->>User: redirect /admin or redirect param
```

### 2. Session restore

```mermaid
  sequenceDiagram
  participant Browser
  participant App as App shell
  participant Auth as AuthProvider
  participant API as Backend

  App->>Auth: mount
  Browser->>API: GET /admin/auth/me with cookie
  Auth->>API: GET /admin/auth/me
  API-->>Auth: admin profile
  Auth-->>App: user + authenticated state
```

### 3. Logout

```mermaid
sequenceDiagram
  participant User
  participant Auth as AuthProvider
  participant API as Backend

  User->>Auth: logout()
  Auth->>API: POST /admin/auth/logout
  API-->>Auth: 204 / success
  Auth-->>User: redirect /auth/login
```

## Auth state rules

- `AuthProvider` relies on the backend session cookie and hydrates the user with `GET /admin/auth/me`.
- `api-client` sends `credentials: 'include'` by default so the backend cookie is attached.
- if `GET /admin/auth/me` returns `401`, the client clears the session and forces a new login.
- if login succeeds but session hydration fails, the client rolls back the session instead of keeping a half-open state.
- the frontend never stores the admin access token in `localStorage` or `sessionStorage`.

## Endpoints branches

| Domaine | Front | Endpoint | Statut | Notes |
| ----------- | --------------- | ---------------------- | ------ | ----- |
| Admin auth | AuthProvider | POST /admin/auth/login | lie | Login et hydration de session |
| Admin auth | AuthProvider | GET /admin/auth/me | lie | Hydratation de session |
| Admin auth | AuthProvider | POST /admin/auth/logout | lie | Logout best-effort + cleanup client |
| Admin users | Users page - tab Users | GET /admin/users/ | lie | Liste paginee des users |
| Admin users | Users page - tab Users | GET /admin/users/{id} | lie | Chargement d'un user par id |
| Admin users | Users page - tab Users | POST /admin/users/ | lie | Creation d'un user |
| Admin users | Users page - tab Users | PUT /admin/users/{id} | lie | Mise a jour d'un user |
| Admin users | Users page - tab Users | DELETE /admin/users/{id} | lie | Suppression d'un user |
| Admin users | Users page - tab Users | POST /admin/users/{id}/block | lie | Blocage d'un user |
| Admin users | Users page - tab Users | POST /admin/users/{id}/unblock | lie | Deblocage d'un user |
| Staff users | Users page - tab Staff users | GET /admin/staff-users/ | lie | Liste des staff users |
| Staff users | Users page - tab Staff users | POST /admin/staff-users/ | lie | Creation d'un staff user |
| Staff users | Users page - tab Staff users | PATCH /admin/staff-users/{staff_user_id} | lie | Mise a jour d'un staff user |
| Staff users | Users page - tab Staff users | DELETE /admin/staff-users/{staff_user_id} | lie | Suppression d'un staff user |
| Admin events | Events page | GET /admin/events/ | lie | Liste et filtres des events |
| Admin events | Events page | POST /admin/events/ | lie | Creation d'un event |
| Admin events | Events page | POST /admin/events/{event_id}/draft | lie | Retour en draft |
| Admin events | Events page | POST /admin/events/{event_id}/schedule | lie | Passage en scheduled |
| Admin events | Events page | POST /admin/events/{event_id}/archive | lie | Archivage d'un event |
| Admin audits | Logs page | GET /admin/audits | lie | Journal d'audit admin |

## Hors scope

Ces elements restent volontairment hors du front actuel:

- register
- password reset
- discord oauth
- public user auth

## Regles de mise a jour

- Ajouter une ligne pour chaque nouvel endpoint branche.
- Mettre a jour les diagrammes si le flow d'auth change.
- Garder cette page alignee avec le comportement reel du front.

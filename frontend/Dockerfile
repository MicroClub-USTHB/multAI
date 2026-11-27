# syntax=docker/dockerfile:1.7
# MultiAi web (TanStack Start). Small runtime: node:22-alpine, non-root, only the packages the SSR bundle imports.

# ---- build ----------------------------------------------------------------
FROM node:22-alpine AS build
WORKDIR /src

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --no-audit --no-fund

# Build-time (baked into the browser bundle): see deploy/README.md
ARG VITE_API_BASE_URL=/api
ARG VITE_APP_TITLE=MultAI
ARG VITE_SITE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL \
    VITE_APP_TITLE=$VITE_APP_TITLE \
    VITE_SITE_URL=$VITE_SITE_URL \
    NODE_OPTIONS=--max-old-space-size=3072

COPY . .
RUN npm run build

# Install only what dist/server imports at runtime (the SSR bundle keeps dependencies external).
RUN node deploy/runtime-package.mjs dist/server /runtime \
 && cd /runtime \
 && npm install --omit=dev --no-audit --no-fund --loglevel=error \
 && find node_modules -type f \( -name '*.map' -o -name '*.d.ts' -o -name '*.d.mts' -o -name '*.d.cts' -o -name '*.md' -o -name 'LICENSE*' -o -name 'CHANGELOG*' \) -delete

# ---- runtime --------------------------------------------------------------
FROM node:22-alpine AS runtime
ENV NODE_ENV=production \
    PORT=3000 \
    NODE_OPTIONS=--max-old-space-size=160
WORKDIR /app

COPY --from=build --chown=node:node /runtime/node_modules ./node_modules
COPY --from=build --chown=node:node /src/dist ./dist
COPY --chown=node:node deploy/serve.mjs ./serve.mjs
# `type: module` for serve.mjs / dist/server; no dependencies are declared here on purpose.
RUN echo '{"type":"module","private":true}' > package.json && chown node:node package.json

USER node
EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:3000/healthz || exit 1
CMD ["node", "serve.mjs"]

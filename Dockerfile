ARG BUN_VERSION='1.3'

FROM oven/bun:${BUN_VERSION}-alpine AS build

WORKDIR /app

COPY package.json bun.lock tsconfig.json ./
COPY src ./src

RUN bun install --frozen-lockfile

# Runtime: Debian-based so PG_VERSION=18 (and any future major) installs cleanly
# from the official PGDG apt repo. Alpine's main+community repos do not yet
# ship `postgresql18-client`, which means PG_VERSION=18 fails at build time:
#
#   ERROR: unable to select packages:
#     postgresql18-client (no such package)
#
# PGDG maintains client packages for every supported major across Debian
# bookworm/trixie, so this build keeps working as users move forward.
FROM oven/bun:${BUN_VERSION}-debian

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
COPY --from=build /app/bun.lock ./
COPY --from=build /app/src ./src
COPY --from=build /app/tsconfig.json ./

ARG PG_VERSION='17'

# postgresql-client-${PG_VERSION} from the PGDG apt repo. Pinned signing key
# stored under /usr/share/postgresql-common/pgdg/ per PGDG's own instructions
# so apt verifies signatures without warnings.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg lsb-release \
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
    && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client-${PG_VERSION} \
    && apt-get purge -y --auto-remove curl gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

CMD pg_isready --dbname=$DATABASE_URL && \
    pg_dump --version && \
    bun run src/index.ts

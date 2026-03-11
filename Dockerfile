ARG BUN_VERSION='1.1'

FROM oven/bun:${BUN_VERSION}-alpine AS build

WORKDIR /app

COPY package.json bun.lockb tsconfig.json ./
COPY src ./src

RUN bun install --frozen-lockfile

FROM oven/bun:${BUN_VERSION}-alpine

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
COPY --from=build /app/bun.lockb ./
COPY --from=build /app/src ./src
COPY --from=build /app/tsconfig.json ./

ARG PG_VERSION='17'

RUN apk add --update --no-cache postgresql${PG_VERSION}-client

CMD pg_isready --dbname=$BACKUP_DATABASE_URL && \
    pg_dump --version && \
    bun run src/index.ts

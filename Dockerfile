# Stage 1 – deps: install node_modules with npm ci for reproducibility
FROM node:20-alpine AS deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci


# Stage 2 – builder: compile the Next.js application
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build-time env vars (non-secret, baked into the bundle)
ARG API_BASE_URL
ENV API_BASE_URL=$API_BASE_URL

RUN npm run build

# Stage 3 – runner: lean production image
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create a non-root group and user to run the application securely
RUN addgroup --system --gid 1001 nodejs && \
    adduser  --system --uid 1001 --ingroup nodejs nextjs

# Next.js standalone output (enable in next.config if needed)
# COPY --from=builder /app/.next/standalone ./
# COPY --from=builder /app/.next/static ./.next/static
# COPY --from=builder /app/public ./public

# Standard (non-standalone) output
# node_modules sourced from deps stage; .next artefacts from builder
COPY --from=builder  /app/public       ./public
COPY --from=builder  /app/.next        ./.next
COPY --from=deps     /app/node_modules ./node_modules
COPY --from=builder  /app/package.json ./package.json

# Transfer ownership of the working directory to the non-root user
RUN chown -R nextjs:nodejs /app

# Drop privileges — never run production containers as root
USER nextjs

EXPOSE 3001

CMD ["npm", "run", "start"]

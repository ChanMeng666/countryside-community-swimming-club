import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import { getCloudflareContext } from "@opennextjs/cloudflare";
import * as schema from "./schema";

// Resolve DATABASE_URL at request time. On Cloudflare Workers (via OpenNext) the
// secret lives on the Cloudflare env binding — accessed through
// getCloudflareContext() — and is NOT mirrored into process.env, nor available
// during cold-start module evaluation. Fall back to process.env for plain
// `next dev` and the seed script, where getCloudflareContext is unavailable.
const getConnectionString = (): string => {
  try {
    const env = getCloudflareContext().env as unknown as {
      DATABASE_URL?: string;
    };
    if (env.DATABASE_URL) return env.DATABASE_URL;
  } catch {
    // Not running inside the Workers runtime — fall back below.
  }
  return process.env.DATABASE_URL!;
};

const createDb = () => drizzle(neon(getConnectionString()), { schema });

let _db: ReturnType<typeof createDb> | null = null;
const getDb = () => (_db ??= createDb());

export const db = new Proxy({} as ReturnType<typeof createDb>, {
  get(_target, prop, receiver) {
    const instance = getDb();
    const value = Reflect.get(instance, prop, receiver);
    return typeof value === "function" ? value.bind(instance) : value;
  },
});

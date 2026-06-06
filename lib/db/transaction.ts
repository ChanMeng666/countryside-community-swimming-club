import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import { getCloudflareContext } from "@opennextjs/cloudflare";
import * as schema from "./schema";

// See lib/db/index.ts for why the connection string is resolved lazily at
// request time from the Cloudflare env binding (with a process.env fallback).
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

export const dbPool = new Proxy({} as ReturnType<typeof createDb>, {
  get(_target, prop, receiver) {
    const instance = getDb();
    const value = Reflect.get(instance, prop, receiver);
    return typeof value === "function" ? value.bind(instance) : value;
  },
});

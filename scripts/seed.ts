import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import * as schema from "../lib/db/schema";

const sql = neon(process.env.DATABASE_URL!);
const db = drizzle(sql, { schema });

async function seed() {
  console.log("🌱 Seeding database...");

  // 1. Create class types
  console.log("Creating class types...");
  await db.insert(schema.classType).values([
    { type: "class", className: "Beginner Swimming", description: "Learn the basics of swimming. Perfect for those new to the water." },
    { type: "class", className: "Intermediate Swimming", description: "Build on your swimming skills with stroke technique and endurance." },
    { type: "class", className: "Advanced Training", description: "Competitive-level training for experienced swimmers." },
    { type: "1-on-1", className: "Private Lesson", description: "One-on-one coaching tailored to your individual needs." },
    { type: "group", className: "Group Session", description: "Fun group swimming sessions for all skill levels." },
    { type: "group", className: "Family Swim", description: "A fun group session for families to swim together." },
  ]);

  // 2. Create locations (pool lanes)
  console.log("Creating locations...");
  await db.insert(schema.location).values([
    { poolName: "Main Pool", laneName: "Lane 1", status: "available" },
    { poolName: "Main Pool", laneName: "Lane 2", status: "available" },
    { poolName: "Main Pool", laneName: "Lane 3", status: "available" },
    { poolName: "Main Pool", laneName: "Lane 4", status: "available" },
    { poolName: "Training Pool", laneName: "Lane 1", status: "available" },
    { poolName: "Training Pool", laneName: "Lane 2", status: "available" },
  ]);

  // 3. Create products (membership plans)
  console.log("Creating products...");
  await db.insert(schema.product).values([
    { name: "Monthly Membership", description: "30-day access to all classes and facilities", price: "49.99" },
    { name: "Annual Membership", description: "365-day access to all classes and facilities — best value!", price: "449.99" },
  ]);

  console.log("✅ Seed complete!");
  console.log("");
  console.log("📝 Note: To create user accounts (manager, instructor, member),");
  console.log("   register them through the app UI at /register, then use the");
  console.log("   database to promote roles:");
  console.log("");
  console.log('   UPDATE "user" SET role = \'manager\' WHERE email = \'admin@example.com\';');
  console.log('   UPDATE "user" SET role = \'instructor\' WHERE email = \'instructor@example.com\';');
}

seed().catch((e) => {
  console.error("❌ Seed failed:", e);
  process.exit(1);
});

# Tech Stack Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Flask/MySQL/Jinja2 swimming club management system with Next.js 15 + Neon PostgreSQL + Drizzle ORM + Better Auth + FullCalendar + shadcn/ui, deployed on Heroku.

**Architecture:** Full rewrite using Next.js App Router with React Server Components for data fetching, Server Actions for mutations, and Drizzle ORM for type-safe database access. Better Auth handles authentication with role-based access (member/instructor/manager). FullCalendar renders interactive timetables.

**Tech Stack:** Next.js 15, React 19, TypeScript, Tailwind CSS 4, shadcn/ui, Drizzle ORM, Neon PostgreSQL, Better Auth, FullCalendar 6, Zod, Heroku

**Design Spec:** `docs/superpowers/specs/2026-03-30-tech-stack-modernization-design.md`

**Old codebase reference:** The Flask app in `scmsapp/` — schema at `scmsapp/database/scms.sql`, models in `scmsapp/model/`, routes in `scmsapp/route/`

---

## Task 1: Initialize Next.js Project and Install Dependencies

**Files:**
- Create: `package.json`, `tsconfig.json`, `next.config.ts`, `tailwind.config.ts`, `components.json`, `.env.local`, `.gitignore`

- [ ] **Step 1: Create Next.js 15 app in a new directory**

Run from project root:
```bash
npx create-next-app@latest . --typescript --tailwind --eslint --app --src=no --import-alias "@/*" --turbopack
```

Note: Since the project root already has files, you may need to run this in a temporary directory and move files, or use `--yes` to force. The old Flask files (`scmsapp/`, `run.py`, `requirements.txt`) will coexist temporarily and be removed at the end.

- [ ] **Step 2: Install core dependencies**

```bash
npm install better-auth drizzle-orm @neondatabase/serverless zod sonner next-themes lucide-react @fullcalendar/core @fullcalendar/react @fullcalendar/daygrid @fullcalendar/timegrid @fullcalendar/interaction
```

- [ ] **Step 3: Install dev dependencies**

```bash
npm install -D drizzle-kit
```

- [ ] **Step 4: Initialize shadcn/ui**

```bash
npx shadcn@latest init
```

Select: New York style, Zinc base color, CSS variables enabled.

- [ ] **Step 5: Add commonly used shadcn/ui components**

```bash
npx shadcn@latest add button card dialog form input label select table badge sheet dropdown-menu separator avatar tabs toast textarea
```

- [ ] **Step 6: Create `.env.local`**

```env
DATABASE_URL=postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/scms?sslmode=require
BETTER_AUTH_SECRET=your-secret-key-here-change-in-production
BETTER_AUTH_URL=http://localhost:3000
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

Replace `DATABASE_URL` with actual Neon connection string. Generate `BETTER_AUTH_SECRET` with `openssl rand -base64 32`.

- [ ] **Step 7: Update `.gitignore`**

Ensure `.env.local` is in `.gitignore`. Also add:
```
.superpowers/
```

- [ ] **Step 8: Verify the dev server starts**

```bash
npm run dev
```

Expected: Next.js dev server starts on http://localhost:3000 with default page.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat: initialize Next.js 15 project with dependencies"
```

---

## Task 2: Database Schema with Drizzle ORM

**Files:**
- Create: `lib/db/schema.ts`, `lib/db/index.ts`, `lib/db/transaction.ts`, `drizzle.config.ts`

- [ ] **Step 1: Create Neon HTTP connection**

Create `lib/db/index.ts`:
```ts
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import * as schema from "./schema";

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql, { schema });
```

- [ ] **Step 2: Create Neon Pool connection for transactions**

Create `lib/db/transaction.ts`:
```ts
import { Pool } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-serverless";
import * as schema from "./schema";

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
export const dbPool = drizzle(pool, { schema });
```

- [ ] **Step 3: Create the full Drizzle schema**

Create `lib/db/schema.ts`:
```ts
import {
  pgTable,
  pgEnum,
  serial,
  integer,
  varchar,
  text,
  boolean,
  date,
  timestamp,
  decimal,
} from "drizzle-orm/pg-core";

// Enums
export const roleEnum = pgEnum("role", ["member", "instructor", "manager"]);
export const classTypeEnum = pgEnum("class_type_enum", [
  "class",
  "1-on-1",
  "group",
]);
export const locationStatusEnum = pgEnum("location_status", [
  "available",
  "unavailable",
]);
export const classStatusEnum = pgEnum("class_status", [
  "active",
  "cancelled",
]);
export const bookingStatusEnum = pgEnum("booking_status", [
  "booked",
  "cancelled",
]);
export const membershipTypeEnum = pgEnum("membership_type", [
  "Monthly",
  "Annual",
  "None",
]);

// Better Auth tables — auto-managed by Better Auth, defined here for Drizzle awareness
export const user = pgTable("user", {
  id: text("id").primaryKey(),
  name: text("name").notNull(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  emailVerified: boolean("email_verified").notNull().default(false),
  image: text("image"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
  role: roleEnum("role").notNull().default("member"),
  isActive: boolean("is_active").notNull().default(true),
});

export const session = pgTable("session", {
  id: text("id").primaryKey(),
  expiresAt: timestamp("expires_at").notNull(),
  token: text("token").notNull().unique(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
  ipAddress: text("ip_address"),
  userAgent: text("user_agent"),
  userId: text("user_id")
    .notNull()
    .references(() => user.id, { onDelete: "cascade" }),
});

export const account = pgTable("account", {
  id: text("id").primaryKey(),
  accountId: text("account_id").notNull(),
  providerId: text("provider_id").notNull(),
  userId: text("user_id")
    .notNull()
    .references(() => user.id, { onDelete: "cascade" }),
  accessToken: text("access_token"),
  refreshToken: text("refresh_token"),
  idToken: text("id_token"),
  accessTokenExpiresAt: timestamp("access_token_expires_at"),
  refreshTokenExpiresAt: timestamp("refresh_token_expires_at"),
  scope: text("scope"),
  password: text("password"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const verification = pgTable("verification", {
  id: text("id").primaryKey(),
  identifier: text("identifier").notNull(),
  value: text("value").notNull(),
  expiresAt: timestamp("expires_at").notNull(),
  createdAt: timestamp("created_at"),
  updatedAt: timestamp("updated_at"),
});

// Application tables
export const member = pgTable("member", {
  id: serial("id").primaryKey(),
  userId: text("user_id")
    .notNull()
    .unique()
    .references(() => user.id, { onDelete: "cascade" }),
  firstName: varchar("first_name", { length: 50 }).notNull(),
  lastName: varchar("last_name", { length: 50 }).notNull(),
  phone: varchar("phone", { length: 20 }).notNull(),
  email: varchar("email", { length: 100 }).notNull(),
  address: varchar("address", { length: 255 }),
  dob: date("dob"),
  healthInfo: text("health_info"),
  membershipType: membershipTypeEnum("membership_type").default("None"),
  expiredDate: date("expired_date"),
  isSubscription: boolean("is_subscription").notNull().default(false),
  image: varchar("image", { length: 255 }).default("default.jpg"),
});

export const instructor = pgTable("instructor", {
  id: serial("id").primaryKey(),
  userId: text("user_id")
    .notNull()
    .unique()
    .references(() => user.id, { onDelete: "cascade" }),
  title: varchar("title", { length: 20 }).notNull(),
  firstName: varchar("first_name", { length: 50 }).notNull(),
  lastName: varchar("last_name", { length: 50 }).notNull(),
  position: varchar("position", { length: 100 }).notNull(),
  phone: varchar("phone", { length: 20 }).notNull(),
  email: varchar("email", { length: 100 }).notNull(),
  profile: text("profile"),
  image: varchar("image", { length: 255 }).default("default.jpg"),
});

export const manager = pgTable("manager", {
  id: serial("id").primaryKey(),
  userId: text("user_id")
    .notNull()
    .unique()
    .references(() => user.id, { onDelete: "cascade" }),
  title: varchar("title", { length: 20 }).notNull(),
  firstName: varchar("first_name", { length: 50 }).notNull(),
  lastName: varchar("last_name", { length: 50 }).notNull(),
  position: varchar("position", { length: 100 }).notNull(),
  phone: varchar("phone", { length: 20 }).notNull(),
  email: varchar("email", { length: 100 }).notNull(),
});

export const classType = pgTable("class_type", {
  id: serial("id").primaryKey(),
  type: classTypeEnum("class_type").notNull(),
  className: varchar("class_name", { length: 100 }).notNull(),
  description: text("description"),
});

export const location = pgTable("location", {
  id: serial("id").primaryKey(),
  poolName: varchar("pool_name", { length: 50 }),
  laneName: varchar("lane_name", { length: 50 }),
  status: locationStatusEnum("status").notNull().default("available"),
});

export const swimmingClass = pgTable("class", {
  id: serial("id").primaryKey(),
  instructorId: integer("instructor_id")
    .notNull()
    .references(() => instructor.id),
  locationId: integer("location_id")
    .notNull()
    .references(() => location.id),
  classTypeId: integer("class_type_id")
    .notNull()
    .references(() => classType.id),
  startTime: timestamp("start_time", { withTimezone: true }).notNull(),
  endTime: timestamp("end_time", { withTimezone: true }).notNull(),
  openSlot: integer("open_slot").notNull(),
  status: classStatusEnum("status").notNull().default("active"),
});

export const booking = pgTable("booking", {
  id: serial("id").primaryKey(),
  memberId: integer("member_id")
    .notNull()
    .references(() => member.id),
  classId: integer("class_id")
    .notNull()
    .references(() => swimmingClass.id),
  createdAt: timestamp("created_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
  status: bookingStatusEnum("status").notNull().default("booked"),
  isAttended: boolean("is_attended").notNull().default(false),
});

export const product = pgTable("product", {
  id: serial("id").primaryKey(),
  name: varchar("product_name", { length: 50 }).notNull(),
  description: varchar("description", { length: 255 }),
  price: decimal("price", { precision: 10, scale: 2 }).notNull(),
});

export const payment = pgTable("payment", {
  id: serial("id").primaryKey(),
  productId: integer("product_id")
    .notNull()
    .references(() => product.id),
  bookingId: integer("booking_id").references(() => booking.id),
  memberId: integer("member_id")
    .notNull()
    .references(() => member.id),
  total: decimal("total", { precision: 10, scale: 2 }).notNull(),
  paidAt: timestamp("paid_at", { withTimezone: true }),
  isPaid: boolean("is_paid").notNull().default(false),
});

export const news = pgTable("news", {
  id: serial("id").primaryKey(),
  authorId: integer("author_id")
    .notNull()
    .references(() => manager.id),
  title: varchar("title", { length: 255 }),
  content: text("content"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});
```

- [ ] **Step 4: Create Drizzle config**

Create `drizzle.config.ts`:
```ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./lib/db/schema.ts",
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

- [ ] **Step 5: Push schema to Neon**

```bash
npx drizzle-kit push
```

Expected: All tables created in Neon. Verify in Neon console that tables `user`, `session`, `account`, `verification`, `member`, `instructor`, `manager`, `class_type`, `location`, `class`, `booking`, `product`, `payment`, `news` exist.

- [ ] **Step 6: Commit**

```bash
git add lib/db/ drizzle.config.ts
git commit -m "feat: add Drizzle ORM schema and Neon database connection"
```

---

## Task 3: Better Auth Configuration

**Files:**
- Create: `lib/auth.ts`, `lib/auth-client.ts`, `app/api/auth/[...all]/route.ts`, `middleware.ts`

- [ ] **Step 1: Create Better Auth server config**

Create `lib/auth.ts`:
```ts
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "./db";
import * as schema from "./db/schema";

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
    schema: {
      user: schema.user,
      session: schema.session,
      account: schema.account,
      verification: schema.verification,
    },
  }),
  emailAndPassword: {
    enabled: true,
  },
  user: {
    additionalFields: {
      role: {
        type: "string",
        defaultValue: "member",
        input: false,
      },
      isActive: {
        type: "boolean",
        defaultValue: true,
        input: false,
      },
    },
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7,
    updateAge: 60 * 60 * 24,
  },
});

export type Session = typeof auth.$Infer.Session;
```

- [ ] **Step 2: Create Better Auth client**

Create `lib/auth-client.ts`:
```ts
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL!,
});
```

- [ ] **Step 3: Create Better Auth API route handler**

Create `app/api/auth/[...all]/route.ts`:
```ts
import { auth } from "@/lib/auth";
import { toNextJsHandler } from "better-auth/next-js";

export const { GET, POST } = toNextJsHandler(auth);
```

- [ ] **Step 4: Create auth middleware**

Create `middleware.ts`:
```ts
import { auth } from "@/lib/auth";
import { NextRequest, NextResponse } from "next/server";
import { headers } from "next/headers";

const protectedPaths = [
  "/dashboard",
  "/booking",
  "/membership",
  "/profile",
  "/attendance",
  "/users",
  "/settings",
  "/reports",
  "/news/manage",
];

const authPaths = ["/login", "/register"];

export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: await headers(),
  });

  const { pathname } = request.nextUrl;

  const isProtected = protectedPaths.some((p) => pathname.startsWith(p));
  if (isProtected && !session) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  const isAuthPage = authPaths.some((p) => pathname === p);
  if (isAuthPage && session) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/dashboard/:path*",
    "/booking/:path*",
    "/membership/:path*",
    "/profile/:path*",
    "/attendance/:path*",
    "/users/:path*",
    "/settings/:path*",
    "/reports/:path*",
    "/news/manage/:path*",
    "/login",
    "/register",
  ],
};
```

- [ ] **Step 5: Create auth helper for Server Components**

Create `lib/auth-utils.ts`:
```ts
import { auth } from "@/lib/auth";
import { headers } from "next/headers";
import { redirect } from "next/navigation";

export async function getSession() {
  const session = await auth.api.getSession({
    headers: await headers(),
  });
  return session;
}

export async function requireSession() {
  const session = await getSession();
  if (!session) redirect("/login");
  return session;
}

export async function requireRole(roles: string[]) {
  const session = await requireSession();
  if (!roles.includes(session.user.role as string)) {
    redirect("/dashboard");
  }
  return session;
}
```

- [ ] **Step 6: Verify auth API endpoint works**

```bash
npm run dev
```

Visit `http://localhost:3000/api/auth/ok` — should return a JSON response confirming Better Auth is active.

- [ ] **Step 7: Commit**

```bash
git add lib/auth.ts lib/auth-client.ts lib/auth-utils.ts app/api/auth/ middleware.ts
git commit -m "feat: configure Better Auth with role-based access control"
```

---

## Task 4: Utility Functions

**Files:**
- Create: `lib/utils.ts`

- [ ] **Step 1: Create shared utilities**

Create `lib/utils.ts` (shadcn/ui may have already created this with `cn`; extend it):
```ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: Date | string): string {
  return new Date(date).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

export function formatTime(date: Date | string): string {
  return new Date(date).toLocaleTimeString("en-GB", {
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function formatDateTime(date: Date | string): string {
  return `${formatDate(date)} ${formatTime(date)}`;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/utils.ts
git commit -m "feat: add shared utility functions"
```

---

## Task 5: Auth Pages (Login & Register)

**Files:**
- Create: `app/(auth)/layout.tsx`, `app/(auth)/login/page.tsx`, `app/(auth)/register/page.tsx`

- [ ] **Step 1: Create auth layout**

Create `app/(auth)/layout.tsx`:
```tsx
export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/50 p-4">
      <div className="w-full max-w-md">{children}</div>
    </div>
  );
}
```

- [ ] **Step 2: Create login page**

Create `app/(auth)/login/page.tsx`:
```tsx
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { authClient } from "@/lib/auth-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { toast } from "sonner";

export default function LoginPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    const formData = new FormData(e.currentTarget);

    const { error } = await authClient.signIn.email({
      email: formData.get("email") as string,
      password: formData.get("password") as string,
    });

    if (error) {
      toast.error(error.message ?? "Login failed");
      setLoading(false);
      return;
    }

    router.push("/dashboard");
    router.refresh();
  }

  return (
    <Card>
      <CardHeader className="text-center">
        <CardTitle className="text-2xl">Welcome Back</CardTitle>
        <CardDescription>
          Sign in to your swimming club account
        </CardDescription>
      </CardHeader>
      <form onSubmit={handleSubmit}>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              name="email"
              type="email"
              placeholder="you@example.com"
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              name="password"
              type="password"
              required
            />
          </div>
        </CardContent>
        <CardFooter className="flex flex-col gap-4">
          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? "Signing in..." : "Sign In"}
          </Button>
          <p className="text-sm text-muted-foreground">
            Don&apos;t have an account?{" "}
            <Link href="/register" className="text-primary underline">
              Register
            </Link>
          </p>
        </CardFooter>
      </form>
    </Card>
  );
}
```

- [ ] **Step 3: Create register page**

Create `app/(auth)/register/page.tsx`:
```tsx
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { authClient } from "@/lib/auth-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { toast } from "sonner";

export default function RegisterPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    const formData = new FormData(e.currentTarget);
    const password = formData.get("password") as string;
    const confirmPassword = formData.get("confirmPassword") as string;

    if (password !== confirmPassword) {
      toast.error("Passwords do not match");
      setLoading(false);
      return;
    }

    const { error } = await authClient.signUp.email({
      email: formData.get("email") as string,
      password,
      name: `${formData.get("firstName")} ${formData.get("lastName")}`,
    });

    if (error) {
      toast.error(error.message ?? "Registration failed");
      setLoading(false);
      return;
    }

    toast.success("Account created! Redirecting...");
    router.push("/dashboard");
    router.refresh();
  }

  return (
    <Card>
      <CardHeader className="text-center">
        <CardTitle className="text-2xl">Create Account</CardTitle>
        <CardDescription>
          Join the Countryside Community Swimming Club
        </CardDescription>
      </CardHeader>
      <form onSubmit={handleSubmit}>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="firstName">First Name</Label>
              <Input id="firstName" name="firstName" required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="lastName">Last Name</Label>
              <Input id="lastName" name="lastName" required />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              name="email"
              type="email"
              placeholder="you@example.com"
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              name="password"
              type="password"
              minLength={8}
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="confirmPassword">Confirm Password</Label>
            <Input
              id="confirmPassword"
              name="confirmPassword"
              type="password"
              minLength={8}
              required
            />
          </div>
        </CardContent>
        <CardFooter className="flex flex-col gap-4">
          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? "Creating account..." : "Create Account"}
          </Button>
          <p className="text-sm text-muted-foreground">
            Already have an account?{" "}
            <Link href="/login" className="text-primary underline">
              Sign in
            </Link>
          </p>
        </CardFooter>
      </form>
    </Card>
  );
}
```

- [ ] **Step 4: Verify login and register pages render**

```bash
npm run dev
```

Visit `http://localhost:3000/login` and `http://localhost:3000/register`. Both should render styled card forms.

- [ ] **Step 5: Commit**

```bash
git add app/(auth)/
git commit -m "feat: add login and register pages with Better Auth"
```

---

## Task 6: Root Layout and Providers

**Files:**
- Create: `components/providers.tsx`
- Modify: `app/layout.tsx`

- [ ] **Step 1: Create providers component**

Create `components/providers.tsx`:
```tsx
"use client";

import { ThemeProvider } from "next-themes";
import { Toaster } from "sonner";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      {children}
      <Toaster richColors position="top-right" />
    </ThemeProvider>
  );
}
```

- [ ] **Step 2: Update root layout**

Modify `app/layout.tsx`:
```tsx
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { Providers } from "@/components/providers";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Countryside Community Swimming Club",
  description: "Swimming club management system",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add components/providers.tsx app/layout.tsx
git commit -m "feat: add root layout with theme and toast providers"
```

---

## Task 7: Dashboard Layout (Sidebar + Topbar)

**Files:**
- Create: `app/(dashboard)/layout.tsx`, `components/sidebar.tsx`, `components/topbar.tsx`

- [ ] **Step 1: Create sidebar component**

Create `components/sidebar.tsx`:
```tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  Calendar,
  ClipboardList,
  CreditCard,
  Users,
  UserCog,
  Settings,
  BarChart3,
  Newspaper,
  User,
  LayoutDashboard,
  MapPin,
  Tag,
  DollarSign,
  CheckSquare,
} from "lucide-react";

interface NavItem {
  label: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  roles: string[];
}

const navItems: NavItem[] = [
  {
    label: "Dashboard",
    href: "/dashboard",
    icon: LayoutDashboard,
    roles: ["member", "instructor", "manager"],
  },
  {
    label: "Timetable",
    href: "/timetable",
    icon: Calendar,
    roles: ["member", "instructor", "manager"],
  },
  {
    label: "My Bookings",
    href: "/booking",
    icon: ClipboardList,
    roles: ["member"],
  },
  {
    label: "Membership",
    href: "/membership",
    icon: CreditCard,
    roles: ["member"],
  },
  {
    label: "Attendance",
    href: "/attendance",
    icon: CheckSquare,
    roles: ["instructor", "manager"],
  },
  {
    label: "Members",
    href: "/users/members",
    icon: Users,
    roles: ["manager"],
  },
  {
    label: "Instructors",
    href: "/users/instructors",
    icon: UserCog,
    roles: ["manager"],
  },
  {
    label: "Class Types",
    href: "/settings/class-types",
    icon: Tag,
    roles: ["manager"],
  },
  {
    label: "Locations",
    href: "/settings/locations",
    icon: MapPin,
    roles: ["manager"],
  },
  {
    label: "Pricing",
    href: "/settings/pricing",
    icon: DollarSign,
    roles: ["manager"],
  },
  {
    label: "Reports",
    href: "/reports",
    icon: BarChart3,
    roles: ["manager"],
  },
  {
    label: "News",
    href: "/news/manage",
    icon: Newspaper,
    roles: ["manager"],
  },
  {
    label: "Profile",
    href: "/profile",
    icon: User,
    roles: ["member", "instructor", "manager"],
  },
];

export function Sidebar({ userRole }: { userRole: string }) {
  const pathname = usePathname();
  const filteredItems = navItems.filter((item) =>
    item.roles.includes(userRole)
  );

  return (
    <aside className="hidden md:flex h-screen w-[220px] flex-col border-r bg-card">
      <div className="flex h-14 items-center border-b px-4">
        <Link href="/dashboard" className="flex items-center gap-2">
          <span className="text-lg font-bold text-primary">SCMS</span>
        </Link>
      </div>
      <nav className="flex-1 overflow-y-auto p-3 space-y-1">
        {filteredItems.map((item) => {
          const isActive =
            pathname === item.href ||
            (item.href !== "/dashboard" && pathname.startsWith(item.href));
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
                isActive
                  ? "bg-primary/10 text-primary font-medium"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground"
              )}
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
```

- [ ] **Step 2: Create topbar component**

Create `components/topbar.tsx`:
```tsx
"use client";

import { useRouter } from "next/navigation";
import { authClient } from "@/lib/auth-client";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { LogOut, Menu } from "lucide-react";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Sidebar } from "./sidebar";

interface TopbarProps {
  userName: string;
  userRole: string;
}

export function Topbar({ userName, userRole }: TopbarProps) {
  const router = useRouter();
  const initials = userName
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  async function handleLogout() {
    await authClient.signOut();
    router.push("/login");
    router.refresh();
  }

  return (
    <header className="flex h-14 items-center justify-between border-b bg-card px-4 md:px-6">
      <div className="flex items-center gap-2">
        <Sheet>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon" className="md:hidden">
              <Menu className="h-5 w-5" />
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="w-[220px] p-0">
            <Sidebar userRole={userRole} />
          </SheetContent>
        </Sheet>
      </div>
      <div className="flex items-center gap-3">
        <span className="hidden text-sm text-muted-foreground sm:inline">
          {userName}
        </span>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="rounded-full">
              <Avatar className="h-8 w-8">
                <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                  {initials}
                </AvatarFallback>
              </Avatar>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={handleLogout}>
              <LogOut className="mr-2 h-4 w-4" />
              Sign Out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
```

- [ ] **Step 3: Create dashboard layout**

Create `app/(dashboard)/layout.tsx`:
```tsx
import { requireSession } from "@/lib/auth-utils";
import { Sidebar } from "@/components/sidebar";
import { Topbar } from "@/components/topbar";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await requireSession();
  const userRole = (session.user.role as string) ?? "member";
  const userName = session.user.name ?? "User";

  return (
    <div className="flex h-screen">
      <Sidebar userRole={userRole} />
      <div className="flex flex-1 flex-col overflow-hidden">
        <Topbar userName={userName} userRole={userRole} />
        <main className="flex-1 overflow-y-auto p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
```

- [ ] **Step 4: Create dashboard home page**

Create `app/(dashboard)/dashboard/page.tsx`:
```tsx
import { requireSession } from "@/lib/auth-utils";

export default async function DashboardPage() {
  const session = await requireSession();
  const role = session.user.role as string;

  return (
    <div>
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
      <p className="text-muted-foreground">
        Welcome back, {session.user.name}. You are logged in as{" "}
        <span className="font-medium capitalize">{role}</span>.
      </p>
    </div>
  );
}
```

- [ ] **Step 5: Verify dashboard layout renders after login**

```bash
npm run dev
```

Register a new user at `/register`, then verify redirect to `/dashboard` with sidebar and topbar visible.

- [ ] **Step 6: Commit**

```bash
git add components/sidebar.tsx components/topbar.tsx app/(dashboard)/
git commit -m "feat: add dashboard layout with role-based sidebar navigation"
```

---

## Task 8: Public Layout and Home Page

**Files:**
- Create: `app/(public)/layout.tsx`, `app/(public)/page.tsx`, `components/public-navbar.tsx`, `components/public-footer.tsx`

- [ ] **Step 1: Create public navbar**

Create `components/public-navbar.tsx`:
```tsx
import Link from "next/link";
import { Button } from "@/components/ui/button";

export function PublicNavbar() {
  return (
    <nav className="border-b bg-card">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <Link href="/" className="text-xl font-bold text-primary">
          Countryside Swimming Club
        </Link>
        <div className="flex items-center gap-6">
          <Link
            href="/timetable"
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            Timetable
          </Link>
          <Link
            href="/courses"
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            Courses
          </Link>
          <Link
            href="/instructors"
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            Instructors
          </Link>
          <Link
            href="/news"
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            News
          </Link>
          <Button asChild size="sm">
            <Link href="/login">Sign In</Link>
          </Button>
        </div>
      </div>
    </nav>
  );
}
```

- [ ] **Step 2: Create public footer**

Create `components/public-footer.tsx`:
```tsx
export function PublicFooter() {
  return (
    <footer className="border-t bg-card py-8">
      <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
        <p>&copy; {new Date().getFullYear()} Countryside Community Swimming Club. All rights reserved.</p>
      </div>
    </footer>
  );
}
```

- [ ] **Step 3: Create public layout**

Create `app/(public)/layout.tsx`:
```tsx
import { PublicNavbar } from "@/components/public-navbar";
import { PublicFooter } from "@/components/public-footer";

export default function PublicLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="flex-1">{children}</main>
      <PublicFooter />
    </div>
  );
}
```

- [ ] **Step 4: Create home page**

Create `app/(public)/page.tsx`:
```tsx
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Calendar, Users, Award } from "lucide-react";

export default function HomePage() {
  return (
    <div>
      {/* Hero Section */}
      <section className="bg-primary/5 py-20">
        <div className="container mx-auto px-4 text-center">
          <h1 className="text-4xl font-bold tracking-tight md:text-5xl">
            Countryside Community
            <br />
            <span className="text-primary">Swimming Club</span>
          </h1>
          <p className="mt-4 text-lg text-muted-foreground max-w-2xl mx-auto">
            Join our community and enjoy swimming lessons, group sessions, and
            private coaching for all skill levels.
          </p>
          <div className="mt-8 flex gap-4 justify-center">
            <Button asChild size="lg">
              <Link href="/register">Join Now</Link>
            </Button>
            <Button asChild variant="outline" size="lg">
              <Link href="/timetable">View Timetable</Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-3 gap-8">
            <Card>
              <CardContent className="pt-6 text-center">
                <Calendar className="h-10 w-10 mx-auto text-primary mb-4" />
                <h3 className="font-semibold text-lg mb-2">
                  Flexible Schedule
                </h3>
                <p className="text-sm text-muted-foreground">
                  Book classes that fit your timetable. Morning, afternoon, and
                  evening sessions available.
                </p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6 text-center">
                <Users className="h-10 w-10 mx-auto text-primary mb-4" />
                <h3 className="font-semibold text-lg mb-2">
                  Expert Instructors
                </h3>
                <p className="text-sm text-muted-foreground">
                  Learn from certified swimming instructors with years of
                  experience in competitive and recreational swimming.
                </p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6 text-center">
                <Award className="h-10 w-10 mx-auto text-primary mb-4" />
                <h3 className="font-semibold text-lg mb-2">All Levels</h3>
                <p className="text-sm text-muted-foreground">
                  From beginners to advanced swimmers. Group classes, 1-on-1
                  lessons, and training sessions.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>
    </div>
  );
}
```

- [ ] **Step 5: Update root `app/page.tsx` to redirect to public home**

Modify `app/page.tsx`:
```tsx
import { redirect } from "next/navigation";

export default function RootPage() {
  redirect("/");
}
```

Note: The `(public)/page.tsx` handles the `/` route since route groups are transparent. Delete the root `app/page.tsx` if it conflicts, or keep the `(public)/page.tsx` as the home page.

- [ ] **Step 6: Verify public pages render**

```bash
npm run dev
```

Visit `http://localhost:3000` — should show the landing page with navbar, hero, and features.

- [ ] **Step 7: Commit**

```bash
git add components/public-navbar.tsx components/public-footer.tsx app/(public)/
git commit -m "feat: add public layout with home page"
```

---

## Task 9: FullCalendar Component and Class Queries

**Files:**
- Create: `components/calendar.tsx`, `lib/db/queries/class-queries.ts`

- [ ] **Step 1: Create class query functions**

Create `lib/db/queries/class-queries.ts`:
```ts
import { db } from "@/lib/db";
import {
  swimmingClass,
  classType,
  instructor,
  location,
} from "@/lib/db/schema";
import { and, eq, gte, lte, ne, not, or } from "drizzle-orm";

const CLASS_TYPE_COLORS: Record<string, string> = {
  class: "#3b82f6",
  "1-on-1": "#facc15",
  group: "#a78bfa",
};

export interface CalendarEvent {
  id: string;
  title: string;
  start: string;
  end: string;
  color: string;
  extendedProps: {
    classId: number;
    instructorName: string;
    locationName: string;
    openSlots: number;
    classType: string;
    status: string;
  };
}

export async function getClassesForCalendar(
  startDate: Date,
  endDate: Date
): Promise<CalendarEvent[]> {
  const classes = await db
    .select({
      id: swimmingClass.id,
      startTime: swimmingClass.startTime,
      endTime: swimmingClass.endTime,
      openSlot: swimmingClass.openSlot,
      status: swimmingClass.status,
      className: classType.className,
      type: classType.type,
      instructorFirstName: instructor.firstName,
      instructorLastName: instructor.lastName,
      poolName: location.poolName,
      laneName: location.laneName,
    })
    .from(swimmingClass)
    .innerJoin(classType, eq(swimmingClass.classTypeId, classType.id))
    .innerJoin(instructor, eq(swimmingClass.instructorId, instructor.id))
    .innerJoin(location, eq(swimmingClass.locationId, location.id))
    .where(
      and(
        gte(swimmingClass.startTime, startDate),
        lte(swimmingClass.startTime, endDate),
        eq(swimmingClass.status, "active")
      )
    );

  return classes.map((c) => ({
    id: String(c.id),
    title: c.className,
    start: c.startTime.toISOString(),
    end: c.endTime.toISOString(),
    color: CLASS_TYPE_COLORS[c.type] ?? "#3b82f6",
    extendedProps: {
      classId: c.id,
      instructorName: `${c.instructorFirstName} ${c.instructorLastName}`,
      locationName: `${c.poolName ?? ""} ${c.laneName ?? ""}`.trim(),
      openSlots: c.openSlot,
      classType: c.type,
      status: c.status,
    },
  }));
}

export async function checkForOverlap(
  locationId: number,
  startTime: Date,
  endTime: Date,
  instructorId: number,
  excludeClassId?: number
): Promise<string | null> {
  const excludeId = excludeClassId ?? -1;

  const locationConflict = await db
    .select()
    .from(swimmingClass)
    .where(
      and(
        ne(swimmingClass.id, excludeId),
        eq(swimmingClass.locationId, locationId),
        eq(swimmingClass.status, "active"),
        not(
          or(
            lte(swimmingClass.endTime, startTime),
            gte(swimmingClass.startTime, endTime)
          )!
        )
      )
    )
    .limit(1);

  if (locationConflict.length > 0) {
    return "Location conflict: another class is scheduled at this location during this time.";
  }

  const instructorConflict = await db
    .select()
    .from(swimmingClass)
    .where(
      and(
        ne(swimmingClass.id, excludeId),
        eq(swimmingClass.instructorId, instructorId),
        eq(swimmingClass.status, "active"),
        not(
          or(
            lte(swimmingClass.endTime, startTime),
            gte(swimmingClass.startTime, endTime)
          )!
        )
      )
    )
    .limit(1);

  if (instructorConflict.length > 0) {
    return "Instructor conflict: this instructor is already teaching another class during this time.";
  }

  return null;
}
```

- [ ] **Step 2: Create FullCalendar wrapper component**

Create `components/calendar.tsx`:
```tsx
"use client";

import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import timeGridPlugin from "@fullcalendar/timegrid";
import interactionPlugin from "@fullcalendar/interaction";
import type { EventClickArg } from "@fullcalendar/core";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface SwimmingCalendarProps {
  events: CalendarEvent[];
  onEventClick?: (classId: number) => void;
  interactive?: boolean;
}

export function SwimmingCalendar({
  events,
  onEventClick,
  interactive = false,
}: SwimmingCalendarProps) {
  function handleEventClick(info: EventClickArg) {
    if (onEventClick) {
      onEventClick(info.event.extendedProps.classId);
    }
  }

  return (
    <FullCalendar
      plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin]}
      initialView="timeGridWeek"
      headerToolbar={{
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay",
      }}
      events={events}
      eventClick={interactive ? handleEventClick : undefined}
      selectable={false}
      editable={false}
      slotMinTime="06:00:00"
      slotMaxTime="22:00:00"
      allDaySlot={false}
      height="auto"
      eventContent={(arg) => (
        <div className="p-1 text-xs">
          <div className="font-medium">{arg.event.title}</div>
          <div className="opacity-75">
            {arg.event.extendedProps.instructorName}
          </div>
          <div className="opacity-75">
            {arg.event.extendedProps.locationName} &middot;{" "}
            {arg.event.extendedProps.openSlots} slots
          </div>
        </div>
      )}
    />
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add components/calendar.tsx lib/db/queries/class-queries.ts
git commit -m "feat: add FullCalendar component and class query functions"
```

---

## Task 10: Public Timetable Page

**Files:**
- Create: `app/(public)/timetable/page.tsx`

- [ ] **Step 1: Create public timetable page**

Create `app/(public)/timetable/page.tsx`:
```tsx
import { getClassesForCalendar } from "@/lib/db/queries/class-queries";
import { SwimmingCalendar } from "@/components/calendar";

export default async function PublicTimetablePage() {
  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0);
  const events = await getClassesForCalendar(start, end);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Class Timetable</h1>
      <p className="text-muted-foreground mb-6">
        Browse our upcoming swimming classes. Sign in to book a spot.
      </p>
      <SwimmingCalendar events={events} />
    </div>
  );
}
```

- [ ] **Step 2: Verify public timetable renders**

```bash
npm run dev
```

Visit `http://localhost:3000/timetable` — should show FullCalendar with week view (empty if no data yet).

- [ ] **Step 3: Commit**

```bash
git add app/(public)/timetable/
git commit -m "feat: add public timetable page with FullCalendar"
```

---

## Task 11: Booking System (Queries + Server Actions)

**Files:**
- Create: `lib/db/queries/booking-queries.ts`, `lib/actions/booking-actions.ts`, `lib/validations/booking-schema.ts`

- [ ] **Step 1: Create booking queries**

Create `lib/db/queries/booking-queries.ts`:
```ts
import { db } from "@/lib/db";
import {
  booking,
  swimmingClass,
  classType,
  instructor,
  location,
  member,
} from "@/lib/db/schema";
import { and, eq, gte, desc } from "drizzle-orm";

export async function getMemberBookings(memberId: number) {
  return db
    .select({
      bookingId: booking.id,
      classId: booking.classId,
      createdAt: booking.createdAt,
      status: booking.status,
      isAttended: booking.isAttended,
      className: classType.className,
      classTypeName: classType.type,
      startTime: swimmingClass.startTime,
      endTime: swimmingClass.endTime,
      instructorFirstName: instructor.firstName,
      instructorLastName: instructor.lastName,
      poolName: location.poolName,
      laneName: location.laneName,
    })
    .from(booking)
    .innerJoin(swimmingClass, eq(booking.classId, swimmingClass.id))
    .innerJoin(classType, eq(swimmingClass.classTypeId, classType.id))
    .innerJoin(instructor, eq(swimmingClass.instructorId, instructor.id))
    .innerJoin(location, eq(swimmingClass.locationId, location.id))
    .where(
      and(
        eq(booking.memberId, memberId),
        eq(booking.status, "booked"),
        gte(swimmingClass.startTime, new Date())
      )
    )
    .orderBy(swimmingClass.startTime);
}

export async function getMemberIdByUserId(userId: string) {
  const [m] = await db
    .select({ id: member.id })
    .from(member)
    .where(eq(member.userId, userId));
  return m?.id;
}

export async function isClassBookedByMember(
  memberId: number,
  classId: number
): Promise<boolean> {
  const [existing] = await db
    .select()
    .from(booking)
    .where(
      and(
        eq(booking.memberId, memberId),
        eq(booking.classId, classId),
        eq(booking.status, "booked")
      )
    )
    .limit(1);
  return !!existing;
}

export async function getClassAttendance(classId: number) {
  return db
    .select({
      bookingId: booking.id,
      memberId: booking.memberId,
      isAttended: booking.isAttended,
      firstName: member.firstName,
      lastName: member.lastName,
      email: member.email,
    })
    .from(booking)
    .innerJoin(member, eq(booking.memberId, member.id))
    .where(
      and(eq(booking.classId, classId), eq(booking.status, "booked"))
    );
}
```

- [ ] **Step 2: Create booking server actions**

Create `lib/actions/booking-actions.ts`:
```ts
"use server";

import { dbPool } from "@/lib/db/transaction";
import { booking, swimmingClass } from "@/lib/db/schema";
import { and, eq, gt, sql } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireSession } from "@/lib/auth-utils";
import { getMemberIdByUserId } from "@/lib/db/queries/booking-queries";

export async function bookClass(classId: number) {
  const session = await requireSession();
  const memberId = await getMemberIdByUserId(session.user.id);
  if (!memberId) return { error: "Member profile not found" };

  try {
    await dbPool.transaction(async (tx) => {
      const [updatedClass] = await tx
        .update(swimmingClass)
        .set({ openSlot: sql`${swimmingClass.openSlot} - 1` })
        .where(
          and(
            eq(swimmingClass.id, classId),
            gt(swimmingClass.openSlot, 0),
            eq(swimmingClass.status, "active")
          )
        )
        .returning();

      if (!updatedClass) throw new Error("No available slots");

      await tx.insert(booking).values({
        memberId,
        classId,
        status: "booked",
        isAttended: false,
      });
    });

    revalidatePath("/timetable");
    revalidatePath("/booking");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Booking failed" };
  }
}

export async function cancelBooking(bookingId: number, classId: number) {
  const session = await requireSession();
  const memberId = await getMemberIdByUserId(session.user.id);
  if (!memberId) return { error: "Member profile not found" };

  try {
    await dbPool.transaction(async (tx) => {
      const [cancelled] = await tx
        .update(booking)
        .set({ status: "cancelled" })
        .where(
          and(
            eq(booking.id, bookingId),
            eq(booking.memberId, memberId),
            eq(booking.status, "booked")
          )
        )
        .returning();

      if (!cancelled) throw new Error("Booking not found");

      await tx
        .update(swimmingClass)
        .set({ openSlot: sql`${swimmingClass.openSlot} + 1` })
        .where(eq(swimmingClass.id, classId));
    });

    revalidatePath("/timetable");
    revalidatePath("/booking");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Cancellation failed" };
  }
}

export async function markAttendance(
  memberId: number,
  classId: number,
  attended: boolean
) {
  await requireSession();

  await dbPool
    .update(booking)
    .set({ isAttended: attended })
    .where(
      and(eq(booking.memberId, memberId), eq(booking.classId, classId))
    );

  revalidatePath(`/attendance/${classId}`);
  return { success: true };
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/db/queries/booking-queries.ts lib/actions/booking-actions.ts
git commit -m "feat: add booking queries and server actions with transaction support"
```

---

## Task 12: Dashboard Timetable with Booking

**Files:**
- Create: `app/(dashboard)/timetable/page.tsx`, `components/class-detail-dialog.tsx`

- [ ] **Step 1: Create class detail dialog**

Create `components/class-detail-dialog.tsx`:
```tsx
"use client";

import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { bookClass, cancelBooking } from "@/lib/actions/booking-actions";
import { toast } from "sonner";
import { formatDateTime } from "@/lib/utils";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface ClassDetailDialogProps {
  event: CalendarEvent | null;
  open: boolean;
  onClose: () => void;
  isBooked?: boolean;
  bookingId?: number;
  isMember: boolean;
}

export function ClassDetailDialog({
  event,
  open,
  onClose,
  isBooked,
  bookingId,
  isMember,
}: ClassDetailDialogProps) {
  const [loading, setLoading] = useState(false);

  if (!event) return null;
  const props = event.extendedProps;

  async function handleBook() {
    setLoading(true);
    const result = await bookClass(props.classId);
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Class booked successfully!");
      onClose();
    }
    setLoading(false);
  }

  async function handleCancel() {
    if (!bookingId) return;
    setLoading(true);
    const result = await cancelBooking(bookingId, props.classId);
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Booking cancelled");
      onClose();
    }
    setLoading(false);
  }

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{event.title}</DialogTitle>
        </DialogHeader>
        <div className="space-y-3 text-sm">
          <div className="flex justify-between">
            <span className="text-muted-foreground">Type</span>
            <Badge variant="outline">{props.classType}</Badge>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Time</span>
            <span>{formatDateTime(event.start)} - {formatDateTime(event.end)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Instructor</span>
            <span>{props.instructorName}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Location</span>
            <span>{props.locationName}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Available Slots</span>
            <span>{props.openSlots}</span>
          </div>
        </div>
        {isMember && (
          <div className="mt-4">
            {isBooked ? (
              <Button
                variant="destructive"
                className="w-full"
                onClick={handleCancel}
                disabled={loading}
              >
                {loading ? "Cancelling..." : "Cancel Booking"}
              </Button>
            ) : props.openSlots > 0 ? (
              <Button
                className="w-full"
                onClick={handleBook}
                disabled={loading}
              >
                {loading ? "Booking..." : "Book This Class"}
              </Button>
            ) : (
              <Button className="w-full" disabled>
                Class Full
              </Button>
            )}
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
```

- [ ] **Step 2: Create dashboard timetable page**

Create `app/(dashboard)/timetable/page.tsx`:
```tsx
import { requireSession } from "@/lib/auth-utils";
import { getClassesForCalendar } from "@/lib/db/queries/class-queries";
import {
  getMemberIdByUserId,
  getMemberBookings,
} from "@/lib/db/queries/booking-queries";
import { TimetableClient } from "./timetable-client";

export default async function DashboardTimetablePage() {
  const session = await requireSession();
  const role = session.user.role as string;

  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0);
  const events = await getClassesForCalendar(start, end);

  let memberBookings: { classId: number; bookingId: number }[] = [];
  if (role === "member") {
    const memberId = await getMemberIdByUserId(session.user.id);
    if (memberId) {
      const bookings = await getMemberBookings(memberId);
      memberBookings = bookings.map((b) => ({
        classId: b.classId,
        bookingId: b.bookingId,
      }));
    }
  }

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Timetable</h1>
      <TimetableClient
        events={events}
        isMember={role === "member"}
        memberBookings={memberBookings}
      />
    </div>
  );
}
```

- [ ] **Step 3: Create timetable client component**

Create `app/(dashboard)/timetable/timetable-client.tsx`:
```tsx
"use client";

import { useState } from "react";
import { SwimmingCalendar } from "@/components/calendar";
import { ClassDetailDialog } from "@/components/class-detail-dialog";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface TimetableClientProps {
  events: CalendarEvent[];
  isMember: boolean;
  memberBookings: { classId: number; bookingId: number }[];
}

export function TimetableClient({
  events,
  isMember,
  memberBookings,
}: TimetableClientProps) {
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(
    null
  );

  function handleEventClick(classId: number) {
    const event = events.find((e) => e.extendedProps.classId === classId);
    if (event) setSelectedEvent(event);
  }

  const bookedClassId = selectedEvent?.extendedProps.classId;
  const bookingInfo = memberBookings.find((b) => b.classId === bookedClassId);

  return (
    <>
      <SwimmingCalendar
        events={events}
        onEventClick={handleEventClick}
        interactive
      />
      <ClassDetailDialog
        event={selectedEvent}
        open={!!selectedEvent}
        onClose={() => setSelectedEvent(null)}
        isMember={isMember}
        isBooked={!!bookingInfo}
        bookingId={bookingInfo?.bookingId}
      />
    </>
  );
}
```

- [ ] **Step 4: Verify timetable renders in dashboard**

```bash
npm run dev
```

Login and visit `/timetable` in the dashboard. The FullCalendar should render.

- [ ] **Step 5: Commit**

```bash
git add app/(dashboard)/timetable/ components/class-detail-dialog.tsx
git commit -m "feat: add dashboard timetable with booking dialog"
```

---

## Task 13: Member Bookings Page

**Files:**
- Create: `app/(dashboard)/booking/page.tsx`

- [ ] **Step 1: Create bookings page**

Create `app/(dashboard)/booking/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import {
  getMemberIdByUserId,
  getMemberBookings,
} from "@/lib/db/queries/booking-queries";
import { cancelBooking } from "@/lib/actions/booking-actions";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { formatDate, formatTime } from "@/lib/utils";
import { CancelBookingButton } from "./cancel-button";

export default async function BookingPage() {
  const session = await requireRole(["member"]);
  const memberId = await getMemberIdByUserId(session.user.id);

  if (!memberId) {
    return (
      <div>
        <h1 className="text-2xl font-bold mb-4">My Bookings</h1>
        <p className="text-muted-foreground">
          No member profile found. Please contact a manager.
        </p>
      </div>
    );
  }

  const bookings = await getMemberBookings(memberId);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">My Bookings</h1>
      {bookings.length === 0 ? (
        <p className="text-muted-foreground">
          No upcoming bookings. Visit the timetable to book a class.
        </p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Class</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Time</TableHead>
              <TableHead>Instructor</TableHead>
              <TableHead>Location</TableHead>
              <TableHead>Type</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {bookings.map((b) => (
              <TableRow key={b.bookingId}>
                <TableCell className="font-medium">{b.className}</TableCell>
                <TableCell>{formatDate(b.startTime)}</TableCell>
                <TableCell>
                  {formatTime(b.startTime)} - {formatTime(b.endTime)}
                </TableCell>
                <TableCell>
                  {b.instructorFirstName} {b.instructorLastName}
                </TableCell>
                <TableCell>
                  {b.poolName} {b.laneName}
                </TableCell>
                <TableCell>
                  <Badge variant="outline">{b.classTypeName}</Badge>
                </TableCell>
                <TableCell>
                  <CancelBookingButton
                    bookingId={b.bookingId}
                    classId={b.classId}
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Create cancel booking button**

Create `app/(dashboard)/booking/cancel-button.tsx`:
```tsx
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { cancelBooking } from "@/lib/actions/booking-actions";
import { toast } from "sonner";

export function CancelBookingButton({
  bookingId,
  classId,
}: {
  bookingId: number;
  classId: number;
}) {
  const [loading, setLoading] = useState(false);

  async function handleCancel() {
    setLoading(true);
    const result = await cancelBooking(bookingId, classId);
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Booking cancelled");
    }
    setLoading(false);
  }

  return (
    <Button
      variant="destructive"
      size="sm"
      onClick={handleCancel}
      disabled={loading}
    >
      {loading ? "..." : "Cancel"}
    </Button>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add app/(dashboard)/booking/
git commit -m "feat: add member bookings page with cancel functionality"
```

---

## Task 14: Membership and Payment

**Files:**
- Create: `lib/db/queries/membership-queries.ts`, `lib/actions/membership-actions.ts`, `app/(dashboard)/membership/page.tsx`

- [ ] **Step 1: Create membership queries**

Create `lib/db/queries/membership-queries.ts`:
```ts
import { db } from "@/lib/db";
import { member, product, payment } from "@/lib/db/schema";
import { eq, desc } from "drizzle-orm";

export async function getMemberProfile(memberId: number) {
  const [m] = await db.select().from(member).where(eq(member.id, memberId));
  return m;
}

export async function getAllProducts() {
  return db.select().from(product);
}

export async function getMemberPayments(memberId: number) {
  return db
    .select({
      id: payment.id,
      total: payment.total,
      paidAt: payment.paidAt,
      isPaid: payment.isPaid,
      productName: product.name,
    })
    .from(payment)
    .innerJoin(product, eq(payment.productId, product.id))
    .where(eq(payment.memberId, memberId))
    .orderBy(desc(payment.paidAt));
}
```

- [ ] **Step 2: Create membership server actions**

Create `lib/actions/membership-actions.ts`:
```ts
"use server";

import { dbPool } from "@/lib/db/transaction";
import { member, payment, product } from "@/lib/db/schema";
import { eq, sql } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireSession } from "@/lib/auth-utils";
import { getMemberIdByUserId } from "@/lib/db/queries/booking-queries";

export async function subscribe(productId: number) {
  const session = await requireSession();
  const memberId = await getMemberIdByUserId(session.user.id);
  if (!memberId) return { error: "Member profile not found" };

  try {
    await dbPool.transaction(async (tx) => {
      const [prod] = await tx
        .select()
        .from(product)
        .where(eq(product.id, productId));

      if (!prod) throw new Error("Product not found");

      const days = prod.name.toLowerCase().includes("annual") ? 365 : 30;
      const membershipType = days === 365 ? "Annual" : "Monthly";

      await tx.insert(payment).values({
        productId,
        memberId,
        total: prod.price,
        paidAt: new Date(),
        isPaid: true,
      });

      await tx
        .update(member)
        .set({
          expiredDate: sql`(COALESCE(${member.expiredDate}::date, CURRENT_DATE) + ${days} * INTERVAL '1 day')::date`,
          isSubscription: true,
          membershipType,
        })
        .where(eq(member.id, memberId));
    });

    revalidatePath("/membership");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Subscription failed" };
  }
}

export async function cancelSubscription() {
  const session = await requireSession();
  const memberId = await getMemberIdByUserId(session.user.id);
  if (!memberId) return { error: "Member profile not found" };

  await dbPool
    .update(member)
    .set({
      isSubscription: false,
      membershipType: "None",
    })
    .where(eq(member.id, memberId));

  revalidatePath("/membership");
  return { success: true };
}
```

- [ ] **Step 3: Create membership page**

Create `app/(dashboard)/membership/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import { getMemberIdByUserId } from "@/lib/db/queries/booking-queries";
import {
  getMemberProfile,
  getAllProducts,
  getMemberPayments,
} from "@/lib/db/queries/membership-queries";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { formatDate } from "@/lib/utils";
import { MembershipActions } from "./membership-actions-client";

export default async function MembershipPage() {
  const session = await requireRole(["member"]);
  const memberId = await getMemberIdByUserId(session.user.id);

  if (!memberId) {
    return (
      <div>
        <h1 className="text-2xl font-bold mb-4">Membership</h1>
        <p className="text-muted-foreground">No member profile found.</p>
      </div>
    );
  }

  const [profile, products, payments] = await Promise.all([
    getMemberProfile(memberId),
    getAllProducts(),
    getMemberPayments(memberId),
  ]);

  const isActive =
    profile?.isSubscription &&
    profile?.expiredDate &&
    new Date(profile.expiredDate) >= new Date();

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Membership</h1>

      <Card>
        <CardHeader>
          <CardTitle>Current Status</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex items-center gap-3">
            <span className="text-muted-foreground">Status:</span>
            <Badge variant={isActive ? "default" : "secondary"}>
              {isActive ? "Active" : "Inactive"}
            </Badge>
          </div>
          {profile?.membershipType && profile.membershipType !== "None" && (
            <div className="flex items-center gap-3">
              <span className="text-muted-foreground">Plan:</span>
              <span>{profile.membershipType}</span>
            </div>
          )}
          {profile?.expiredDate && (
            <div className="flex items-center gap-3">
              <span className="text-muted-foreground">Expires:</span>
              <span>{formatDate(profile.expiredDate)}</span>
            </div>
          )}
        </CardContent>
      </Card>

      <MembershipActions
        products={products}
        isSubscribed={!!profile?.isSubscription}
      />

      {payments.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Payment History</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Product</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {payments.map((p) => (
                  <TableRow key={p.id}>
                    <TableCell>{p.productName}</TableCell>
                    <TableCell>${p.total}</TableCell>
                    <TableCell>
                      {p.paidAt ? formatDate(p.paidAt) : "-"}
                    </TableCell>
                    <TableCell>
                      <Badge variant={p.isPaid ? "default" : "secondary"}>
                        {p.isPaid ? "Paid" : "Pending"}
                      </Badge>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
```

- [ ] **Step 4: Create membership actions client component**

Create `app/(dashboard)/membership/membership-actions-client.tsx`:
```tsx
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { subscribe, cancelSubscription } from "@/lib/actions/membership-actions";
import { toast } from "sonner";

interface MembershipActionsProps {
  products: { id: number; name: string; description: string | null; price: string }[];
  isSubscribed: boolean;
}

export function MembershipActions({
  products,
  isSubscribed,
}: MembershipActionsProps) {
  const [loading, setLoading] = useState<number | null>(null);

  async function handleSubscribe(productId: number) {
    setLoading(productId);
    const result = await subscribe(productId);
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Subscription activated!");
    }
    setLoading(null);
  }

  async function handleCancel() {
    setLoading(-1);
    const result = await cancelSubscription();
    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success("Subscription cancelled");
    }
    setLoading(null);
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Subscription Plans</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid md:grid-cols-2 gap-4">
          {products.map((p) => (
            <div
              key={p.id}
              className="border rounded-lg p-4 flex flex-col justify-between"
            >
              <div>
                <h3 className="font-semibold">{p.name}</h3>
                <p className="text-sm text-muted-foreground mt-1">
                  {p.description}
                </p>
                <p className="text-2xl font-bold mt-2">${p.price}</p>
              </div>
              <Button
                className="mt-4"
                onClick={() => handleSubscribe(p.id)}
                disabled={loading !== null}
              >
                {loading === p.id ? "Processing..." : "Subscribe"}
              </Button>
            </div>
          ))}
        </div>
        {isSubscribed && (
          <Button
            variant="outline"
            className="mt-4"
            onClick={handleCancel}
            disabled={loading !== null}
          >
            {loading === -1 ? "Cancelling..." : "Cancel Subscription"}
          </Button>
        )}
      </CardContent>
    </Card>
  );
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/db/queries/membership-queries.ts lib/actions/membership-actions.ts app/(dashboard)/membership/
git commit -m "feat: add membership page with subscription and payment tracking"
```

---

## Task 15: Class Management (Manager Timetable)

**Files:**
- Create: `app/(dashboard)/timetable/manage/page.tsx`, `lib/actions/class-actions.ts`, `components/class-form.tsx`, `app/api/classes/overlap/route.ts`

- [ ] **Step 1: Create class server actions**

Create `lib/actions/class-actions.ts`:
```ts
"use server";

import { db } from "@/lib/db";
import { dbPool } from "@/lib/db/transaction";
import { swimmingClass, instructor, location, classType } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireRole } from "@/lib/auth-utils";
import { checkForOverlap } from "@/lib/db/queries/class-queries";

export async function createClass(data: {
  instructorId: number;
  locationId: number;
  classTypeId: number;
  startTime: string;
  endTime: string;
  openSlot: number;
}) {
  await requireRole(["manager"]);

  const overlap = await checkForOverlap(
    data.locationId,
    new Date(data.startTime),
    new Date(data.endTime),
    data.instructorId
  );

  if (overlap) return { error: overlap };

  await db.insert(swimmingClass).values({
    instructorId: data.instructorId,
    locationId: data.locationId,
    classTypeId: data.classTypeId,
    startTime: new Date(data.startTime),
    endTime: new Date(data.endTime),
    openSlot: data.openSlot,
    status: "active",
  });

  revalidatePath("/timetable");
  return { success: true };
}

export async function updateClass(
  classId: number,
  data: {
    instructorId: number;
    locationId: number;
    classTypeId: number;
    startTime: string;
    endTime: string;
    openSlot: number;
  }
) {
  await requireRole(["manager"]);

  const overlap = await checkForOverlap(
    data.locationId,
    new Date(data.startTime),
    new Date(data.endTime),
    data.instructorId,
    classId
  );

  if (overlap) return { error: overlap };

  await db
    .update(swimmingClass)
    .set({
      instructorId: data.instructorId,
      locationId: data.locationId,
      classTypeId: data.classTypeId,
      startTime: new Date(data.startTime),
      endTime: new Date(data.endTime),
      openSlot: data.openSlot,
    })
    .where(eq(swimmingClass.id, classId));

  revalidatePath("/timetable");
  return { success: true };
}

export async function deleteClass(classId: number) {
  await requireRole(["manager"]);

  await db
    .update(swimmingClass)
    .set({ status: "cancelled" })
    .where(eq(swimmingClass.id, classId));

  revalidatePath("/timetable");
  return { success: true };
}

export async function getFormData() {
  const [instructors, locations, classTypes] = await Promise.all([
    db.select({ id: instructor.id, firstName: instructor.firstName, lastName: instructor.lastName }).from(instructor),
    db.select().from(location).where(eq(location.status, "available")),
    db.select().from(classType),
  ]);
  return { instructors, locations, classTypes };
}
```

- [ ] **Step 2: Create class form component**

Create `components/class-form.tsx`:
```tsx
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { createClass, updateClass } from "@/lib/actions/class-actions";
import { toast } from "sonner";

interface ClassFormProps {
  open: boolean;
  onClose: () => void;
  instructors: { id: number; firstName: string; lastName: string }[];
  locations: { id: number; poolName: string | null; laneName: string | null }[];
  classTypes: { id: number; className: string; type: string }[];
  editData?: {
    id: number;
    instructorId: number;
    locationId: number;
    classTypeId: number;
    startTime: string;
    endTime: string;
    openSlot: number;
  };
}

export function ClassForm({
  open,
  onClose,
  instructors,
  locations,
  classTypes,
  editData,
}: ClassFormProps) {
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    const fd = new FormData(e.currentTarget);
    const data = {
      instructorId: Number(fd.get("instructorId")),
      locationId: Number(fd.get("locationId")),
      classTypeId: Number(fd.get("classTypeId")),
      startTime: fd.get("startTime") as string,
      endTime: fd.get("endTime") as string,
      openSlot: Number(fd.get("openSlot")),
    };

    const result = editData
      ? await updateClass(editData.id, data)
      : await createClass(data);

    if (result.error) {
      toast.error(result.error);
    } else {
      toast.success(editData ? "Class updated" : "Class created");
      onClose();
    }
    setLoading(false);
  }

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {editData ? "Edit Class" : "Add New Class"}
          </DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>Instructor</Label>
            <Select
              name="instructorId"
              defaultValue={editData?.instructorId?.toString()}
              required
            >
              <SelectTrigger>
                <SelectValue placeholder="Select instructor" />
              </SelectTrigger>
              <SelectContent>
                {instructors.map((i) => (
                  <SelectItem key={i.id} value={String(i.id)}>
                    {i.firstName} {i.lastName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label>Location</Label>
            <Select
              name="locationId"
              defaultValue={editData?.locationId?.toString()}
              required
            >
              <SelectTrigger>
                <SelectValue placeholder="Select location" />
              </SelectTrigger>
              <SelectContent>
                {locations.map((l) => (
                  <SelectItem key={l.id} value={String(l.id)}>
                    {l.poolName} {l.laneName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label>Class Type</Label>
            <Select
              name="classTypeId"
              defaultValue={editData?.classTypeId?.toString()}
              required
            >
              <SelectTrigger>
                <SelectValue placeholder="Select class type" />
              </SelectTrigger>
              <SelectContent>
                {classTypes.map((ct) => (
                  <SelectItem key={ct.id} value={String(ct.id)}>
                    {ct.className} ({ct.type})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Start Time</Label>
              <Input
                name="startTime"
                type="datetime-local"
                defaultValue={editData?.startTime}
                required
              />
            </div>
            <div className="space-y-2">
              <Label>End Time</Label>
              <Input
                name="endTime"
                type="datetime-local"
                defaultValue={editData?.endTime}
                required
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label>Available Slots</Label>
            <Input
              name="openSlot"
              type="number"
              min={1}
              defaultValue={editData?.openSlot ?? 15}
              required
            />
          </div>
          <Button type="submit" className="w-full" disabled={loading}>
            {loading
              ? "Saving..."
              : editData
                ? "Update Class"
                : "Create Class"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
```

- [ ] **Step 3: Create manage timetable page**

Create `app/(dashboard)/timetable/manage/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import { getClassesForCalendar } from "@/lib/db/queries/class-queries";
import { getFormData } from "@/lib/actions/class-actions";
import { ManageTimetableClient } from "./manage-client";

export default async function ManageTimetablePage() {
  await requireRole(["manager"]);

  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0);

  const [events, formData] = await Promise.all([
    getClassesForCalendar(start, end),
    getFormData(),
  ]);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Manage Timetable</h1>
      <ManageTimetableClient events={events} formData={formData} />
    </div>
  );
}
```

- [ ] **Step 4: Create manage client component**

Create `app/(dashboard)/timetable/manage/manage-client.tsx`:
```tsx
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { SwimmingCalendar } from "@/components/calendar";
import { ClassForm } from "@/components/class-form";
import { Plus } from "lucide-react";
import type { CalendarEvent } from "@/lib/db/queries/class-queries";

interface ManageClientProps {
  events: CalendarEvent[];
  formData: {
    instructors: { id: number; firstName: string; lastName: string }[];
    locations: { id: number; poolName: string | null; laneName: string | null }[];
    classTypes: { id: number; className: string; type: string }[];
  };
}

export function ManageTimetableClient({
  events,
  formData,
}: ManageClientProps) {
  const [showForm, setShowForm] = useState(false);

  return (
    <>
      <div className="flex justify-end mb-4">
        <Button onClick={() => setShowForm(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Add Class
        </Button>
      </div>
      <SwimmingCalendar events={events} interactive />
      <ClassForm
        open={showForm}
        onClose={() => setShowForm(false)}
        {...formData}
      />
    </>
  );
}
```

- [ ] **Step 5: Create overlap check API route**

Create `app/api/classes/overlap/route.ts`:
```ts
import { checkForOverlap } from "@/lib/db/queries/class-queries";
import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  const body = await request.json();
  const { locationId, startTime, endTime, instructorId, excludeClassId } = body;

  const error = await checkForOverlap(
    locationId,
    new Date(startTime),
    new Date(endTime),
    instructorId,
    excludeClassId
  );

  return NextResponse.json({ overlap: !!error, message: error });
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/actions/class-actions.ts components/class-form.tsx app/(dashboard)/timetable/manage/ app/api/classes/
git commit -m "feat: add class management with overlap detection"
```

---

## Task 16: Attendance Pages

**Files:**
- Create: `app/(dashboard)/attendance/page.tsx`, `app/(dashboard)/attendance/[classId]/page.tsx`

- [ ] **Step 1: Create attendance overview page**

Create `app/(dashboard)/attendance/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import { db } from "@/lib/db";
import {
  swimmingClass,
  classType,
  instructor,
  location,
  booking,
} from "@/lib/db/schema";
import { eq, gte, desc, sql, and } from "drizzle-orm";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { formatDate, formatTime } from "@/lib/utils";
import Link from "next/link";

export default async function AttendancePage() {
  const session = await requireRole(["instructor", "manager"]);
  const role = session.user.role as string;

  let classes;
  if (role === "manager") {
    classes = await db
      .select({
        id: swimmingClass.id,
        startTime: swimmingClass.startTime,
        endTime: swimmingClass.endTime,
        className: classType.className,
        instructorName: sql<string>`${instructor.firstName} || ' ' || ${instructor.lastName}`,
        locationName: sql<string>`COALESCE(${location.poolName}, '') || ' ' || COALESCE(${location.laneName}, '')`,
        bookingCount: sql<number>`(SELECT COUNT(*) FROM booking WHERE class_id = ${swimmingClass.id} AND status = 'booked')`,
      })
      .from(swimmingClass)
      .innerJoin(classType, eq(swimmingClass.classTypeId, classType.id))
      .innerJoin(instructor, eq(swimmingClass.instructorId, instructor.id))
      .innerJoin(location, eq(swimmingClass.locationId, location.id))
      .where(eq(swimmingClass.status, "active"))
      .orderBy(desc(swimmingClass.startTime))
      .limit(50);
  } else {
    // Instructor: get their own classes
    const { instructor: instructorTable } = await import("@/lib/db/schema");
    const [inst] = await db
      .select({ id: instructorTable.id })
      .from(instructorTable)
      .where(eq(instructorTable.userId, session.user.id));

    if (!inst) {
      return <p className="text-muted-foreground">No instructor profile found.</p>;
    }

    classes = await db
      .select({
        id: swimmingClass.id,
        startTime: swimmingClass.startTime,
        endTime: swimmingClass.endTime,
        className: classType.className,
        instructorName: sql<string>`${instructor.firstName} || ' ' || ${instructor.lastName}`,
        locationName: sql<string>`COALESCE(${location.poolName}, '') || ' ' || COALESCE(${location.laneName}, '')`,
        bookingCount: sql<number>`(SELECT COUNT(*) FROM booking WHERE class_id = ${swimmingClass.id} AND status = 'booked')`,
      })
      .from(swimmingClass)
      .innerJoin(classType, eq(swimmingClass.classTypeId, classType.id))
      .innerJoin(instructor, eq(swimmingClass.instructorId, instructor.id))
      .innerJoin(location, eq(swimmingClass.locationId, location.id))
      .where(
        and(
          eq(swimmingClass.instructorId, inst.id),
          eq(swimmingClass.status, "active")
        )
      )
      .orderBy(desc(swimmingClass.startTime))
      .limit(50);
  }

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Attendance</h1>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Class</TableHead>
            <TableHead>Date</TableHead>
            <TableHead>Time</TableHead>
            <TableHead>Instructor</TableHead>
            <TableHead>Location</TableHead>
            <TableHead>Booked</TableHead>
            <TableHead></TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {classes.map((c) => (
            <TableRow key={c.id}>
              <TableCell className="font-medium">{c.className}</TableCell>
              <TableCell>{formatDate(c.startTime)}</TableCell>
              <TableCell>
                {formatTime(c.startTime)} - {formatTime(c.endTime)}
              </TableCell>
              <TableCell>{c.instructorName}</TableCell>
              <TableCell>{c.locationName}</TableCell>
              <TableCell>{c.bookingCount}</TableCell>
              <TableCell>
                <Button asChild size="sm" variant="outline">
                  <Link href={`/attendance/${c.id}`}>Mark</Link>
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
```

- [ ] **Step 2: Create attendance marking page**

Create `app/(dashboard)/attendance/[classId]/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import { getClassAttendance } from "@/lib/db/queries/booking-queries";
import { AttendanceForm } from "./attendance-form";

export default async function AttendanceClassPage({
  params,
}: {
  params: Promise<{ classId: string }>;
}) {
  await requireRole(["instructor", "manager"]);
  const { classId } = await params;
  const attendance = await getClassAttendance(Number(classId));

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Mark Attendance</h1>
      <AttendanceForm classId={Number(classId)} attendance={attendance} />
    </div>
  );
}
```

- [ ] **Step 3: Create attendance form client component**

Create `app/(dashboard)/attendance/[classId]/attendance-form.tsx`:
```tsx
"use client";

import { useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { markAttendance } from "@/lib/actions/booking-actions";
import { toast } from "sonner";
import { Check, X } from "lucide-react";

interface AttendanceFormProps {
  classId: number;
  attendance: {
    bookingId: number;
    memberId: number;
    isAttended: boolean;
    firstName: string;
    lastName: string;
    email: string;
  }[];
}

export function AttendanceForm({ classId, attendance }: AttendanceFormProps) {
  const [states, setStates] = useState(
    attendance.reduce(
      (acc, a) => ({ ...acc, [a.memberId]: a.isAttended }),
      {} as Record<number, boolean>
    )
  );

  async function toggle(memberId: number) {
    const newState = !states[memberId];
    setStates((s) => ({ ...s, [memberId]: newState }));
    const result = await markAttendance(memberId, classId, newState);
    if (result.success) {
      toast.success("Attendance updated");
    }
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Member</TableHead>
          <TableHead>Email</TableHead>
          <TableHead>Attended</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {attendance.map((a) => (
          <TableRow key={a.memberId}>
            <TableCell>
              {a.firstName} {a.lastName}
            </TableCell>
            <TableCell>{a.email}</TableCell>
            <TableCell>
              <Button
                variant={states[a.memberId] ? "default" : "outline"}
                size="sm"
                onClick={() => toggle(a.memberId)}
              >
                {states[a.memberId] ? (
                  <Check className="h-4 w-4" />
                ) : (
                  <X className="h-4 w-4" />
                )}
              </Button>
            </TableCell>
          </TableRow>
        ))}
        {attendance.length === 0 && (
          <TableRow>
            <TableCell colSpan={3} className="text-center text-muted-foreground">
              No bookings for this class.
            </TableCell>
          </TableRow>
        )}
      </TableBody>
    </Table>
  );
}
```

- [ ] **Step 4: Commit**

```bash
git add app/(dashboard)/attendance/
git commit -m "feat: add attendance overview and marking pages"
```

---

## Task 17: User Management (Members & Instructors)

**Files:**
- Create: `lib/db/queries/user-queries.ts`, `lib/actions/user-actions.ts`, `app/(dashboard)/users/members/page.tsx`, `app/(dashboard)/users/members/[id]/page.tsx`, `app/(dashboard)/users/instructors/page.tsx`, `app/(dashboard)/users/instructors/[id]/page.tsx`

- [ ] **Step 1: Create user queries**

Create `lib/db/queries/user-queries.ts`:
```ts
import { db } from "@/lib/db";
import { member, instructor, manager, user } from "@/lib/db/schema";
import { eq } from "drizzle-orm";

export async function getAllMembers() {
  return db
    .select({
      id: member.id,
      userId: member.userId,
      firstName: member.firstName,
      lastName: member.lastName,
      email: member.email,
      phone: member.phone,
      membershipType: member.membershipType,
      isSubscription: member.isSubscription,
      expiredDate: member.expiredDate,
    })
    .from(member);
}

export async function getMemberById(id: number) {
  const [m] = await db.select().from(member).where(eq(member.id, id));
  return m;
}

export async function getAllInstructors() {
  return db
    .select({
      id: instructor.id,
      userId: instructor.userId,
      title: instructor.title,
      firstName: instructor.firstName,
      lastName: instructor.lastName,
      email: instructor.email,
      phone: instructor.phone,
      position: instructor.position,
    })
    .from(instructor);
}

export async function getInstructorById(id: number) {
  const [i] = await db
    .select()
    .from(instructor)
    .where(eq(instructor.id, id));
  return i;
}
```

- [ ] **Step 2: Create user server actions**

Create `lib/actions/user-actions.ts`:
```ts
"use server";

import { db } from "@/lib/db";
import { member, instructor, manager, user } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireRole } from "@/lib/auth-utils";

export async function updateMember(
  memberId: number,
  data: {
    firstName: string;
    lastName: string;
    phone: string;
    email: string;
    address?: string;
    dob?: string;
    healthInfo?: string;
  }
) {
  await requireRole(["manager"]);

  await db
    .update(member)
    .set({
      firstName: data.firstName,
      lastName: data.lastName,
      phone: data.phone,
      email: data.email,
      address: data.address ?? null,
      dob: data.dob ?? null,
      healthInfo: data.healthInfo ?? null,
    })
    .where(eq(member.id, memberId));

  revalidatePath("/users/members");
  return { success: true };
}

export async function updateInstructor(
  instructorId: number,
  data: {
    title: string;
    firstName: string;
    lastName: string;
    position: string;
    phone: string;
    email: string;
    profile?: string;
  }
) {
  await requireRole(["manager"]);

  await db
    .update(instructor)
    .set({
      title: data.title,
      firstName: data.firstName,
      lastName: data.lastName,
      position: data.position,
      phone: data.phone,
      email: data.email,
      profile: data.profile ?? null,
    })
    .where(eq(instructor.id, instructorId));

  revalidatePath("/users/instructors");
  return { success: true };
}

export async function deactivateUser(userId: string) {
  await requireRole(["manager"]);

  await db.update(user).set({ isActive: false }).where(eq(user.id, userId));

  revalidatePath("/users/members");
  revalidatePath("/users/instructors");
  return { success: true };
}

export async function changeUserRole(userId: string, role: "member" | "instructor" | "manager") {
  await requireRole(["manager"]);

  await db.update(user).set({ role }).where(eq(user.id, userId));

  revalidatePath("/users/members");
  revalidatePath("/users/instructors");
  return { success: true };
}
```

- [ ] **Step 3: Create members list page**

Create `app/(dashboard)/users/members/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import { getAllMembers } from "@/lib/db/queries/user-queries";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";

export default async function MembersPage() {
  await requireRole(["manager"]);
  const members = await getAllMembers();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Members</h1>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Name</TableHead>
            <TableHead>Email</TableHead>
            <TableHead>Phone</TableHead>
            <TableHead>Membership</TableHead>
            <TableHead>Status</TableHead>
            <TableHead></TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {members.map((m) => (
            <TableRow key={m.id}>
              <TableCell className="font-medium">
                {m.firstName} {m.lastName}
              </TableCell>
              <TableCell>{m.email}</TableCell>
              <TableCell>{m.phone}</TableCell>
              <TableCell>{m.membershipType ?? "None"}</TableCell>
              <TableCell>
                <Badge
                  variant={m.isSubscription ? "default" : "secondary"}
                >
                  {m.isSubscription ? "Active" : "Inactive"}
                </Badge>
              </TableCell>
              <TableCell>
                <Button asChild size="sm" variant="outline">
                  <Link href={`/users/members/${m.id}`}>View</Link>
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
```

- [ ] **Step 4: Create member detail page**

Create `app/(dashboard)/users/members/[id]/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import { getMemberById } from "@/lib/db/queries/user-queries";
import { notFound } from "next/navigation";
import { MemberEditForm } from "./edit-form";

export default async function MemberDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  await requireRole(["manager"]);
  const { id } = await params;
  const memberData = await getMemberById(Number(id));
  if (!memberData) notFound();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">
        {memberData.firstName} {memberData.lastName}
      </h1>
      <MemberEditForm member={memberData} />
    </div>
  );
}
```

- [ ] **Step 5: Create member edit form**

Create `app/(dashboard)/users/members/[id]/edit-form.tsx`:
```tsx
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { updateMember } from "@/lib/actions/user-actions";
import { toast } from "sonner";

interface MemberEditFormProps {
  member: {
    id: number;
    firstName: string;
    lastName: string;
    phone: string;
    email: string;
    address: string | null;
    dob: string | null;
    healthInfo: string | null;
  };
}

export function MemberEditForm({ member }: MemberEditFormProps) {
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    const fd = new FormData(e.currentTarget);
    const result = await updateMember(member.id, {
      firstName: fd.get("firstName") as string,
      lastName: fd.get("lastName") as string,
      phone: fd.get("phone") as string,
      email: fd.get("email") as string,
      address: fd.get("address") as string,
      dob: fd.get("dob") as string,
      healthInfo: fd.get("healthInfo") as string,
    });
    if (result.success) toast.success("Member updated");
    setLoading(false);
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Edit Profile</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>First Name</Label>
              <Input name="firstName" defaultValue={member.firstName} required />
            </div>
            <div className="space-y-2">
              <Label>Last Name</Label>
              <Input name="lastName" defaultValue={member.lastName} required />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Email</Label>
              <Input name="email" type="email" defaultValue={member.email} required />
            </div>
            <div className="space-y-2">
              <Label>Phone</Label>
              <Input name="phone" defaultValue={member.phone} required />
            </div>
          </div>
          <div className="space-y-2">
            <Label>Address</Label>
            <Input name="address" defaultValue={member.address ?? ""} />
          </div>
          <div className="space-y-2">
            <Label>Date of Birth</Label>
            <Input name="dob" type="date" defaultValue={member.dob ?? ""} />
          </div>
          <div className="space-y-2">
            <Label>Health Information</Label>
            <Textarea name="healthInfo" defaultValue={member.healthInfo ?? ""} />
          </div>
          <Button type="submit" disabled={loading}>
            {loading ? "Saving..." : "Save Changes"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
```

- [ ] **Step 6: Create instructors list and detail pages**

Create `app/(dashboard)/users/instructors/page.tsx` (similar pattern to members list) and `app/(dashboard)/users/instructors/[id]/page.tsx` with edit form. Follow the same pattern as the member pages but with instructor fields (title, position, profile bio).

- [ ] **Step 7: Commit**

```bash
git add lib/db/queries/user-queries.ts lib/actions/user-actions.ts app/(dashboard)/users/
git commit -m "feat: add user management pages for members and instructors"
```

---

## Task 18: Settings Pages (Class Types, Locations, Pricing)

**Files:**
- Create: `lib/actions/settings-actions.ts`, `app/(dashboard)/settings/class-types/page.tsx`, `app/(dashboard)/settings/locations/page.tsx`, `app/(dashboard)/settings/pricing/page.tsx`

- [ ] **Step 1: Create settings server actions**

Create `lib/actions/settings-actions.ts`:
```ts
"use server";

import { db } from "@/lib/db";
import { classType, location, product } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireRole } from "@/lib/auth-utils";

export async function createClassType(data: { type: "class" | "1-on-1" | "group"; className: string; description?: string }) {
  await requireRole(["manager"]);
  await db.insert(classType).values({ type: data.type, className: data.className, description: data.description ?? null });
  revalidatePath("/settings/class-types");
  return { success: true };
}

export async function updateClassType(id: number, data: { type: "class" | "1-on-1" | "group"; className: string; description?: string }) {
  await requireRole(["manager"]);
  await db.update(classType).set({ type: data.type, className: data.className, description: data.description ?? null }).where(eq(classType.id, id));
  revalidatePath("/settings/class-types");
  return { success: true };
}

export async function createLocation(data: { poolName: string; laneName: string }) {
  await requireRole(["manager"]);
  await db.insert(location).values({ poolName: data.poolName, laneName: data.laneName, status: "available" });
  revalidatePath("/settings/locations");
  return { success: true };
}

export async function updateLocationStatus(id: number, status: "available" | "unavailable") {
  await requireRole(["manager"]);
  await db.update(location).set({ status }).where(eq(location.id, id));
  revalidatePath("/settings/locations");
  return { success: true };
}

export async function createProduct(data: { name: string; description?: string; price: string }) {
  await requireRole(["manager"]);
  await db.insert(product).values({ name: data.name, description: data.description ?? null, price: data.price });
  revalidatePath("/settings/pricing");
  return { success: true };
}

export async function updateProduct(id: number, data: { name: string; description?: string; price: string }) {
  await requireRole(["manager"]);
  await db.update(product).set({ name: data.name, description: data.description ?? null, price: data.price }).where(eq(product.id, id));
  revalidatePath("/settings/pricing");
  return { success: true };
}
```

- [ ] **Step 2: Create class types, locations, and pricing pages**

Each follows the same pattern: a table listing existing items with an "Add" button that opens a dialog form. Use the server actions from Step 1. Build all three pages following the established patterns from previous tasks.

- [ ] **Step 3: Commit**

```bash
git add lib/actions/settings-actions.ts app/(dashboard)/settings/
git commit -m "feat: add settings pages for class types, locations, and pricing"
```

---

## Task 19: Reports Page

**Files:**
- Create: `lib/db/queries/report-queries.ts`, `app/(dashboard)/reports/page.tsx`

- [ ] **Step 1: Create report queries**

Create `lib/db/queries/report-queries.ts`:
```ts
import { db } from "@/lib/db";
import { payment, product, booking, swimmingClass, classType, member } from "@/lib/db/schema";
import { eq, and, gte, lte, sql, sum } from "drizzle-orm";

export async function getFinancialReport(startDate: Date, endDate: Date) {
  return db
    .select({
      productName: product.name,
      totalAmount: sql<string>`COALESCE(SUM(${payment.total}::numeric), 0)`,
      paymentCount: sql<number>`COUNT(${payment.id})`,
    })
    .from(product)
    .leftJoin(
      payment,
      and(
        eq(payment.productId, product.id),
        eq(payment.isPaid, true),
        gte(payment.paidAt, startDate),
        lte(payment.paidAt, endDate)
      )
    )
    .groupBy(product.id, product.name);
}

export async function getClassPopularityReport(startDate: Date, endDate: Date) {
  return db
    .select({
      className: classType.className,
      classTypeName: classType.type,
      totalBookings: sql<number>`COUNT(${booking.id})`,
    })
    .from(classType)
    .leftJoin(swimmingClass, eq(swimmingClass.classTypeId, classType.id))
    .leftJoin(
      booking,
      and(
        eq(booking.classId, swimmingClass.id),
        eq(booking.status, "booked"),
        gte(booking.createdAt, startDate),
        lte(booking.createdAt, endDate)
      )
    )
    .groupBy(classType.id, classType.className, classType.type);
}

export async function getAttendanceReport(startDate: Date, endDate: Date) {
  return db
    .select({
      className: classType.className,
      totalBooked: sql<number>`COUNT(${booking.id})`,
      totalAttended: sql<number>`SUM(CASE WHEN ${booking.isAttended} THEN 1 ELSE 0 END)`,
    })
    .from(booking)
    .innerJoin(swimmingClass, eq(booking.classId, swimmingClass.id))
    .innerJoin(classType, eq(swimmingClass.classTypeId, classType.id))
    .where(
      and(
        eq(booking.status, "booked"),
        gte(swimmingClass.startTime, startDate),
        lte(swimmingClass.startTime, endDate)
      )
    )
    .groupBy(classType.id, classType.className);
}
```

- [ ] **Step 2: Create reports page**

Create `app/(dashboard)/reports/page.tsx`:
```tsx
import { requireRole } from "@/lib/auth-utils";
import {
  getFinancialReport,
  getClassPopularityReport,
  getAttendanceReport,
} from "@/lib/db/queries/report-queries";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

export default async function ReportsPage() {
  await requireRole(["manager"]);

  const now = new Date();
  const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
  const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);

  const [financial, popularity, attendance] = await Promise.all([
    getFinancialReport(startDate, endDate),
    getClassPopularityReport(startDate, endDate),
    getAttendanceReport(startDate, endDate),
  ]);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Reports</h1>
      <Tabs defaultValue="financial">
        <TabsList>
          <TabsTrigger value="financial">Financial</TabsTrigger>
          <TabsTrigger value="popularity">Class Popularity</TabsTrigger>
          <TabsTrigger value="attendance">Attendance</TabsTrigger>
        </TabsList>

        <TabsContent value="financial">
          <Card>
            <CardHeader>
              <CardTitle>Financial Report (Current Month)</CardTitle>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Product</TableHead>
                    <TableHead>Payments</TableHead>
                    <TableHead>Total</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {financial.map((r) => (
                    <TableRow key={r.productName}>
                      <TableCell>{r.productName}</TableCell>
                      <TableCell>{r.paymentCount}</TableCell>
                      <TableCell>${r.totalAmount}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="popularity">
          <Card>
            <CardHeader>
              <CardTitle>Class Popularity (Current Month)</CardTitle>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Class</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Total Bookings</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {popularity.map((r) => (
                    <TableRow key={r.className}>
                      <TableCell>{r.className}</TableCell>
                      <TableCell>{r.classTypeName}</TableCell>
                      <TableCell>{r.totalBookings}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="attendance">
          <Card>
            <CardHeader>
              <CardTitle>Attendance Report (Current Month)</CardTitle>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Class</TableHead>
                    <TableHead>Total Booked</TableHead>
                    <TableHead>Attended</TableHead>
                    <TableHead>Rate</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {attendance.map((r) => (
                    <TableRow key={r.className}>
                      <TableCell>{r.className}</TableCell>
                      <TableCell>{r.totalBooked}</TableCell>
                      <TableCell>{r.totalAttended}</TableCell>
                      <TableCell>
                        {r.totalBooked > 0
                          ? `${Math.round((r.totalAttended / r.totalBooked) * 100)}%`
                          : "N/A"}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/db/queries/report-queries.ts app/(dashboard)/reports/
git commit -m "feat: add reports page with financial, popularity, and attendance tabs"
```

---

## Task 20: Profile Page

**Files:**
- Create: `app/(dashboard)/profile/page.tsx`, `lib/actions/profile-actions.ts`

- [ ] **Step 1: Create profile server actions**

Create `lib/actions/profile-actions.ts`:
```ts
"use server";

import { db } from "@/lib/db";
import { member, instructor, manager } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireSession } from "@/lib/auth-utils";
import { auth } from "@/lib/auth";
import { headers } from "next/headers";

export async function updateProfile(data: {
  firstName: string;
  lastName: string;
  phone: string;
  email: string;
  address?: string;
  dob?: string;
  healthInfo?: string;
  title?: string;
  position?: string;
  profile?: string;
}) {
  const session = await requireSession();
  const role = session.user.role as string;

  if (role === "member") {
    await db
      .update(member)
      .set({
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
        email: data.email,
        address: data.address ?? null,
        dob: data.dob ?? null,
        healthInfo: data.healthInfo ?? null,
      })
      .where(eq(member.userId, session.user.id));
  } else if (role === "instructor") {
    await db
      .update(instructor)
      .set({
        title: data.title ?? "",
        firstName: data.firstName,
        lastName: data.lastName,
        position: data.position ?? "",
        phone: data.phone,
        email: data.email,
        profile: data.profile ?? null,
      })
      .where(eq(instructor.userId, session.user.id));
  } else if (role === "manager") {
    await db
      .update(manager)
      .set({
        title: data.title ?? "",
        firstName: data.firstName,
        lastName: data.lastName,
        position: data.position ?? "",
        phone: data.phone,
        email: data.email,
      })
      .where(eq(manager.userId, session.user.id));
  }

  revalidatePath("/profile");
  return { success: true };
}
```

- [ ] **Step 2: Create profile page**

Create `app/(dashboard)/profile/page.tsx` — fetches the current user's profile data based on role, renders an editable form. Follow the pattern from the member edit form in Task 17, but adapted for self-editing.

- [ ] **Step 3: Commit**

```bash
git add lib/actions/profile-actions.ts app/(dashboard)/profile/
git commit -m "feat: add profile page with role-based self-editing"
```

---

## Task 21: News Pages (Public + Manager)

**Files:**
- Create: `lib/actions/news-actions.ts`, `app/(public)/news/page.tsx`, `app/(public)/news/[id]/page.tsx`, `app/(dashboard)/news/manage/page.tsx`

- [ ] **Step 1: Create news server actions**

Create `lib/actions/news-actions.ts`:
```ts
"use server";

import { db } from "@/lib/db";
import { news, manager } from "@/lib/db/schema";
import { eq, desc } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireRole } from "@/lib/auth-utils";

export async function getAllNews() {
  return db
    .select({
      id: news.id,
      title: news.title,
      content: news.content,
      createdAt: news.createdAt,
      authorFirstName: manager.firstName,
      authorLastName: manager.lastName,
    })
    .from(news)
    .innerJoin(manager, eq(news.authorId, manager.id))
    .orderBy(desc(news.createdAt));
}

export async function getNewsById(id: number) {
  const [n] = await db
    .select({
      id: news.id,
      title: news.title,
      content: news.content,
      createdAt: news.createdAt,
      authorFirstName: manager.firstName,
      authorLastName: manager.lastName,
    })
    .from(news)
    .innerJoin(manager, eq(news.authorId, manager.id))
    .where(eq(news.id, id));
  return n;
}

export async function createNews(data: { title: string; content: string }) {
  const session = await requireRole(["manager"]);
  const [mgr] = await db
    .select({ id: manager.id })
    .from(manager)
    .where(eq(manager.userId, session.user.id));

  if (!mgr) return { error: "Manager profile not found" };

  await db.insert(news).values({
    authorId: mgr.id,
    title: data.title,
    content: data.content,
  });

  revalidatePath("/news");
  revalidatePath("/news/manage");
  return { success: true };
}

export async function deleteNews(id: number) {
  await requireRole(["manager"]);
  await db.delete(news).where(eq(news.id, id));
  revalidatePath("/news");
  revalidatePath("/news/manage");
  return { success: true };
}
```

- [ ] **Step 2: Create public news list and detail pages**

Create `app/(public)/news/page.tsx` and `app/(public)/news/[id]/page.tsx` — read-only views with cards and formatted dates.

- [ ] **Step 3: Create news management page**

Create `app/(dashboard)/news/manage/page.tsx` — manager-only page with a list of news articles and a form to create new ones.

- [ ] **Step 4: Commit**

```bash
git add lib/actions/news-actions.ts app/(public)/news/ app/(dashboard)/news/
git commit -m "feat: add news pages (public list/detail + manager CRUD)"
```

---

## Task 22: Public Course & Instructor Pages

**Files:**
- Create: `app/(public)/courses/page.tsx`, `app/(public)/instructors/page.tsx`

- [ ] **Step 1: Create courses page**

Create `app/(public)/courses/page.tsx`:
```tsx
import { db } from "@/lib/db";
import { classType } from "@/lib/db/schema";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export default async function CoursesPage() {
  const courses = await db.select().from(classType);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Our Courses</h1>
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {courses.map((c) => (
          <Card key={c.id}>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>{c.className}</CardTitle>
                <Badge variant="outline">{c.type}</Badge>
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground">
                {c.description ?? "No description available."}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Create instructors page**

Create `app/(public)/instructors/page.tsx`:
```tsx
import { db } from "@/lib/db";
import { instructor } from "@/lib/db/schema";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";

export default async function InstructorsPage() {
  const instructors = await db.select().from(instructor);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Our Instructors</h1>
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {instructors.map((i) => (
          <Card key={i.id}>
            <CardHeader className="flex flex-row items-center gap-4">
              <Avatar className="h-12 w-12">
                <AvatarFallback>
                  {i.firstName[0]}
                  {i.lastName[0]}
                </AvatarFallback>
              </Avatar>
              <div>
                <CardTitle className="text-lg">
                  {i.title} {i.firstName} {i.lastName}
                </CardTitle>
                <p className="text-sm text-muted-foreground">{i.position}</p>
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground text-sm">
                {i.profile ?? "No bio available."}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add app/(public)/courses/ app/(public)/instructors/
git commit -m "feat: add public courses and instructors pages"
```

---

## Task 23: Heroku Deployment Configuration

**Files:**
- Create: `Procfile`
- Modify: `package.json` (ensure build/start scripts)

- [ ] **Step 1: Create Procfile**

Create `Procfile`:
```
web: npm start
```

- [ ] **Step 2: Verify package.json scripts**

Ensure `package.json` has:
```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  }
}
```

- [ ] **Step 3: Update next.config.ts for standalone output**

Edit `next.config.ts` to add standalone output for Heroku:
```ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
};

export default nextConfig;
```

- [ ] **Step 4: Create Heroku app and deploy**

```bash
heroku create scms-app
heroku buildpacks:set heroku/nodejs
heroku config:set DATABASE_URL="your-neon-connection-string"
heroku config:set BETTER_AUTH_SECRET="your-generated-secret"
heroku config:set BETTER_AUTH_URL="https://scms-app.herokuapp.com"
heroku config:set NEXT_PUBLIC_APP_URL="https://scms-app.herokuapp.com"
heroku config:set NODE_ENV=production
git push heroku main
```

- [ ] **Step 5: Verify deployment**

```bash
heroku open
```

Expected: The app opens in the browser, the home page renders, login/register work.

- [ ] **Step 6: Commit deployment config**

```bash
git add Procfile next.config.ts
git commit -m "feat: add Heroku deployment configuration"
```

---

## Task 24: Cleanup Old Flask Files

**Files:**
- Delete: `scmsapp/`, `run.py`, `requirements.txt`

- [ ] **Step 1: Remove old Flask application files**

```bash
git rm -r scmsapp/ run.py requirements.txt
```

Note: Keep the design spec in `docs/` as documentation.

- [ ] **Step 2: Commit cleanup**

```bash
git commit -m "chore: remove old Flask application files after migration"
```

---

## Task 25: Final Verification

- [ ] **Step 1: Run local dev server and test all features**

```bash
npm run dev
```

Test checklist:
1. Home page renders with hero and features
2. Public timetable shows FullCalendar
3. Courses page lists class types
4. Instructors page lists instructor profiles
5. Register a new member account
6. Login with the new account
7. Dashboard shows with correct role sidebar
8. Timetable shows calendar with booking dialog
9. Booking page shows booked classes (after booking one)
10. Membership page shows subscription options
11. Profile page allows editing
12. News page shows articles

Manager-specific tests (change user role in database first):
13. Class management (add/edit/delete classes)
14. Attendance marking
15. User management (view/edit members and instructors)
16. Settings pages (class types, locations, pricing)
17. Reports page (financial, popularity, attendance)
18. News management (create/delete)

- [ ] **Step 2: Build and verify production build**

```bash
npm run build
npm start
```

Expected: No build errors. App runs on port 3000.

- [ ] **Step 3: Deploy to Heroku and verify**

```bash
git push heroku main
heroku open
```

Verify all features work in production.

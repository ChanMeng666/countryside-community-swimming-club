# Tech Stack Modernization — Design Spec

## Context

The Countryside Community Swimming Club Management System (SCMS) is currently built with an aging tech stack: Python Flask + Jinja2 server-side rendering, MySQL with raw SQL queries, custom session-based authentication with hardcoded salt, and Bootstrap 5 + vanilla JavaScript. The project has no deployment configuration.

This modernization replaces the entire stack with a professional, modern alternative while preserving all existing features. The new stack will be deployed on Heroku with Neon Database (PostgreSQL).

## Tech Stack

| Layer | Old | New |
|-------|-----|-----|
| Framework | Flask 3.0.2 + Jinja2 | Next.js 15 (App Router) |
| Language | Python | TypeScript |
| Frontend | Bootstrap 5 + vanilla JS | React 19 + Tailwind CSS 4 + shadcn/ui |
| Database | MySQL 8.3 (raw SQL) | Neon PostgreSQL + Drizzle ORM |
| Auth | Custom (Flask-Hashing, hardcoded salt) | Better Auth (integrated with Neon) |
| Calendar | Custom HTML tables | FullCalendar (React) |
| Deployment | None (dev server only) | Heroku (heroku/nodejs buildpack) |

## Database Schema (Drizzle + Neon PostgreSQL)

### Better Auth Tables (auto-managed)

Better Auth creates and manages: `user`, `session`, `account`, `verification`. We extend `user` with a `role` field via Better Auth's plugin system.

### Application Tables

**member** — Links to auth user, stores profile data:
- `id`, `userId` (FK → user), `firstName`, `lastName`, `phone`, `email`, `dob`, `address`, `healthInfo`, `membershipType` (enum: monthly/annual/none), `expiredDate`, `image`

**instructor** — Links to auth user, stores instructor profile:
- `id`, `userId` (FK → user), `title`, `firstName`, `lastName`, `position`, `phone`, `email`, `profile` (bio text), `image`

**manager** — Links to auth user, stores manager profile:
- `id`, `userId` (FK → user), `title`, `firstName`, `lastName`, `position`, `phone`, `email`

**classType** — Defines class categories:
- `id`, `type` (pgEnum: class/1-on-1/group), `name`, `description`

**location** — Pool lanes and facilities:
- `id`, `poolName`, `laneName`, `status` (pgEnum: available/unavailable)

**class** — Scheduled swimming classes:
- `id`, `instructorId` (FK → instructor), `locationId` (FK → location), `classTypeId` (FK → classType), `startTime` (timestamptz), `endTime` (timestamptz), `openSlot` (integer), `status` (pgEnum: active/cancelled)

**booking** — Member class bookings:
- `id`, `memberId` (FK → member), `classId` (FK → class), `createdAt` (timestamptz), `status` (pgEnum: booked/cancelled), `isAttended` (boolean)

**product** — Membership products:
- `id`, `name`, `description`, `price` (decimal)

**payment** — Payment records (tracking only, no gateway):
- `id`, `productId` (FK → product), `bookingId` (FK → booking, nullable), `memberId` (FK → member), `total` (decimal), `paidAt` (timestamptz), `isPaid` (boolean)

**news** — Announcements:
- `id`, `authorId` (FK → user), `title`, `content` (text), `createdAt` (timestamptz)

### Key Changes from MySQL
- PostgreSQL enums replace MySQL ENUM strings
- TIMESTAMPTZ replaces DATETIME (timezone-aware)
- Proper FK constraints with ON DELETE CASCADE/SET NULL
- Drizzle provides full TypeScript type safety
- Better Auth replaces custom user/session tables

## Page Structure (Next.js App Router)

### Route Groups

**`(public)/`** — No auth required. Simple navbar + footer layout.
- `/` — Landing/home page
- `/timetable` — Public read-only timetable (FullCalendar)
- `/courses` — Course descriptions
- `/instructors` — Instructor profiles
- `/news`, `/news/[id]` — News list and detail

**`(auth)/`** — Centered card layout. Redirects to dashboard if authenticated.
- `/login` — Login form
- `/register` — Registration form

**`(dashboard)/`** — Auth required. Sidebar + topbar layout. Role-based access.
- `/dashboard` — Role-based dashboard home
- `/booking` — View & manage bookings (member)
- `/membership` — Membership status & payments (member)
- `/profile` — Edit profile & change password (all roles)
- `/timetable` — Interactive timetable with FullCalendar (all roles, booking actions for members)
- `/timetable/manage` — Add/edit classes (manager)
- `/attendance` — Attendance overview (manager/instructor)
- `/attendance/[classId]` — Mark attendance for a class
- `/users/members` — List all members (manager)
- `/users/members/[id]` — View/edit member (manager)
- `/users/instructors` — List all instructors (manager)
- `/users/instructors/[id]` — View/edit instructor (manager)
- `/settings/class-types` — Manage class types (manager)
- `/settings/locations` — Manage pool/lanes (manager)
- `/settings/pricing` — Manage products/pricing (manager)
- `/reports` — Financial, attendance, popularity reports (manager)
- `/news/manage` — Create/edit news (manager)

### API Routes
- `/api/auth/[...all]` — Better Auth catch-all handler
- `/api/classes/overlap` — Class overlap check endpoint (used by timetable manage)

## UI Design

### Layout: Classic Sidebar
- Fixed left sidebar (220px) with collapsible role-based menu sections
- Top bar with page title, notification bell, user avatar
- Sidebar sections: Common (Timetable, Bookings, Membership), role-specific items
- Mobile: sidebar collapses to hamburger menu
- Built with shadcn/ui `Sheet` component for mobile, custom sidebar for desktop

### Component Library
- shadcn/ui for all UI components: Button, Card, Dialog, Table, Form, Input, Select, Badge, Toast (Sonner), Sheet, Calendar, DropdownMenu
- FullCalendar React component for timetable views (week/day/month)
- Tailwind CSS 4 for all styling, dark/light mode support via `next-themes`

### Color-coded Classes
- Regular classes: blue (`#3b82f6`)
- Advanced/training: green (`#34d399`)
- 1-on-1 lessons: yellow (`#facc15`)
- Group sessions: purple (`#a78bfa`)

## Authentication (Better Auth)

### Configuration
- Better Auth server instance in `lib/auth.ts` with Drizzle adapter
- Better Auth client in `lib/auth-client.ts` for client components
- `middleware.ts` protects all `(dashboard)` routes
- User role stored in Better Auth's user table (extended via plugin)

### Role-Based Access
- Three roles: `member`, `instructor`, `manager`
- Middleware checks auth status; page-level checks verify role
- Manager sees all menu items; instructor sees schedule/attendance; member sees booking/membership

### Registration Flow
- New users register as `member` by default
- Manager can promote users to `instructor` or `manager` via user management

## Data Flow

### Server Components (reads)
- Pages use React Server Components to fetch data directly with Drizzle
- No loading spinners for initial page loads — data is server-rendered

### Server Actions (mutations)
- Form submissions use Server Actions with Zod validation
- `useActionState` hook for form state management
- Toast notifications (Sonner) for success/error feedback

### FullCalendar Integration
- Calendar fetches events via Server Components on initial load
- Booking actions (book/cancel) use Server Actions
- Class management (add/edit/delete) uses Server Actions with overlap validation
- Calendar events map from `class` table: title, start, end, color (by type), extendedProps (instructor, location, slots)

## Deployment (Heroku)

### Configuration
- Buildpack: `heroku/nodejs`
- `Procfile`: `web: npm start`
- Next.js builds with `next build`, runs with `next start`

### Environment Variables
- `DATABASE_URL` — Neon PostgreSQL connection string (pooled)
- `BETTER_AUTH_SECRET` — Auth secret key
- `BETTER_AUTH_URL` — App URL (e.g., `https://scms-app.herokuapp.com`)
- `NODE_ENV=production`

### Neon Database
- Serverless PostgreSQL — auto-scales, connection pooling built in
- Use `@neondatabase/serverless` driver with Drizzle
- Schema managed via `drizzle-kit push` (schema push to Neon)

## Project Structure

```
countryside-community-swimming-club/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── (public)/
│   ├── (auth)/
│   ├── (dashboard)/
│   └── api/
├── components/
│   ├── ui/                  # shadcn/ui components
│   ├── sidebar.tsx
│   ├── topbar.tsx
│   ├── calendar.tsx         # FullCalendar wrapper
│   └── ...
├── lib/
│   ├── db/
│   │   ├── schema.ts        # Drizzle schema
│   │   ├── index.ts          # Neon connection
│   │   └── queries/          # Reusable query functions
│   ├── auth.ts               # Better Auth server config
│   ├── auth-client.ts        # Better Auth client
│   └── utils.ts
├── public/
│   └── images/
├── drizzle.config.ts
├── middleware.ts
├── next.config.ts
├── tailwind.config.ts
├── package.json
├── Procfile
├── tsconfig.json
└── .env.local
```

## Verification Plan

1. **Database**: Run `drizzle-kit push` to apply schema to Neon, verify tables in Neon console
2. **Auth**: Test login, register, logout, session persistence, role-based redirect
3. **Timetable**: Verify FullCalendar renders classes, test week/day/month views
4. **Booking**: Test book/cancel class as member, verify slot count updates
5. **Attendance**: Test marking attendance as instructor and manager
6. **User Management**: Test CRUD operations for members and instructors as manager
7. **Reports**: Verify financial, attendance, and popularity report data
8. **Deployment**: Deploy to Heroku, verify all features work in production
9. **Responsive**: Test sidebar collapse, FullCalendar mobile view

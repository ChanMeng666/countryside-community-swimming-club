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
export const classStatusEnum = pgEnum("class_status", ["active", "cancelled"]);
export const bookingStatusEnum = pgEnum("booking_status", [
  "booked",
  "cancelled",
]);
export const membershipTypeEnum = pgEnum("membership_type", [
  "Monthly",
  "Annual",
  "None",
]);

// Better Auth tables
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

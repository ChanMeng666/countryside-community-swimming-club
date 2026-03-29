import { requireSession } from "@/lib/auth-utils";
import { db } from "@/lib/db";
import {
  member,
  instructor,
  booking,
  swimmingClass,
  classType,
  payment,
} from "@/lib/db/schema";
import { eq, and, gte, sql, count } from "drizzle-orm";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { LinkButton } from "@/components/link-button";
import {
  Calendar,
  ClipboardList,
  CreditCard,
  Users,
  DollarSign,
  CheckSquare,
} from "lucide-react";

export default async function DashboardPage() {
  const session = await requireSession();
  const role = session.user.role as string;

  return (
    <div>
      <h1 className="text-2xl font-bold mb-2">Dashboard</h1>
      <p className="text-muted-foreground mb-6">
        Welcome back, {session.user.name}. You are logged in as{" "}
        <span className="font-medium capitalize">{role}</span>.
      </p>

      {role === "member" && <MemberDashboard userId={session.user.id} />}
      {role === "instructor" && (
        <InstructorDashboard userId={session.user.id} />
      )}
      {role === "manager" && <ManagerDashboard />}
    </div>
  );
}

async function MemberDashboard({ userId }: { userId: string }) {
  const [m] = await db
    .select({ id: member.id, isSubscription: member.isSubscription })
    .from(member)
    .where(eq(member.userId, userId));

  let upcomingBookings = 0;
  if (m) {
    const [result] = await db
      .select({ count: count() })
      .from(booking)
      .innerJoin(swimmingClass, eq(booking.classId, swimmingClass.id))
      .where(
        and(
          eq(booking.memberId, m.id),
          eq(booking.status, "booked"),
          gte(swimmingClass.startTime, new Date())
        )
      );
    upcomingBookings = result?.count ?? 0;
  }

  return (
    <div className="grid md:grid-cols-3 gap-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">
            Upcoming Bookings
          </CardTitle>
          <ClipboardList className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{upcomingBookings}</div>
          <LinkButton href="/booking" variant="link" size="sm" className="px-0">
            View bookings
          </LinkButton>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Membership</CardTitle>
          <CreditCard className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {m?.isSubscription ? "Active" : "Inactive"}
          </div>
          <LinkButton
            href="/membership"
            variant="link"
            size="sm"
            className="px-0"
          >
            Manage membership
          </LinkButton>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Schedule</CardTitle>
          <Calendar className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">Browse</div>
          <LinkButton
            href="/schedule"
            variant="link"
            size="sm"
            className="px-0"
          >
            View timetable
          </LinkButton>
        </CardContent>
      </Card>
    </div>
  );
}

async function InstructorDashboard({ userId }: { userId: string }) {
  const [inst] = await db
    .select({ id: instructor.id })
    .from(instructor)
    .where(eq(instructor.userId, userId));

  let upcomingClasses = 0;
  if (inst) {
    const [result] = await db
      .select({ count: count() })
      .from(swimmingClass)
      .where(
        and(
          eq(swimmingClass.instructorId, inst.id),
          eq(swimmingClass.status, "active"),
          gte(swimmingClass.startTime, new Date())
        )
      );
    upcomingClasses = result?.count ?? 0;
  }

  return (
    <div className="grid md:grid-cols-2 gap-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">
            Upcoming Classes
          </CardTitle>
          <Calendar className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{upcomingClasses}</div>
          <LinkButton
            href="/schedule"
            variant="link"
            size="sm"
            className="px-0"
          >
            View schedule
          </LinkButton>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Attendance</CardTitle>
          <CheckSquare className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">Manage</div>
          <LinkButton
            href="/attendance"
            variant="link"
            size="sm"
            className="px-0"
          >
            Mark attendance
          </LinkButton>
        </CardContent>
      </Card>
    </div>
  );
}

async function ManagerDashboard() {
  const [[membersResult], [instructorsResult], [classesResult], [revenueResult]] =
    await Promise.all([
      db.select({ count: count() }).from(member),
      db.select({ count: count() }).from(instructor),
      db
        .select({ count: count() })
        .from(swimmingClass)
        .where(
          and(
            eq(swimmingClass.status, "active"),
            gte(swimmingClass.startTime, new Date())
          )
        ),
      db
        .select({
          total: sql<string>`COALESCE(SUM(${payment.total}::numeric), 0)`,
        })
        .from(payment)
        .where(eq(payment.isPaid, true)),
    ]);

  return (
    <div className="grid md:grid-cols-4 gap-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Total Members</CardTitle>
          <Users className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{membersResult?.count ?? 0}</div>
          <LinkButton
            href="/users/members"
            variant="link"
            size="sm"
            className="px-0"
          >
            View all
          </LinkButton>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Instructors</CardTitle>
          <Users className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {instructorsResult?.count ?? 0}
          </div>
          <LinkButton
            href="/users/instructors"
            variant="link"
            size="sm"
            className="px-0"
          >
            View all
          </LinkButton>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">
            Upcoming Classes
          </CardTitle>
          <Calendar className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{classesResult?.count ?? 0}</div>
          <LinkButton
            href="/schedule/manage"
            variant="link"
            size="sm"
            className="px-0"
          >
            Manage
          </LinkButton>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
          <DollarSign className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            ${Number(revenueResult?.total ?? 0).toFixed(2)}
          </div>
          <LinkButton
            href="/reports"
            variant="link"
            size="sm"
            className="px-0"
          >
            View reports
          </LinkButton>
        </CardContent>
      </Card>
    </div>
  );
}

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
import { LinkButton } from "@/components/link-button";
import { formatDate, formatTime } from "@/lib/utils";

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
                <LinkButton href={`/attendance/${c.id}`} size="sm" variant="outline">Mark</LinkButton>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

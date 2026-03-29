import { db } from "@/lib/db";
import { swimmingClass, classType, instructor, location } from "@/lib/db/schema";
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

export async function getClassesForCalendar(startDate: Date, endDate: Date): Promise<CalendarEvent[]> {
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
    .where(and(gte(swimmingClass.startTime, startDate), lte(swimmingClass.startTime, endDate), eq(swimmingClass.status, "active")));

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
  locationId: number, startTime: Date, endTime: Date, instructorId: number, excludeClassId?: number
): Promise<string | null> {
  const excludeId = excludeClassId ?? -1;

  const locationConflict = await db.select().from(swimmingClass)
    .where(and(
      ne(swimmingClass.id, excludeId),
      eq(swimmingClass.locationId, locationId),
      eq(swimmingClass.status, "active"),
      not(or(lte(swimmingClass.endTime, startTime), gte(swimmingClass.startTime, endTime))!)
    )).limit(1);

  if (locationConflict.length > 0) return "Location conflict: another class is scheduled at this location during this time.";

  const instructorConflict = await db.select().from(swimmingClass)
    .where(and(
      ne(swimmingClass.id, excludeId),
      eq(swimmingClass.instructorId, instructorId),
      eq(swimmingClass.status, "active"),
      not(or(lte(swimmingClass.endTime, startTime), gte(swimmingClass.startTime, endTime))!)
    )).limit(1);

  if (instructorConflict.length > 0) return "Instructor conflict: this instructor is already teaching another class during this time.";

  return null;
}

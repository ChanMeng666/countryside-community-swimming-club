import { db } from "@/lib/db";
import { booking, swimmingClass, classType, instructor, location, member } from "@/lib/db/schema";
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
    .where(and(eq(booking.memberId, memberId), eq(booking.status, "booked"), gte(swimmingClass.startTime, new Date())))
    .orderBy(swimmingClass.startTime);
}

export async function getMemberIdByUserId(userId: string) {
  const [m] = await db.select({ id: member.id }).from(member).where(eq(member.userId, userId));
  return m?.id;
}

export async function isClassBookedByMember(memberId: number, classId: number): Promise<boolean> {
  const [existing] = await db.select().from(booking)
    .where(and(eq(booking.memberId, memberId), eq(booking.classId, classId), eq(booking.status, "booked")))
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
    .where(and(eq(booking.classId, classId), eq(booking.status, "booked")));
}

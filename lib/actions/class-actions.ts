"use server";

import { db } from "@/lib/db";
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

  revalidatePath("/schedule");
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

  revalidatePath("/schedule");
  return { success: true };
}

export async function deleteClass(classId: number) {
  await requireRole(["manager"]);

  await db
    .update(swimmingClass)
    .set({ status: "cancelled" })
    .where(eq(swimmingClass.id, classId));

  revalidatePath("/schedule");
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

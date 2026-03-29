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
        .where(and(eq(swimmingClass.id, classId), gt(swimmingClass.openSlot, 0), eq(swimmingClass.status, "active")))
        .returning();
      if (!updatedClass) throw new Error("No available slots");

      await tx.insert(booking).values({ memberId, classId, status: "booked", isAttended: false });
    });

    revalidatePath("/schedule");
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
        .where(and(eq(booking.id, bookingId), eq(booking.memberId, memberId), eq(booking.status, "booked")))
        .returning();
      if (!cancelled) throw new Error("Booking not found");

      await tx.update(swimmingClass).set({ openSlot: sql`${swimmingClass.openSlot} + 1` }).where(eq(swimmingClass.id, classId));
    });

    revalidatePath("/schedule");
    revalidatePath("/booking");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Cancellation failed" };
  }
}

export async function markAttendance(memberId: number, classId: number, attended: boolean) {
  await requireSession();
  await dbPool.update(booking).set({ isAttended: attended }).where(and(eq(booking.memberId, memberId), eq(booking.classId, classId)));
  revalidatePath(`/attendance/${classId}`);
  return { success: true };
}

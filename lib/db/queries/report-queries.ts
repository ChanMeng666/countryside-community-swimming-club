import { db } from "@/lib/db";
import { product, payment, classType, swimmingClass, booking } from "@/lib/db/schema";
import { eq, and, gte, lte, sql } from "drizzle-orm";

export async function getFinancialReport(startDate: Date, endDate: Date) {
  return db
    .select({
      productName: product.name,
      totalAmount: sql<number>`COALESCE(SUM(${payment.total}::numeric), 0)`,
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
        gte(swimmingClass.startTime, startDate),
        lte(swimmingClass.startTime, endDate)
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

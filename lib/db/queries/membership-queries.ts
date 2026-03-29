import { db } from "@/lib/db";
import { member, product, payment } from "@/lib/db/schema";
import { eq, desc } from "drizzle-orm";

export async function getMemberProfile(memberId: number) {
  const [profile] = await db
    .select()
    .from(member)
    .where(eq(member.id, memberId));
  return profile;
}

export async function getAllProducts() {
  return db.select().from(product);
}

export async function getMemberPayments(memberId: number) {
  return db
    .select({
      paymentId: payment.id,
      productName: product.name,
      total: payment.total,
      isPaid: payment.isPaid,
      paidAt: payment.paidAt,
    })
    .from(payment)
    .innerJoin(product, eq(payment.productId, product.id))
    .where(eq(payment.memberId, memberId))
    .orderBy(desc(payment.paidAt));
}

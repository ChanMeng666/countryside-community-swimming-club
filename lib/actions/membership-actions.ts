"use server";

import { dbPool } from "@/lib/db/transaction";
import { member, product, payment } from "@/lib/db/schema";
import { eq, sql } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireSession } from "@/lib/auth-utils";
import { getMemberIdByUserId } from "@/lib/db/queries/booking-queries";

export async function subscribe(productId: number) {
  const session = await requireSession();
  const memberId = await getMemberIdByUserId(session.user.id);
  if (!memberId) return { error: "Member profile not found" };

  try {
    await dbPool.transaction(async (tx) => {
      const [prod] = await tx
        .select()
        .from(product)
        .where(eq(product.id, productId));
      if (!prod) throw new Error("Product not found");

      const days = prod.name.toLowerCase().includes("annual") ? 365 : 30;
      const membershipType = days === 365 ? "Annual" : "Monthly";

      await tx.insert(payment).values({
        productId: prod.id,
        memberId,
        total: prod.price,
        isPaid: true,
        paidAt: new Date(),
      });

      await tx
        .update(member)
        .set({
          expiredDate: sql`COALESCE(${member.expiredDate}, CURRENT_DATE) + ${days}`,
          isSubscription: true,
          membershipType,
        })
        .where(eq(member.id, memberId));
    });

    revalidatePath("/membership");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Subscription failed" };
  }
}

export async function cancelSubscription() {
  const session = await requireSession();
  const memberId = await getMemberIdByUserId(session.user.id);
  if (!memberId) return { error: "Member profile not found" };

  try {
    await dbPool
      .update(member)
      .set({
        isSubscription: false,
        membershipType: "None",
      })
      .where(eq(member.id, memberId));

    revalidatePath("/membership");
    return { success: true };
  } catch (e) {
    return {
      error: e instanceof Error ? e.message : "Cancellation failed",
    };
  }
}

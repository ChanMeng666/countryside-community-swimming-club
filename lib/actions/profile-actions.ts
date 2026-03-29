"use server";

import { db } from "@/lib/db";
import { member, instructor, manager } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { requireSession } from "@/lib/auth-utils";

export async function updateProfile(data: Record<string, string>) {
  const session = await requireSession();
  const role = session.user.role as string;
  const userId = session.user.id;

  try {
    if (role === "member") {
      await db
        .update(member)
        .set({
          firstName: data.firstName,
          lastName: data.lastName,
          phone: data.phone,
          email: data.email,
          address: data.address || null,
          dob: data.dob || null,
          healthInfo: data.healthInfo || null,
        })
        .where(eq(member.userId, userId));
    } else if (role === "instructor") {
      await db
        .update(instructor)
        .set({
          title: data.title,
          firstName: data.firstName,
          lastName: data.lastName,
          position: data.position,
          phone: data.phone,
          email: data.email,
          profile: data.profile || null,
        })
        .where(eq(instructor.userId, userId));
    } else if (role === "manager") {
      await db
        .update(manager)
        .set({
          title: data.title,
          firstName: data.firstName,
          lastName: data.lastName,
          position: data.position,
          phone: data.phone,
          email: data.email,
        })
        .where(eq(manager.userId, userId));
    } else {
      return { error: "Unknown role" };
    }

    revalidatePath("/profile");
    return { success: true };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Update failed" };
  }
}
